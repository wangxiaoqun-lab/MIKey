function report = MIKey_registration_qc(stage, phase, reference, moving, reportPath, checkpoint)
% Conservative, scale-invariant safety checks, not a registration certificate.
% References/moving inputs may use a ',volume' suffix. No image is modified.
if nargin < 6, checkpoint = @() []; end
if ~ismember(stage,[6 7]) || ~any(strcmp(phase,{'pre','post'}))
    error('MIKey:RegistrationQC','Registration QC requires stage 6/7 and pre/post.');
end
limits = struct('maxSizeRatio',2,'maxInitialCenterDistance',1, ...
    'maxInitialAxisAngle',75,'minAxisAnisotropy',1.4, ...
    'minInitialCoverage',0.01,'maxNoOverlapCenterDistance',0.5, ...
    'minCoverage',0.20,'minSupportOverlap',0.30,'maxFinalCenterDistance',0.45, ...
    'maxFinalAxisAngle',60,'maxFinalSizeRatio',1.8);
if stage == 7
    limits.minCoverage=0.25;limits.minSupportOverlap=0.35;
    limits.maxFinalCenterDistance=0.35;
end
report=struct('version',1,'stage',stage,'phase',phase, ...
    'reference',reference,'moving',moving,'status','failed', ...
    'limits',limits,'metrics',struct(),'reasons',{{}}, ...
    'interpretation','Heuristic safety screen; a pass does not certify alignment or exclude left/right errors.');
try
    checkpoint();
    [vr,ar]=header(reference,checkpoint);[vm,am]=header(moving,checkpoint);
    report.metrics.referenceHeader=ar;report.metrics.movingHeader=am;
    r=sampleImage(vr(1),checkpoint);m=sampleImage(vm(1),checkpoint);
    report.metrics.referenceSupport=r.summary;report.metrics.movingSupport=m.summary;
    ratio=m.summary.principalSpans./r.summary.principalSpans;
    center=norm(m.summary.center-r.summary.center)/max(r.summary.principalSpans(1),m.summary.principalSpans(1));
    angle=acosd(min(1,abs(dot(r.axis,m.axis))));
    reliable=r.summary.anisotropy>=limits.minAxisAnisotropy && m.summary.anisotropy>=limits.minAxisAnisotropy;
    report.metrics.sizeRatios=ratio;report.metrics.centerDistanceInBrainSpans=center;
    report.metrics.principalAxisAngleDegrees=angle;report.metrics.axisAngleReliable=reliable;
    if strcmp(phase,'pre')
        if all(ratio>limits.maxSizeRatio) || all(ratio<1/limits.maxSizeRatio)
            report.reasons{end+1}=sprintf('Physical foreground size differs by approximately %.2fx. Check inconsistent voxel scaling (for example scale 1 versus 20) and template units.',median(ratio));
        elseif any(ratio>4 | ratio<0.25)
            report.reasons{end+1}='Extreme physical extent mismatch on one or more axes. Check affine voxel sizes, field of view and scale factors.';
        end
        if center>limits.maxInitialCenterDistance
            report.reasons{end+1}=sprintf('Image centers are %.2f brain spans apart. Check image origins/translations in SPM Display before registration.',center);
        end
        checkpoint();
        mr=sampleAt(vm(1),r.world);rm=sampleAt(vr(1),m.world);
        coverageR=nnz(r.mask & isfinite(mr) & abs(mr)>m.threshold)/nnz(r.mask);
        coverageM=nnz(m.mask & isfinite(rm) & abs(rm)>r.threshold)/nnz(m.mask);
        report.metrics.initialReferenceCoverage=coverageR;
        report.metrics.initialMovingCoverage=coverageM;
        if max(coverageR,coverageM)<limits.minInitialCoverage && center>limits.maxNoOverlapCenterDistance
            report.reasons{end+1}=sprintf('Initial foregrounds have almost no overlap (reference coverage %.3f, moving coverage %.3f) and their centers are %.2f brain spans apart. Check affine origins/translations and explicitly initialize alignment in SPM Display before registration.',coverageR,coverageM,center);
        end
        if reliable && angle>limits.maxInitialAxisAngle
            report.reasons{end+1}=sprintf('Physical brain long axes differ by %.1f degrees. Check acquisition orientation and affine rotations with SPM Check Reg.',angle);
        end
    else
        checkpoint();
        mr=sampleAt(vm(1),r.world);rm=sampleAt(vr(1),m.world);
        jointR=r.mask & isfinite(mr) & abs(mr)>m.threshold;
        jointM=m.mask & isfinite(rm) & abs(rm)>r.threshold;
        coverageR=nnz(jointR)/nnz(r.mask);coverageM=nnz(jointM)/nnz(m.mask);
        overlap=2*coverageR*coverageM/max(eps,coverageR+coverageM);
        report.metrics.referenceCoverage=coverageR;report.metrics.movingCoverage=coverageM;
        report.metrics.supportOverlap=overlap;
        report.metrics.normalizedMutualInformation=nmi(r.values(jointR),mr(jointR));
        if min(coverageR,coverageM)<limits.minCoverage || overlap<limits.minSupportOverlap
            report.reasons{end+1}=sprintf('Registered foreground overlap is too low (reference coverage %.3f, moving coverage %.3f, support overlap %.3f). Check the affine, origin, scale, orientation and brain masks.',coverageR,coverageM,overlap);
        end
        if center>limits.maxFinalCenterDistance
            report.reasons{end+1}=sprintf('Registered foreground centers remain %.2f brain spans apart; the estimated registration is implausible.',center);
        end
        if any(ratio>limits.maxFinalSizeRatio | ratio<1/limits.maxFinalSizeRatio)
            report.reasons{end+1}='Registered brain extents remain incompatible. Check scaling, cropping and the selected template.';
        end
        if reliable && angle>limits.maxFinalAxisAngle
            report.reasons{end+1}=sprintf('Registered physical brain long axes remain %.1f degrees apart.',angle);
        end
        % A plausible first frame must not hide blank/corrupt later BOLD frames.
        for k=unique([1 ceil(numel(vm)/2) numel(vm)])
            checkpoint();sampleImage(vm(k),checkpoint);
        end
    end
    if isempty(report.reasons),report.status='passed';end
catch ME
    if strcmp(ME.identifier,'MIKey:Stopped'),rethrow(ME);end
    report.reasons{end+1}=['QC could not validate the image: ' ME.message];
end
report.created=datestr(now,30);
if strcmp(report.status,'failed') && strcmp(phase,'post')
    % Step 6's private workspace is removed when the stage unwinds. Retain
    % its small anatomical candidate so the reported failure can be reviewed.
    report.reviewImage=regexprep(moving,',\d+$','');
    [~,candidateName]=fileparts(report.reviewImage);
    if stage==6 && strncmp(candidateName,'coreg',5) && exist(report.reviewImage,'file')
        try
            folder=fullfile(fileparts(reportPath),'failed_candidates');
            if ~exist(folder,'dir'),mkdir(folder);end
            [~,reportName]=fileparts(reportPath);
            retained=fullfile(folder,[reportName '_T2w.nii']);
            copyfile(report.reviewImage,retained);
            sidecar=[report.reviewImage(1:end-4) '.mat'];
            if exist(sidecar,'file'),copyfile(sidecar,[retained(1:end-4) '.mat']);end
            report.reviewImage=retained;
        catch ME
            report.retentionError=ME.message;
        end
    end
end
try
    folder=fileparts(reportPath);if ~exist(folder,'dir'),mkdir(folder);end
    temporary=[tempname(folder) '.json'];
    cleanup=onCleanup(@()removeTemporary(temporary)); %#ok<NASGU>
    fid=fopen(temporary,'w','n','UTF-8');
    if fid<0,error('MIKey:RegistrationQC','Cannot write QC report.');end
    closeFile=onCleanup(@()fclose(fid));
    fprintf(fid,'%s',jsonencode(report));clear closeFile;
    movefile(temporary,reportPath,'f');
catch ME
    error('MIKey:RegistrationQC','Step %d %s QC report could not be saved: %s. Processing stopped.',stage,phase,ME.message);
end
if ~strcmp(report.status,'passed')
    review='';if isfield(report,'reviewImage'),review=[' Review image: ' report.reviewImage '.'];end
    error('MIKey:RegistrationQC','Step %d %s registration check FAILED. %s Reference: %s. Moving: %s. QC report: %s. Processing stopped; correct the geometry/mask/template and rerun this step. No automatic header correction was applied.', ...
        stage,phase,[strjoin(report.reasons,' ') review],reference,moving,reportPath);
end
end

function [v,description]=header(path,checkpoint)
v=spm_vol(path);
if isempty(v),error('MIKey:RegistrationQC','No image volumes: %s',path);end
for i=1:numel(v)
    if mod(i-1,64)==0,checkpoint();end
    a=v(i).mat;
    if ~isequal(size(a),[4 4]) || any(~isfinite(a(:))) || norm(a(4,:)-[0 0 0 1])>1e-6
        error('MIKey:RegistrationQC','Invalid/nonfinite homogeneous affine: %s',path);
    end
    if rcond(a(1:3,1:3))<1e-6 || any(v(i).dim<2)
        error('MIKey:RegistrationQC','Singular/near-singular affine or invalid 3D dimensions: %s',path);
    end
    % Determinant sign alone is not an error: valid storage flips are allowed.
    if i>1
        difference=v(1).mat\a-eye(4);
        if any(v(i).dim~=v(1).dim) || any(abs(difference(:))>1e-3)
            error('MIKey:RegistrationQC','Volumes do not share a resliced spatial grid: %s',path);
        end
    end
end
description=struct('dimensions',v(1).dim,'affine',v(1).mat, ...
    'voxelSizes',sqrt(sum(v(1).mat(1:3,1:3).^2,1)),'volumes',numel(v));
end

function s=sampleImage(v,checkpoint)
axes=cell(1,3);
for j=1:3,axes{j}=linspace(1,v.dim(j),min(48,v.dim(j)));end
[x,y,z]=ndgrid(axes{:});vox=[x(:)';y(:)';z(:)';ones(1,numel(x))];
s.world=v.mat*vox;checkpoint();
s.values=spm_sample_vol(v,x(:),y(:),z(:),1);
finite=isfinite(s.values);values=abs(s.values(finite));
if numel(values)<32,error('MIKey:RegistrationQC','Too few finite image samples.');end
low=percentile(values,0.02);high=percentile(values,0.98);
if high-low<=max(eps,high*1e-6)
    error('MIKey:RegistrationQC','Blank/constant image or insufficient intensity contrast.');
end
s.threshold=low+0.08*(high-low);
s.mask=finite & abs(s.values)>s.threshold;
if nnz(s.mask)<32,error('MIKey:RegistrationQC','Insufficient non-background foreground.');end
points=s.world(1:3,s.mask);center=mean(points,2);centered=bsxfun(@minus,points,center);
[directions,variance]=eig(centered*centered'/size(points,2));
[eigenvalues,order]=sort(diag(variance),'descend');directions=directions(:,order);
projected=directions'*centered;spans=zeros(1,3);
for j=1:3,spans(j)=percentile(projected(j,:),0.98)-percentile(projected(j,:),0.02);end
if any(spans<=0),error('MIKey:RegistrationQC','Degenerate foreground spatial support.');end
s.axis=directions(:,1);
s.summary=struct('center',center','principalSpans',spans,'foregroundSamples',nnz(s.mask), ...
    'anisotropy',eigenvalues(1)/max(eps,eigenvalues(2)),'threshold',s.threshold);
end

function values=sampleAt(v,world)
voxel=v.mat\world;
values=spm_sample_vol(v,voxel(1,:)',voxel(2,:)',voxel(3,:)',1);
end

function value=percentile(values,fraction)
values=sort(values(:));position=1+(numel(values)-1)*fraction;
lo=floor(position);hi=ceil(position);value=values(lo)+(values(hi)-values(lo))*(position-lo);
end

function value=nmi(a,b)
% Diagnostic multimodal NMI; no universal NMI cutoff is assumed.
value=NaN;if numel(a)<64,return;end
a=bin(a);b=bin(b);joint=accumarray([a b],1,[32 32]);joint=joint/sum(joint(:));
pa=sum(joint,2);pb=sum(joint,1);
entropy=@(p)-sum(p(p>0).*log(p(p>0)));
h=entropy(joint(:));if h>0,value=(entropy(pa)+entropy(pb))/h;end
end

function a=bin(a)
lo=min(a);hi=max(a);a=1+min(31,floor(32*(a-lo)/max(eps,hi-lo)));
end

function removeTemporary(path)
if exist(path,'file'),delete(path);end
end

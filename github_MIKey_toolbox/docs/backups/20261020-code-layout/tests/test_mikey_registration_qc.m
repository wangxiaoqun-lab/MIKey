function test_mikey_registration_qc(spmPath)
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);
if usejava('jvm')
    MIKey_setup(spmPath);
else
    addpath(spmPath);addpath(fullfile(root,'scripts'));spm('defaults','fmri');
end
work=tempname;mkdir(work);
[x,y,z]=ndgrid(1:32,1:40,1:24);
mask=((x-16.5)/10).^2+((y-20.5)/17).^2+((z-12.5)/7).^2<1;
image=mask.*(100+20*sin(x/3)+15*cos(y/4)+2*z);
a=eye(4);a(1:3,4)=-[16.5;20.5;12.5];
reference=fullfile(work,'ref.nii');moving=fullfile(work,'moving.nii');
write(reference,image,a);write(moving,sqrt(image)*10,a);
for stage=[6 7]
    for phase={'pre','post'}
        report=check(stage,phase{1},moving);
        assert(strcmp(report.status,'passed'));
    end
end
% Different voxel resolutions with the same physical object must pass.
finer=a;finer(1:3,1:3)=diag([0.5 0.5 0.5]);
[xf,yf,zf]=ndgrid((1:64)*0.5,(1:80)*0.5,(1:48)*0.5);
fineMask=((xf-16.5)/10).^2+((yf-20.5)/17).^2+((zf-12.5)/7).^2<1;
write(moving,fineMask.*(100+20*sin(xf/3)+15*cos(yf/4)+2*zf),finer);
check(6,'pre',moving);check(7,'post',moving);
% Storage flips and axis permutations do not imply world-space misalignment.
flipMatrix=eye(4);flipMatrix(1,1)=-1;flipMatrix(1,4)=33;
write(moving,flip(image,1),a*flipMatrix);check(6,'pre',moving);check(7,'post',moving);
permuteMatrix=eye(4);permuteMatrix(1:3,1:3)=[0 1 0;1 0 0;0 0 1];
write(moving,permute(image,[2 1 3]),a*permuteMatrix);check(6,'pre',moving);check(7,'post',moving);
for stage=[6 7]
    % A sub-span center offset can still leave the short axis disjoint.
    offset=a;offset(3,4)=offset(3,4)+20;write(moving,image,offset);
    expectFailure(stage,'pre',moving,'overlap');
    % A similar offset along the long axis retains overlap and remains usable.
    offset=a;offset(2,4)=offset(2,4)+20;write(moving,image,offset);
    check(stage,'pre',moving);
    scaled=a;scaled(1:3,:)=20*scaled(1:3,:);write(moving,image,scaled);
    expectFailure(stage,'pre',moving,'scale');
    offset=a;offset(1,4)=offset(1,4)+300;write(moving,image,offset);
    expectFailure(stage,'pre',moving,'centers');
    rotation=eye(4);rotation(1:3,1:3)=[0 -1 0;1 0 0;0 0 1];
    write(moving,image,rotation*a);expectFailure(stage,'pre',moving,'axes');
    offset=a;offset(1,4)=offset(1,4)+40;write(moving,image,offset);
    expectFailure(stage,'post',moving,'overlap');
    write(moving,zeros(size(image)),a);expectFailure(stage,'post',moving,'constant');
end
% Incomplete and late blank functional outputs must not be accepted.
raw=fullfile(work,'bold.nii');write(raw,repmat(image,[1 1 1 3]),a);
write(moving,image,a);
try
    MIKey_registration_pair(7,raw,moving,reference);error('MIKey:Test','Expected incomplete output failure.');
catch ME,assert(strcmp(ME.identifier,'MIKey:RegistrationQC'));end
write(moving,cat(4,image,image,zeros(size(image))),a);
expectFailure(7,'post',moving,'constant');
% Near-singular geometry is unsafe even if its voxel data are present.
bad=a;bad(3,3)=1e-8;write(moving,image,bad);
expectFailure(6,'pre',moving,'singular');
% A large origin must not inflate the allowed BOLD/T2w grid mismatch.
largeOrigin=a;largeOrigin(1:3,4)=1e6;
write(reference,image,largeOrigin);write(raw,image,largeOrigin);
shifted=largeOrigin;shifted(1,4)=shifted(1,4)+1;
write(moving,image,shifted);
try
    MIKey_registration_pair(7,raw,moving,reference);error('MIKey:Test','Expected grid mismatch failure.');
catch ME,assert(strcmp(ME.identifier,'MIKey:RegistrationQC'));end
disp('MIKEY_REGISTRATION_QC_PASS');

    function report=check(stage,phase,path)
        report=MIKey_registration_qc(stage,phase,reference,path,fullfile(work,'qc.json'));
    end
    function expectFailure(stage,phase,path,reason)
        try
            check(stage,phase,path);error('MIKey:Test','Expected registration QC failure.');
        catch ME,assert(strcmp(ME.identifier,'MIKey:RegistrationQC'),ME.message);end
        saved=jsondecode(fileread(fullfile(work,'qc.json')));
        assert(strcmp(saved.status,'failed'));
        assert(~isempty(strfind(lower(strjoin(saved.reasons,' ')),reason))); %#ok<STREMP>
    end
end

function write(path,data,matrix)
if exist(path,'file'),delete(path);end
sidecar=[path(1:end-4) '.mat'];if exist(sidecar,'file'),delete(sidecar);end
for i=1:size(data,4)
    v=struct('fname',path,'dim',[size(data,1) size(data,2) size(data,3)], ...
        'dt',[16 0],'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','Registration QC synthetic test');
    spm_write_vol(v,data(:,:,:,i));
end
end

function MIKey_registration_pair(stage, original, output, anatomy, reportPath, checkpoint)
% Registered BOLD must be complete and share its anatomical output grid.
if nargin<5,reportPath='';end
if nargin<6,checkpoint=@()[];end
report=struct('stage',stage,'phase','grid','original',original,'output',output, ...
    'anatomy',anatomy,'status','passed','reason','','gridToleranceInVoxels',1e-3);
try
    checkpoint();
    before=spm_vol(original);after=spm_vol(output);target=spm_vol(anatomy);
    report.originalVolumes=numel(before);report.outputVolumes=numel(after);
    if any(~isfinite(target(1).mat(:))) || rcond(target(1).mat(1:3,1:3))<1e-6
        error('MIKey:RegistrationQC','Anatomical output has an invalid affine.');
    end
    if numel(before)~=numel(after)
        error('MIKey:RegistrationQC','BOLD output contains %d/%d volumes.',numel(after),numel(before));
    end
    for i=1:numel(after)
        if mod(i-1,64)==0,checkpoint();end
        difference=target(1).mat\after(i).mat-eye(4);
        if any(after(i).dim~=target(1).dim) || ...
                any(~isfinite(after(i).mat(:))) || ...
                any(~isfinite(difference(:))) || any(abs(difference(:))>report.gridToleranceInVoxels)
            error('MIKey:RegistrationQC','BOLD and T2w do not share the registered grid (volume %d).',i);
        end
    end
catch ME
    if strcmp(ME.identifier,'MIKey:Stopped'),rethrow(ME);end
    report.status='failed';report.reason=ME.message;
end
if ~isempty(reportPath)
    folder=fileparts(reportPath);if ~exist(folder,'dir'),mkdir(folder);end
    temporary=[tempname(folder) '.json'];
    cleanup=onCleanup(@()removeTemporary(temporary)); %#ok<NASGU>
    fid=fopen(temporary,'w','n','UTF-8');
    if fid<0,error('MIKey:RegistrationQC','Cannot save Step %d grid QC report: %s',stage,reportPath);end
    closeFile=onCleanup(@()fclose(fid));
    fprintf(fid,'%s',jsonencode(report));clear closeFile;
    movefile(temporary,reportPath,'f');
end
if strcmp(report.status,'failed')
    error('MIKey:RegistrationQC','Step %d output consistency check FAILED: %s. BOLD: %s. T2w: %s. QC report: %s. Processing stopped.',stage,report.reason,output,anatomy,reportPath);
end
end

function removeTemporary(path)
if exist(path,'file'),delete(path);end
end

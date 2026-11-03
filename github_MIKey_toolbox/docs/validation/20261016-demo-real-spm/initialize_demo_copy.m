function initialize_demo_copy
% Explicit TEST-ONLY translation; never used by MIKey production processing.
folder=fileparts(mfilename('fullpath'));workspace=jsondecode(fileread(fullfile(folder,'workspace.json')));
assert(strcmp(workspace.workspace,'C:\MIKeyRealSPM\20261016-958dc7c6'));
oldPath=path;cleanup=onCleanup(@()path(oldPath)); %#ok<NASGU>
addpath('D:/Program Files/MATLAB/mytoolbox/spm12');
base=fullfile(workspace.bidsPath,'derivatives','MIKey','sub-001');
bold=fullfile(base,'func','sub-001_task-rest_run-01_desc-mean_boldref.nii');
t2=fullfile(base,'anat','sub-001_acq-t2fsetra_run-01_desc-masked_T2w.nii');
template=fullfile(workspace.workspace,'templates','Template_Mouse_v38.nii');
recordPath=fullfile(workspace.workspace,'initialization.json');
assert(~exist(recordPath,'file'),'Test copy already initialized.');
% Archive baseline reports before subsequent checks overwrite their paths.
copyfile(fullfile(base,'func','registration_qc'),fullfile(workspace.workspace,'baseline-qc'));
copyfile(t2,fullfile(workspace.workspace,'before-initialization_T2w.nii'));
copyfile(bold,fullfile(workspace.workspace,'before-initialization_boldref.nii'));
q1=fullfile(folder,'initialization-bold-t2.json');q2=fullfile(folder,'initialization-template-t2.json');
try,MIKey_registration_qc(6,'pre',bold,t2,q1);catch ME,assert(strcmp(ME.identifier,'MIKey:RegistrationQC'));end
try,MIKey_registration_qc(7,'pre',template,t2,q2);catch ME,assert(strcmp(ME.identifier,'MIKey:RegistrationQC'));end
r1=jsondecode(fileread(q1));r2=jsondecode(fileread(q2));
target=r2.metrics.referenceSupport.center(:);
tb=eye(4);tb(1:3,4)=target-r1.metrics.referenceSupport.center(:);
ta=eye(4);ta(1:3,4)=target-r1.metrics.movingSupport.center(:);
entries=struct('path',{},'before',{},'after',{},'frames',{},'sampleUnchanged',{});
for k=1:4
    entries(end+1)=translate(fullfile(base,'func',sprintf('sub-001_task-rest_run-%02d_desc-realign_bold.nii',k)),tb); %#ok<AGROW>
    entries(end+1)=translate(fullfile(base,'func',sprintf('sub-001_task-rest_run-%02d_desc-mean_boldref.nii',k)),tb); %#ok<AGROW>
end
entries(end+1)=translate(fullfile(base,'func','sub-001_desc-boldbrain_mask.nii'),tb);
entries(end+1)=translate(t2,ta);
entries(end+1)=translate(fullfile(base,'anat','sub-001_desc-anatbrain_mask.nii'),ta);
record=struct('purpose','Explicit center initialization of independent test copy only; not an automatic MIKey correction.', ...
    'templateCenter',target,'boldTranslation',tb,'anatomicalTranslation',ta,'files',entries,'created',datestr(now,30));
fid=fopen(recordPath,'w','n','UTF-8');closeFile=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(record));
disp('MIKEY_TEST_COPY_INITIALIZED');
end

function entry=translate(filename,t)
prefix='C:\MIKeyRealSPM\20261016-958dc7c6\';
assert(strncmp(filename,prefix,numel(prefix)),'Only the independent copy may be initialized.');
v=spm_vol(filename);before=v(1).mat;
[x,y,z]=ndgrid(linspace(1,v(1).dim(1),8),linspace(1,v(1).dim(2),8),linspace(1,v(1).dim(3),8));
sampleBefore=spm_sample_vol(v(1),x(:),y(:),z(:),0);
n=nifti(filename);n.mat=t*n.mat;n.mat0=t*n.mat0;
extra=n.extras;
if isstruct(extra) && isfield(extra,'mat')
    for j=1:size(extra.mat,3)
        if any(any(extra.mat(:,:,j))),extra.mat(:,:,j)=t*extra.mat(:,:,j);end
    end
    n.extras=extra;
end
create(n); % Header/extras only: no empty-image allocation or voxel rewrite.
after=spm_vol(filename);assert(numel(after)==numel(v));
for j=1:numel(after)
    delta=(t*v(j).mat)\after(j).mat-eye(4);assert(max(abs(delta(:)))<1e-3);
end
sampleAfter=spm_sample_vol(after(1),x(:),y(:),z(:),0);assert(isequaln(sampleBefore,sampleAfter));
entry=struct('path',filename,'before',before,'after',after(1).mat,'frames',numel(after),'sampleUnchanged',true);
end

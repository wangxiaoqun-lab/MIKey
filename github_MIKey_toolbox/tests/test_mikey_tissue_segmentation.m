function test_mikey_tissue_segmentation(spmPath)
% SERVER ONLY. Real SPM NIfTI I/O, mocked estimates; no research-data processing.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));MIKey_paths();
if nargin>0 && ~isempty(spmPath),addpath(spmPath);end
assert(~isempty(which('spm_vol')),'Add real SPM12 before this server test.');
mock=fullfile(work,'mock');mkdir(mock);
copyfile(fullfile(root,'tests','fixtures','segmentation_stub','spm_jobman.m.fixture'),fullfile(mock,'spm_jobman.m'));
addpath(mock,'-begin');clear spm_jobman;
assert(strcmp(which('spm_jobman'),fullfile(mock,'spm_jobman.m')));
global MIKEY_SEGMENTATION_JOBS MIKEY_SEGMENTATION_OMIT
MIKEY_SEGMENTATION_JOBS={};MIKEY_SEGMENTATION_OMIT='';
templates=fullfile(work,'templates');mkdir(templates);mkdir(fullfile(templates,'AMCP_temp'));
templateAffine=diag([2 2 8 1]);templateAffine(1:3,4)=[-10;20;30];
writeImage(fullfile(templates,'Template_Mouse_v38.nii'),2,1,templateAffine);
for volume=1:5,writeImage(fullfile(templates,'AMCP_temp','AMCP_TPM.nii'),0.2,volume,templateAffine);end
anat=fullfile(work,'sub-001','anat');mkdir(anat);writeImage(fullfile(anat,'sub-001_T2w.nii'),2,1);
deriv=fullfile(work,'derivatives','MIKey','sub-001','anat');mkdir(deriv);
scaled=MIKey_bids_path(deriv,'sub-001_T2w_desc-scaled.nii');writeImage(scaled,2,1);
masked=MIKey_bids_path(deriv,'sub-001_T2w_desc-masked.nii');writeImage(masked,1,1);
% A former oldseg GM result must not cause the new workflow to skip.
oldGM=MIKey_bids_path(deriv,'sub-001_T2w_desc-gmvol.nii');writeImage(oldGM,9,1);
cfg=MIKey_defaults();cfg.bidsPath=work;cfg.subjectFilter='sub-001';cfg.steps=17;
cfg.templatePath=templates;cfg.codePath=mock;cfg.segSmoothFWHM=[2 3 4];
MIKey_check_stage(cfg,17);pre=MIKey_preflight(cfg);
assert(any(strcmp(pre.requiredImages,fullfile(templates,'AMCP_temp','AMCP_TPM.nii'))));
assert(~any(contains(pre.requiredImages,'AMCP_GM.nii')));
state=MIKeyBatchState(cfg,-1);MIKey('batch',state,17);
assert(numel(MIKEY_SEGMENTATION_JOBS)==3);
first=MIKEY_SEGMENTATION_JOBS{1}.spm.tools.oldnorm.estwrite;
assert(contains(first.subj.source{1},'desc-masked'));
assert(isequal(first.roptions.wrap,[0 0 0]) && first.roptions.interp==2);
assert(isequal(first.roptions.bb,[-8 22 38;-2 30 54])); % Actual translated template corners.
assert(isequal(MIKEY_SEGMENTATION_JOBS{3}.spm.spatial.smooth.fwhm,[2 3 4]));
out=MIKey_tissue_paths(deriv,'sub-001_T2w');assert(all(cellfun(@(p)exist(p,'file')==2,out.required)));
assert(exist(out.complete,'file')==2);
normalMetadata=jsondecode(fileread([out.normalized(1:end-4) '.json']));assert(~normalMetadata.SkullStripped);
smoothMetadata=jsondecode(fileread([out.smoothed{1}(1:end-4) '.json']));assert(isequal(smoothMetadata.FWHM(:)',[2 3 4]));
oldData=spm_read_vols(spm_vol(oldGM));assert(all(oldData(:)==9));
for i=1:5,assert(endsWith(out.native{i},'_probseg.nii'));end
MIKey('batch',state,17);assert(numel(MIKEY_SEGMENTATION_JOBS)==3,'Identical complete outputs should be reused.');
cfg.segSmoothFWHM=[4 4 4];state=MIKeyBatchState(cfg,-1);MIKey('batch',state,17);
assert(numel(MIKEY_SEGMENTATION_JOBS)==6,'Changed FWHM must invalidate the cache.');
assert(isequal(MIKEY_SEGMENTATION_JOBS{6}.spm.spatial.smooth.fwhm,[4 4 4]));
% Missing AIR output must fail and cannot publish a completion record.
scaled2=strrep(scaled,'sub-001','sub-002');masked2=strrep(masked,'sub-001','sub-002');
mkdir(fileparts(scaled2));copyfile(scaled,scaled2);copyfile(masked,masked2);
MIKEY_SEGMENTATION_OMIT='c5';out2=MIKey_tissue_paths(fileparts(scaled2),'sub-002_T2w');
expect(@()MIKey_segment_t2(masked2,scaled2,fileparts(scaled2),'sub-002_T2w',templates,[2 3 4]),'MIKey:SegmentationOutput');
assert(exist(out2.complete,'file')==0);
% Independent selected-stage validation, scalar expansion, inactive preservation.
a=MIKey_config(struct('steps',17,'segSmoothFWHM',2));assert(isequal(a.segSmoothFWHM,[2 2 2]));
a=MIKey_config(struct('steps',1,'segSmoothFWHM',struct('unused',1)));assert(isstruct(a.segSmoothFWHM));
expect(@()MIKey_config(struct('steps',17,'segSmoothFWHM',[-1 2 3])),'MIKey:Parameter');
expect(@()MIKey_config(struct('steps',17,'segSmoothFWHM',[1 2])),'MIKey:Parameter');
exported=MIKey_export_config(fullfile(work,'segmentation_config.m'),cfg);
loaded=MIKey_config(exported);assert(isequal(loaded.segSmoothFWHM,[4 4 4]));
disp('MIKEY_TISSUE_SEGMENTATION_ROUTING_PASS');
end
function writeImage(filename,value,volume,affine)
if nargin<4,affine=diag([2 2 8 1]);end
head=struct('fname',filename,'dim',[4 5 3],'dt',[16 0], ...
    'mat',affine,'pinfo',[1;0;0],'n',[volume 1],'descrip','MIKey Step 17 routing fixture');
spm_write_vol(head,ones(4,5,3)*value);
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end
function restore(oldPath,oldDirectory,work)
cd(oldDirectory);path(oldPath);clear spm_jobman;
clear global MIKEY_SEGMENTATION_JOBS MIKEY_SEGMENTATION_OMIT
target=char(java.io.File(work).getCanonicalPath());parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

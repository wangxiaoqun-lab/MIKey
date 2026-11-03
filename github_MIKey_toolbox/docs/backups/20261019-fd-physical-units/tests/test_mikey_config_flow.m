function test_mikey_config_flow
% Validation/dispatch/metadata flow using an empty temporary BIDS dataset.
% Placeholder files below test provenance writing only, never SPM image I/O.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work));
addpath(root);addpath(fullfile(root,'scripts'));
raw=fullfile(work,'sub-test','func');mkdir(raw);
cfg=MIKey_defaults();cfg.steps=1;cfg.bidsPath=work;cfg.subjectFilter='sub-test';
cfg.templatePath=struct('unused',1);cfg.useDefaultTemplate=struct('unused',1);
cfg.customPCCounts={false,'unused'};cfg.useDefaultPCStrategy=struct('unused',1);
cfg.advRegressionPCOnly=struct('unused',1);cfg.fcLabel=false;
cfg.parcNetwork='296rois';cfg.percentTop=NaN;cfg.maxIter=[];
cfg=MIKey_config(cfg);
% MAT/JSON import follows the same scope as direct structs.
config=cfg;save(fullfile(work,'config.mat'),'config');
loaded=MIKey_config(fullfile(work,'config.mat'));assert(isequaln(loaded.fcLabel,false));
fid=fopen(fullfile(work,'config.json'),'w');assert(fid>=0);
fprintf(fid,'%s',jsonencode(cfg));fclose(fid);
loaded=MIKey_config(fullfile(work,'config.json'));assert(strcmp(loaded.parcNetwork,'296rois'));
before=pwd;
state=MIKeyBatchState(cfg,-1);MIKey_check_stage(cfg,1);MIKey('batch',state,1);
assert(strcmp(pwd,before)); % Step 1 needs no template and has no images to read.
assert(exist(fullfile(work,'derivatives','MIKey','dataset_description.json'),'file')==2);
assert(isequaln(state.Config.customPCCounts,{false,'unused'}));
% Metadata must not interpret inactive template settings for an old normalized
% result. The zero-byte .nii files are never read by SPM or header validation.
base='sub-test_task-rest_bold';touch(fullfile(raw,[base '.nii']));
derived=fullfile(work,'derivatives','MIKey','sub-test','func');mkdir(derived);
image=fullfile(derived,'sub-test_task-rest_space-template_desc-normalized_bold.nii');touch(image);
MIKey_write_derivative_metadata(cfg);metadata=jsondecode(fileread([image(1:end-4) '.json']));
assert(~isfield(metadata,'SpatialReference') && metadata.MIKeyVoxelScaleFactor==20);
% A later phase uses no scale parameter; do not stamp an arbitrary value from
% an unused field or substitute a default into provenance.
cfg.steps=2:10;cfg.templatePath=work;cfg.useDefaultTemplate=true;
cfg.useDefaultPCStrategy=true;cfg.voxelScaleFactor=struct('unused',1);
cfg=MIKey_config(cfg);delete([image(1:end-4) '.json']);
MIKey_write_derivative_metadata(cfg);metadata=jsondecode(fileread([image(1:end-4) '.json']));
assert(~isfield(metadata,'MIKeyVoxelScaleFactor'));
report=MIKey_preflight(cfg);assert(isstruct(report) && ~report.ok);
assert(~any(contains(report.issues,'296')) && ~any(contains(report.issues,'group network')));
% A new selection reuses the requested value, not an earlier placeholder.
cfg=MIKey_defaults();cfg.steps=1;cfg.sliceTimingNSlices=7;
state=MIKeyBatchState(cfg,-1);assert(state.UserData.sliceTimingNSlices.Value==30);
cfg=state.Config;cfg.steps=4;controls=MIKey_batch_controls(cfg);
assert(controls.sliceTimingNSlices.Value==7);
disp('MIKEY_CONFIG_FLOW_PASS');
end

function touch(name)
fid=fopen(name,'w');assert(fid>=0);fclose(fid);
end

function restore(oldPath,oldDirectory,work)
cd(oldDirectory);path(oldPath);
% work was created by this test under tempdir, never a caller-supplied path.
target=char(java.io.File(work).getCanonicalPath());parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));
if exist(target,'dir'),rmdir(target,'s');end
end

function test_mikey_bids_names()
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);
examples={
 'sub-01_task-rest_run-01_bold_desc-scaled.nii','sub-01_task-rest_run-01_desc-scaled_bold.nii';
 'sub-01_task-rest_bold_space-template_desc-smoothed.nii','sub-01_task-rest_space-template_desc-smoothed_bold.nii';
 'sub-01_T2w_desc-masked.nii','sub-01_desc-masked_T2w.nii';
 'sub-01_magnitude1_desc-scaled.nii','sub-01_desc-scaled_magnitude1.nii';
 'sub-01_task-rest_bold_desc-mean.nii','sub-01_task-rest_desc-mean_boldref.nii';
 'sub-01_task-rest_bold_desc-T2coreg.nii','sub-01_task-rest_space-bold_desc-T2coreg_T2w.nii';
 'sub-01_task-rest_bold_space-template_desc-individualParcellation.nii','sub-01_task-rest_space-template_desc-individualParcellation_dseg.nii';
 'sub-01_task-rest_bold_space-template_desc-tSNR_Regressedpc.nii','sub-01_task-rest_space-template_desc-tSNRRegressedpc_statmap.nii';
 'sub-01_desc-preproc_bold_desc-scaled.nii.gz','sub-01_desc-preprocscaled_bold.nii.gz'};
for i=1:size(examples,1)
    assert(strcmp(MIKey_bids_name(examples{i,1}),examples{i,2}));
    assert(strcmp(MIKey_bids_name(examples{i,2}),examples{i,2}));
end
work=tempname;mkdir(work);func=fullfile(work,'sub-01','func');mkdir(func);
df=fullfile(work,'derivatives','MIKey','sub-01','func');mkdir(df);
base='sub-01_task-rest_run-01_bold';touch(fullfile(func,[base '.nii']));
fid=fopen(fullfile(func,[base '.json']),'w');fprintf(fid,'{"RepetitionTime":2,"TaskName":"rest"}');fclose(fid);
legacy=[base '_desc-scaled.nii'];old=fullfile(df,legacy);touch(old);
assert(strcmp(MIKey_bids_path(df,legacy,'input'),old));
new=MIKey_bids_path(df,legacy);touch(new);
assert(strcmp(MIKey_bids_path(df,legacy,'input'),new) && exist(old,'file')==2);
assert(strcmp(MIKey_prefixed_file('norm',old),fullfile(df,['norm' legacy])));
motionName=MIKey_bids_name([base '_desc-slicetimed.nii']);
touch(fullfile(df,['rp_' motionName(1:end-4) '.txt']));
touch(fullfile(df,['rp_' base '.txt']));
motion=MIKey_motion_files(df,base);assert(numel(motion)==1);
assert(strcmp(motion.name,['rp_' motionName(1:end-4) '.txt']));
masked=MIKey_bids_path(df,[base '_desc-masked.nii']);touch(masked);
cfg=MIKey_defaults();cfg.bidsPath=work;MIKey_write_derivative_metadata(cfg);
description=jsondecode(fileread(fullfile(work,'derivatives','MIKey','dataset_description.json')));
assert(strcmp(description.DatasetType,'derivative') && isfield(description,'GeneratedBy'));
scaledJSON=jsondecode(fileread([new(1:end-4) '.json']));
maskedJSON=jsondecode(fileread([masked(1:end-4) '.json']));
assert(~scaledJSON.SkullStripped && maskedJSON.SkullStripped && scaledJSON.RepetitionTime==2);
assert(isfield(scaledJSON,'Sources') && isfield(maskedJSON,'MIKeyRawSources'));
assert(~exist([old(1:end-4) '.json'],'file'),'Legacy file was treated as a new canonical output.');
nested=fullfile(df,'parcellation');mkdir(nested);
label=MIKey_bids_path(nested,[base '_space-template_desc-individualParcellation.nii']);touch(label);
preproc=[base(1:end-5) '_desc-preproc_bold'];touch(fullfile(func,[preproc '.nii']));
preprocOutput=MIKey_bids_path(df,[preproc '_desc-scaled.nii']);touch(preprocOutput);
MIKey_write_derivative_metadata(cfg);
assert(exist([label(1:end-4) '.json'],'file')==2);
specific=jsondecode(fileread([preprocOutput(1:end-4) '.json']));
assert(numel(specific.Sources)==1 && ~isempty(strfind(specific.Sources{1},'_desc-preproc_bold'))); %#ok<STREMP>
assert(strcmp(MIKey_bids_name('sub-01_space-template_desc-concatenatedParcellation.nii'), ...
    'sub-01_space-template_desc-concatenatedParcellation_dseg.nii'));
disp('MIKEY_BIDS_NAMES_PASS');
end

function touch(path)
fid=fopen(path,'w');assert(fid>=0);fclose(fid);
end

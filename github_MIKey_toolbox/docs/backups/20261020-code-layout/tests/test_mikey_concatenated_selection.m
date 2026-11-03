function test_mikey_concatenated_selection(spmPath, work)
% Selected session/run concatenation must use a safe filename and own namespace.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);
loaded=load(fullfile(work,'config.mat')); cfg=loaded.config;
cfg.spmPath=spmPath; cfg.bidsPath=work;
cfg.templatePath=fullfile(work,'templates');
cfg.groupNetworkPath=fullfile(work,'user_network.nii');
cfg.steps=16; cfg.parcellationMode='concatenated';
report=MIKey_run(cfg); assert(strcmp(report.status,'completed'));
df=fullfile(work,'derivatives','MIKey','sub-01','ses-baseline','func');
out=fullfile(df,'parcellation_concatenated_voxel',MIKey_selection_key(cfg), ...
    'voxel_2_Regressedpc','sub-01_ses-baseline_space-template_desc-concatenatedParcellation.nii');
assert(exist(out,'file')==2);
info=load(fullfile(fileparts(out),'concatenation_info.mat'));
assert(numel(info.concat_info.valid_runs)==1);
disp('MIKEY_CONCATENATED_SELECTION_PASS');
end

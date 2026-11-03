function result = test_mikey_batch(spmPath)
% Real SPM NIfTI smoke test, using synthetic data only. Leaves artifacts in tempdir.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);
MIKey_setup(spmPath);
work = tempname;
mkdir(work);
func = fullfile(work,'sub-01','func'); mkdir(func);
anat = fullfile(work,'sub-01','anat'); mkdir(anat);
templates = fullfile(work,'templates'); mkdir(templates);
mkdir(fullfile(templates,'AMCP_temp'));
cfg = MIKey_defaults();
cfg.spmPath = spmPath;
cfg.bidsPath = work;
cfg.templatePath = templates;
cfg.voxelScaleFactor = 2;
cfg.advRegressionPCCSF = false;
cfg.advRegressionPCGS = false;
cfg.advRegressionPCCSFGS = false;
cfg.smoothFWHM = [1 2 3];
cfg.fcLabel = 'Custom...';
cfg.fcCustomPath = fullfile(templates,'labels.nii');
base = 'sub-01_task-rest_bold';
rng(42);
data = 100 + randn(5,6,4,48);
matrix = diag([0.2 0.2 0.2 1]);
writeNifti(fullfile(func,[base '.nii']),data,matrix);
writeNifti(fullfile(anat,'sub-01_T2w.nii'),mean(data,4),matrix);
fid=fopen(fullfile(func,[base '.json']),'w');
fprintf(fid,'{"RepetitionTime":2,"SliceTiming":[0,0.5,1,1.5]}'); fclose(fid);
oldDirectory=pwd; oldPath=path; oldVisibility=get(groot,'DefaultFigureVisible');
cfg.dryRun=true;
pre = MIKey_run(cfg);
assert(pre.preflight.ok);
assert(~exist(fullfile(work,'derivatives'),'dir'));
assert(strcmp(path,oldPath) && strcmp(pwd,oldDirectory));
assert(strcmp(get(groot,'DefaultFigureVisible'),oldVisibility));
cfg.dryRun=false;
first=MIKey_run(cfg);
df=fullfile(work,'derivatives','MIKey','sub-01','func');
da=fullfile(work,'derivatives','MIKey','sub-01','anat');
scaled=MIKey_bids_path(df,[base '_desc-scaled.nii']);
v=spm_vol(scaled); values=spm_read_vols(v);
assert(max(abs(values(:)-data(:)))<1e-4);
assert(norm(v(1).mat-diag([0.4 0.4 0.4 1]),'fro')<1e-7);
assert(numel(v)==48 && strcmp(first.status,'completed'));
again=MIKey_run(cfg); assert(strcmp(again.status,'completed'));
mask=ones(5,6,4); mask(1,:,:)=0;
writeNifti(fullfile(df,'sub-01_brainmask.nii'),mask,v(1).mat);
writeNifti(fullfile(da,'sub-01_brainmask.nii'),mask,v(1).mat);
cfg.steps=2; MIKey_run(cfg);
masked=spm_read_vols(spm_vol(MIKey_bids_path(df,[base '_desc-masked.nii'])));
expected=data.*repmat(mask,[1 1 1 48]);
assert(max(abs(masked(:)-expected(:)))<1e-4);
% Provide synthetic template-space input: test smoothing rather than registration quality.
copyfile(scaled,MIKey_bids_path(df,[base '_space-template_desc-normalized.nii']));
cfg.steps=8; smoothing=MIKey_run(cfg);
assert(strcmp(smoothing.status,'completed'));
smoothPath=MIKey_bids_path(df,[base '_space-template_desc-smoothed.nii']);
assert(exist(smoothPath,'file')==2);
assert(~isempty(strfind(fileread(fullfile(smoothing.runDirectory,'run.log')),'FWHM=[1  2  3]')));
writeNifti(fullfile(templates,'brainmask_Mouse_v38.nii'),mask,v(1).mat);
writeNifti(fullfile(templates,'AMCP_temp','AMCP_ventricle_mask.nii'),mask,v(1).mat);
labels=zeros(5,6,4); labels(2:3,:,:)=1; labels(4:5,:,:)=2;
writeNifti(cfg.fcCustomPath,labels,v(1).mat);
group=fullfile(work,'derivatives','MIKey','group_analysis'); mkdir(group);
best_strategy_info=struct('best_strategy','12rp'); %#ok<NASGU>
save(fullfile(group,'best_regression_strategy.mat'),'best_strategy_info');
PC=randn(48,3); save(fullfile(df,[base '_desc-NBPCs.mat']),'PC');
rp=randn(48,6)*0.01;
save(fullfile(df,['rp_' base '.txt']),'rp','-ascii');
cfg.steps=[12 13]; regression=MIKey_run(cfg);
assert(strcmp(regression.status,'completed'));
fc=load(fullfile(df,[base '_desc-CustomregionFC_Regressedpc.mat']));
assert(isequal(size(fc.pearson_corr_z),[2 2]));
assert(all(isfinite(fc.pearson_corr_z(:))));
% Configuration import and typo/syntax rejection must work without eval.
config=cfg; save(fullfile(work,'config.mat'),'config');
loaded=MIKey_config(fullfile(work,'config.mat')); assert(isequal(loaded.steps,[12 13]));
fid=fopen(fullfile(work,'config.json'),'w'); fprintf(fid,'%s',jsonencode(cfg)); fclose(fid);
loaded=MIKey_config(fullfile(work,'config.json')); assert(strcmp(loaded.subjectFilter,'sub-*'));
expectError(@() MIKey_config(struct('steps','1;system(''bad'')')), 'MIKey:Steps');
expectError(@() MIKey_config(struct('smoothFWHN',1)), 'MIKey:UnknownParameter');
expectError(@() MIKey_config(struct('percentTop',2)), 'MIKey:Parameter');
expectError(@() MIKey_config(struct('highFreq',0.6)), 'MIKey:Parameter');
% A missing prerequisite and malformed input must fail, with a saved report.
cfg.steps=4;
delete(MIKey_bids_path(df,[base '_desc-masked.nii']));
expectError(@() MIKey_run(cfg),'MIKey:RunFailed');
cfg.steps=1;
bad=fullfile(work,'sub-bad','func'); mkdir(bad);
fid=fopen(fullfile(bad,'sub-bad_task-rest_bold.nii'),'w'); fprintf(fid,'not a NIfTI'); fclose(fid);
cfg.subjectFilter='sub-bad'; expectError(@() MIKey_run(cfg),'MIKey:RunFailed');
cfg.subjectFilter='sub-01'; cfg.steps=15;
check=MIKey_preflight(cfg);
assert(~check.ok && any(cellfun(@(x) ~isempty(strfind(x,'AMCP_428prior')),check.issues)));
assert(strcmp(path,oldPath) && strcmp(pwd,oldDirectory));
assert(strcmp(get(groot,'DefaultFigureVisible'),oldVisibility));
result=struct('status','passed','syntheticDirectory',work, ...
    'testedStages',[1 2 8 12 13], 'spm',spm('Ver'),'matlab',version);
disp(result);
disp('MIKEY_SMOKE_PASS');
end

function expectError(action,identifier)
try
    action();
catch ME
    assert(strcmp(ME.identifier,identifier),getReport(ME));
    return;
end
error('MIKey:Test','Expected error %s was not raised.',identifier);
end

function writeNifti(filename,data,matrix)
for i=1:size(data,4)
    v=struct('fname',filename,'dim',[size(data,1) size(data,2) size(data,3)], ...
        'dt',[16 0],'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','MIKey synthetic test');
    spm_write_vol(v,data(:,:,:,i));
end
end

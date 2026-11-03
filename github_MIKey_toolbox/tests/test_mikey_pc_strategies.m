function result = test_mikey_pc_strategies(spmPath)
% Actual steps 10/11/12 with custom, non-20-step PC counts and cached estimates.
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));MIKey_setup(spmPath);
if ispc
    folder=fullfile([getenv('SystemDrive') filesep],'MIKeyTest');
    if ~exist(folder,'dir'),mkdir(folder);end
    work=tempname(folder);
else,work=tempname;end
mkdir(work);func=fullfile(work,'sub-01','func');mkdir(func);
df=fullfile(work,'derivatives','MIKey','sub-01','func');mkdir(df);
templates=fullfile(work,'templates');mkdir(templates);mkdir(fullfile(templates,'AMCP_temp'));
matrix=diag([0.4 0.4 0.4 1]);mask=ones(5,6,4);mask(1,:,:)=0;
writeNifti(fullfile(templates,'brainmask_Mouse_v38.nii'),mask,matrix);
writeNifti(fullfile(templates,'AMCP_temp','AMCP_ventricle_mask.nii'),mask,matrix);
rng(19);
for run=1:2
    T=80-16*(run-1);base=sprintf('sub-01_task-rest_run-%02d_bold',run);
    data=100+randn(5,6,4,T);
    writeNifti(fullfile(func,[base '.nii']),data,matrix);
    copyfile(fullfile(func,[base '.nii']),MIKey_bids_path(df,[base '_space-template_desc-smoothed.nii']));
    [PC,~]=qr(randn(T,6),0);save(fullfile(df,[base '_desc-NBPCs.mat']),'PC');
    rp=randn(T,6)*0.01;save(fullfile(df,['rp_' base '.txt']),'rp','-ascii');
end
cfg=MIKey_defaults();cfg.spmPath=spmPath;cfg.bidsPath=work;cfg.templatePath=templates;
cfg.steps=10;cfg.useDefaultPCStrategy=false;cfg.customPCCounts=[0 1 3];
cfg.advRegressionPCCSF=false;cfg.advRegressionPCGS=false;cfg.advRegressionPCCSFGS=false;
assert(isequal(MIKey_pc_counts(true,[],101,85),[0 20 40 60 80]));
expectError(@() MIKey_pc_counts(false,[0 7],80,6),'MIKey:PCCounts');
expectError(@() MIKey_pc_counts(false,'0;disp(1)',80,6),'MIKey:PCCounts');
expectError(@() MIKey_config(struct('steps',10,'useDefaultPCStrategy',false,'customPCCounts',[0 2 2])),'MIKey:Parameter');
first=MIKey_run(cfg);assert(strcmp(first.status,'completed'));
for run=1:2
    file=fullfile(df,sprintf('sub-01_task-rest_run-%02d_bold_desc-regressionResults.mat',run));
    saved=load(file);assert(isequal(saved.pc_configs,[0 1 3]));
    assert(strcmp(saved.fd_info.method,'euclidean') && saved.fd_info.rotationRadius==100);
    assert(isequal(saved.FD,MIKey_framewise_displacement(saved.rp_original,'euclidean',100,cfg.voxelScaleFactor)));
    assert(abs(saved.corr0-corr(saved.FD(2:end),saved.DVARS0(2:end)'))<1e-12);
    [counts,values]=MIKey_noise_result(file);assert(isequal(counts,[0 1 3]) && numel(values)==4);
end
cfg.runFilter='02';cfg.customPCCounts=[0 2 3];
changed=MIKey_run(cfg);assert(~isempty(strfind(fileread(fullfile(changed.runDirectory,'run.log')),'recomputing strategy')));
saved=load(fullfile(df,'sub-01_task-rest_run-02_bold_desc-regressionResults.mat'));
assert(isequal(saved.pc_configs,[0 2 3]) && ~isfield(saved,'corr4'));
again=MIKey_run(cfg);assert(~isempty(strfind(fileread(fullfile(again.runDirectory,'run.log')),'Skipping - strategy estimates')));
% Changing FD settings must invalidate a matching-PC cache.
cfg.fdMethod='power';changedFD=MIKey_run(cfg);
assert(contains(fileread(fullfile(changedFD.runDirectory,'run.log')),'recomputing strategy'));
file02=fullfile(df,'sub-01_task-rest_run-02_bold_desc-regressionResults.mat');
saved=load(file02);assert(strcmp(saved.fd_info.method,'power'));
assert(isequal(saved.FD,MIKey_framewise_displacement(saved.rp_original,'power',100,cfg.voxelScaleFactor)));
allRuns=cfg;allRuns.steps=11;allRuns.runFilter='*';
expectError(@()MIKey('batch',MIKeyBatchState(allRuns,-1),11),'MIKey:StrategyFDDefinition');
cfg.fdRadius=80;changedRadius=MIKey_run(cfg);
assert(contains(fileread(fullfile(changedRadius.runDirectory,'run.log')),'recomputing strategy'));
saved=load(file02);assert(saved.fd_info.rotationRadius==80);
% A scale-only change invalidates cache and leaves Pearson CC unchanged.
oldScale=saved;cfg.voxelScaleFactor=10;changedScale=MIKey_run(cfg);
assert(contains(fileread(fullfile(changedScale.runDirectory,'run.log')),'recomputing strategy'));
saved=load(file02);assert(saved.fd_info.voxelScaleFactor==10 && strcmp(saved.fd_info.spatialUnits,'mm'));
assert(max(abs(saved.FD-2*oldScale.FD))<1e-12);
assert(abs(saved.corr0-oldScale.corr0)<1e-12);
expectError(@()MIKey('batch',MIKeyBatchState(allRuns,-1),11),'MIKey:StrategyFDDefinition');
cfg.voxelScaleFactor=20;MIKey_run(cfg);saved=load(file02);
% Version-1 scaled-space metadata is invalid and is refreshed by Step 10.
legacyInfo=rmfield(saved.fd_info,{'voxelScaleFactor','physicalRotationRadius','inputSpatialUnits'});
legacyInfo.version=1;legacyInfo.spatialUnits='SPM image units';
saved.fd_info=legacyInfo;save(file02,'-struct','saved');
expectError(@()MIKey_noise_result(file02),'MIKey:StrategyResults');
MIKey_run(cfg);saved=load(file02);assert(saved.fd_info.version==2);
% Legacy metadata-free results are rejected by Step 11 and refreshed by 10.
saved=rmfield(saved,'fd_info');save(file02,'-struct','saved');
expectError(@()MIKey('batch',MIKeyBatchState(allRuns,-1),11),'MIKey:StrategyFDDefinition');
cfg.fdMethod='euclidean';cfg.fdRadius=100;MIKey_run(cfg);
cfg.runFilter='*';cfg.steps=11;
group=MIKey_run(cfg);assert(strcmp(group.status,'completed'));
saved=load(fullfile(MIKey_group_analysis(cfg),'group_level_noise_estimation.mat'));
assert(isequal(saved.pc_configs,[0 3]) && isequal(size(saved.all_corr_data),[2 3]));
assert(isequal(saved.config_labels,{'No regress','12rp','12rp+3'}));
best=load(fullfile(MIKey_group_analysis(cfg),'best_regression_strategy.mat'));
assert(ismember(best.best_strategy_info.pc_count,[0 3]));
[~,expectedBest]=min(mean(abs(saved.all_corr_data),1));
assert(best.best_strategy_info.best_idx==expectedBest);
assert(strcmp(best.best_strategy_info.selection_rule,'global_min_mean_abs_cc'));
assert(strcmp(best.best_strategy_info.fd_info.method,'euclidean'));
cfg.steps=12;final=MIKey_run(cfg);assert(strcmp(final.status,'completed'));
assert(numel(dir(fullfile(df,'*_space-template_desc-Regressedpc_bold.nii')))==2);
cfg.customPCCounts=[0 1 3];config=cfg;save(fullfile(work,'config.mat'),'config');
loaded=MIKey_config(fullfile(work,'config.mat'));assert(~loaded.useDefaultPCStrategy && isequal(loaded.customPCCounts,[0 1 3]));
legacy=fullfile(work,'legacy.mat');corr0=.8;corr1=.3;corr2=.4;extraMetadata=ones(1,17); %#ok<NASGU>
save(legacy,'corr0','corr1','corr2','extraMetadata');
[counts,~]=MIKey_noise_result(legacy);assert(isequal(counts,[0 20]));
% The GUI/batch dispatcher must reject missing selected results, not pool a subset.
saved=load(file02);delete(file02);
expectError(@()MIKey('batch',MIKeyBatchState(allRuns,-1),11),'MIKey:Prerequisite');
save(file02,'-struct','saved');
result=struct('status','passed','syntheticDirectory',work,'testedStages',[10 11 12]);
disp(result);disp('MIKEY_PC_STRATEGIES_PASS');
end

function expectError(action,id)
try,action();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s',id);
end
function writeNifti(filename,data,matrix)
for i=1:size(data,4)
    v=struct('fname',filename,'dim',[size(data,1) size(data,2) size(data,3)], ...
        'dt',[16 0],'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','MIKey synthetic PC strategy test');
    spm_write_vol(v,data(:,:,:,i));
end
end

function result = test_mikey_bids_filters(spmPath)
% Real NIfTI fixture with sessions/tasks/runs plus shared anatomy.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);addpath(fullfile(root,'scripts'));
MIKey_setup(spmPath);
% SPM's Windows MEX writer may reject paths >260 chars; keep fixture root short.
if ispc
    testRoot=fullfile([getenv('SystemDrive') filesep],'MIKeyTest');
    if ~exist(testRoot,'dir'),mkdir(testRoot);end
    work=tempname(testRoot);
else
    work=tempname;
end
mkdir(work);
cfg=MIKey_defaults(); cfg.bidsPath=work; cfg.spmPath=spmPath;
cfg.voxelScaleFactor=2;
rng(13); data=100+randn(5,6,4,16); matrix=diag([0.2 0.2 0.2 1]);
for subject={'sub-01','sub-02'}
    anat=fullfile(work,subject{1},'anat'); mkdir(anat);
    writeNifti(fullfile(anat,[subject{1} '_T2w.nii']),mean(data,4),matrix);
    for session={'ses-baseline','ses-followup'}
        func=fullfile(work,subject{1},session{1},'func'); mkdir(func);
        for task={'rest','motor'}
            for run={'01','02'}
                base=[subject{1} '_' session{1} '_task-' task{1} '_run-' run{1} '_bold'];
                writeNifti(fullfile(func,[base '.nii']),data,matrix);
            end
        end
    end
end
% No-session/no-run is explicitly selectable and remains included by *.
func=fullfile(work,'sub-01','func'); mkdir(func);
writeNifti(fullfile(func,'sub-01_task-rest_bold.nii'),data,matrix);
assert(MIKey_match_entity('','*','ses'));
assert(MIKey_match_entity('','none','run'));
cfg.steps=13; contexts=MIKey_subjects(cfg); assert(numel(contexts)==5);
cfg.subjectFilter='sub-01'; cfg.sessionFilter='baseline';
cfg.taskFilter='rest'; cfg.runFilter='02'; cfg.steps=1;
contexts=MIKey_subjects(cfg); assert(numel(contexts)==1);
assert(strcmp(contexts.subjectID,'sub-01') && strcmp(contexts.sessionID,'ses-baseline'));
assert(strcmp(MIKey_anat_path(fullfile(work,contexts.name)),fullfile(work,'sub-01','anat')));
selected=MIKey_bold_files(fullfile(work,contexts.name,'func'),cfg); assert(numel(selected)==1);
cfg.dryRun=true; pre=MIKey_run(cfg); assert(pre.preflight.ok);
assert(pre.preflight.rawCounts(1,1)==1 && ~exist(fullfile(work,'derivatives'),'dir'));
cfg.dryRun=false; processed=MIKey_run(cfg); assert(strcmp(processed.status,'completed'));
df=fullfile(work,'derivatives','MIKey','sub-01','ses-baseline','func');
base='sub-01_ses-baseline_task-rest_run-02_bold';
assert(exist(MIKey_bids_path(df,[base '_desc-scaled.nii']),'file')==2);
assert(numel(dir(fullfile(df,'*_desc-scaled_bold.nii')))==1);
assert(~exist(fullfile(work,'derivatives','MIKey','sub-01','ses-followup'),'dir'));
assert(~exist(fullfile(work,'derivatives','MIKey','sub-02'),'dir'));
assert(~exist(fullfile(work,'derivatives','MIKey','sub-01','func'),'dir'));
cfg.sessionFilter='ses-baseline,ses-followup'; cfg.runFilter='01,02';
contexts=MIKey_subjects(cfg); assert(numel(contexts)==2);
assert(numel(MIKey_bold_files(fullfile(work,contexts(1).name,'func'),cfg))==2);
cfg.sessionFilter='none'; cfg.runFilter='none'; contexts=MIKey_subjects(cfg);
assert(numel(contexts)==1 && strcmp(contexts.name,'sub-01'));
cfg.sessionFilter='baseline'; cfg.runFilter='99'; assert(isempty(MIKey_subjects(cfg)));
check=MIKey_preflight(cfg); assert(~check.ok);
% Different selections have different group/concatenation namespaces.
cfg.runFilter='02'; key=MIKey_selection_key(cfg);
other=cfg; other.runFilter='01'; assert(~strcmp(key,MIKey_selection_key(other)));
assert(~strcmp(MIKey_group_analysis(cfg),MIKey_group_analysis(other)));
% Custom group network: no requirement for a particular historical filename.
cfg.templatePath=fullfile(work,'templates'); mkdir(cfg.templatePath);
mkdir(fullfile(cfg.templatePath,'AMCP_temp'));
mask=ones(5,6,4); mask(1,:,:)=0;
labels=zeros(5,6,4); labels(2:3,:,:)=1; labels(4:5,:,:)=2;
scaled=spm_vol(MIKey_bids_path(df,[base '_desc-scaled.nii']));
writeNifti(fullfile(cfg.templatePath,'AMCP_temp','AMCP_GMWM_mask.nii'),mask,scaled(1).mat);
cfg.groupNetworkPath=fullfile(work,'user_network.nii');
writeNifti(cfg.groupNetworkPath,labels,scaled(1).mat);
copyfile(MIKey_bids_path(df,[base '_desc-scaled.nii']),MIKey_bids_path(df,[base '_space-template_desc-Regressedpc.nii']));
cfg.steps=15; cfg.clustROINums=2; cfg.maxIter=2;
cfg.advRegressionPCCSF=false; cfg.advRegressionPCGS=false; cfg.advRegressionPCCSFGS=false;
check=MIKey_preflight(cfg); assert(check.ok);
assert(any(strcmp(check.requiredImages,cfg.groupNetworkPath)));
assert(~any(cellfun(@(x) ~isempty(strfind(x,'final_network')),check.requiredImages)));
cfg.useCustomParc=true; cfg.networkCustomPath=cfg.groupNetworkPath; cfg.groupNetworkPath='';
assert(strcmp(MIKey_group_network(cfg),cfg.networkCustomPath));
cfg.groupNetworkPath=cfg.networkCustomPath;
parcellation=MIKey_run(cfg); assert(strcmp(parcellation.status,'completed'));
assert(~isempty(strfind(fileread(fullfile(parcellation.runDirectory,'run.log')),cfg.groupNetworkPath)));
cfg.steps=16; cfg.voxelDownsampleFactor=2;
voxel=MIKey_run(cfg); assert(strcmp(voxel.status,'completed'));
% Bundled choices are resolved explicitly, including a user-specified 17net file.
cfg.templatePath=fullfile(root,'share_temp'); cfg.useCustomParc=false; cfg.groupNetworkPath='';
assert(exist(MIKey_group_network(cfg),'file')==2);
cfg.groupNetworkPath=fullfile(cfg.templatePath,'AMCP_temp','AMCP_428prior_17net.nii');
assert(strcmp(MIKey_group_network(cfg),cfg.groupNetworkPath));
config=cfg; save(fullfile(work,'config.mat'),'config');
loaded=MIKey_config(fullfile(work,'config.mat')); assert(strcmp(loaded.runFilter,'02'));
result=struct('status','passed','syntheticDirectory',work,'testedStages',[1 15 16]);
disp(result); disp('MIKEY_BIDS_FILTERS_PASS');
end

function writeNifti(filename,data,matrix)
for i=1:size(data,4)
    v=struct('fname',filename,'dim',[size(data,1) size(data,2) size(data,3)], ...
        'dt',[16 0],'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','MIKey synthetic filter test');
    spm_write_vol(v,data(:,:,:,i));
end
end

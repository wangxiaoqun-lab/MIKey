function result=test_mikey_timepoint_filter(spmPath)
% Actual header counts, threshold boundary, scaling and selected group estimates.
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));MIKey_setup(spmPath);
work=tempname;mkdir(work);func=fullfile(work,'sub-01','func');mkdir(func);
cfg=MIKey_defaults();cfg.bidsPath=work;cfg.spmPath=spmPath;cfg.minTimepoints=10;
matrix=diag([0.2 0.2 0.2 1]);lengths=[5 10 11];
% Count headers in both byte orders, and reject a negative temporal dimension.
for little=[true false]
    header=zeros(1,80,'uint8');
    header(1:4)=encoded(348,4,little);header(41:42)=encoded(4,2,little);
    header(49:50)=encoded(10,2,little);
    path=fullfile(work,sprintf('header-%d.nii',little));writeBytes(path,header);
    assert(MIKey_timepoints(path)==10);
    header(49:50)=uint8([255 255]);writeBytes(path,header);
    expectError(@()MIKey_timepoints(path),'MIKey:NIfTIHeader');
end
for i=1:3
    base=sprintf('sub-01_task-rest_run-%02d_bold',i);
    path=fullfile(func,[base '.nii']);
    writeNifti(path,randn(5,6,4,lengths(i)),matrix);
    assert(MIKey_timepoints(path)==lengths(i));
    if i~=2,gzip(path);delete(path);assert(MIKey_timepoints([path '.gz'])==lengths(i));end
end
cfg.minTimepoints=0;assert(numel(MIKey_bold_files(func,cfg))==3);
oldKey=MIKey_selection_key(cfg);cfg.minTimepoints=10;
[files,excluded]=MIKey_bold_files(func,cfg);
assert(numel(files)==2 && numel(excluded)==1 && excluded.timepoints==5);
assert(~isempty(strfind(files(1).name,'run-02'))); %#ok<STREMP>
assert(~strcmp(oldKey,MIKey_selection_key(cfg)));
cfg.minTimepoints=11;assert(numel(MIKey_bold_files(func,cfg))==1);
cfg.minTimepoints=10;
check=MIKey_preflight(cfg);assert(check.ok && check.rawCounts(1,1)==2 && numel(check.excludedBold)==1);
cfg.dryRun=true;MIKey_run(cfg);assert(~exist(fullfile(work,'derivatives'),'dir'));
cfg.dryRun=false;report=MIKey_run(cfg);assert(strcmp(report.status,'completed'));
df=fullfile(work,'derivatives','MIKey','sub-01','func');
assert(numel(dir(fullfile(df,'*_desc-scaled_bold.nii')))==2);
assert(~exist(MIKey_bids_path(df,'sub-01_task-rest_run-01_bold_desc-scaled.nii'),'file'));
log=fileread(fullfile(report.runDirectory,'run.log'));assert(~isempty(strfind(log,'T=5 < N=10'))); %#ok<STREMP>
% Old estimates for the five-frame run must remain excluded from Step 11.
for i=1:3
    corr0=0.8;corr1=0.3+i/100;corr2=0.2;pc_configs=[0 1]; %#ok<NASGU>
    save(fullfile(df,sprintf('sub-01_task-rest_run-%02d_bold_desc-regressionResults.mat',i)), ...
        'corr0','corr1','corr2','pc_configs');
end
cfg.steps=11;group=MIKey_run(cfg);assert(strcmp(group.status,'completed'));
estimated=load(fullfile(MIKey_group_analysis(cfg),'group_level_noise_estimation.mat'));
assert(size(estimated.all_corr_data,1)==2);
assert(all(cellfun(@(x) isempty(strfind(x,'run-01')),estimated.run_files)));
config=cfg;save(fullfile(work,'threshold.mat'),'config');
loaded=MIKey_config(fullfile(work,'threshold.mat'));assert(loaded.minTimepoints==10);
expectError(@()MIKey_config(struct('minTimepoints',-1)),'MIKey:Parameter');
expectError(@()MIKey_config(struct('minTimepoints',1.5)),'MIKey:Parameter');
% Optional parcellation callbacks must propagate cancellation before computation.
control=MIKeyRunControl();control.start();control.requestStop();
expectError(@()individualized_parcellation_rsfMRI_v3([],[],[],'voxel',2,0.8,'',1,0.001,2.5, ...
    'CheckpointFcn',@()control.checkpoint(true)),'MIKey:Stopped');
control.finish();
result=struct('status','passed','syntheticDirectory',work);disp(result);
disp('MIKEY_TIMEPOINT_FILTER_PASS');
end

function expectError(action,id)
try,action();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end

function bytes=encoded(value,width,little)
bytes=uint8(mod(floor(value./256.^(0:width-1)),256));
if ~little,bytes=bytes(end:-1:1);end
end

function writeBytes(path,bytes)
fid=fopen(path,'wb');assert(fid>=0);fwrite(fid,bytes,'uint8');fclose(fid);
end

function writeNifti(path,data,matrix)
for i=1:size(data,4)
    v=struct('fname',path,'dim',[size(data,1) size(data,2) size(data,3)],'dt',[16 0], ...
        'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','MIKey threshold synthetic test');
    spm_write_vol(v,data(:,:,:,i));
end
end

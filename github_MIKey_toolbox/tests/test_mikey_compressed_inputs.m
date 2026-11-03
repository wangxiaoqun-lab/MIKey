function result = test_mikey_compressed_inputs(spmPath)
% Actual scaling, modality masking and noise PCs from mixed .nii/.nii.gz inputs.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);addpath(fullfile(root,'scripts')); MIKey_setup(spmPath);
work=tempname; mkdir(work);
scope=fullfile(work,'sub-01','ses-baseline');
func=fullfile(scope,'func'); mkdir(func);
anat=fullfile(work,'sub-01','anat'); mkdir(anat);
fmap=fullfile(scope,'fmap'); mkdir(fmap);
base='sub-01_ses-baseline_task-rest_run-02_bold';
matrix=diag([0.2 0.2 0.2 1]); rng(28);
data=100+randn(20,20,12,12);
writeNifti(fullfile(func,[base '.nii']),data,matrix);
compressOnly(fullfile(func,[base '.nii']));
unselected='sub-01_ses-baseline_task-rest_run-01_bold';
writeNifti(fullfile(func,[unselected '.nii']),data+50,matrix);
t2base='sub-01_T2w'; t2=mean(data,4);
writeNifti(fullfile(anat,[t2base '.nii']),t2,matrix);
compressOnly(fullfile(anat,[t2base '.nii']));
for component={'magnitude1','phase1','magnitude2','phase2'}
    path=fullfile(fmap,['sub-01_' component{1} '.nii']);
    writeNifti(path,t2,matrix);
    if ~strcmp(component{1},'magnitude2'), compressOnly(path); end
end
sourceFiles=[dir(fullfile(func,'*.gz'));dir(fullfile(anat,'*.gz'));dir(fullfile(fmap,'*.gz'))];
sourceBytes=cell(numel(sourceFiles),1);
for i=1:numel(sourceFiles),sourceBytes{i}=readBytes(fullfile(sourceFiles(i).folder,sourceFiles(i).name));end
cfg=MIKey_defaults(); cfg.spmPath=spmPath;cfg.bidsPath=work;
cfg.sessionFilter='baseline';cfg.taskFilter='rest';cfg.runFilter='02';cfg.voxelScaleFactor=2;
cfg.dryRun=true;report=MIKey_run(cfg);assert(report.preflight.ok);
assert(isequal(report.preflight.rawCounts,[1 1]));
assert(~exist(fullfile(work,'derivatives'),'dir'));
assert(strcmp(MIKey_anat_path(scope),anat));
cfg.dryRun=false;MIKey_run(cfg);
deriv=fullfile(work,'derivatives','MIKey','sub-01','ses-baseline');
df=fullfile(deriv,'func');da=fullfile(deriv,'anat');
scaled=MIKey_bids_path(df,[base '_desc-scaled.nii']);
actual=spm_read_vols(spm_vol(scaled));assert(max(abs(actual(:)-data(:)))<1e-4);
assert(~exist(MIKey_bids_path(df,[unselected '_desc-scaled.nii']),'file'));
assert(numel(dir(fullfile(deriv,'fmap','*_desc-scaled_*.nii')))==4);
scaledMatrix=diag([0.4 0.4 0.4 1]);
boldMask=zeros(20,20,12);boldMask(8:13,8:13,:)=1;
anatMask=ones(20,20,12);anatMask(1:3,:,:)=0;
boldPath=fullfile(df,'sub-01_desc-boldbrain_mask.nii');
anatPath=fullfile(da,'sub-01_desc-anatbrain_mask.nii');
writeNifti(boldPath,boldMask,scaledMatrix);compressOnly(boldPath);
writeNifti(anatPath,anatMask,scaledMatrix);gzip(anatPath);
% A mask for the other modality must never be selected, even in the same folder.
writeNifti(fullfile(df,'sub-01_desc-anatbrain_mask.nii'),anatMask,scaledMatrix);
writeNifti(fullfile(da,'sub-01_desc-boldbrain_mask.nii'),boldMask,scaledMatrix);
% A current modality-specific mask takes precedence over legacy masks.
writeNifti(fullfile(df,'sub-01_brainmask.nii'),ones(20,20,12),scaledMatrix);
assert(strcmp(MIKey_mask_file(da,'anat'),anatPath));
assert(strcmp(MIKey_mask_file(df,'func'),[boldPath '.gz']));
cfg.steps=2;MIKey_run(cfg);
masked=spm_read_vols(spm_vol(MIKey_bids_path(df,[base '_desc-masked.nii'])));
expected=data.*repmat(boldMask,[1 1 1 12]);assert(max(abs(masked(:)-expected(:)))<1e-4);
maskedAnat=spm_read_vols(spm_vol(MIKey_bids_path(da,[t2base '_desc-masked.nii'])));
expected=t2.*anatMask;assert(max(abs(maskedAnat(:)-expected(:)))<1e-4);
cfg.steps=9;MIKey_run(cfg);
pcs=load(fullfile(df,[base '_desc-NBPCs.mat']));
assert(isequal(size(pcs.PC),[12 11]) && all(isfinite(pcs.PC(:))));
% Matching .nii/.nii.gz pairs count once and prefer the uncompressed file.
gzip(fullfile(func,[unselected '.nii']));
allFiles=MIKey_bold_files(func,MIKey_defaults());assert(numel(allFiles)==2);
plain=allFiles(strcmp({allFiles.name},[unselected '.nii']));
assert(strcmp(plain.sourceName,[unselected '.nii']));
% New names do not select multiple unrelated masks silently.
writeNifti(fullfile(df,'sub-other_desc-boldbrain_mask.nii'),boldMask,scaledMatrix);
expectError(@() MIKey_mask_file(df,'func'),'MIKey:MaskSelection');
delete(fullfile(df,'sub-other_desc-boldbrain_mask.nii'));
bad=fullfile(work,'bad-mask');mkdir(bad);
writeNifti(fullfile(bad,'sub-01_desc-boldbrain_mask.nii'),boldMask,matrix);
expectError(@() MIKey_load_mask(bad,'func',scaled),'MIKey:MaskGeometry');
% GUI dispatch must use the same selection and compressed mask readers.
guiDeriv=fullfile(work,'derivatives','MIKey','sub-01','ses-baseline','func');
delete(MIKey_bids_path(guiDeriv,[base '_desc-masked.nii']));
delete(anatPath);
delete(MIKey_bids_path(da,[t2base '_desc-masked.nii']));
old=get(groot,'DefaultFigureVisible');restore=onCleanup(@()set(groot,'DefaultFigureVisible',old)); %#ok<NASGU>
set(groot,'DefaultFigureVisible','off');before=findall(groot,'Type','figure');MIKey;
created=findall(groot,'Type','figure');created=created(~ismember(created,before));assert(numel(created)==1);
fig=created(1);closeFigure=onCleanup(@()delete(fig)); %#ok<NASGU>
fig.UserData.bidsPath=work;fig.UserData.sessionEdit.Value='baseline';
fig.UserData.taskEdit.Value='rest';fig.UserData.runEdit.Value='02';
fig.UserData.maskButton.ButtonPushedFcn(fig.UserData.maskButton,[]);
assert(exist(MIKey_bids_path(guiDeriv,[base '_desc-masked.nii']),'file')==2);
log=strjoin(fig.UserData.statusText.Value,sprintf('\n'));
assert(~isempty(strfind(log,'desc-boldbrain_mask.nii.gz'))); %#ok<STREMP>
assert(~isempty(strfind(log,'desc-anatbrain_mask.nii.gz'))); %#ok<STREMP>
maskedAnat=spm_read_vols(spm_vol(MIKey_bids_path(da,[t2base '_desc-masked.nii'])));
expected=t2.*anatMask;assert(max(abs(maskedAnat(:)-expected(:)))<1e-4);
for i=1:numel(sourceFiles)
    path=fullfile(sourceFiles(i).folder,sourceFiles(i).name);
    assert(isequal(sourceBytes{i},readBytes(path)));
    assert(~exist(path(1:end-3),'file'),'Compressed raw input was expanded in-place.');
end
result=struct('status','passed','syntheticDirectory',work,'testedStages',[1 2 9]);
disp(result);disp('MIKEY_COMPRESSED_INPUTS_PASS');
end

function compressOnly(path)
gzip(path);delete(path);
end

function bytes=readBytes(path)
fid=fopen(path,'rb');assert(fid>=0);closer=onCleanup(@()fclose(fid)); %#ok<NASGU>
bytes=fread(fid,Inf,'*uint8');
end

function expectError(action,identifier)
try,action();catch ME,assert(strcmp(ME.identifier,identifier),getReport(ME));return;end
error('MIKey:Test','Expected error %s.',identifier);
end

function writeNifti(path,data,matrix)
for i=1:size(data,4)
    v=struct('fname',path,'dim',[size(data,1) size(data,2) size(data,3)], ...
        'dt',[16 0],'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','MIKey synthetic test');
    spm_write_vol(v,data(:,:,:,i));
end
end

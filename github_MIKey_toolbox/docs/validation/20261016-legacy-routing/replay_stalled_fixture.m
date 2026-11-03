function result = replay_stalled_fixture(spmPath, legacyPath)
% Replay the exact retained synthetic input, without changing its files.
root='K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';
oldPath=path;cleanup=onCleanup(@()restorePath(oldPath)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));addpath(spmPath);
files=dir(fullfile(legacyPath,'**','*.nii'));
assert(~isempty(files),'Retained synthetic inputs are missing.');
hashes=cell(1,numel(files));
for i=1:numel(files),hashes{i}=hashFile(fullfile(files(i).folder,files(i).name));end
work=tempname;mkdir(work);copyfile(fullfile(legacyPath,'*'),work);
mock=fullfile(work,'spm_naming_stub');addpath(mock,'-begin');clear spm_jobman;
assert(strcmp(which('spm_jobman'),fullfile(mock,'spm_jobman.m')));
cfg=MIKey_defaults();cfg.bidsPath=work;cfg.useDefaultTemplate=false;
cfg.customTemplatePath=fullfile(work,'sub-01','anat','sub-01_T2w.nii');
fid=fopen(fullfile(fileparts(mfilename('fullpath')),'retained-fixture-stage.log'),'w');
logCleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
state=MIKeyBatchState(cfg,fid);started=tic;
MIKey('batch',state,6);MIKey('batch',state,7);
df=fullfile(work,'derivatives','MIKey','sub-01','func');base='sub-01_task-rest_run-01_bold';
assert(exist(MIKey_bids_path(df,[base '_desc-T2coreg.nii']),'file')==2);
assert(exist(MIKey_bids_path(df,[base '_space-template_desc-T2normalized.nii']),'file')==2);
assert(exist(MIKey_bids_path(df,[base '_space-template_desc-normalized.nii']),'file')==2);
for i=1:numel(files),assert(strcmp(hashes{i},hashFile(fullfile(files(i).folder,files(i).name))),'Original synthetic input changed.');end
result=struct('status','passed','seconds',toc(started),'source',legacyPath,'copy',work,'originalImagesUnchanged',true, ...
    'sourceFiles',{{files.name}},'sourceSHA256',{hashes});
disp('MIKEY_EXACT_STALLED_FIXTURE_REPLAY_PASS');
end

function value=hashFile(filename)
fid=fopen(filename,'rb');cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
bytes=fread(fid,Inf,'*uint8');digest=java.security.MessageDigest.getInstance('SHA-256');
digest.update(bytes);value=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
end

function restorePath(oldPath)
path(oldPath);clear spm_jobman;
end

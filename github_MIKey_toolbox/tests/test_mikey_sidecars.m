function result = test_mikey_sidecars(spmPath)
% Exact affine/value preservation and selective compaction, real SPM I/O.
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));MIKey_setup(spmPath);
work=tempname;mkdir(work);raw=fullfile(work,'sub-01','func');mkdir(raw);
derived=fullfile(work,'derivatives','MIKey','sub-01','func');mkdir(derived);
cfg=MIKey_defaults();cfg.bidsPath=work;cfg.steps=8;cfg.subjectFilter='sub-01';
write(fullfile(raw,'sub-01_task-rest_bold.nii'));
old=fullfile(derived,'sub-01_task-rest_desc-old_bold.nii');make(old,'same');
oldMatHash=hash([old(1:end-4) '.mat']);
before=MIKey_sidecar_snapshot(cfg);
new=fullfile(derived,'sub-01_task-rest_desc-new_bold.nii');make(new,'same');
zero=fullfile(derived,'sub-01_task-rest_desc-zero_bold.nii');make(zero,'zero');
needed=fullfile(derived,'sub-01_task-rest_desc-needed_bold.nii');make(needed,'different');
near=fullfile(derived,'sub-01_task-rest_desc-near_bold.nii');make(near,'near');
opaque=fullfile(derived,'sub-01_task-rest_desc-opaque_bold.nii');make(opaque,'opaque');
PC=randn(3,2);save(fullfile(derived,'sub-01_task-rest_bold_desc-NBPCs.mat'),'PC');
corr0=.2;save(fullfile(derived,'sub-01_task-rest_bold_desc-regressionResults.mat'),'corr0');
analysisHashes={hash(fullfile(derived,'sub-01_task-rest_bold_desc-NBPCs.mat')),hash(fullfile(derived,'sub-01_task-rest_bold_desc-regressionResults.mat'))};
images={old,new,zero,needed,near,opaque};matrices=cell(size(images));payloads=cell(size(images));
for i=1:numel(images),headers=spm_vol(images{i});matrices{i}=cat(3,headers.mat);payloads{i}=hash(images{i});end
neededHash=hash([needed(1:end-4) '.mat']);opaqueHash=hash([opaque(1:end-4) '.mat']);
report=MIKey_finalize_sidecars(cfg,before);
assert(numel(report.removed)==2 && numel(report.retained)==2 && numel(report.unknown)==1);
assert(exist([new(1:end-4) '.mat'],'file')==0 && exist([zero(1:end-4) '.mat'],'file')==0);
assert(strcmp(hash([old(1:end-4) '.mat']),oldMatHash));
assert(strcmp(hash([needed(1:end-4) '.mat']),neededHash));
assert(strcmp(hash([opaque(1:end-4) '.mat']),opaqueHash));
for i=1:numel(images)
    headers=spm_vol(images{i});assert(isequal(cat(3,headers.mat),matrices{i}));
    assert(strcmp(hash(images{i}),payloads{i}));
end
assert(strcmp(hash(fullfile(derived,'sub-01_task-rest_bold_desc-NBPCs.mat')),analysisHashes{1}));
assert(strcmp(hash(fullfile(derived,'sub-01_task-rest_bold_desc-regressionResults.mat')),analysisHashes{2}));
% A later no-op must leave old sidecars untouched and do no compaction.
snapshot=MIKey_sidecar_snapshot(cfg);again=MIKey_finalize_sidecars(cfg,snapshot);
assert(isempty(again.removed) && isempty(again.retained) && isempty(again.unknown));
% Cancellation before compaction preserves a newly produced sidecar.
cancelled=fullfile(derived,'sub-01_task-rest_desc-cancelled_bold.nii');make(cancelled,'same');
try
    MIKey_finalize_sidecars(cfg,snapshot,@()error('MIKey:Stopped','Test cancellation'));
    error('MIKey:Test','Expected cancellation.');
catch ME,assert(strcmp(ME.identifier,'MIKey:Stopped'),getReport(ME));end
assert(exist([cancelled(1:end-4) '.mat'],'file')==2);
result=struct('status','passed','syntheticDirectory',work,'removedRedundant',2,'preservedDistinctTransforms',2);
disp(result);disp('MIKEY_SIDECARS_PASS');
end
function make(name,kind)
write(name);N=nifti(name);mat=repmat(N.mat,[1 1 3]);
switch kind
    case 'zero',mat(:)=0;
    case 'different',mat(1,4,2)=mat(1,4,2)+.125;
    case 'near',mat(1,4,2)=mat(1,4,2)+1e-12;
end
if strcmp(kind,'opaque'),provenance='keep';save([name(1:end-4) '.mat'],'mat','provenance');
else,save([name(1:end-4) '.mat'],'mat');end
end
function write(name)
for t=1:3
    head=struct('fname',name,'dim',[4 5 3],'dt',[16 0],'mat',diag([.5 .5 .5 1]), ...
        'pinfo',[1;0;0],'n',[t 1],'descrip','sidecar policy synthetic test');
    spm_write_vol(head,ones(4,5,3)*t);
end
end
function value=hash(name)
fid=fopen(name,'rb');assert(fid>=0);data=fread(fid,Inf,'*uint8');fclose(fid);
digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(data);
value=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
end

function test_mikey_cleanup()
% SERVER ONLY. Synthetic files in an isolated temporary BIDS tree; no SPM needed.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(fullfile(root,'scripts'));
base=[tempname '-mikey-cleanup-test']; mkdir(base);
cleanup=onCleanup(@() removeFixture(base)); %#ok<NASGU>
deriv=fullfile(base,'derivatives','MIKey'); mkdir(deriv);
original='sub-001/func/sub-001_task-rest_run-01_desc-orig_bold.nii.gz';
sidecar='sub-001/func/sub-001_task-rest_run-01_desc-orig_bold.json';
raw=fullfile(base,'sub-001','func','sub-001_task-rest_run-01_bold.nii.gz'); write(raw,'raw');
mask='sub-001/func/sub-001_desc-boldbrain_mask.nii.gz';
nii='sub-001/func/sub-001_task-rest_run-01_space-template_desc-Regressedpc_bold.nii';
marker='sub-001/func/sub-001_task-rest_run-01_bold_desc-advancedRegressionResults.mat';
for relative={original,sidecar,mask,nii,marker,'dataset_description.json','sub-001/func/notes.txt','logs/config.mat'}
    write(fullfile(deriv,relative{1}),'fixture');
end
plan=MIKey_cleanup_inventory(base); names={plan.files.relative};
assert(~any(startsWith(names,'logs/')));
assert(plan.files(strcmp(names,mask)).protected);
assert(plan.files(strcmp(names,'sub-001/func/notes.txt')).protected);
assert(plan.files(strcmp(names,original)).step==1);
allKeep=true(numel(names),1);
result=MIKey_cleanup_delete(plan,allKeep,'DELETE_REVIEWED_FILES'); assert(result.deleted==0);
throws(@() MIKey_cleanup_delete(plan,allKeep,''),'MIKey:CleanupConfirmation');
throws(@() MIKey_cleanup_guard(base,'../sub-001/func'),'MIKey:CleanupPath');
throws(@() MIKey_cleanup_guard(base,'sub-001/func/*'),'MIKey:CleanupPath');
keep=allKeep; keep(strcmp(names,mask))=false; keep=MIKey_cleanup_keep(plan,keep);
assert(keep(strcmp(names,mask)));
keep=allKeep; row=find(strcmp(names,original)); keep(row)=false;
keep=MIKey_cleanup_keep(plan,keep,row); assert(~keep(strcmp(names,sidecar)));
regKeep=allKeep; row=find(strcmp(names,nii)); regKeep(row)=false;
regKeep=MIKey_cleanup_keep(plan,regKeep,row); assert(~regKeep(strcmp(names,marker)));
% Changed size and changed file set both refuse before deleting anything.
write(fullfile(deriv,original),'a changed fixture');
throws(@() MIKey_cleanup_delete(plan,keep,'DELETE_REVIEWED_FILES'),'MIKey:CleanupChanged');
assert(isfile(fullfile(deriv,original)) && isfile(fullfile(deriv,sidecar)));
plan=MIKey_cleanup_inventory(base); names={plan.files.relative};
keep=true(numel(names),1); row=find(strcmp(names,original)); keep(row)=false;
keep=MIKey_cleanup_keep(plan,keep,row);
write(fullfile(deriv,'sub-001/func/new-notes.txt'),'added');
throws(@() MIKey_cleanup_delete(plan,keep,'DELETE_REVIEWED_FILES'),'MIKey:CleanupChanged');
plan=MIKey_cleanup_inventory(base); names={plan.files.relative};
keep=true(numel(names),1); row=find(strcmp(names,original)); keep(row)=false;
keep=MIKey_cleanup_keep(plan,keep,row);
result=MIKey_cleanup_delete(plan,keep,'DELETE_REVIEWED_FILES');
assert(result.deleted==2 && result.failed==0 && isfile(result.auditFile));
assert(~isfile(fullfile(deriv,original)) && ~isfile(fullfile(deriv,sidecar)));
assert(isfile(raw) && isfile(fullfile(deriv,mask)) && isfile(fullfile(deriv,nii)) && isfile(fullfile(deriv,marker)));
audit=fileread(result.auditFile); assert(contains(audit,'"event":"deleted"'));
% Every processing step has at least one recognized representative output.
examples={ ...
'sub-001/func/sub-001_desc-scaled_bold.nii'; ...
'sub-001/anat/sub-001_desc-masked_T2w.nii'; ...
'sub-001/func/sub-001_desc-fieldmap_bold.nii'; ...
'sub-001/func/sub-001_desc-slicetimed_bold.nii'; ...
'sub-001/func/rp_sub-001_desc-slicetimed_bold.txt'; ...
'sub-001/anat/sub-001_space-bold_desc-T2coreg_T2w.nii'; ...
'sub-001/func/sub-001_space-template_desc-normalized_bold.nii'; ...
'sub-001/func/sub-001_space-template_desc-smoothed_bold.nii'; ...
'sub-001/func/sub-001_bold_desc-NBPCs.mat'; ...
'sub-001/func/sub-001_bold_desc-regressionResults.mat'; ...
'group_analysis/selection-key/best_regression_strategy.mat'; ...
'sub-001/func/sub-001_space-template_desc-RegressedpcCSF_bold.nii'; ...
'sub-001/func/sub-001_bold_desc-296regionFC_Regressedpc.mat'; ...
'sub-001/func/sub-001_bold_parcellation_prior_mode_214_Regressedpc/Final_Parcellation/individual_network_map.nii'; ...
'sub-001/func/sub-001_bold_parcellation_clust_100_Regressedpc/parcellation_summary.mat'; ...
'sub-001/func/sub-001_bold_parcellation_voxel_2_Regressedpc/Final_Parcellation/Network_FC.mat'; ...
'sub-001/anat/sub-001_space-template_label-GM_desc-fiveClassModulatedSmoothed_statmap.nii'};
for k=1:17
    [step,~,locked]=MIKey_cleanup_classify(examples{k}); assert(step==k && ~locked);
end
fprintf('MIKEY_CLEANUP_SYNTHETIC_PASS\n');
end
function write(file,content)
folder=fileparts(file); if ~isfolder(folder), mkdir(folder); end
fid=fopen(file,'wt'); assert(fid>=0); fcloseCleanup=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',content);
end
function throws(callback,identifier)
try, callback(); catch ME, assert(strcmp(ME.identifier,identifier),ME.message); return; end
error('MIKey:Test','Expected %s',identifier);
end
function removeFixture(base)
file=java.io.File(base); target=char(file.getCanonicalPath());
parent=java.io.File(tempdir); parent=char(parent.getCanonicalPath());
[~,name]=fileparts(target);
assert(startsWith([target filesep],[parent filesep]) && endsWith(name,'-mikey-cleanup-test'));
if isfolder(target), rmdir(target,'s'); end
end

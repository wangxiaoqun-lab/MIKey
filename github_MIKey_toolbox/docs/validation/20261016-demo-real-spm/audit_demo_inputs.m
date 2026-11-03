function audit_demo_inputs
root='K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';folder=fileparts(mfilename('fullpath'));
oldPath=path;global defaults;oldDefaults=defaults;
cleanup=onCleanup(@()restoreSession(oldPath,oldDefaults)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));addpath('D:/Program Files/MATLAB/mytoolbox/spm12');
assert(strcmpi(which('spm_jobman'),'D:\Program Files\MATLAB\mytoolbox\spm12\spm_jobman.m'));
base=fullfile(root,'demo_BIDS_dataset','derivatives','MIKey','sub-001');
bold=fullfile(base,'func','sub-001_task-rest_run-01_desc-realign_bold.nii');
meanBold=fullfile(base,'func','sub-001_task-rest_run-01_desc-mean_boldref.nii');
t2=fullfile(base,'anat','sub-001_acq-t2fsetra_run-01_desc-masked_T2w.nii');
oldCoreg=fullfile(base,'anat','sub-001_task-rest_run-01_space-bold_desc-T2coreg_T2w.nii');
template=fullfile(root,'share_temp','Template_Mouse_v38.nii');
cases={6,'pre',bold,t2,'original-step6-pre';6,'post',meanBold,oldCoreg,'existing-step6-post';7,'pre',template,oldCoreg,'existing-step7-pre'};
result=struct('spmJobman',which('spm_jobman'),'checks',{{}});
for i=1:size(cases,1)
    reportPath=fullfile(folder,[cases{i,5} '.json']);
    try
        MIKey_registration_qc(cases{i,1},cases{i,2},cases{i,3},cases{i,4},reportPath);
    catch ME
        fprintf('%s: %s\n',cases{i,5},ME.message);
    end
    report=jsondecode(fileread(reportPath));result.checks{end+1}=report;
    fprintf('REAL_DEMO_AUDIT %s %s\n',cases{i,5},report.status);
end
fid=fopen(fullfile(folder,'input-audit.json'),'w','n','UTF-8');closeFile=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(result));
end

function restoreSession(oldPath,oldDefaults)
global defaults;defaults=oldDefaults;path(oldPath);
end

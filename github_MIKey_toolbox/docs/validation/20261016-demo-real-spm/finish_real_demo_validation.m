function finish_real_demo_validation
folder=fileparts(mfilename('fullpath'));w=jsondecode(fileread(fullfile(folder,'workspace.json')));
gui=jsondecode(fileread(fullfile(folder,'gui-stop-result.json')));assert(strcmp(gui.status,'passed'));
successful=jsondecode(fileread(fullfile(folder,'initialized-run01-result.json')));assert(strcmp(successful.status,'completed'));
restored=jsondecode(fileread(fullfile(folder,'restored-cache-run01-result.json')));assert(strcmp(restored.status,'completed'));
assert(strcmpi(which('spm_jobman'),'D:\Program Files\MATLAB\mytoolbox\spm12\spm_jobman.m'));
base=fullfile(w.bidsPath,'derivatives','MIKey','sub-001');stem='sub-001_task-rest_run-01';
input=spm_vol(fullfile(base,'func',[stem '_desc-realign_bold.nii']));
output=spm_vol(fullfile(base,'func',[stem '_space-template_desc-normalized_bold.nii']));
assert(numel(input)==480 && numel(output)==480);
originalFigures=findall(groot,'Type','figure');assert(numel(originalFigures)==1 && isvalid(originalFigures(1)));
result=struct('status','passed','matlab',version,'spm',spm('Ver'),'spmJobman',which('spm_jobman'), ...
    'inputVolumes',numel(input),'outputVolumes',numel(output),'outputDimensions',output(1).dim, ...
    'outputAffine',output(1).mat,'cwd',pwd,'diary',get(0,'Diary'),'figureCount',numel(originalFigures), ...
    'breakpointCount',numel(dbstatus('-completenames')),'finished',datestr(now,30));
fid=fopen(fullfile(folder,'session-restoration.json'),'w','n','UTF-8');
assert(fid>=0);fprintf(fid,'%s',jsonencode(result));fclose(fid);
% The user enabled this existing instance specifically for this validation.
enableservice('AutomationServer',false);
result.automationServerEnabled=logical(enableservice('AutomationServer'));
assert(~result.automationServerEnabled);
fid=fopen(fullfile(folder,'session-restoration.json'),'w','n','UTF-8');
assert(fid>=0);fprintf(fid,'%s',jsonencode(result));fclose(fid);
disp('MIKEY_REAL_DEMO_VALIDATION_FINISHED_AUTOMATION_OFF');
end

function test_real_demo_gui_stops
% Fault injection into independent test derivatives; no mock estimator.
folder=fileparts(mfilename('fullpath'));w=jsondecode(fileread(fullfile(folder,'workspace.json')));
oldPath=path;oldVisible=get(groot,'DefaultFigureVisible');
session=onCleanup(@()restoreSession(oldPath,oldVisible)); %#ok<NASGU>
addpath('D:/Program Files/MATLAB/mytoolbox/spm12');
assert(strcmpi(which('spm_jobman'),'D:\Program Files\MATLAB\mytoolbox\spm12\spm_jobman.m'));
base=fullfile(w.bidsPath,'derivatives','MIKey','sub-001');
stem='sub-001_task-rest_run-01';
coreg=fullfile(base,'anat',[stem '_space-bold_desc-T2coreg_T2w.nii']);
normalized=fullfile(base,'anat',[stem '_space-template_desc-T2normalized_T2w.nii']);
blank=fullfile(w.workspace,'baseline-qc','failed_candidates',[stem '_desc-step6postQC_T2w.nii']);
assert(exist(coreg,'file')==2 && exist(normalized,'file')==2 && exist(blank,'file')==2);
before=findall(groot,'Type','figure');results=struct('step',{},'status',{},'log',{},'controlsRestored',{});
for step=[6 7]
    if step==6,target=coreg;else,target=normalized;end
    backup=fullfile(w.workspace,sprintf('valid-step%d-before-fault_T2w.nii',step));
    copyfile(target,backup);sidecar=[target(1:end-4) '.mat'];backupMat=[backup(1:end-4) '.mat'];
    hasMat=exist(sidecar,'file')==2;
    if hasMat,copyfile(sidecar,backupMat);delete(sidecar);end
    restoreImage=onCleanup(@()restoreDerivative(target,backup,sidecar,backupMat,hasMat));
    copyfile(blank,target,'f');
    cfg=MIKey_defaults();cfg.bidsPath=w.bidsPath;cfg.spmPath='D:/Program Files/MATLAB/mytoolbox/spm12';
    cfg.templatePath=fullfile(w.workspace,'templates');cfg.subjectFilter='sub-001';cfg.runFilter='01';
    cfg.minTimepoints=20;cfg.steps=step:8;cfg.failFast=false;
    cfg.logDir=fullfile(w.workspace,'logs',sprintf('injected-step%d-failure',step));
    try,MIKey_run(cfg);error('MIKey:Test','Expected failed script run.');
    catch ME,assert(strcmp(ME.identifier,'MIKey:RunFailed'),ME.message);end
    reports=dir(fullfile(cfg.logDir,'*','report.mat'));assert(numel(reports)==1);
    saved=load(fullfile(reports(1).folder,reports(1).name));
    assert(numel(saved.report.stages)==1 && saved.report.stages.step==step);
    assert(~isempty(strfind(saved.report.stages.error,sprintf('Step %d post registration check FAILED',step)))); %#ok<STREMP>
    set(groot,'DefaultFigureVisible','off');existing=findall(groot,'Type','figure');MIKey;
    figures=findall(groot,'Type','figure');figures=figures(~ismember(figures,existing));assert(numel(figures)==1);
    fig=figures(1);closeFigure=onCleanup(@()delete(fig));
    fig.UserData.bidsPath=w.bidsPath;fig.UserData.subjectsEdit.Value='sub-001';
    fig.UserData.runEdit.Value='01';fig.UserData.minTimepointsEdit.Value=20;
    fig.UserData.templateEdit.Value=fullfile(w.workspace,'templates');
    fig.UserData.stagesEdit.Value=sprintf('%d:8',step);
    ui=fig.UserData;ui.runStepsButton.ButtonPushedFcn(ui.runStepsButton,[]);
    log=strjoin(ui.statusText.Value,sprintf('\n'));
    assert(~isempty(strfind(log,'Processing stopped:'))); %#ok<STREMP>
    assert(~isempty(strfind(log,sprintf('Step %d post registration check FAILED',step)))); %#ok<STREMP>
    assert(isempty(strfind(log,sprintf('=== Starting Step %d ===',step+1)))); %#ok<STREMP>
    controls=~ui.runControl.Active && strcmp(ui.runStepsButton.Enable,'on');assert(controls);
    results(end+1)=struct('step',step,'status','passed','log',log,'controlsRestored',controls); %#ok<AGROW>
    fid=fopen(fullfile(folder,sprintf('gui-step%d-stop.log',step)),'w','n','UTF-8');fprintf(fid,'%s',log);fclose(fid);
    clear closeFigure restoreImage;
end
after=findall(groot,'Type','figure');assert(numel(before)==numel(after) && all(ismember(before,after)));
result=struct('status','passed','method','Actual hidden GUI callback on real demo derivatives, with deliberately injected baseline blank candidate; no estimator fixtures.', ...
    'originalFiguresPreserved',true,'checks',results);
fid=fopen(fullfile(folder,'gui-stop-result.json'),'w','n','UTF-8');closeFile=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(result));disp('MIKEY_REAL_DEMO_GUI_STOPS_PASS');
end

function restoreDerivative(target,backup,sidecar,backupMat,hasMat)
copyfile(backup,target,'f');
if hasMat,copyfile(backupMat,sidecar,'f');elseif exist(sidecar,'file'),delete(sidecar);end
end

function restoreSession(oldPath,oldVisible)
path(oldPath);set(groot,'DefaultFigureVisible',oldVisible);
end

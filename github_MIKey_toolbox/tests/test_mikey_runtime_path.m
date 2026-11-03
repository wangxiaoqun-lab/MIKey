function test_mikey_runtime_path(testGUI)
% No SPM estimation: launch from Current Folder, change cwd, recover errors.
if nargin<1,testGUI=usejava('desktop');end
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
oldVisible=get(groot,'DefaultFigureVisible');work=tempname;mkdir(work);
cleanup=onCleanup(@()restore(oldPath,oldDirectory,oldVisible)); %#ok<NASGU>
before=findall(groot,'Type','figure');set(groot,'DefaultFigureVisible','off');
% Reproduce the user's launch pattern: root is cwd, not an explicit path entry.
entries=strsplit(path,pathsep);
if any(strcmp(entries,root)),rmpath(root);end
cd(root);
if ~testGUI
    addpath(fullfile(root,'scripts'));MIKey_paths();
    cfg=MIKey_defaults();cfg.bidsPath=work;cfg.templatePath=work;
    cfg.subjectFilter='sub-missing';
    state=MIKeyBatchState(cfg,-1);MIKey('batch',state,3);
    cd(work);control=MIKeyRunControl();control.start();control.checkpoint(true);control.finish();
    report=MIKey_check_runtime(control);assert(strcmp(report.status,'passed'));
    MIKey_write_derivative_metadata(cfg);
    assert(exist(fullfile(work,'derivatives','MIKey','dataset_description.json'),'file')==2);
    disp('MIKEY_RUNTIME_PATH_HEADLESS_PASS');return;
end
MIKey;
figures=findall(groot,'Type','figure');figures=figures(~ismember(figures,before));assert(numel(figures)==1);
fig=figures(1);closeFigure=onCleanup(@()deleteValid(fig)); %#ok<NASGU>
cd(work);report=MIKey_check_runtime(fig.UserData.runControl);assert(strcmp(report.status,'passed'));
control=fig.UserData.runControl;control.start();control.checkpoint(true);control.finish();
% A missing raw scope returns without SPM, but still writes metadata.
fig.UserData.bidsPath=work;fig.UserData.subjectsEdit.Value='sub-missing';
button=fig.UserData.fieldmapButton;button.ButtonPushedFcn(button,[]);
assert(~control.Active && ~fig.UserData.runCallbackActive);
assert(strcmp(fig.UserData.runStepsButton.Enable,'on'));
assert(exist(fullfile(work,'derivatives','MIKey','dataset_description.json'),'file')==2);
assert(strcmp(pwd,work));
% An unexpected processing error must clear state and restore cwd/buttons.
fig.UserData.useDefaultTemplateCheckbox.Value=false;
fig.UserData.templateCustomEdit.Value=fullfile(work,'missing-template.nii');
fid=fopen(fullfile(work,'derivatives','MIKey','dataset_description.json'),'w');fprintf(fid,'{');fclose(fid);
button=fig.UserData.normButton;button.ButtonPushedFcn(button,[]);
log=strjoin(fig.UserData.statusText.Value,sprintf('\n'));
assert(~isempty(strfind(log,'Processing stopped: Step 7 template is missing'))); %#ok<STREMP>
assert(~control.Active && ~fig.UserData.runCallbackActive);
assert(strcmp(fig.UserData.runStepsButton.Enable,'on') && strcmp(pwd,work));
% Recover an orphaned flag; never force-close a genuinely executing callback.
control.Active=true;fig.UserData.runCallbackActive=false;
stop=fig.UserData.stopButton;stop.ButtonPushedFcn(stop,[]);
assert(~control.Active);
control.Active=true;fig.CloseRequestFcn(fig,[]);assert(~isvalid(fig));
disp('MIKEY_RUNTIME_PATH_AND_RECOVERY_PASS');
end

function deleteValid(fig)
if isvalid(fig),delete(fig);end
end

function restore(oldPath,oldDirectory,oldVisible)
cd(oldDirectory);path(oldPath);set(groot,'DefaultFigureVisible',oldVisible);
end

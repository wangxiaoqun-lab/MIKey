function test_mikey_registration_dispatch(spmPath, testGUI)
% Actual stage dispatch; COPY-ONLY SPM fixture isolates QC/failure propagation.
if nargin<2,testGUI=false;end
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));addpath(fullfile(root,'scripts'));addpath(spmPath);
spm('defaults','fmri');spm_get_defaults('cmdline',true);
work=tempname;mkdir(work);oldPath=path;
cleanup=onCleanup(@()restore(oldPath)); %#ok<NASGU>
mock=fullfile(work,'stub');mkdir(mock);
copyfile(fullfile(root,'tests','fixtures','registration_stub','spm_jobman.m.fixture'),fullfile(mock,'spm_jobman.m'));
addpath(mock,'-begin');clear spm_jobman;
[cfg,df,da,base,t2,image,a]=prepare(fullfile(work,'valid'));
setappdata(0,'MIKeyRegistrationFixtureMode','copy');setappdata(0,'MIKeyRegistrationCalls',[]);
state=MIKeyBatchState(cfg,-1);
MIKey('batch',state,6);MIKey('batch',state,7);
coreg=MIKey_bids_path(df,[base '_desc-T2coreg.nii']);
norm=MIKey_bids_path(df,[base '_space-template_desc-normalized.nii']);
assert(exist(coreg,'file')==2 && exist(norm,'file')==2);
% Cached outputs are rechecked, not blindly skipped.
write(coreg,zeros(size(image)),a);expect(@()MIKey('batch',state,6));
assert(exist(coreg,'file')==2); % Never delete an existing user's failed result.
write(coreg,image,a);write(norm,image,a);expect(@()MIKey('batch',state,7));
% Fresh failed candidates are never promoted to canonical output names.
for stage=[6 7]
    [current,funcPath,~,stem]=prepare(fullfile(work,sprintf('bad%d',stage)));
    if stage==7,copyfile(fullfile(da,[t2 '_desc-masked_T2w.nii']),MIKey_bids_path(funcPath,[stem '_desc-T2coreg.nii']));end
    setappdata(0,'MIKeyRegistrationFixtureMode',sprintf('blank%d',stage));
    expect(@()MIKey('batch',MIKeyBatchState(current,-1),stage));
    if stage==6,target=MIKey_bids_path(funcPath,[stem '_desc-T2coreg.nii']);
    else,target=MIKey_bids_path(funcPath,[stem '_space-template_desc-normalized.nii']);end
    assert(~exist(target,'file'));
end
% Unsafe input geometry must block SPM before estimation in both stages.
for stage=[6 7]
    [current,funcPath,anatomical,stem,~,data,matrix]=prepare(fullfile(work,sprintf('pre%d',stage)));
    matrix(1:3,:)=matrix(1:3,:)*20;
    if stage==6,target=fullfile(anatomical,'sub-01_desc-masked_T2w.nii');
    else,target=MIKey_bids_path(funcPath,[stem '_desc-T2coreg.nii']);end
    write(target,data,matrix);
    setappdata(0,'MIKeyRegistrationFixtureMode','copy');setappdata(0,'MIKeyRegistrationCalls',[]);
    expect(@()MIKey('batch',MIKeyBatchState(current,-1),stage));
    assert(isempty(getappdata(0,'MIKeyRegistrationCalls')));
end
% Estimator exceptions also escape the per-subject loop as fatal failures.
[current,~,~,~]=prepare(fullfile(work,'estimator'));
setappdata(0,'MIKeyRegistrationFixtureMode','crash');
expect(@()MIKey('batch',MIKeyBatchState(current,-1),6));
% Script must stop even if failFast=false; Stage 7/8 must not start.
[current,funcPath,~,stem]=prepare(fullfile(work,'failfast'));
current.steps=[6 7 8];current.failFast=false;current.spmPath='';
current.logDir=fullfile(current.bidsPath,'logs');
setappdata(0,'MIKeyRegistrationFixtureMode','blank6');
try,MIKey_run(current);error('MIKey:Test','Expected a failed run.');
catch ME,assert(strcmp(ME.identifier,'MIKey:RunFailed'),ME.message);end
saved=dir(fullfile(current.logDir,'*','report.mat'));assert(numel(saved)==1);
result=load(fullfile(saved(1).folder,saved(1).name));
assert(numel(result.report.stages)==1 && result.report.stages.step==6);
assert(~exist(MIKey_bids_path(funcPath,[stem '_space-template_desc-normalized.nii']),'file'));
if testGUI
    oldVisible=get(groot,'DefaultFigureVisible');visibility=onCleanup(@()set(groot,'DefaultFigureVisible',oldVisible)); %#ok<NASGU>
    set(groot,'DefaultFigureVisible','off');before=findall(groot,'Type','figure');MIKey;
    figures=findall(groot,'Type','figure');figures=figures(~ismember(figures,before));assert(numel(figures)==1);
    fig=figures(1);closeFigure=onCleanup(@()delete(fig)); %#ok<NASGU>
    fig.UserData.bidsPath=current.bidsPath;fig.UserData.stagesEdit.Value='6:8';
    fig.UserData.useDefaultTemplateCheckbox.Value=false;fig.UserData.templateCustomEdit.Value=current.customTemplatePath;
    ui=fig.UserData;ui.runStepsButton.ButtonPushedFcn(ui.runStepsButton,[]);
    log=strjoin(ui.statusText.Value,sprintf('\n'));
    assert(~isempty(strfind(log,'Processing stopped:')) && isempty(strfind(log,'=== Starting Step 7 ==='))); %#ok<STREMP>
    assert(~ui.runControl.Active && strcmp(ui.runStepsButton.Enable,'on'));
    disp('MIKEY_REGISTRATION_GUI_STOP_PASS');
end
disp('MIKEY_REGISTRATION_DISPATCH_PASS');
end

function [cfg,df,da,base,t2,image,a]=prepare(work)
func=fullfile(work,'sub-01','func');anat=fullfile(work,'sub-01','anat');mkdir(func);mkdir(anat);
df=fullfile(work,'derivatives','MIKey','sub-01','func');da=fullfile(work,'derivatives','MIKey','sub-01','anat');mkdir(df);mkdir(da);
[x,y,z]=ndgrid(1:20,1:28,1:16);mask=((x-10.5)/7).^2+((y-14.5)/11).^2+((z-8.5)/5).^2<1;
image=mask.*(100+20*sin(x/3)+10*cos(y/3)+z);
a=eye(4);a(1:3,4)=-[10.5;14.5;8.5];base='sub-01_task-rest_run-01_bold';t2='sub-01';
write(fullfile(func,[base '.nii']),repmat(image,[1 1 1 3]),a);
write(fullfile(anat,'sub-01_T2w.nii'),image,a);
write(MIKey_bids_path(df,[base '_desc-realign.nii']),repmat(image,[1 1 1 3]),a);
write(fullfile(da,'sub-01_desc-masked_T2w.nii'),image,a);
cfg=MIKey_defaults();cfg.bidsPath=work;cfg.useDefaultTemplate=false;cfg.customTemplatePath=fullfile(anat,'sub-01_T2w.nii');
end

function write(funcPath,data,a)
if exist(funcPath,'file'),delete(funcPath);end
for i=1:size(data,4)
    v=struct('fname',funcPath,'dim',[size(data,1) size(data,2) size(data,3)],'dt',[16 0], ...
        'mat',a,'pinfo',[1;0;0],'n',[i 1],'descrip','Registration dispatch fixture');
    spm_write_vol(v,data(:,:,:,i));
end
end

function expect(call)
try,call();error('MIKey:Test','Expected registration failure.');
catch ME,assert(strncmp(ME.identifier,'MIKey:Registration',18),ME.message);end
end

function restore(oldPath)
path(oldPath);clear spm_jobman;
for key={'MIKeyRegistrationCalls','MIKeyRegistrationFixtureMode'}
    if isappdata(0,key{1}),rmappdata(0,key{1});end
end
end

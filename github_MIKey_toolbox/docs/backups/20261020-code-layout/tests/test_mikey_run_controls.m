function result=test_mikey_run_controls(spmPath, useUIEvents)
if nargin<2,useUIEvents=false;end
if useUIEvents,driver=matlab.uitest.TestCase.forInteractiveUse;end
% Timers invoke GUI callbacks during scaling; optional UITest execution-button events.
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);MIKey_setup(spmPath);
work=tempname;mkdir(work);
pauseWork=fullfile(work,'pause');stopWork=fullfile(work,'stop');
prepare(pauseWork);prepare(stopWork);
old=get(groot,'DefaultFigureVisible');restore=onCleanup(@()set(groot,'DefaultFigureVisible',old)); %#ok<NASGU>
set(groot,'DefaultFigureVisible','off');before=findall(groot,'Type','figure');MIKey;
created=findall(groot,'Type','figure');created=created(~ismember(created,before));assert(numel(created)==1);
fig=created(1);if useUIEvents,fig.Visible='on';drawnow;end
closeFigure=onCleanup(@()delete(fig)); %#ok<NASGU>
ui=fig.UserData;assert(strcmp(ui.pauseButton.Enable,'off') && strcmp(ui.stopButton.Enable,'off'));
fig.UserData.bidsPath=pauseWork;fig.UserData.voxelScaleEdit.Value=2;
mode='pause';pauseSent=false;sawPaused=false;resumeSent=false;stopSent=false;pauseStarted=[];pausedCount=[];
failure=[];deadline=tic;
watcher=timer('ExecutionMode','fixedSpacing','Period',0.02,'BusyMode','drop','TimerFcn',@observe);
cleanupTimer=onCleanup(@()closeTimer(watcher)); %#ok<NASGU>
start(watcher);press(ui.scalingButton);stop(watcher);
if ~isempty(failure),rethrow(failure);end
disp(strjoin(ui.statusText.Value,sprintf('\n')));
assert(pauseSent && sawPaused && resumeSent,'Pause/resume did not reach the first run volume loop.');
assert(~ui.runControl.Active && countScaled(pauseWork)==3);
assert(strcmp(ui.scalingButton.Enable,'on') && strcmp(ui.pauseButton.Enable,'off'));
assert(~isempty(strfind(strjoin(ui.statusText.Value,sprintf('\n')),'Resumed processing.'))); %#ok<STREMP>
% Stop during the first run must discard its partial image,
% restore controls, and allow a subsequent run without restarting MATLAB.
mode='stop';deadline=tic;fig.UserData.bidsPath=stopWork;ui.statusText.Value={''};
ui.stagesEdit.Value='1,8';start(watcher);
press(ui.runStepsButton);stop(watcher);
if ~isempty(failure),rethrow(failure);end
assert(stopSent && ~ui.runControl.Active && countScaled(stopWork)==0);
log=strjoin(ui.statusText.Value,sprintf('\n'));
assert(~isempty(strfind(log,'Stopped by user.'))); %#ok<STREMP>
assert(isempty(strfind(log,'=== Starting Step 8 ===')) && isempty(strfind(log,'All selected steps completed!'))); %#ok<STREMP>
assert(strcmp(ui.runStepsButton.Enable,'on') && isvalid(fig));
mode='idle';press(ui.scalingButton);
assert(countScaled(stopWork)==3 && ~ui.runControl.Active);
result=struct('status','passed','syntheticDirectory',work);disp(result);
disp('MIKEY_RUN_CONTROLS_PASS');

    function press(button, fromObserver)
        if nargin<2,fromObserver=false;end
        % UITest gestures cannot be nested inside an HG/timer callback.
        if useUIEvents && ~fromObserver
            driver.press(button);
        else
            button.ButtonPushedFcn(button,[]);
        end
    end

    function observe(~,~)
        try
        if ~isvalid(fig) || ~ui.runControl.Active,return;end
        if toc(deadline)>60,error('MIKey:Test','Timed out waiting for GUI run controls.');end
        logText=strjoin(ui.statusText.Value,sprintf('\n'));
        if strcmp(mode,'pause')
            if ~pauseSent && ~isempty(strfind(logText,'Scaling BOLD volume 1 of')) %#ok<STREMP>
                pauseSent=true;press(ui.pauseButton,true);
                assert(strcmp(ui.scalingButton.Enable,'off'));
            elseif ui.runControl.Paused && ~resumeSent
                sawPaused=true;
                if isempty(pauseStarted),pauseStarted=tic;pausedCount=countScaled(pauseWork);end
                assert(countScaled(pauseWork)==pausedCount,'Outputs changed while paused.');
                if toc(pauseStarted)>0.2
                    resumeSent=true;press(ui.resumeButton,true);
                end
            end
        elseif strcmp(mode,'stop') && ~stopSent && ~isempty(strfind(logText,'Scaling BOLD volume 1 of')) %#ok<STREMP>
            stopSent=true;press(ui.stopButton,true);
        end
        catch ME
            failure=ME;ui.runControl.requestStop();
        end
    end
end

function closeTimer(watcher)
if isvalid(watcher),stop(watcher);delete(watcher);end
end

function count=countScaled(work)
count=numel(dir(fullfile(work,'derivatives','MIKey','sub-01','func','*_desc-scaled_bold.nii')));
end

function prepare(work)
func=fullfile(work,'sub-01','func');mkdir(func);rng(18);
for run=1:3
    path=fullfile(func,sprintf('sub-01_task-rest_run-%02d_bold.nii',run));
    data=100+randn(5,6,4,8);
    for i=1:8
        v=struct('fname',path,'dim',[5 6 4],'dt',[16 0],'mat',diag([0.2 0.2 0.2 1]), ...
            'pinfo',[1;0;0],'n',[i 1],'descrip','MIKey GUI control synthetic test');
        spm_write_vol(v,data(:,:,:,i));
    end
end
end

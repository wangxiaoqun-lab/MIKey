% General headless entry: edit cfg fields below, then run this script.
% First use cfg.steps = 1; prepare masks externally; then use cfg.steps = 2:10.
toolboxRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(toolboxRoot, '-begin');

% Optional saved GUI configuration. Set configFile = '' to start from defaults.
configFile = fullfile(toolboxRoot, 'MIKey_BIDS_config.mat');
if isempty(configFile)
    cfg = MIKey_defaults();
else
    cfg = MIKey_config(configFile);
end

% ----------------------- EDIT PARAMETERS HERE ---------------------------
cfg.bidsPath = '/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main/BIDS_demo';
cfg.spmPath = ''; % Set '/absolute/server/path/spm12', or use SPM already on path.
cfg.codePath = fullfile(toolboxRoot, 'scripts');
cfg.templatePath = fullfile(toolboxRoot, 'share_temp');
cfg.subjectFilter = 'sub-002'; % Any subject ID/pattern, e.g. 'sub-003' or 'sub-*'.
cfg.sessionFilter = '*';
cfg.taskFilter = '*';
cfg.runFilter = '*';
cfg.steps = 1; % Run alone. After preparing masks, change this to 2:10.
cfg.minTimepoints = 100;
cfg.voxelScaleFactor = 20;
cfg.sliceTimingTR = 1;
cfg.sliceTimingNSlices = 28;
cfg.sliceTimingOrder = 'Auto-detect';
cfg.smoothFWHM = [6 6 6];
cfg.coregInterp = 2;
cfg.normInterp = 2;
cfg.useDefaultTemplate = true;
cfg.customTemplatePath = ''; % Used for Step 7 when useDefaultTemplate=false.
cfg.useDefaultPCStrategy = true;
cfg.customPCCounts = [0 5 10 20]; % Used when useDefaultPCStrategy=false.
cfg.dryRun = false; % true checks configuration/dependencies without processing.
cfg.failFast = true;
cfg.strictWarnings = true;
cfg.logDir = ''; % Default: BIDS/derivatives/MIKey/logs, unique folder per run.
% Other GUI parameters remain in cfg from configFile or MIKey_defaults().
% Add further cfg.<parameter> assignments here as needed.
% ------------------------------------------------------------------------

cfg = MIKey_config(cfg);
if ismember(1, cfg.steps) && numel(cfg.steps) > 1
    error('MIKey:MaskPreparationRequired', ...
        'Run Step 1 alone, prepare the functional/anatomical masks on scaled images, then edit cfg.steps and rerun.');
end
if isempty(cfg.spmPath)
    spmEntry = which('spm');
    if isempty(spmEntry)
        error('MIKey:MissingSPM', 'Set cfg.spmPath to the server SPM12 root in the parameter block.');
    end
    cfg.spmPath = fileparts(spmEntry);
end
fprintf('Subject: %s; steps: %s; minTimepoints: %d\n', ...
    cfg.subjectFilter, mat2str(cfg.steps), cfg.minTimepoints);
report = MIKey_run(cfg);
if isequal(cfg.steps, 1) && ~cfg.dryRun
    fprintf('Step 1 finished. Prepare the selected subjects'' masks before running subsequent steps.\n');
end
if isfield(report, 'runDirectory')
    fprintf('Run report and log: %s\n', report.runDirectory);
end

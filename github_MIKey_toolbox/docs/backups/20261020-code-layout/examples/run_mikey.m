function report = run_mikey(configFile)
% General headless entry: default config or one GUI-exported .m function.
% run_mikey() / run_mikey('/absolute/path/to/mikey_config_gui.m')
% Run Step 1, prepare masks externally, then change cfg.steps to 2:10 there.
toolboxRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(toolboxRoot, '-begin');
addpath(fullfile(toolboxRoot, 'examples'), '-begin');
if nargin == 0 || isempty(configFile)
    configFile = fullfile(toolboxRoot, 'examples', 'mikey_config_example.m');
end
if ~(ischar(configFile) && isrow(configFile) || isstring(configFile) && isscalar(configFile))
    error('MIKey:ConfigFile','Specify one configuration .m filename.');
end
configFile = MIKey_resolve_config_path(configFile, toolboxRoot);
fprintf('Configuration source: %s\n', configFile);
cfg = MIKey_load_config_function(configFile);

selection = MIKey_config(struct('steps', cfg.steps));
if ismember(1, selection.steps) && numel(selection.steps) > 1
    error('MIKey:MaskPreparationRequired', ...
        'Run Step 1 alone, prepare the functional/anatomical masks on scaled images, then edit cfg.steps and rerun.');
end
cfg = MIKey_config(cfg);
if isempty(cfg.spmPath)
    spmEntry = which('spm');
    if isempty(spmEntry)
        error('MIKey:MissingSPM', 'Set cfg.spmPath to the server SPM12 root in the selected configuration file.');
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
end

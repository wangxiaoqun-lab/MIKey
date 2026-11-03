% General headless entry. Edit parameters only in mikey_config_example.m.
% Run Step 1, prepare masks externally, then change cfg.steps to 2:10 there.
toolboxRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(toolboxRoot, '-begin');
addpath(fullfile(toolboxRoot, 'examples'), '-begin');
cfg = mikey_config_example();

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

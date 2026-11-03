function report = MIKey_run(input)
%MIKEY_RUN Execute selected GUI stages without creating a user interface.
% report = MIKey_run(configStruct | 'config.mat' | 'config.json')
cfg = MIKey_config(input);
oldPath = path;
oldDirectory = pwd;
oldVisible = get(groot, 'DefaultFigureVisible');
oldFigures = findall(groot, 'Type', 'figure');
cleanup = onCleanup(@() restoreSession(oldPath, oldDirectory, oldVisible, oldFigures)); %#ok<NASGU>
set(groot, 'DefaultFigureVisible', 'off');
environment = MIKey_setup(cfg.spmPath, cfg.codePath);
preflight = MIKey_preflight(cfg);
if cfg.dryRun
    report = struct('status', 'preflight', 'config', cfg, ...
        'environment', environment, 'preflight', preflight);
    disp(preflight);
    for i = 1:numel(preflight.issues), fprintf(2, '%s\n', preflight.issues{i}); end
    if ~preflight.ok
        error('MIKey:Preflight', 'Preflight failed with %d issue(s).', numel(preflight.issues));
    end
    return;
end
if isempty(cfg.logDir)
    cfg.logDir = fullfile(cfg.bidsPath, 'derivatives', 'MIKey', 'logs');
end
if ~exist(cfg.logDir, 'dir')
    [ok, message] = mkdir(cfg.logDir);
    if ~ok, error('MIKey:LogPath', '%s', message); end
end
% tempname avoids collisions between cluster tasks started in the same second.
runDirectory = tempname(cfg.logDir);
mkdir(runDirectory);
config = cfg; %#ok<NASGU>
save(fullfile(runDirectory, 'config.mat'), 'config', 'environment', 'preflight');
logPath = fullfile(runDirectory, 'run.log');
fid = fopen(logPath, 'w');
if fid < 0, error('MIKey:LogPath', 'Cannot write %s', logPath); end
logCleanup = onCleanup(@() fclose(fid)); %#ok<NASGU>
state = MIKeyBatchState(cfg, fid);
report = struct('status', 'running', 'started', datestr(now, 30), ...
    'config', cfg, 'environment', environment, 'preflight', preflight, ...
    'runDirectory', runDirectory, 'stages', [], 'warnings', {{}});
state.log(['Run directory: ' runDirectory]);
if ~preflight.ok
    report.status = 'failed';
    report.issues = preflight.issues;
    save(fullfile(runDirectory, 'report.mat'), 'report');
    for i = 1:numel(preflight.issues), fprintf(fid, '%s\n', preflight.issues{i}); end
    error('MIKey:Preflight', '%s', strjoin(preflight.issues, sprintf('\n')));
end
for step = cfg.steps
    stage = struct('step', step, 'status', 'running', 'seconds', 0, ...
        'identifier', '', 'error', '');
    timer = tic;
    state.Activity = 0;
    state.log(sprintf('=== Starting Step %d ===', step));
    try
        if cfg.strictWarnings
            MIKey_check_stage(cfg, step);
        end
        MIKey('batch', state, step);
        if state.Activity == 0
            error('MIKey:NoWork', 'Step %d produced/skipped no known outputs. Check prerequisites in run.log.', step);
        end
        stage.status = 'completed';
    catch ME
        stage.status = 'failed';
        stage.identifier = ME.identifier;
        stage.error = getReport(ME, 'extended', 'hyperlinks', 'off');
        fprintf(fid, '%s\n', stage.error);
        fprintf(2, '%s\n', stage.error);
    end
    stage.seconds = toc(timer);
    report.stages = [report.stages stage];
    report.warnings = state.Warnings;
    save(fullfile(runDirectory, 'report.mat'), 'report');
    state.log(sprintf('=== Step %d: %s (%.2f s) ===', step, stage.status, stage.seconds));
    if strcmp(stage.status, 'failed') && (cfg.failFast || ismember(step, [6 7]) || strncmp(stage.identifier, 'MIKey:Registration', 18))
        break;
    end
end
report.finished = datestr(now, 30);
if any(strcmp({report.stages.status}, 'failed'))
    report.status = 'failed';
else
    report.status = 'completed';
end
save(fullfile(runDirectory, 'report.mat'), 'report');
if strcmp(report.status, 'failed')
    error('MIKey:RunFailed', 'Run failed; full error, effective config and stage results: %s', runDirectory);
end
state.log('All selected steps completed.');
end

function restoreSession(oldPath, oldDirectory, oldVisible, oldFigures)
newFigures = findall(groot, 'Type', 'figure');
newFigures = newFigures(~ismember(newFigures, oldFigures));
delete(newFigures);
set(groot, 'DefaultFigureVisible', oldVisible);
cd(oldDirectory);
path(oldPath);
end

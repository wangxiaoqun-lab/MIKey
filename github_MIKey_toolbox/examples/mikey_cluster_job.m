% Noninteractive cluster entry. All paths are read from environment variables.
root = getenv('MIKEY_ROOT');
configFile = getenv('MIKEY_CONFIG');
if isempty(root) || isempty(configFile)
    error('MIKey:ClusterEnvironment', 'Set MIKEY_ROOT and MIKEY_CONFIG to absolute paths.');
end
addpath(fullfile(root,'scripts'),'-begin');MIKey_paths();
cfg = MIKey_config(configFile);
subject = getenv('MIKEY_SUBJECT');
steps = getenv('MIKEY_STEPS');
if ~isempty(subject), cfg.subjectFilter = subject; end
if ~isempty(steps), cfg.steps = steps; end
overrides = {'MIKEY_SESSION','sessionFilter'; 'MIKEY_TASK','taskFilter'; 'MIKEY_RUN','runFilter'};
for i = 1:size(overrides,1)
    value = getenv(overrides{i,1});
    if ~isempty(value), cfg.(overrides{i,2}) = value; end
end
minimum = getenv('MIKEY_MIN_TIMEPOINTS');
if ~isempty(minimum), cfg.minTimepoints = str2double(minimum); end
report = MIKey_run(cfg); %#ok<NASGU>

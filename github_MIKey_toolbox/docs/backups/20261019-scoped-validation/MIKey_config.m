function cfg = MIKey_config(input)
%MIKEY_CONFIG Merge/validate struct, saved GUI MAT, or JSON config.
if nargin == 0
    input = struct();
end
if ischar(input) || (isstring(input) && isscalar(input))
    filename = char(input);
    [~, ~, ext] = fileparts(filename);
    if strcmpi(ext, '.mat')
        input = load(filename);
        if isfield(input, 'config')
            input = input.config;
        end
    elseif strcmpi(ext, '.json')
        input = jsondecode(fileread(filename));
    else
        error('MIKey:ConfigFile', 'Use a .mat or .json configuration file.');
    end
end
if ~isstruct(input) || ~isscalar(input)
    error('MIKey:ConfigType', 'Configuration must be a scalar struct.');
end
% Legacy GUI saved these nonexistent controls; preserve filter settings.
legacy = {'bandpassLow', 'bandpassHigh'};
replacement = {'lowFreq', 'highFreq'};
for i = 1:numel(legacy)
    if isfield(input, legacy{i})
        if ~isfield(input, replacement{i})
            input.(replacement{i}) = input.(legacy{i});
        end
        input = rmfield(input, legacy{i});
    end
end
cfg = MIKey_defaults();
names = fieldnames(input);
for i = 1:numel(names)
    if ~isfield(cfg, names{i})
        error('MIKey:UnknownParameter', 'Unknown parameter: %s', names{i});
    end
    cfg.(names{i}) = input.(names{i});
end
textFields = {'bidsPath', 'spmPath', 'templatePath', 'codePath', ...
    'subjectFilter', 'sessionFilter', 'taskFilter', 'runFilter', ...
    'sliceTimingOrder', 'customTemplatePath', ...
    'fcLabel', 'fcCustomPath', 'parcNetwork', 'networkCustomPath', ...
    'labelCustomPath', 'groupNetworkPath', 'parcellationMode', 'logDir'};
for i = 1:numel(textFields)
    name = textFields{i};
    if isstring(cfg.(name)) && isscalar(cfg.(name))
        cfg.(name) = char(cfg.(name));
    end
    if ~ischar(cfg.(name)) || size(cfg.(name), 1) > 1
        error('MIKey:Parameter', '%s must be a character vector.', name);
    end
end
paths = {'bidsPath', 'spmPath', 'templatePath', 'codePath', ...
    'customTemplatePath', 'fcCustomPath', 'networkCustomPath', ...
    'labelCustomPath', 'groupNetworkPath', 'logDir'};
for i = 1:numel(paths)
    name = paths{i};
    value = cfg.(name);
    if ~isempty(value) && isempty(regexp(value, '^(/|[A-Za-z]:[\\/]|\\\\)', 'once'))
        cfg.(name) = fullfile(pwd, value);
    end
end
if isempty(regexp(cfg.subjectFilter, '^sub-[^/\\]+$', 'once'))
    error('MIKey:Parameter', 'subjectFilter must be a sub-* name/pattern without directory separators.');
end
cfg.steps = parseSteps(cfg.steps);
for name = {'sessionFilter','taskFilter','runFilter'}
    value = strrep(cfg.(name{1}), ' ', '');
    if isempty(regexp(value, '^[A-Za-z0-9*?\-]+(,[A-Za-z0-9*?\-]+)*$', 'once'))
        error('MIKey:Parameter', '%s requires an entity value/pattern or comma-separated values; use * for all, none for absent.', name{1});
    end
    cfg.(name{1}) = value;
end
cfg.smoothFWHM = numericList(cfg.smoothFWHM, 'smoothFWHM');
if isscalar(cfg.smoothFWHM)
    cfg.smoothFWHM = repmat(cfg.smoothFWHM, 1, 3);
end
if numel(cfg.smoothFWHM) ~= 3 || any(cfg.smoothFWHM < 0)
    error('MIKey:Parameter', 'smoothFWHM requires one or three nonnegative values.');
end
cfg.clustROINums = numericList(cfg.clustROINums, 'clustROINums');
flags = {'useDefaultTemplate', 'useDefaultPCStrategy', 'detrendFlag', 'filterFlag', ...
    'advRegressionPCOnly', 'advRegressionPCCSF', 'advRegressionPCGS', ...
    'advRegressionPCCSFGS', 'useCustomParc', 'useTSNR', ...
    'useInterSubjectVar', 'parcellationUseParallel', 'dryRun', 'failFast', 'strictWarnings'};
for i = 1:numel(flags)
    value = cfg.(flags{i});
    if ~(islogical(value) || isnumeric(value)) || ~isscalar(value) || ~ismember(value, [0 1])
        error('MIKey:Parameter', '%s must be true or false.', flags{i});
    end
    cfg.(flags{i}) = logical(value);
end
if islogical(cfg.customPCCounts)
    error('MIKey:Parameter', ['customPCCounts is a PC-count list, not a true/false switch. ' ...
        'For the default strategy set useDefaultPCStrategy=true and customPCCounts=[]; ' ...
        'for custom candidates set useDefaultPCStrategy=false and customPCCounts=[0 5 10 20].']);
end
if cfg.useDefaultPCStrategy && emptyPCList(cfg.customPCCounts)
    cfg.customPCCounts = []; % Unused custom candidates may be blank in default mode.
else
    cfg.customPCCounts = numericList(cfg.customPCCounts, 'customPCCounts');
end
if any(cfg.customPCCounts < 0 | cfg.customPCCounts ~= fix(cfg.customPCCounts)) || numel(unique(cfg.customPCCounts)) ~= numel(cfg.customPCCounts)
    error('MIKey:Parameter', 'customPCCounts must contain distinct nonnegative integers.');
end
cfg.customPCCounts = sort(cfg.customPCCounts);
if any(cfg.clustROINums < 1 | cfg.clustROINums ~= fix(cfg.clustROINums))
    error('MIKey:Parameter', 'clustROINums must contain positive integers.');
end
positive = {'voxelScaleFactor', 'sliceTimingTR', 'sliceTimingNSlices', ...
    'voxelDownsampleFactor', 'maxIter', 'confThr'};
nonnegative = {'changeThr', 'lowFreq', 'highFreq', 'minTimepoints'};
for i = 1:numel(positive)
    checkScalar(cfg.(positive{i}), positive{i}, true);
end
for i = 1:numel(nonnegative)
    checkScalar(cfg.(nonnegative{i}), nonnegative{i}, false);
end
integers = {'sliceTimingNSlices', 'voxelDownsampleFactor', 'maxIter', ...
    'coregInterp', 'normInterp', 'minTimepoints'};
for i = 1:numel(integers)
    name = integers{i};
    checkScalar(cfg.(name), name, false);
    if cfg.(name) ~= fix(cfg.(name))
        error('MIKey:Parameter', '%s must be an integer.', name);
    end
end
if cfg.coregInterp > 7 || cfg.normInterp > 7
    error('MIKey:Parameter', 'Interpolation must be an integer from 0 to 7.');
end
checkScalar(cfg.percentTop, 'percentTop', true);
if cfg.percentTop > 1
    error('MIKey:Parameter', 'percentTop must be in (0, 1].');
end
if cfg.filterFlag && (cfg.lowFreq >= cfg.highFreq || cfg.highFreq >= 1/(2*cfg.sliceTimingTR))
    error('MIKey:Parameter', 'Require 0 <= lowFreq < highFreq < 1/(2*sliceTimingTR). Check each run''s actual TR too.');
end
% Unselected stages must not be blocked by unused choice values. Keep values
% unchanged so selecting those stages later still triggers their validation.
if ismember(4, cfg.steps)
    choices(cfg.sliceTimingOrder, {'Auto-detect','ascending','descending','interleaved'}, 'sliceTimingOrder (Step 4)');
end
if ismember(13, cfg.steps)
    choices(cfg.fcLabel, {'214','428','604','1184','Custom...'}, 'fcLabel (Step 13)');
end
if any(ismember(cfg.steps, 14:16))
    choices(cfg.parcNetwork, {'214rois','428rois','604rois','1184rois'}, 'parcNetwork (Steps 14-16)');
    choices(cfg.parcellationMode, {'individual','concatenated'}, 'parcellationMode (Steps 14-16)');
end
if any(ismember(cfg.steps, 12:16)) && ~any([cfg.advRegressionPCOnly cfg.advRegressionPCCSF cfg.advRegressionPCGS cfg.advRegressionPCCSFGS])
    error('MIKey:Parameter', 'Select at least one advanced regression strategy for steps 12-16.');
end
end

function empty = emptyPCList(value)
empty = isnumeric(value) && isempty(value);
if ischar(value) || (isstring(value) && isscalar(value))
    empty = isempty(strtrim(char(value)));
end
end

function values = numericList(value, name)
if ischar(value) || (isstring(value) && isscalar(value))
    tokens = regexp(strtrim(char(value)), '[,\s]+', 'split');
    value = cellfun(@str2double, tokens);
end
if ~isnumeric(value) || ~isreal(value) || ~isvector(value) || isempty(value) || any(~isfinite(value))
    error('MIKey:Parameter', '%s must be a finite numeric vector.', name);
end
values = double(value(:)');
end

function steps = parseSteps(value)
if ischar(value) || (isstring(value) && isscalar(value))
    tokens = strsplit(strrep(char(value), ' ', ''), ',');
    value = [];
    for i = 1:numel(tokens)
        if isempty(regexp(tokens{i}, '^\d+(:\d+)?$', 'once'))
            error('MIKey:Steps', 'Use a numeric vector or a string such as 1,2,5:8.');
        end
        bounds = cellfun(@str2double, strsplit(tokens{i}, ':'));
        if any(bounds < 1 | bounds > 17) || (numel(bounds) == 2 && bounds(1) > bounds(2))
            error('MIKey:Steps', 'Step ranges must ascend within 1-17.');
        end
        value = [value bounds(1):bounds(end)]; %#ok<AGROW>
    end
end
steps = numericList(value, 'steps');
if any(steps < 1 | steps > 17 | steps ~= fix(steps)) || numel(unique(steps)) ~= numel(steps)
    error('MIKey:Steps', 'Select distinct integer steps in 1-17; order is preserved.');
end
end

function checkScalar(value, name, positive)
if ~isnumeric(value) || ~isreal(value) || ~isscalar(value) || ~isfinite(value) || value < 0 || (positive && value == 0)
    error('MIKey:Parameter', '%s requires a finite %s scalar.', name, 'nonnegative/positive');
end
end

function choices(value, allowed, name)
if ~any(strcmp(value, allowed))
    error('MIKey:Parameter', '%s must be one of: %s', name, strjoin(allowed, ', '));
end
end

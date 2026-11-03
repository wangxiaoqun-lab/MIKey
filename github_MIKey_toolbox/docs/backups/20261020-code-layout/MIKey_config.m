function [cfg, active] = MIKey_config(input)
%MIKEY_CONFIG Merge/validate a struct, .m configuration function, MAT or JSON.
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
    elseif strcmpi(ext, '.m')
        input = MIKey_load_config_function(filename);
    else
        error('MIKey:ConfigFile', 'Use a .m configuration function, .mat or .json configuration file.');
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
% Determine usage before touching stage-specific values. Inactive values
% are preserved, including []/false/text from saved configurations.
cfg.steps = parseSteps(cfg.steps);
active = MIKey_parameter_scope(cfg);
valid = active;
issues = {};
flags = {'useDefaultTemplate','useDefaultPCStrategy','detrendFlag','filterFlag', ...
    'advRegressionPCOnly','advRegressionPCCSF','advRegressionPCGS', ...
    'advRegressionPCCSFGS','useCustomParc','useTSNR','useInterSubjectVar', ...
    'parcellationUseParallel','dryRun','failFast','strictWarnings'};
for i=1:numel(flags)
    name=flags{i};if ~active.(name),continue;end
    value=cfg.(name);
    if ~(islogical(value) || isnumeric(value)) || ~isreal(value) || ...
            ~isscalar(value) || ~isfinite(value) || ~ismember(value,[0 1])
        issues{end+1}=[name ' must be true or false.'];valid.(name)=false; %#ok<AGROW>
    else
        cfg.(name)=logical(value);
    end
end
textFields = {'bidsPath','spmPath','templatePath','codePath','subjectFilter', ...
    'sessionFilter','taskFilter','runFilter','sliceTimingOrder','customTemplatePath', ...
    'fcLabel','fcCustomPath','parcNetwork','networkCustomPath','labelCustomPath', ...
    'groupNetworkPath','parcellationMode','logDir','fdMethod'};
paths = {'bidsPath','spmPath','templatePath','codePath','customTemplatePath', ...
    'fcCustomPath','networkCustomPath','labelCustomPath','groupNetworkPath','logDir'};
for i=1:numel(textFields)
    name=textFields{i};if ~active.(name),continue;end
    value=cfg.(name);
    if isstring(value) && isscalar(value),value=char(value);end
    if ~ischar(value) || size(value,1)>1
        issues{end+1}=[name ' must be a character vector.'];valid.(name)=false; %#ok<AGROW>
        continue;
    end
    if ismember(name,paths) && ~isempty(value) && isempty(regexp(value,'^(/|[A-Za-z]:[\\/]|\\\\)','once'))
        value=fullfile(pwd,value);
    end
    cfg.(name)=value;
end
if valid.subjectFilter
    tokens=strtrim(strsplit(cfg.subjectFilter,',','CollapseDelimiters',false));
    if any(cellfun(@(token) isempty(regexp(token,'^sub-[^/\\,\s]+$','once')),tokens))
        issues{end+1}='subjectFilter requires sub-* names/patterns separated by commas, without empty entries or directory separators.';
        valid.subjectFilter=false;
    else
        cfg.subjectFilter=strjoin(tokens,',');
    end
end
for names={'sessionFilter','taskFilter','runFilter'}
    name=names{1};if ~valid.(name),continue;end
    value=strrep(cfg.(name),' ','');
    if isempty(regexp(value,'^[A-Za-z0-9*?\-]+(,[A-Za-z0-9*?\-]+)*$','once'))
        issues{end+1}=[name ' requires an entity pattern or comma-separated values; use * for all, none for absent.']; %#ok<AGROW>
        valid.(name)=false;
    else,cfg.(name)=value;
    end
end
lists={'smoothFWHM','clustROINums','customPCCounts'};
for i=1:numel(lists)
    name=lists{i};if ~active.(name),continue;end
    try
        if strcmp(name,'customPCCounts') && islogical(cfg.(name))
            error('MIKey:Parameter','customPCCounts is a PC-count list, not a true/false switch. Use a numeric list such as [0 5 10 20].');
        end
        value=numericList(cfg.(name),name);
        switch name
            case 'smoothFWHM'
                if isscalar(value),value=repmat(value,1,3);end
                if numel(value)~=3 || any(value<0)
                    error('MIKey:Parameter','smoothFWHM requires one or three nonnegative values.');
                end
            case 'clustROINums'
                if any(value<1 | value~=fix(value))
                    error('MIKey:Parameter','clustROINums must contain positive integers.');
                end
            case 'customPCCounts'
                if any(value<0 | value~=fix(value)) || numel(unique(value))~=numel(value)
                    error('MIKey:Parameter','customPCCounts must contain distinct nonnegative integers.');
                end
                value=sort(value);
        end
        cfg.(name)=value;
    catch ME
        issues{end+1}=ME.message;valid.(name)=false; %#ok<AGROW>
    end
end
positive={'voxelScaleFactor','sliceTimingTR','sliceTimingNSlices', ...
    'voxelDownsampleFactor','maxIter','confThr','percentTop','fdRadius'};
nonnegative={'changeThr','lowFreq','highFreq','minTimepoints','coregInterp','normInterp'};
integers={'sliceTimingNSlices','voxelDownsampleFactor','maxIter','coregInterp','normInterp','minTimepoints'};
for names=[positive nonnegative]
    name=names{1};if ~active.(name),continue;end
    try
        checkScalar(cfg.(name),name,ismember(name,positive));
        value=double(cfg.(name));
        if ismember(name,integers) && value~=fix(value)
            error('MIKey:Parameter','%s must be an integer.',name);
        end
        if ismember(name,{'coregInterp','normInterp'}) && value>7
            error('MIKey:Parameter','%s interpolation must be an integer from 0 to 7.',name);
        end
        if strcmp(name,'percentTop') && value>1
            error('MIKey:Parameter','percentTop must be in (0, 1].');
        end
        cfg.(name)=value;
    catch ME
        issues{end+1}=ME.message;valid.(name)=false; %#ok<AGROW>
    end
end
atlases=MIKey_atlas_catalog();
options={ ...
    'sliceTimingOrder',{'Auto-detect','ascending','descending','interleaved'}; ...
    'fcLabel',[{atlases.label} {'Custom...'}]; ...
    'parcNetwork',{atlases.parcellation}; ...
    'parcellationMode',{'individual','concatenated'}; ...
    'fdMethod',{'power','euclidean'}};
for i=1:size(options,1)
    name=options{i,1};if ~active.(name) || ~valid.(name),continue;end
    try,choices(cfg.(name),options{i,2},name);
    catch ME,issues{end+1}=ME.message;valid.(name)=false;end %#ok<AGROW>
end
if active.highFreq && valid.lowFreq && valid.highFreq && valid.sliceTimingTR && ...
        (cfg.lowFreq>=cfg.highFreq || cfg.highFreq>=1/(2*cfg.sliceTimingTR))
    issues{end+1}='Require 0 <= lowFreq < highFreq < 1/(2*sliceTimingTR) for Step 12 filtering. Check each run''s actual TR too.';
end
strategy={'advRegressionPCOnly','advRegressionPCCSF','advRegressionPCGS','advRegressionPCCSFGS'};
if active.advRegressionPCOnly && all(cellfun(@(n)valid.(n),strategy)) && ...
        ~any(cellfun(@(n)cfg.(n),strategy))
    issues{end+1}='Select at least one advanced regression strategy for steps 12-16.';
end
if ~isempty(issues)
    error('MIKey:Parameter','Invalid parameters for selected steps %s:\n - %s', ...
        mat2str(cfg.steps),strjoin(issues,sprintf('\n - ')));
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

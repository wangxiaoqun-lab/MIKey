function [counts, correlations, fd_info] = MIKey_noise_result(filename)
% Explicit candidate metadata for new files; numbered corr fields for legacy.
results = load(filename);
fd_info=[];
if isfield(results,'fd_info')
    fd_info=results.fd_info;
    if ~isstruct(fd_info) || ~isscalar(fd_info) || ...
            ~isfield(fd_info,'method') || ~isfield(fd_info,'rotationRadius')
        error('MIKey:StrategyResults','Invalid FD metadata in %s; recompute Step 10.',filename);
    end
    [~,expected]=MIKey_framewise_displacement(zeros(3,6),fd_info.method,fd_info.rotationRadius);
    if ~isequal(fd_info,expected)
        error('MIKey:StrategyResults','Unsupported FD definition in %s; recompute Step 10.',filename);
    end
end
fields = fieldnames(results);
indices = [];
for i = 1:numel(fields)
    token = regexp(fields{i},'^corr([1-9]\d*)$','tokens','once');
    if ~isempty(token), indices(end+1) = str2double(token{1}); end %#ok<AGROW>
end
indices = sort(indices);
if isempty(indices) || ~isequal(indices,1:numel(indices)) || ~isfield(results,'corr0')
    error('MIKey:StrategyResults','Missing or noncontiguous correlation fields: %s',filename);
end
if isfield(results,'pc_configs')
    counts = double(results.pc_configs(:)');
else
    counts = 0:20:(numel(indices)-1)*20;
end
if numel(counts) ~= numel(indices) || any(~isfinite(counts) | counts < 0 | counts ~= fix(counts)) || numel(unique(counts)) ~= numel(counts)
    error('MIKey:StrategyResults','PC candidate metadata does not match correlation fields: %s',filename);
end
correlations = zeros(1,numel(counts)+1);
correlations(1) = results.corr0;
for i = 1:numel(counts), correlations(i+1) = results.(['corr' num2str(i)]); end
if any(~isfinite(correlations))
    error('MIKey:StrategyResults','Nonfinite FD-DVARS correlations in %s; check motion/data variance and regression rank.',filename);
end
end

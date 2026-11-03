function counts = MIKey_pc_counts(useDefault, customCounts, timepoints, availablePCs)
% Candidates in ascending PC count; 0 means motion-only (12rp).
if timepoints < 2 || availablePCs < 0
    error('MIKey:PCCounts','Need at least two time points and a valid PC matrix.');
end
maximum = min(timepoints-1,availablePCs);
if useDefault
    counts = 0:20:maximum;
    return;
end
if ischar(customCounts) || (isstring(customCounts) && isscalar(customCounts))
    tokens = regexp(strtrim(char(customCounts)),'[,\s]+','split');
    customCounts = cellfun(@str2double,tokens);
end
if ~isnumeric(customCounts) || ~isreal(customCounts) || ~isvector(customCounts) || isempty(customCounts) || ...
        any(~isfinite(customCounts) | customCounts < 0 | customCounts ~= fix(customCounts)) || ...
        numel(unique(customCounts)) ~= numel(customCounts)
    error('MIKey:PCCounts','Custom PC counts must be distinct nonnegative integers, e.g. 0 5 10 20.');
end
counts = sort(double(customCounts(:)'));
if any(counts > maximum)
    error('MIKey:PCCounts','Requested %d PCs but this run permits at most %d (%d frames, %d available PCs).',max(counts),maximum,timepoints,availablePCs);
end
end

function [best, meanAbsolute, meanSigned] = MIKey_select_noise_strategy(CC)
% Rows are runs, columns are matched strategies; ties retain the first column.
if ~isnumeric(CC) || ~isreal(CC) || ~ismatrix(CC) || isempty(CC) || any(~isfinite(CC(:)))
    error('MIKey:StrategyResults','CC must be a nonempty finite run-by-strategy matrix.');
end
meanAbsolute=mean(abs(CC),1);meanSigned=mean(CC,1);
[~,best]=min(meanAbsolute);
end

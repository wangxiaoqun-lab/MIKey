function CC = MIKey_fd_dvars_correlation(FD, DVARS)
% Pearson correlation on paired frame transitions; frame 1 has no predecessor.
if ~isnumeric(FD) || ~isreal(FD) || ~isvector(FD) || ...
        ~isnumeric(DVARS) || ~isreal(DVARS) || ~isvector(DVARS) || ...
        numel(FD)~=numel(DVARS) || numel(FD)<3 || ...
        any(~isfinite(FD(:))) || any(~isfinite(DVARS(:)))
    error('MIKey:FDCorrelation','FD and DVARS must be finite equal-length vectors with at least 3 frames.');
end
x=double(FD(2:end));y=double(DVARS(2:end));
if max(x)==min(x) || max(y)==min(y)
    error('MIKey:FDCorrelation','FD-DVARS correlation is undefined for a constant transition series; inspect motion/data variance and regression rank.');
end
CC=corr(x(:),y(:),'type','Pearson');
if ~isfinite(CC),error('MIKey:FDCorrelation','Nonfinite Pearson FD-DVARS correlation.');end
end

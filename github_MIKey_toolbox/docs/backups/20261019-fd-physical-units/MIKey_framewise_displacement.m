function [FD, info] = MIKey_framewise_displacement(rp, method, radius)
% Raw SPM motion: translations in image units, rotations in radians.
% Both metrics use backward differences; the first frame has no displacement.
if ~(isnumeric(rp) && isreal(rp) && ismatrix(rp) && size(rp,2)==6 && ...
        size(rp,1)>=3 && all(isfinite(rp(:))))
    error('MIKey:MotionParameters','Motion parameters must be a finite T-by-6 matrix with T >= 3.');
end
if isstring(method) && isscalar(method),method=char(method);end
if ~ischar(method) || ~any(strcmp(method,{'power','euclidean'}))
    error('MIKey:FDMethod','fdMethod must be power or euclidean.');
end
if ~isnumeric(radius) || ~isreal(radius) || ~isscalar(radius) || ~isfinite(radius) || radius<=0
    error('MIKey:FDRadius','fdRadius must be a finite positive radius in the same units as SPM translations.');
end
delta=[zeros(1,6);diff(double(rp),1,1)];
delta(:,4:6)=delta(:,4:6)*double(radius);
if strcmp(method,'power'),FD=sum(abs(delta),2);
else,FD=sqrt(sum(delta.^2,2));end
if any(~isfinite(FD)),error('MIKey:MotionParameters','FD overflow; check motion parameters and fdRadius.');end
info=struct('version',1,'method',method,'rotationRadius',double(radius), ...
    'difference','backward','firstFrame',0,'correlationStartFrame',2, ...
    'rotationInputUnits','radians','spatialUnits','SPM image units');
end

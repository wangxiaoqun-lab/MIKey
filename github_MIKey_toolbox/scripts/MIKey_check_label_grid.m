function MIKey_check_label_grid(header, reference, context)
%MIKEY_CHECK_LABEL_GRID Require the same voxel grid before direct indexing.
if nargin < 3, context = 'Label image'; end
if isempty(reference) || isempty(header)
    error('MIKey:LabelGrid','Missing reference header for %s.',context);
end
reference = reference(1);
for k = 1:numel(header)
    if ~isequal(header(k).dim(1:3),reference.dim(1:3))
        error('MIKey:LabelGrid','Grid size mismatch for %s: image=%s, reference=%s. Reslice labels to the analysis grid using nearest-neighbour interpolation.', ...
            context,mat2str(header(k).dim(1:3)),mat2str(reference.dim(1:3)));
    end
    a = reference.mat; b = header(k).mat;
    if any(~isfinite(a(:))) || any(~isfinite(b(:))) || rcond(a) < eps || rcond(b) < eps
        error('MIKey:LabelGrid','Invalid voxel-to-world affine for %s.',context);
    end
    [x,y,z] = ndgrid([1 reference.dim(1)],[1 reference.dim(2)],[1 reference.dim(3)]);
    corners = [x(:)'; y(:)'; z(:)'; ones(1,numel(x))];
    delta = (a \ b)*corners-corners;
    if max(abs(delta(:))) > 1e-3
        error('MIKey:LabelGrid','Voxel orientation/origin/scale mismatch for %s (%.6g reference voxels). Reslice labels to the analysis grid using nearest-neighbour interpolation.',context,max(abs(delta(:))));
    end
end
end

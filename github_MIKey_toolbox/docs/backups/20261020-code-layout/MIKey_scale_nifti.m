function MIKey_scale_nifti(source, destination, factor, checkpoint, progress)
% Scale voxel geometry one volume at a time; publish only a complete image.
if nargin < 4, checkpoint = @() []; end
if nargin < 5, progress = @(volume,total) []; end
checkpoint();
volumes = spm_vol(source);
spm_check_orientations(volumes);
temporary = [tempname(fileparts(destination)) '.nii'];
cleanup = onCleanup(@() removePartial(temporary)); %#ok<NASGU>
for i = 1:numel(volumes)
    checkpoint();
    data = spm_read_vols(volumes(i));
    checkpoint();
    output = volumes(i);
    output.mat = output.mat * factor;
    output.mat(4,4) = 1;
    output.fname = temporary;
    spm_write_vol(output, data);
    progress(i, numel(volumes));
    checkpoint();
end
% SPM may use a MAT sidecar for distinct per-volume affine matrices.
sidecar = [temporary(1:end-4) '.mat'];
if exist(sidecar, 'file')
    movefile(sidecar, [destination(1:end-4) '.mat'], 'f');
end
movefile(temporary, destination, 'f');
end

function removePartial(temporary)
% Both exact paths belong to this invocation; no directory-wide cleanup.
if exist(temporary, 'file'), delete(temporary); end
sidecar = [temporary(1:end-4) '.mat'];
if exist(sidecar, 'file'), delete(sidecar); end
end

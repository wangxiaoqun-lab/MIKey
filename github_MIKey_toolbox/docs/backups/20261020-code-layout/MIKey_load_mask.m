function [values, source] = MIKey_load_mask(directory, modality, image, sourceDirectory)
% GUI and batch use the same binary-mask and scaled-space validation.
if nargin < 4, sourceDirectory = ''; end
source = MIKey_mask_file(directory,modality,sourceDirectory);
if isempty(source)
    if strcmp(modality,'func'), name = 'boldbrain'; else, name = 'anatbrain'; end
    error('MIKey:Prerequisite','Mask missing: expected *_desc-%s_mask.nii or .nii.gz in %s (legacy *brainmask.nii is also supported).',name,directory);
end
[readable,cleanup] = MIKey_readable_nifti(source); %#ok<ASGLU>
maskHead = spm_vol(readable); imageHead = spm_vol(image);
if numel(maskHead) ~= 1 || ~isequal(maskHead.dim,imageHead(1).dim) || norm(maskHead.mat-imageHead(1).mat,'fro') > 1e-4
    error('MIKey:MaskGeometry','Mask dimensions/affine must match the scaled image. Mask: %s; image: %s.',source,image);
end
values = spm_read_vols(maskHead);
if any(~isfinite(values(:)) | (values(:)~=0 & values(:)~=1)) || ~any(values(:))
    error('MIKey:MaskValues','Brain mask must be nonempty binary 0/1: %s',source);
end
end

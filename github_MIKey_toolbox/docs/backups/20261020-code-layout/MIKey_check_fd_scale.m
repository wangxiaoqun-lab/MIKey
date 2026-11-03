function MIKey_check_fd_scale(scaledImage, voxelScaleFactor)
% Reject a configured scale that contradicts recorded Step 1 provenance.
if ~isnumeric(voxelScaleFactor) || ~isreal(voxelScaleFactor) || ...
        ~isscalar(voxelScaleFactor) || ~isfinite(voxelScaleFactor) || voxelScaleFactor<=0
    error('MIKey:FDScaleFactor','voxelScaleFactor must be the finite positive factor used in Step 1.');
end
sidecar=regexprep(scaledImage,'\.nii(?:\.gz)?$','.json');
if strcmp(sidecar,scaledImage) || ~exist(sidecar,'file'),return;end
try
    metadata=jsondecode(fileread(sidecar));
catch ME
    error('MIKey:FDScaleFactor','Cannot read Step 1 scale metadata %s: %s',sidecar,ME.message);
end
if ~isstruct(metadata) || ~isscalar(metadata)
    error('MIKey:FDScaleFactor','Invalid Step 1 metadata: %s',sidecar);
end
% Older outputs may have no scale metadata; their configured factor is used.
if ~isfield(metadata,'MIKeyVoxelScaleFactor'),return;end
recorded=metadata.MIKeyVoxelScaleFactor;
if ~isnumeric(recorded) || ~isreal(recorded) || ~isscalar(recorded) || ...
        ~isfinite(recorded) || recorded<=0 || recorded~=voxelScaleFactor
    error('MIKey:FDScaleFactor', ...
        'Step 1 scale metadata conflicts with voxelScaleFactor=%g in %s. Set the Scale field / cfg.voxelScaleFactor to the actual Step 1 factor; do not rescale existing images again.',voxelScaleFactor,sidecar);
end
end

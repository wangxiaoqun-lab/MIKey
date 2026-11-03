function [labels, ids, header] = MIKey_read_label(filename, reference)
%MIKEY_READ_LABEL Read categorical ROI/network labels without renumbering IDs.
% Zero is background. Missing, sparse and signed integer IDs are valid.
% Storage may be integer or floating point; voxel values must be integral.
[readable, cleanup] = MIKey_readable_nifti(filename); %#ok<NASGU>
header = spm_vol(readable);
if numel(header) ~= 1
    error('MIKey:LabelVolume','Expected one 3-D label volume: %s',filename);
end
if nargin > 1 && ~isempty(reference)
    MIKey_check_label_grid(header, reference, filename);
end
labels = spm_read_vols(header);
if any(~isfinite(labels(:)))
    error('MIKey:LabelValues','Label image contains NaN/Inf. Use zero for background: %s',filename);
end
if any(labels(:) ~= round(labels(:)))
    error('MIKey:LabelValues','Expected discrete integer ROI/network labels, not intensities or probabilities: %s',filename);
end
ids = unique(labels(labels ~= 0));
if isempty(ids)
    error('MIKey:LabelValues','Label image has no nonzero ROI/network IDs: %s',filename);
end
end

function [timeseries, roi_ids] = MIKey_roi_timeseries(images, labels)
% Rows follow sorted, present nonzero atlas IDs, including signed/sparse IDs.
if ~isequal([size(images,1) size(images,2) size(images,3)], ...
        [size(labels,1) size(labels,2) size(labels,3)])
    error('MIKey:LabelGrid','BOLD and ROI label dimensions differ.');
end
if any(~isfinite(labels(:))) || any(labels(:) ~= round(labels(:)))
    error('MIKey:LabelValues','ROI labels must be finite integer IDs; zero is background.');
end
roi_ids = unique(labels(labels ~= 0));
if isempty(roi_ids), error('MIKey:LabelValues','No nonzero ROI IDs.'); end
flat = reshape(images,[],size(images,4));
timeseries = zeros(numel(roi_ids),size(flat,2));
for k = 1:numel(roi_ids)
    timeseries(k,:) = mean(flat(labels(:) == roi_ids(k),:),1);
end
end

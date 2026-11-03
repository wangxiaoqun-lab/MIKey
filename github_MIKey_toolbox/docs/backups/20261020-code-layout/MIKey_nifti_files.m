function files = MIKey_nifti_files(directory, pattern)
% List .nii and .nii.gz as logical .nii names without touching input files.
% sourceName preserves the filename on disk. Prefer .nii when both exist.
if nargin < 2, pattern = '*.nii'; end
files = dir(fullfile(directory,pattern));
if numel(pattern) >= 4 && strcmp(pattern(end-3:end),'.nii')
    files = [files; dir(fullfile(directory,[pattern '.gz']))];
end
files = files(~[files.isdir]);
for i = 1:numel(files)
    files(i).sourceName = files(i).name;
    if numel(files(i).name) >= 7 && strcmp(files(i).name(end-6:end),'.nii.gz')
        files(i).name = files(i).name(1:end-3);
    end
end
if isempty(files), return; end
[~,keep] = unique({files.name},'stable');
files = files(keep);
[~,order] = sort({files.name}); files = files(order);
end

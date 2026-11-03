function filename = MIKey_mask_file(directory, modality, sourceDirectory)
% Select a modality-specific mask; retain legacy derivative mask names.
if nargin < 3, sourceDirectory = ''; end
switch modality
    case 'func', pattern = '*_desc-boldbrain_mask.nii';
    case 'anat', pattern = '*_desc-anatbrain_mask.nii';
    otherwise, error('MIKey:MaskModality','Unsupported mask modality: %s',modality);
end
directories = {directory};
if ~isempty(sourceDirectory), directories{end+1} = sourceDirectory; end
for i = 1:numel(directories)
    matches = MIKey_nifti_files(directories{i},pattern);
    if ~isempty(matches)
        filename = select(matches,directories{i},pattern); return;
    end
end
matches = MIKey_nifti_files(directory,'*brainmask.nii');
filename = '';
if ~isempty(matches), filename = select(matches,directory,'*brainmask.nii'); end
end

function filename = select(matches,directory,pattern)
if numel(matches) ~= 1
    error('MIKey:MaskSelection','Expected one %s[.gz] in %s; found %d. Remove ambiguity before processing.',pattern,directory,numel(matches));
end
filename = fullfile(matches(1).folder,matches(1).sourceName);
end

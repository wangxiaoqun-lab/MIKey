function files=MIKey_fmap_files(directory,component)
files=dir(fullfile(directory,['sub*_desc-scaled_' component '.nii']));
if isempty(files),files=dir(fullfile(directory,['sub*' component '_desc-scaled.nii']));end
end

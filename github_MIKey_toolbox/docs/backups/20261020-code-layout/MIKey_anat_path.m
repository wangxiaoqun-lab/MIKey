function directory = MIKey_anat_path(scopePath)
% A session without T2w may reuse the subject-level anatomical acquisition.
directory = fullfile(scopePath,'anat');
[parent,name] = fileparts(scopePath);
if strncmp(name,'ses-',4) && isempty(MIKey_nifti_files(directory,'*_T2w.nii'))
    shared = fullfile(parent,'anat');
    if ~isempty(MIKey_nifti_files(shared,'*_T2w.nii')), directory = shared; end
end
end

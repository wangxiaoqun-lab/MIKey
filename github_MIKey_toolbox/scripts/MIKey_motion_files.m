function files=MIKey_motion_files(directory,base)
% SPM motion filenames follow the exact input basename, which may be canonical.
for descriptor={'slicetimed','fieldmap','masked'}
    name=MIKey_bids_name([base '_desc-' descriptor{1} '.nii']);
    files=dir(fullfile(directory,['rp_' name(1:end-4) '.txt']));
    if ~isempty(files),return;end
end
files=dir(fullfile(directory,['rp_' base '*']));
end

function path = MIKey_bids_path(directory, name, mode)
% New outputs use canonical names; input reads can fall back to old MIKey names.
if nargin<3,mode='output';end
canonical=MIKey_bids_name(name);
targetDirectory=directory;
if ~isempty(regexp(name,'_desc-T2(?:coreg|normalized)\.nii$','once'))
    [parent,modality]=fileparts(directory);
    if strcmp(modality,'func'),targetDirectory=fullfile(parent,'anat');end
end
path=fullfile(targetDirectory,canonical);
if strcmp(mode,'input') && ~exist(path,'file')
    legacy=fullfile(directory,name);
    if exist(legacy,'file'),path=legacy;end
end
end

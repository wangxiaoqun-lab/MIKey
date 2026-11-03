function report = MIKey_finalize_sidecars(cfg, before, checkpoint)
% Compact only image/MAT pairs created or updated by a successful stage.
% Required per-volume transforms and unknown content are always retained.
if nargin<3,checkpoint=@() [];end
report=struct('removed',{{}},'retained',{{}},'unknown',{{}});
after=MIKey_sidecar_snapshot(cfg,checkpoint);
root=char(java.io.File(fullfile(cfg.bidsPath,'derivatives','MIKey')).getCanonicalPath());
for i=1:numel(after)
    checkpoint();
    old=find(strcmp(after(i).image,{before.image}),1);
    if ~isempty(old) && isequal(after(i),before(old)),continue;end
    [action,sidecar]=compact(after(i).image,root);
    if ~isempty(action),report.(action){end+1}=sidecar;end
end
end

function [action,sidecar]=compact(image,root)
action='unknown';sidecar=[image(1:end-4) '.mat'];
imageTarget=char(java.io.File(image).getCanonicalPath());
matTarget=char(java.io.File(sidecar).getCanonicalPath());
prefix=[root filesep];
if ispc
    inside=strncmpi(imageTarget,prefix,numel(prefix)) && strncmpi(matTarget,prefix,numel(prefix));
else
    inside=strncmp(imageTarget,prefix,numel(prefix)) && strncmp(matTarget,prefix,numel(prefix));
end
if ~inside,return;end
try
    info=whos('-file',sidecar);
    if numel(info)~=1 || ~strcmp(info.name,'mat') || ~any(strcmp(info.class,{'double','single'})),return;end
    content=load(sidecar,'mat');M=content.mat;
    if ~isnumeric(M) || ~isreal(M) || issparse(M) || ndims(M)>3 || ...
            size(M,1)~=4 || size(M,2)~=4 || any(~isfinite(M(:))),return;end
    N=nifti(image);base=N.mat;
    % An all-zero matrix means "use the NIfTI header" in SPM. Otherwise
    % require exact numerical identity, without approximation or resampling.
    for frame=1:size(M,3)
        value=double(M(:,:,frame));
        if any(value(:)~=0) && ~isequal(value,base)
            action='retained';return;
        end
    end
    % Recheck the sidecar contents before deleting this exact file. No other
    % MAT files, raw inputs, image bytes or header fields are modified.
    current=load(sidecar);
    if ~isequaln(current,content),return;end
    delete(sidecar);
    if ~exist(sidecar,'file'),action='removed';else,action='unknown';end
catch
    % Failed proof/permission/read is a keep decision, never a deletion.
    action='unknown';
end
end

function keep = MIKey_cleanup_keep(plan, keep, changedRow)
% Pair NIfTI/JSON/affine sidecars and invalidate completion caches on removal.
keep=logical(keep(:)); files=plan.files;
if numel(keep)~=numel(files), error('MIKey:CleanupSelection','Selection size changed. Rescan.'); end
if nargin>2 && ~isempty(changedRow)
    members=strcmp({files.group},files(changedRow).group);
    keep(members)=keep(changedRow);
end
keep([files.protected])=true;
% A deleted Step 12 image must not leave its run marked completed.
for i=1:numel(files)
    if files(i).step~=12 || isempty(regexp(files(i).relative,'_desc-advancedRegressionResults\.mat$','once')), continue; end
    prefix=regexprep(files(i).relative,'_desc-advancedRegressionResults\.mat$','');
    removed=false;
    legacyPrefix=[prefix '_space-template_desc-Regressedpc'];
    imagePrefix=regexprep(MIKey_bids_name([legacyPrefix '.nii']),'_bold\.nii$','');
    for j=1:numel(files)
        if ~keep(j) && files(j).step==12 && ...
                (startsWith(files(j).relative,imagePrefix) || startsWith(files(j).relative,legacyPrefix)) && ...
                ~isempty(regexp(files(j).relative,'\.nii(\.gz)?$','once'))
            removed=true; break;
        end
    end
    if removed, keep(i)=false; end
end
end

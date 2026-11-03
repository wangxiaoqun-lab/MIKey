function plan = MIKey_cleanup_inventory(bidsPath)
% Read-only inventory. No source BIDS files or external links are traversed.
[directory,~]=MIKey_cleanup_guard(bidsPath);
plan=struct('bidsPath',bidsPath,'directory',directory,'files', ...
    struct('relative',{},'step',{},'description',{},'protected',{},'bytes',{},'datenum',{},'group',{}));
walk('');
if ~isempty(plan.files)
    [~,order]=sort({plan.files.relative}); plan.files=plan.files(order);
end
    function walk(relative)
        [~,folder]=MIKey_cleanup_guard(bidsPath,relative);
        listing=dir(folder);
        for i=1:numel(listing)
            item=listing(i); if ismember(item.name,{'.','..'}), continue; end
            child=item.name; if ~isempty(relative), child=[relative '/' child]; end
            try
                MIKey_cleanup_guard(bidsPath,child);
            catch ME
                if strcmp(ME.identifier,'MIKey:CleanupPath'), continue; else, rethrow(ME); end
            end
            if item.isdir
                % Logs are retained in place and can contain many frozen config copies.
                if ~strcmp(child,'logs'), walk(child); end
            else
                [step,description,locked]=MIKey_cleanup_classify(child);
                group=regexprep(child,'\.(nii(\.gz)?|json|mat)$','');
                plan.files(end+1)=struct('relative',child,'step',step, ...
                    'description',description,'protected',locked,'bytes',item.bytes, ...
                    'datenum',item.datenum,'group',group); %#ok<AGROW>
            end
        end
    end
end

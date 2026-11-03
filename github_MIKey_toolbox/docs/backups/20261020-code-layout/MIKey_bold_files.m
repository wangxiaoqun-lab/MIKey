function [files, excluded] = MIKey_bold_files(directory, cfg, pattern)
% Filter raw BOLD once, then downstream stages derive filenames from it.
if nargin < 3, pattern = '*_bold.nii'; end
files = MIKey_nifti_files(directory,pattern);
keep = false(size(files));
excluded=struct('name',{},'source',{},'timepoints',{},'minimum',{});
minimum=0;if isfield(cfg,'minTimepoints'),minimum=cfg.minTimepoints;end
if ~isnumeric(minimum) || ~isscalar(minimum) || ~isfinite(minimum) || minimum<0 || minimum~=fix(minimum)
    error('MIKey:Parameter','minTimepoints must be a finite nonnegative integer.');
end
for i = 1:numel(files)
    task = entity(files(i).name,'task');
    run = entity(files(i).name,'run');
    keep(i) = MIKey_match_entity(task,cfg.taskFilter,'task') && ...
        MIKey_match_entity(run,cfg.runFilter,'run');
    if keep(i) && minimum>0
        source=fullfile(files(i).folder,files(i).sourceName);
        count=MIKey_timepoints(source);
        if count<minimum
            keep(i)=false;
            excluded(end+1)=struct('name',files(i).name,'source',source, ...
                'timepoints',count,'minimum',minimum); %#ok<AGROW>
        end
    end
end
files = files(keep);
end

function value = entity(filename,name)
token = regexp(filename,['(?:^|_)' name '-([^_\.]+)(?:_|\.)'],'tokens','once');
value = ''; if ~isempty(token), value = token{1}; end
end

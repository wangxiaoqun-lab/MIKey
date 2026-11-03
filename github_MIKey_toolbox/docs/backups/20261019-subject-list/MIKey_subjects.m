function [scopes, excluded] = MIKey_subjects(input, subjectFilter)
% Enumerate selected subject/session scopes; name is a relative BIDS path.
if isstruct(input)
    cfg = input;
else
    cfg = MIKey_defaults(); cfg.bidsPath = input; cfg.subjectFilter = subjectFilter;
end
scopes = struct('name',{},'folder',{},'subjectID',{},'sessionID',{});
excluded=struct('name',{},'source',{},'timepoints',{},'minimum',{});
subjects = dir(fullfile(cfg.bidsPath,'sub-*'));
subjects = subjects([subjects.isdir]);
expression = ['^' regexptranslate('wildcard',cfg.subjectFilter) '$'];
for i = 1:numel(subjects)
    subjectID = subjects(i).name;
    if isempty(regexp(subjectID,expression,'once')), continue; end
    root = fullfile(cfg.bidsPath,subjectID);
    sessions = dir(fullfile(root,'ses-*')); sessions = sessions([sessions.isdir]);
    names = [{''} {sessions.name}];
    for j = 1:numel(names)
        sessionID = names{j};
        if ~MIKey_match_entity(strrep(sessionID,'ses-',''),cfg.sessionFilter,'ses'), continue; end
        relative = fullfile(subjectID,sessionID);
        if isempty(sessionID), relative = subjectID; end
        scopePath = fullfile(cfg.bidsPath,relative);
        [bold, shortRuns] = MIKey_bold_files(fullfile(scopePath,'func'),cfg);
        excluded=[excluded shortRuns]; %#ok<AGROW>
        t2 = MIKey_nifti_files(MIKey_anat_path(scopePath),'*_T2w.nii');
        functional = any(ismember(cfg.steps,3:16));
        narrowed = ~strcmp(cfg.taskFilter,'*') || ~strcmp(cfg.runFilter,'*');
        selected = ~isempty(bold);
        if ~functional && (~narrowed || isequal(cfg.steps,17))
            selected = selected || ~isempty(t2);
        end
        if ~selected, continue; end
        scopes(end+1) = struct('name',relative,'folder',cfg.bidsPath, ...
            'subjectID',subjectID,'sessionID',sessionID); %#ok<AGROW>
    end
end
end

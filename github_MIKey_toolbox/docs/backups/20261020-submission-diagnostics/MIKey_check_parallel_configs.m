function MIKey_check_parallel_configs(configs, sources)
% Reject output collisions within one multi-configuration submission batch.
if nargin<2,sources=arrayfun(@(i)sprintf('configuration %d',i),1:numel(configs),'UniformOutput',false);end
info=cell(size(configs));
for i=1:numel(configs)
    cfg=MIKey_config(configs{i});scopes=MIKey_subjects(cfg);
    if isempty(scopes)
        error('MIKey:SubmissionSelection','No subjects/scans selected by %s; check filters and minTimepoints.',sources{i});
    end
    output=java.io.File(fullfile(cfg.bidsPath,'derivatives','MIKey'));
    group=java.io.File(MIKey_group_analysis(cfg));
    inter=any(ismember(cfg.steps,14:16)) && cfg.useInterSubjectVar;
    info{i}=struct('output',char(output.getCanonicalPath()), ...
        'subjects',{unique({scopes.subjectID})},'group',char(group.getCanonicalPath()), ...
        'groupUse',any(ismember(cfg.steps,[11 12])) || inter, ...
        'groupWrite',ismember(11,cfg.steps) || inter,'dryRun',cfg.dryRun);
end
for i=1:numel(info)
    for j=i+1:numel(info)
        a=info{i};b=info{j};if a.dryRun || b.dryRun,continue;end
        if strcmp(a.output,b.output)
            shared=intersect(a.subjects,b.subjects);
            if ~isempty(shared)
                error('MIKey:ParallelOutputs', ...
                    '%s and %s share subject outputs (%s). Use disjoint subjects, run dependent jobs sequentially, or use separate working datasets for parameter comparisons.', ...
                    sources{i},sources{j},strjoin(shared,', '));
            end
        end
        if a.groupUse && b.groupUse && (a.groupWrite || b.groupWrite) && strcmp(a.group,b.group)
            error('MIKey:ParallelOutputs', ...
                '%s and %s share group results at %s and at least one job writes them. Complete cohort-level estimation separately before dependent jobs.', ...
                sources{i},sources{j},a.group);
        end
    end
end
end

function MIKey_check_stage(cfg, step)
% Check derivatives immediately before a step, after earlier steps have run.
selection = cfg; selection.steps = step;
cfg = MIKey_config(selection);
subjects = MIKey_subjects(cfg);
if ismember(step, [11 12])
    if step == 12
        requireFile(fullfile(MIKey_group_analysis(cfg),'best_regression_strategy.mat'));
    end
end
strategies = {};
if ismember(step,12:16)
    flags = [cfg.advRegressionPCOnly cfg.advRegressionPCCSF cfg.advRegressionPCGS cfg.advRegressionPCCSFGS];
    strategies = {'Regressedpc','RegressedpcCSF','RegressedpcGS','RegressedpcCSFGS'};
    strategies = strategies(flags);
end
for i = 1:numel(subjects)
    subject = fullfile(subjects(i).folder, subjects(i).name);
    deriv = fullfile(cfg.bidsPath,'derivatives','MIKey',subjects(i).name);
    bold = MIKey_bold_files(fullfile(subject,'func'),cfg);
    t2 = MIKey_nifti_files(MIKey_anat_path(subject),'*_T2w.nii');
    for j = 1:numel(bold)
        [~,base] = fileparts(bold(j).name);
        func = fullfile(deriv,'func');
        image = @(suffix) MIKey_bids_path(func,[base suffix '.nii'],'input');
        output = @(suffix) MIKey_bids_path(func,[base suffix '.nii']);
        switch step
            case 2
                if ~exist(output('_desc-masked'),'file')
                    requireFile(image('_desc-scaled'));
                    MIKey_load_mask(func,'func',image('_desc-scaled'),fullfile(subject,'func'));
                end
            case 3
                if ~exist(output('_desc-fieldmap'),'file')
                    requireFile(image('_desc-masked'));
                    for part = {'magnitude1','phase1','magnitude2','phase2'}
                        matches = MIKey_fmap_files(fullfile(deriv,'fmap'),part{1});
                        if numel(matches) ~= 1
                            error('MIKey:Prerequisite','Expected one %s fieldmap for %s; found %d.',part{1},subjects(i).name,numel(matches));
                        end
                    end
                end
            case 4
                if ~exist(output('_desc-slicetimed'),'file')
                    requireAny({image('_desc-fieldmap'),image('_desc-masked')});
                end
            case 5
                if ~exist(output('_desc-realign'),'file')
                    requireAny({image('_desc-slicetimed'),image('_desc-fieldmap'),image('_desc-masked')});
                end
            case 6
                if ~exist(output('_desc-T2coreg'),'file')
                    requireFile(image('_desc-realign'));
                    if numel(t2) ~= 1
                        error('MIKey:Prerequisite','Coregistration requires one unambiguous T2w for %s; found %d.',subjects(i).name,numel(t2));
                    end
                    [~,t2base] = fileparts(t2(1).name);
                    requireFile(MIKey_bids_path(fullfile(deriv,'anat'),[t2base '_desc-masked.nii'],'input'));
                end
            case 7
                if ~exist(output('_space-template_desc-normalized'),'file') || ~exist(output('_space-template_desc-T2normalized'),'file')
                    requireFile(image('_desc-realign'));
                    requireFile(image('_desc-T2coreg'));
                end
            case 8
                if ~exist(output('_space-template_desc-smoothed'),'file')
                    requireFile(image('_space-template_desc-normalized'));
                end
            case 9
                if ~exist(fullfile(func,[base '_desc-NBPCs.mat']),'file')
                    requireFile(image('_desc-scaled'));
                    MIKey_load_mask(func,'func',image('_desc-scaled'),fullfile(subject,'func'));
                end
            case {10,12}
                requireFile(image('_space-template_desc-smoothed'));
                requireFile(fullfile(func,[base '_desc-NBPCs.mat']));
                motion = MIKey_motion_files(func,base);
                if numel(motion) ~= 1
                    error('MIKey:Prerequisite','Expected one rp_ motion file for %s; found %d.',base,numel(motion));
                end
            case 11
                requireFile(fullfile(func,[base '_desc-regressionResults.mat']));
            case {13,14,15,16}
                for k = 1:numel(strategies)
                    requireFile(image(['_space-template_desc-' strategies{k}]));
                end
        end
    end
    if ismember(step,[2 17])
        for j = 1:numel(t2)
            [~,base] = fileparts(t2(j).name);
            anat = fullfile(deriv,'anat');
            if step == 2 && ~exist(MIKey_bids_path(anat,[base '_desc-masked.nii']),'file')
                scaled = MIKey_bids_path(anat,[base '_desc-scaled.nii'],'input');
                requireFile(scaled); MIKey_load_mask(anat,'anat',scaled,MIKey_anat_path(subject));
            elseif step == 17 && ~exist(MIKey_bids_path(anat,[base '_desc-gmvol.nii']),'file')
                requireFile(MIKey_bids_path(anat,[base '_desc-scaled.nii'],'input'));
                requireFile(MIKey_bids_path(anat,[base '_desc-masked.nii'],'input'));
            end
        end
    end
end
end

function requireFile(filename)
if ~exist(filename,'file')
    error('MIKey:Prerequisite','Required input missing: %s',filename);
end
end

function requireAny(filenames)
if ~any(cellfun(@(name) exist(name,'file')==2,filenames))
    error('MIKey:Prerequisite','None of the alternative inputs exist: %s',strjoin(filenames,', '));
end
end


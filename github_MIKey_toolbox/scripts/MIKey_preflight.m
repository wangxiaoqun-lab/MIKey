function report = MIKey_preflight(input)
%MIKEY_PREFLIGHT Check configuration, installed dependencies and raw layout.
% Does not run a processing step or create derivatives.
[cfg, active] = MIKey_config(input);
issues = {};
notes = {};
[subjects, excluded] = MIKey_subjects(cfg);
if isempty(cfg.bidsPath) || ~exist(cfg.bidsPath, 'dir')
    issues{end+1} = ['BIDS directory not found: ' cfg.bidsPath];
elseif isempty(subjects)
    issues{end+1} = sprintf('No scans match subject=%s, session=%s, task=%s, run=%s, minTimepoints=%d.',cfg.subjectFilter,cfg.sessionFilter,cfg.taskFilter,cfg.runFilter,cfg.minTimepoints);
end
dirs = {cfg.codePath};
if active.templatePath, dirs{end+1} = cfg.templatePath; end
for i = 1:numel(dirs)
    if ~exist(dirs{i}, 'dir'), issues{end+1} = ['Directory not found: ' dirs{i}]; end
end
deps = {'spm','spm_vol','spm_read_vols','spm_write_vol','spm_jobman', ...
    'spm_get_defaults','spm_write_vol_4D'};
stageDeps = {
    {}; {}; {'UN_fieldmap_batch_struct','UN_find_images_in_all_scans'};
    {'UN_get_default_slicetiming_batch_struct','UN_find_images_in_all_scans'};
    {'MY_get_default_realign_batch_struct','UN_find_images_in_all_scans'};
    {'MY_get_default_coreg_batch_struct','spm_sample_vol','MIKey_registration_qc','MIKey_registration_pair'};
    {'UN_get_default_oldnormalize_batch_struct','spm_sample_vol','MIKey_registration_qc','MIKey_registration_pair'};
    {'MY_get_default_smooth_batch_struct','UN_find_images_in_all_scans'};
    {'MY_get_principle_component_out_of_brian','pca','strel','imerode'};
    {'MY_headmotion_regression_estimate','zscore','corr'};
    {}; {'MY_headmotion_regression_combined','zscore','corr'};
    {'MY_headmotion_regression_combined','corr'};
    {'individualized_parcellation_rsfMRI_v3','kmeans','prctile'};
    {'individualized_parcellation_rsfMRI_v3','kmeans','prctile'};
    {'individualized_parcellation_rsfMRI_v3','kmeans','prctile'};
    {'UN_get_default_oldnormalize_batch_struct','UN_get_segment_batch_struct','MY_get_default_smooth_batch_struct','MIKey_segment_t2','MIKey_tissue_paths'}};
for step = cfg.steps
    deps = [deps stageDeps{step}]; %#ok<AGROW>
end
if active.parcellationUseParallel && cfg.parcellationUseParallel
    deps{end+1} = 'parpool';
    if ~license('test','Distrib_Computing_Toolbox')
        issues{end+1} = 'Parallel parcellation requires Parallel Computing Toolbox; set parcellationUseParallel=false for serial execution.';
    end
end
for i = 1:numel(deps)
    if isempty(which(deps{i})), issues{end+1} = ['Missing function: ' deps{i}]; end
end
required = {};
if any(ismember(cfg.steps, [3 7 17]))
    if ismember(7, cfg.steps) && ~cfg.useDefaultTemplate
        required{end+1} = cfg.customTemplatePath;
    end
    if any(ismember(cfg.steps, [3 17])) || (ismember(7, cfg.steps) && cfg.useDefaultTemplate)
        required{end+1} = fullfile(cfg.templatePath, 'Template_Mouse_v38.nii');
    end
end
if any(ismember(cfg.steps, [10 12 13]))
    required{end+1} = fullfile(cfg.templatePath, 'brainmask_Mouse_v38.nii');
end
if ismember(12, cfg.steps)
    required{end+1} = fullfile(cfg.templatePath, 'AMCP_temp', 'AMCP_ventricle_mask.nii');
end
if ismember(13, cfg.steps)
    if strcmp(cfg.fcLabel, 'Custom...')
        required{end+1} = cfg.fcCustomPath;
    else
        atlas = MIKey_atlas_catalog(cfg.fcLabel);
        required{end+1} = fullfile(cfg.templatePath, atlas.labelFile);
    end
end
if any(ismember(cfg.steps, 14:16))
    required{end+1} = fullfile(cfg.templatePath, 'AMCP_temp', 'AMCP_GMWM_mask.nii');
    if cfg.useInterSubjectVar || any(ismember(cfg.steps, [15 16]))
        try
            required{end+1} = MIKey_group_network(cfg);
        catch ME
            issues{end+1} = ME.message;
        end
    end
    if active.useInterSubjectVar && cfg.useInterSubjectVar
        required{end+1} = fullfile(cfg.templatePath, 'Template_Mouse_v38.nii');
        required{end+1} = fullfile(cfg.templatePath, 'brainmask_Mouse_v38.nii');
    end
end
if ismember(14, cfg.steps)
    if cfg.useCustomParc
        required = [required {cfg.networkCustomPath cfg.labelCustomPath}];
    else
        atlas = MIKey_atlas_catalog(cfg.parcNetwork);
        required{end+1} = fullfile(cfg.templatePath, atlas.labelFile);
        try
            prior = MIKey_builtin_prior(cfg);
            required{end+1} = prior.network_file;
        catch ME
            issues{end+1} = ME.message;
        end
    end
end
if ismember(17, cfg.steps)
    tissueTPM=fullfile(cfg.templatePath,'AMCP_temp','AMCP_TPM.nii');
    required{end+1}=tissueTPM;
    if exist(tissueTPM,'file')==2 && ~isempty(which('spm_vol'))
        try
            tissueHeaders=spm_vol(tissueTPM);
            if numel(tissueHeaders)~=5
                issues{end+1}='AMCP_TPM.nii must have exactly 5 volumes: GM, WM, CSF, OT, AIR.';
            end
        catch ME
            issues{end+1}=['Cannot read Step 17 five-volume TPM: ' ME.message];
        end
    end
end
for i = 1:numel(required)
    if isempty(required{i}) || ~exist(required{i}, 'file')
        issues{end+1} = ['Required image missing: ' required{i}];
    end
end
rawCounts = zeros(numel(subjects), 2);
for i = 1:numel(subjects)
    sub = fullfile(subjects(i).folder, subjects(i).name);
    rawCounts(i, :) = [numel(MIKey_bold_files(fullfile(sub,'func'),cfg)) numel(MIKey_nifti_files(MIKey_anat_path(sub),'*_T2w.nii'))];
    if any(ismember(cfg.steps, 3:16)) && rawCounts(i, 1) == 0
        issues{end+1} = [subjects(i).name ': no func/*_bold.nii or .nii.gz found.'];
    end
    if any(ismember(cfg.steps, [6 7 17])) && rawCounts(i, 2) == 0
        issues{end+1} = [subjects(i).name ': no anat/*_T2w.nii or .nii.gz found.'];
    end
    if sum(rawCounts(i,:)) == 0
        issues{end+1} = [subjects(i).name ': no supported BOLD or T2w input found.'];
    end
end
if active.useInterSubjectVar && cfg.useInterSubjectVar
    notes{end+1} = 'Inter-subject variability is a group operation; use the complete intended cohort in one job.';
end
notes{end+1} = 'Preflight does not verify NIfTI geometry, registration quality or all future derivatives. Runtime warnings are fatal by default.';
report = struct('ok', isempty(issues), 'issues', {unique(issues,'stable')}, ...
    'notes', {notes}, 'subjects', {{subjects.name}}, 'rawCounts', rawCounts, ...
    'steps', cfg.steps, 'requiredImages', {required}, 'functions', {unique(deps,'stable')});
report.selection = struct('subjectFilter',cfg.subjectFilter, ...
    'sessionFilter',cfg.sessionFilter,'taskFilter',cfg.taskFilter,'runFilter',cfg.runFilter, ...
    'minTimepoints',cfg.minTimepoints);
report.parameterScope=active;
report.excludedBold=excluded;
report.groupAnalysisPath = MIKey_group_analysis(cfg);
report.subjectIDs = unique({subjects.subjectID},'stable');
report.scopes = subjects;
end

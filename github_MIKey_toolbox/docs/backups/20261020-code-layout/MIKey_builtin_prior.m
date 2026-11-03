function prior = MIKey_builtin_prior(cfg)
% Resolve a bundled ROI atlas and its explicitly available network prior.
atlas=MIKey_atlas_catalog(cfg.parcNetwork);
if isempty(atlas.networkFile)
    network=MIKey_group_network(cfg); % 296/592 require an explicit Group Network.
else
    % Existing built-ins retain their original Step 14 initialization prior.
    network=fullfile(cfg.templatePath,'AMCP_temp',atlas.networkFile);
end
prior=struct('network_file',network,'label_file',fullfile(cfg.templatePath,atlas.labelFile), ...
    'folder_suffix',['prior_mode_' atlas.label], ...
    'dice_file',['dice_cross_runs_based_' atlas.label 'roi.mat']);
end

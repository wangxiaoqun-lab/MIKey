function filename = MIKey_group_network(cfg)
% Group network for clustering/voxel modes and inter-subject variability.
% An explicit path wins; otherwise reuse the GUI custom/selected network.
if ~isempty(cfg.groupNetworkPath)
    filename = cfg.groupNetworkPath;
elseif cfg.useCustomParc
    filename = cfg.networkCustomPath;
else
    atlas=MIKey_atlas_catalog(cfg.parcNetwork);
    if isempty(atlas.networkFile)
        error('MIKey:AtlasNetwork', ...
            'Atlas %s supplies ROI labels but no bundled AMCP network prior. Select a suitable Group Network file (cfg.groupNetworkPath) for parcellation.',atlas.label);
    end
    filename=fullfile(cfg.templatePath,'AMCP_temp',atlas.networkFile);
end
end

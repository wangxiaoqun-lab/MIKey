function filename = MIKey_group_network(cfg)
% Group network for clustering/voxel modes and inter-subject variability.
% An explicit path wins; otherwise reuse the GUI custom/selected network.
if ~isempty(cfg.groupNetworkPath)
    filename = cfg.groupNetworkPath;
elseif cfg.useCustomParc
    filename = cfg.networkCustomPath;
else
    names = struct('n214rois','AMCP_214prior_11net.nii', ...
        'n428rois','AMCP_428prior_11net.nii', ...
        'n604rois','AMCP_604prior_12net.nii', ...
        'n1184rois','AMCP_1184prior_13net.nii');
    filename = fullfile(cfg.templatePath,'AMCP_temp',names.(['n' cfg.parcNetwork]));
end
end

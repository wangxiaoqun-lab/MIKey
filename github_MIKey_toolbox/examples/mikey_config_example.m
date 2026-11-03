function cfg = mikey_config_example()
% Edit parameters only in this file; examples/run_mikey.m loads and runs them.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root,'scripts'), '-begin');
MIKey_paths();
cfg = MIKey_defaults();
cfg.spmPath = ''; % Set the server SPM12 root, or use SPM already on path.
cfg.codePath = fullfile(root, 'scripts');
cfg.templatePath = fullfile(root, 'share_temp');
cfg.bidsPath = '/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main/BIDS_demo';
cfg.subjectFilter = 'sub-002'; % One ID/pattern or a comma-separated list, e.g. 'sub-001,sub-002'.
cfg.sessionFilter = '*'; % e.g. '01', 'ses-01', '01,02', or 'none'
cfg.taskFilter = '*'; % e.g. 'rest' or 'rest,motor'
cfg.runFilter = '*'; % e.g. '01', '01,03', or 'none'
cfg.steps = 1; % Run alone; prepare masks externally; then change to 2:10.
cfg.minTimepoints = 100;
cfg.voxelScaleFactor = 20; % Step 1 enlargement; Step 10 divides FD by this factor to return physical mm.
cfg.sliceTimingTR = 1;
cfg.sliceTimingNSlices = 28;
cfg.sliceTimingOrder = 'Auto-detect';
cfg.smoothFWHM = [6 6 6];
cfg.segSmoothFWHM = [6 6 6]; % Step 17 GM/WM/CSF modulated maps; image-space mm.
cfg.coregInterp = 2;
cfg.normInterp = 2;
cfg.useDefaultTemplate = true;
cfg.customTemplatePath = '';
cfg.detrendFlag = true;
cfg.filterFlag = true;
cfg.lowFreq = 0.01;
cfg.highFreq = 0.1;
cfg.useDefaultPCStrategy = true;
cfg.fdMethod = 'euclidean'; % 'power': L1, 'euclidean': L2 of framewise motion changes.
cfg.fdRadius = 100; % Scaled-space rotation radius; physical 5 mm * scale 20 = 100. FD output is physical mm.
cfg.customPCCounts = [0 5 10 20]; % used when useDefaultPCStrategy=false
cfg.advRegressionPCOnly = true;
cfg.advRegressionPCCSF = true;
cfg.advRegressionPCGS = true;
cfg.advRegressionPCCSFGS = true;
cfg.fcLabel = '296';
cfg.fcCustomPath = '';
cfg.parcNetwork = '296rois';
cfg.useCustomParc = false;
cfg.networkCustomPath = '';
cfg.labelCustomPath = '';
cfg.groupNetworkPath = ''; % Optional custom group network; blank uses GUI network selection.
cfg.clustROINums = 100; % GUI accepts one integer; scripts may still use a vector.
cfg.voxelDownsampleFactor = 2;
cfg.percentTop = 0.8;
cfg.maxIter = 30;
cfg.changeThr = 0.001;
cfg.confThr = 2.5;
cfg.useTSNR = false;
cfg.useInterSubjectVar = false;
cfg.parcellationUseParallel = false; % true requires Parallel Computing Toolbox and allocated workers.
cfg.parcellationMode = 'individual'; % or 'concatenated'
cfg.dryRun = false; % true checks configuration/dependencies without processing.
cfg.failFast = true;
cfg.strictWarnings = true;
cfg.logDir = ''; % default: BIDS/derivatives/MIKey/logs
end

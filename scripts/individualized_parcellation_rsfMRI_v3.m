function [individual_network_map, max_corr_map, iter_info] = individualized_parcellation_rsfMRI_v3(...
    individual_bold, group_network, Gmask_head, method, method_param, ...
    percent_top, output_path, max_iter, change_thr, conf_thr, varargin)

%% Unified Individualized Brain Parcellation (Modified v3)
% Combines prior-label, k-means ROI, and voxel-based approaches for individualized parcellation
% with flexible tSNR calculation and weighting for correlation calculations
%
% Parameters:
%   individual_bold : 4D BOLD fMRI data [x,y,z,t]
%   group_network   : 3D group-level network labels [x,y,z] (for initialization)
%   Gmask_head      : Header for binary brain mask
%   method          : 'prior' for label-based, 'kmeans' for ROI-based, or 'voxel' for voxel-based approach
%   method_param    : Prior label file path (for 'prior'), number of ROIs (for 'kmeans'),
%                     or downsampling factor (for 'voxel', e.g., 2, 3, 4)
%   percent_top     : Top percentage threshold (0-1) for network selection
%   output_path     : Output directory path for saving results
%   max_iter        : Maximum number of iterations
%   change_thr      : Change threshold (0-1) for stopping criterion
%   conf_thr        : Confidence threshold for stopping criterion
%   varargin        : Optional name-value pairs:
%                     - 'InterSubjectVar': Inter-subject variability map
%                     - 'tSNR': true/false to compute and use tSNR weighting in correlations
%                     - 'tSNRfile': Path to external tSNR map file
%                     - 'save_intermediate': true/false to save intermediate iteration results (default: false)
%
% Outputs:
%   individual_network_map : 3D individualized network parcellation map
%   max_corr_map          : 3D maximum correlation values map
%   iter_info             : Structure containing iteration performance data
%
% Example usage:
%   % Use internal tSNR calculation and save intermediate results
%   [net_map, corr_map, info] = individualized_parcellation_rsfMRI_v3(...
%       bold_data, group_net, mask_hdr, 'prior', 'atlas.nii', ...
%       0.8, './results', 20, 0.05, 1.5, 'tSNR', true, 'save_intermediate', true);
%
%   % Use external tSNR file, don't save intermediate results
%   [net_map, corr_map, info] = individualized_parcellation_rsfMRI_v3(...
%       bold_data, group_net, mask_hdr, 'prior', 'atlas.nii', ...
%       0.8, './results', 20, 0.05, 1.5, 'tSNRfile', 'tSNR_map.nii', 'save_intermediate', false);
%
%   Author: Yijuan Zou
%   Created: 2025-08-12
%   Modified: 2025-08-22 (Added flexible tSNR input options and intermediate results saving)
%   Copyright (c) 2025-ZYJ. All rights reserved.
%
%   Version: 3 
%   Last Modified: 2025-08-22

%% Validate parameters
if nargin < 10
    error('Insufficient input arguments');
end
if percent_top < 0 || percent_top > 1
    error('percent_top must be between 0 and 1');
end
if change_thr < 0 || change_thr > 1
    error('change_thr must be between 0 and 1');
end
if conf_thr < 0
    error('conf_thr must be non-negative');
end
if ~ismember(method, {'prior', 'kmeans', 'voxel'})
    error('method must be either "prior", "kmeans", or "voxel"');
end
if strcmp(method, 'voxel') && (method_param < 1 || mod(method_param, 1) ~= 0)
    error('For voxel method, method_param must be a positive integer downsampling factor');
end

%% Handle additional inputs
inter_subject_var_head = [];
tSNR_flag = false;
tSNR_file = [];
downsample_method = 'nearest';
save_intermediate = false;

if ~isempty(varargin)
    for i = 1:2:length(varargin)
        if i+1 > length(varargin)
            error('Invalid name-value pair arguments');
        end
        param_name = validatestring(varargin{i}, ...
            {'InterSubjectVar', 'tSNR', 'tSNRfile', 'DownsampleMethod', 'save_intermediate'});
        
        switch param_name
            case 'InterSubjectVar'
                inter_subject_var_head = varargin{i+1};
            case 'tSNR'
                tSNR_flag = varargin{i+1};
                if ~islogical(tSNR_flag)
                    error('tSNR parameter must be logical (true/false)');
                end
            case 'tSNRfile'
                tSNR_file = varargin{i+1};
                if ~ischar(tSNR_file)
                    error('tSNRfile must be a string (file path)');
                end
            case 'DownsampleMethod'
                downsample_method = validatestring(varargin{i+1}, {'nearest', 'average'});
            case 'save_intermediate'
                save_intermediate = varargin{i+1};
                if ~islogical(save_intermediate)
                    error('save_intermediate parameter must be logical (true/false)');
                end
        end
    end
end

%% Load and validate mask
Gmask = spm_read_vols(Gmask_head);
if ~isequal(size(Gmask), size(individual_bold(:,:,:,1)))
    error('Mask dimensions mismatch with BOLD data');
end

%% Load Inter-subject variability map if provided
inter_subject_var = [];

if ~isempty(inter_subject_var_head)
    if ischar(inter_subject_var_head)
        inter_subject_var_head = spm_vol(inter_subject_var_head);
    end
    inter_subject_var = spm_read_vols(inter_subject_var_head);
    if ~isequal(size(inter_subject_var), size(Gmask))
        error('Inter-subject variability map dimensions mismatch');
    end
    fprintf('Loaded inter-subject variability map\n');
else
    fprintf('No inter-subject variability map provided\n');
end

%% Handle tSNR map
snr_map = [];
tSNR_source = 'none';

if ~isempty(tSNR_file)
    fprintf('Loading external tSNR map from: %s\n', tSNR_file);
    snr_head = spm_vol(tSNR_file);
    snr_map = spm_read_vols(snr_head);
    if ~isequal(size(snr_map), size(Gmask))
        error('External tSNR map dimensions mismatch');
    end
    tSNR_source = 'external';
    fprintf('Loaded external tSNR map\n');
    
elseif tSNR_flag
    fprintf('Computing tSNR map from BOLD data...\n');
    [snr_map, mean_tSNR] = compute_temporal_snr(individual_bold, Gmask);
    fprintf('Mean tSNR: %.2f\n', mean_tSNR);
    tSNR_source = 'internal';
    
    if ~isempty(output_path)
        tSNR_dir = fullfile(output_path, 'tSNR_Results');
        if ~exist(tSNR_dir, 'dir'), mkdir(tSNR_dir); end
        
        vol_out = Gmask_head;
        vol_out.fname = fullfile(tSNR_dir, 'computed_tSNR_map.nii');
        vol_out.dt = [16,0];
        spm_write_vol(vol_out, snr_map);
        
        save(fullfile(tSNR_dir, 'tSNR_summary.mat'), 'snr_map', 'mean_tSNR');
        fprintf('Saved computed tSNR map to: %s\n', tSNR_dir);
    end
end

%% Apply tSNR correction to BOLD data if tSNR map is available
if ~isempty(snr_map)
    fprintf('Applying tSNR correction to BOLD data (source: %s)...\n', tSNR_source);
    
    snr_4D = repmat(snr_map, [1, 1, 1, size(individual_bold, 4)]);
    
    mask_4D = repmat(Gmask, [1, 1, 1, size(individual_bold, 4)]);
    individual_bold(mask_4D > 0) = individual_bold(mask_4D > 0) .* snr_4D(mask_4D > 0);
    
    fprintf('tSNR correction applied to BOLD data\n');
end

%% Initialize variables for all methods
Gmask_original = Gmask;
group_network_original = group_network;
inter_subject_var_original = inter_subject_var;
snr_map_original = snr_map;
original_size = size(Gmask);

%% Extract unit time series based on method
if strcmp(method, 'prior')
    prior_head = spm_vol(method_param);
    prior_label = spm_read_vols(prior_head);
    
    if ~isequal(size(prior_label), size(Gmask))
        error('Prior label dimensions mismatch');
    end
    
    unit_ids = unique(prior_label(prior_label > 0 & Gmask > 0));
    num_units = numel(unit_ids);
    fprintf('Using %d prior regions from: %s\n', num_units, method_param);
    
    unit_ts = zeros(num_units, size(individual_bold,4));
    for i = 1:num_units
        region_mask = (prior_label == unit_ids(i)) & (Gmask > 0);
        if any(region_mask(:))
            region_voxels = individual_bold(repmat(region_mask, [1,1,1,size(individual_bold,4)]));
            region_voxels = reshape(region_voxels, [], size(individual_bold,4));
            unit_ts(i,:) = mean(region_voxels, 1);
        end
    end
    unit_masks = prior_label;
    
elseif strcmp(method, 'kmeans')
    num_units = method_param;
    fprintf('Creating %d ROIs using k-means clustering\n', num_units);
    
    [x,y,z] = ind2sub(size(Gmask), find(Gmask>0));
    coordinates = [x,y,z];
    
    coord_mean = mean(coordinates);
    coord_std = std(coordinates);
    coordinates_norm = (coordinates - coord_mean) ./ coord_std;
    
    options = statset('UseParallel', true, 'MaxIter', 1000);
    [unit_idx, ~] = kmeans(coordinates_norm, num_units, 'Replicates', 5, 'Options', options,'Distance','correlation');
    
    unit_masks = zeros(size(Gmask));
    unit_masks(Gmask>0) = unit_idx;
    unit_ids = 1:num_units;
    
    masked_bold = reshape(individual_bold, [], size(individual_bold,4));
    masked_bold = masked_bold(Gmask>0, :);
    unit_ts = zeros(num_units, size(individual_bold,4));
    for i = 1:num_units
        unit_ts(i,:) = mean(masked_bold(unit_idx==i, :), 1);
    end
    
elseif strcmp(method, 'voxel')
    downsample_factor = method_param;
    fprintf('Using voxel-based approach with downsampling factor: %d\n', downsample_factor);
    fprintf('Downsampling method: %s\n', downsample_method);
    
    [individual_bold_ds, Gmask_ds, group_network_ds, inter_subject_var_ds, snr_map_ds, ds_info] = ...
        downsample_volume_data(individual_bold, Gmask, group_network, inter_subject_var, snr_map, ...
        downsample_factor, downsample_method);
    
    unit_ids = find(Gmask_ds > 0);
    num_units = numel(unit_ids);
    
    [x_ds, y_ds, z_ds] = ind2sub(size(Gmask_ds), unit_ids);
    unit_ts = zeros(num_units, size(individual_bold_ds, 4));
    for i = 1:num_units
        unit_ts(i, :) = squeeze(individual_bold_ds(x_ds(i), y_ds(i), z_ds(i), :));
    end
    
    ds_data.individual_bold_ds = individual_bold_ds;
    ds_data.Gmask_ds = Gmask_ds;
    ds_data.group_network_ds = group_network_ds;
    ds_data.inter_subject_var_ds = inter_subject_var_ds;
    ds_data.snr_map_ds = snr_map_ds;
    ds_data.ds_info = ds_info;
    ds_data.unit_coords = [x_ds, y_ds, z_ds];
    
    fprintf('Downsampled from %dx%dx%d to %dx%dx%d, %d voxels selected\n', ...
        original_size(1), original_size(2), original_size(3), ...
        size(Gmask_ds,1), size(Gmask_ds,2), size(Gmask_ds,3), num_units);
    
    Gmask = Gmask_ds;
    group_network = group_network_ds;
    if ~isempty(inter_subject_var)
        inter_subject_var = inter_subject_var_ds;
    end
    if ~isempty(snr_map)
        snr_map = snr_map_ds;
    end
end

%% Calculate unit-level SNR and Inter-subject variability
unit_snr = ones(num_units, 1);
unit_var = ones(num_units, 1);

if ~isempty(snr_map) || ~isempty(inter_subject_var)
    fprintf('Calculating unit-level weights...\n');
    
    if ~isempty(snr_map)
        for i = 1:num_units
            if strcmp(method, 'prior')
                region_mask = (unit_masks == unit_ids(i)) & (Gmask > 0);
            elseif strcmp(method, 'kmeans')
                region_mask = (unit_masks == i) & (Gmask > 0);
            else
                coord = ds_data.unit_coords(i, :);
                unit_snr(i) = snr_map(coord(1), coord(2), coord(3));
                continue;
            end
            
            if any(region_mask(:))
                snr_vals = snr_map(region_mask);
                unit_snr(i) = mean(snr_vals(snr_vals > 0));
            end
        end
        min_snr = min(unit_snr);
        max_snr = max(unit_snr);
        if max_snr > min_snr
            unit_snr = (unit_snr - min_snr) / (max_snr - min_snr);
        else
            unit_snr = ones(size(unit_snr));
        end
    end
    
    if ~isempty(inter_subject_var)
        for i = 1:num_units
            if strcmp(method, 'prior')
                region_mask = (unit_masks == unit_ids(i)) & (Gmask > 0);
            elseif strcmp(method, 'kmeans')
                region_mask = (unit_masks == i) & (Gmask > 0);
            else
                coord = ds_data.unit_coords(i, :);
                unit_var(i) = inter_subject_var(coord(1), coord(2), coord(3));
                continue;
            end
            
            if any(region_mask(:))
                var_vals = inter_subject_var(region_mask);
                unit_var(i) = mean(var_vals(var_vals > 0));
            end
        end
        min_var = min(unit_var);
        max_var = max(unit_var);
        if max_var > min_var
            unit_var = (unit_var - min_var) / (max_var - min_var);
        else
            unit_var = ones(size(unit_var));
        end
    end
end

%% Initialize unit network labels
unit_net_labels = zeros(num_units, 1);
for i = 1:num_units
    if strcmp(method, 'prior')
        region_mask = (unit_masks == unit_ids(i)) & (Gmask > 0);
    elseif strcmp(method, 'kmeans')
        region_mask = (unit_masks == i) & (Gmask > 0);
    else
        coord = ds_data.unit_coords(i, :);
        unit_net_labels(i) = group_network(coord(1), coord(2), coord(3));
        continue;
    end
    
    net_vals = group_network(region_mask);
    net_vals = net_vals(net_vals > 0);
    
    if ~isempty(net_vals)
        unit_net_labels(i) = mode(net_vals);
    end
end

%% Prepare for iteration
valid_nets = unique(unit_net_labels(unit_net_labels > 0));
num_nets = numel(valid_nets);
fprintf('Identified %d valid networks for initialization\n', num_nets);

current_net_labels = unit_net_labels;
iter_idx = 0;
iter_info = struct('iteration', [], 'unit_change', [], 'time_sec', [], ...
                  'mean_confidence', [], 'conf_threshold', []);

%% Store initial reference signals
initial_net_ts = zeros(num_nets, size(unit_ts,2));
for n = 1:num_nets
    member_units = (current_net_labels == valid_nets(n));
    if any(member_units)
        initial_net_ts(n,:) = mean(unit_ts(member_units, :), 1);
    end
end
prev_net_ts = initial_net_ts;

%% Create output directory
if ~exist(output_path, 'dir'), mkdir(output_path); end
fprintf('\n===== Starting Iterative Reconstruction =====\n');
if save_intermediate
    fprintf('Intermediate iteration results will be saved\n');
else
    fprintf('Intermediate iteration results will NOT be saved (only final results)\n');
end

%% Main iteration loop
while iter_idx < max_iter
    iter_idx = iter_idx + 1;
    tic;
    fprintf('\n----- Iteration %d/%d -----\n', iter_idx, max_iter);
    
    if save_intermediate
        iter_dir = fullfile(output_path, sprintf('Iter_%d', iter_idx));
        if ~exist(iter_dir, 'dir'), mkdir(iter_dir); end
    end
    
    %% Step 1: Calculate network time series with Wang et al. weighting
    net_ts = zeros(num_nets, size(unit_ts,2));
    core_signals = zeros(num_nets, size(unit_ts,2));
    core_weights = zeros(num_nets, 1);
    
    for n = 1:num_nets
        member_units = (current_net_labels == valid_nets(n));
        
        if any(member_units)
            core_signals(n,:) = mean(unit_ts(member_units, :), 1);
            
            avg_snr = mean(unit_snr(member_units));
            avg_var = mean(unit_var(member_units));
            
            iter_weight = min(1, 0.3 + 0.7 * (iter_idx / max_iter));
            
            core_weight = (avg_snr + avg_var + iter_weight) / 3;
            core_weights(n) = min(1, max(0, core_weight));
            
            net_ts(n,:) = core_weights(n) * core_signals(n,:) + ...
                          (1 - core_weights(n)) * initial_net_ts(n,:);
        else
            net_ts(n,:) = initial_net_ts(n,:);
            core_weights(n) = 0;
        end
    end
    
    %% Step 2: Compute unit-network correlations
    unit_net_corr = corr(unit_ts', net_ts');
    unit_net_corr(isnan(unit_net_corr)) = -Inf;
    
    %% Step 3: Calculate ROI confidence and assign networks
    roi_confidence = zeros(num_units, 1);
    new_net_labels = zeros(num_units, 1);
    max_corr_vals = zeros(num_units, 1);
    
    for u = 1:num_units
        corr_vals = unit_net_corr(u, :);
        [sorted_vals, sorted_idx] = sort(corr_vals, 'descend');
        
        if numel(sorted_vals) > 1 && sorted_vals(1) > 0
            conf_ratio = sorted_vals(1) / sorted_vals(2);
        else
            conf_ratio = Inf;
        end
        roi_confidence(u) = conf_ratio;
        
        top_n = max(1, round(percent_top * num_nets));
        candidate_nets = valid_nets(sorted_idx(1:top_n));
        [~, idx_in_candidate] = max(corr_vals(sorted_idx(1:top_n)));
        new_net_labels(u) = candidate_nets(idx_in_candidate);
        max_corr_vals(u) = sorted_vals(1);
    end
    
    %% Step 4: Calculate changed units and confidence status
    changed_mask = (new_net_labels ~= current_net_labels);
    changed_units = sum(changed_mask);
    change_percent = 100 * changed_units / num_units;
    
    valid_conf = roi_confidence(isfinite(roi_confidence));
    if ~isempty(valid_conf)
        mean_confidence = mean(valid_conf);
    else
        mean_confidence = 0;
    end
    
    %% Step 5: Check stopping criteria
    change_criterion_met = (change_percent <= change_thr * 100);
    conf_criterion_met = (mean_confidence >= conf_thr);
    
    if change_criterion_met && conf_criterion_met
        fprintf('Stopping: Both thresholds reached (Change: %.2f%% <= %.2f%%, Confidence: %.2f >= %.2f)\n',...
                change_percent, change_thr*100, mean_confidence, conf_thr);
    elseif change_criterion_met
        fprintf('Change threshold reached (%.2f%% <= %.2f%%) but confidence not met (%.2f < %.2f)\n',...
                change_percent, change_thr*100, mean_confidence, conf_thr);
    elseif conf_criterion_met
        fprintf('Confidence threshold achieved (%.2f >= %.2f) but change not met (%.2f%% > %.2f%%)\n',...
                mean_confidence, conf_thr, change_percent, change_thr*100);
    end
    
    %% Step 6: Save iteration results only if requested
    if save_intermediate
        save(fullfile(iter_dir, 'unit_network_correlations.mat'), ...
            'unit_net_corr', 'max_corr_vals', 'net_ts', 'roi_confidence', 'core_weights');
    end
    
    %% Update for next iteration
    current_net_labels = new_net_labels;
    prev_net_ts = net_ts;
    iter_time = toc;
    
    iter_info(iter_idx).iteration = iter_idx;
    iter_info(iter_idx).unit_change = change_percent;
    iter_info(iter_idx).time_sec = iter_time;
    iter_info(iter_idx).mean_confidence = mean_confidence;
    iter_info(iter_idx).conf_threshold = conf_thr;
    iter_info(iter_idx).mean_core_weight = mean(core_weights);
    
    fprintf('Units changed: %.2f%% | Mean confidence: %.2f | Mean weight: %.2f | Time: %.1f sec\n', ...
            change_percent, mean_confidence, mean(core_weights), iter_time);
    
    if change_criterion_met && conf_criterion_met
        break;
    end
end

%% Final output
fprintf('\n===== Processing completed after %d iterations =====\n', iter_idx);
fprintf('Final change: %.2f%% (Threshold: %.2f%%)\n', ...
        iter_info(end).unit_change, change_thr*100);
fprintf('Final mean confidence: %.2f (Threshold: %.2f)\n', ...
        iter_info(end).mean_confidence, conf_thr);

if strcmp(method, 'voxel')
    individual_network_map_ds = zeros(size(Gmask));
    max_corr_map_ds = zeros(size(Gmask));
    final_confidence_map_ds = zeros(size(Gmask));
    
    for i = 1:num_units
        coord = ds_data.unit_coords(i, :);
        individual_network_map_ds(coord(1), coord(2), coord(3)) = current_net_labels(i);
        max_corr_map_ds(coord(1), coord(2), coord(3)) = max_corr_vals(i);
        final_confidence_map_ds(coord(1), coord(2), coord(3)) = roi_confidence(i);
    end
    
    fprintf('Upsampling results to original space...\n');
    individual_network_map = upsample_volume(individual_network_map_ds, ...
        original_size, downsample_method, 'nearest');
    max_corr_map = upsample_volume(max_corr_map_ds, ...
        original_size, downsample_method, 'linear');
    final_confidence_map = upsample_volume(final_confidence_map_ds, ...
        original_size, downsample_method, 'linear');
    
    individual_network_map = individual_network_map .* Gmask_original;
    max_corr_map = max_corr_map .* Gmask_original;
    final_confidence_map = final_confidence_map .* Gmask_original;
    
else
    individual_network_map = zeros(size(Gmask_original));
    max_corr_map = zeros(size(Gmask_original));
    final_confidence_map = zeros(size(Gmask_original));
    
    for i = 1:num_units
        if strcmp(method, 'prior')
            region_mask = (unit_masks == unit_ids(i)) & (Gmask_original > 0);
        else
            region_mask = (unit_masks == i) & (Gmask_original > 0);
        end
        individual_network_map(region_mask) = current_net_labels(i);
        max_corr_map(region_mask) = max_corr_vals(i);
        final_confidence_map(region_mask) = roi_confidence(i);
    end
end

%% Save final results
final_dir = fullfile(output_path, 'Final_Parcellation');
if ~exist(final_dir, 'dir'), mkdir(final_dir); end

vol_out = Gmask_head;
vol_out.fname = fullfile(final_dir, 'individual_network_map.nii');
spm_write_vol(vol_out, individual_network_map);

vol_out.fname = fullfile(final_dir, 'max_correlation_value.nii');
vol_out.dt = [16,0];
spm_write_vol(vol_out, max_corr_map);

vol_out.fname = fullfile(final_dir, 'final_confidence_map.nii');
spm_write_vol(vol_out, final_confidence_map);

if strcmp(method, 'voxel')
    unit_info = table(unit_ids(:), ds_data.unit_coords(:,1), ds_data.unit_coords(:,2), ds_data.unit_coords(:,3), ...
        current_net_labels, max_corr_vals, roi_confidence, ...
        'VariableNames', {'UnitID', 'X', 'Y', 'Z', 'Network', 'MaxCorrelation', 'Confidence'});
else
    unit_info = table(unit_ids(:), current_net_labels, max_corr_vals, roi_confidence, ...
        'VariableNames', {'UnitID', 'Network', 'MaxCorrelation', 'Confidence'});
end
writetable(unit_info, fullfile(final_dir, 'unit_assignments.csv'));

save(fullfile(output_path, 'parcellation_summary.mat'), ...
    'iter_info', 'percent_top', 'max_iter', 'change_thr', 'conf_thr', 'method', 'tSNR_source', 'save_intermediate');

if iter_idx > 0
    plot_iteration_progress(iter_info, output_path);
end

%% Calculate Network Functional Connectivity and Plot Heatmap
fprintf('\n===== Calculating Network Functional Connectivity =====\n');

final_networks = unique(current_net_labels(current_net_labels > 0));
num_final_nets = numel(final_networks);
fprintf('Found %d final networks for FC calculation\n', num_final_nets);

if strcmp(method, 'voxel')
    bold_data_fc = individual_bold;
    network_map_fc = individual_network_map;
else
    bold_data_fc = individual_bold;
    network_map_fc = individual_network_map;
end

network_ts = zeros(num_final_nets, size(bold_data_fc,4));
network_labels = final_networks;
valid_network_indices = [];

for n = 1:num_final_nets
    net_mask = (network_map_fc == final_networks(n)) & (Gmask_original > 0);
    if sum(net_mask(:)) > 10
        net_voxels = bold_data_fc(repmat(net_mask, [1,1,1,size(bold_data_fc,4)]));
        net_voxels = reshape(net_voxels, [], size(bold_data_fc,4));
        
        ts_var = var(net_voxels, 0, 2);
        if any(ts_var > eps)
            network_ts(n,:) = mean(net_voxels, 1);
            valid_network_indices = [valid_network_indices, n];
            fprintf('Network %d: %d voxels\n', final_networks(n), size(net_voxels,1));
        else
            warning('Network %d has constant time series, skipping', final_networks(n));
        end
    else
        warning('Network %d has insufficient voxels (%d), skipping', final_networks(n), sum(net_mask(:)));
    end
end

if isempty(valid_network_indices)
    error('No valid networks found for FC calculation');
end

network_ts = network_ts(valid_network_indices, :);
network_labels = network_labels(valid_network_indices);
num_valid_nets = numel(network_labels);

fprintf('Calculating FC matrix for %d valid networks...\n', num_valid_nets);

FC_matrix = corr(network_ts', 'rows', 'complete');
FC_matrix(isnan(FC_matrix) | isinf(FC_matrix)) = 0;

fc_filename = fullfile(final_dir, 'Network_FC.mat');
save(fc_filename, 'FC_matrix', 'network_labels', 'network_ts');
fprintf('Saved FC matrix to: %s\n', fc_filename);

csv_filename = fullfile(final_dir, 'Network_FC.csv');
csvwrite(csv_filename, FC_matrix);
fprintf('Saved FC matrix (CSV) to: %s\n', csv_filename);

fprintf('Plotting FC heatmap...\n');
plot_FC_heatmap(FC_matrix, network_labels, final_dir);

fprintf('Results saved to: %s\n', output_path);
end

%% tSNR Calculation Function
function [tSNR_map, mean_tSNR] = compute_temporal_snr(data, mask)

fprintf('Computing tSNR map...\n');

data_2D = reshape(data, [], size(data,4));

time_mean = mean(data_2D, 2, 'omitnan');
time_std = std(data_2D, 0, 2, 'omitnan');

tSNR_values = time_mean ./ time_std;

tSNR_values(isinf(tSNR_values) | isnan(tSNR_values)) = 0;

tSNR_map = reshape(tSNR_values, size(data(:,:,:,1)));

mask_linear = mask(:) > 0;
tSNR_masked = tSNR_values(mask_linear);
mean_tSNR = mean(tSNR_masked(tSNR_masked > 0), 'omitnan');

fprintf('tSNR calculation completed. Mean tSNR: %.2f\n', mean_tSNR);
end

%% Helper function for downsampling volume data
function [bold_ds, mask_ds, network_ds, var_ds, snr_ds, ds_info] = downsample_volume_data(...
    bold_data, mask, network, var_map, snr_map, downsample_factor, method)

original_size = size(mask);
ds_size = ceil(original_size / downsample_factor);

fprintf('Downsampling from %dx%dx%d to %dx%dx%d\n', ...
    original_size(1), original_size(2), original_size(3), ...
    ds_size(1), ds_size(2), ds_size(3));

mask_ds = zeros(ds_size);
network_ds = zeros(ds_size);
if ~isempty(var_map)
    var_ds = zeros(ds_size);
else
    var_ds = [];
end
if ~isempty(snr_map)
    snr_ds = zeros(ds_size);
else
    snr_ds = [];
end

for i = 1:ds_size(1)
    for j = 1:ds_size(2)
        for k = 1:ds_size(3)
            i_range = (i-1)*downsample_factor + 1 : min(i*downsample_factor, original_size(1));
            j_range = (j-1)*downsample_factor + 1 : min(j*downsample_factor, original_size(2));
            k_range = (k-1)*downsample_factor + 1 : min(k*downsample_factor, original_size(3));
            
            mask_block = mask(i_range, j_range, k_range);
            
            if mean(mask_block(:)) > 0.5
                mask_ds(i,j,k) = 1;
            else
                mask_ds(i,j,k) = 0;
            end
            
            network_block = network(i_range, j_range, k_range);
            network_block = network_block(mask_block > 0);
            if ~isempty(network_block)
                network_ds(i,j,k) = mode(network_block);
            end
            
            if ~isempty(var_map)
                var_block = var_map(i_range, j_range, k_range);
                var_block = var_block(mask_block > 0);
                if ~isempty(var_block)
                    var_ds(i,j,k) = mean(var_block);
                end
            end
            
            if ~isempty(snr_map)
                snr_block = snr_map(i_range, j_range, k_range);
                snr_block = snr_block(mask_block > 0);
                if ~isempty(snr_block)
                    snr_ds(i,j,k) = mean(snr_block);
                end
            end
        end
    end
end

bold_ds = zeros([ds_size, size(bold_data,4)]);
for t = 1:size(bold_data,4)
    fprintf('Downsampling time point %d/%d\n', t, size(bold_data,4));
    
    time_volume = bold_data(:,:,:,t);
    time_volume_ds = zeros(ds_size);
    
    for i = 1:ds_size(1)
        for j = 1:ds_size(2)
            for k = 1:ds_size(3)
                i_range = (i-1)*downsample_factor + 1 : min(i*downsample_factor, original_size(1));
                j_range = (j-1)*downsample_factor + 1 : min(j*downsample_factor, original_size(2));
                k_range = (k-1)*downsample_factor + 1 : min(k*downsample_factor, original_size(3));
                
                bold_block = time_volume(i_range, j_range, k_range);
                mask_block = mask(i_range, j_range, k_range);
                bold_block_masked = bold_block(mask_block > 0);
                
                if ~isempty(bold_block_masked)
                    if strcmp(method, 'average')
                        time_volume_ds(i,j,k) = mean(bold_block_masked);
                    else
                        center_idx = ceil(length(i_range)/2);
                        time_volume_ds(i,j,k) = bold_block(center_idx, center_idx, center_idx);
                    end
                end
            end
        end
    end
    bold_ds(:,:,:,t) = time_volume_ds;
end

ds_info.original_size = original_size;
ds_info.ds_size = ds_size;
ds_info.downsample_factor = downsample_factor;
ds_info.method = method;
end

%% Helper function for upsampling volume data
function volume_us = upsample_volume(volume_ds, target_size, method, data_type)

if nargin < 4
    data_type = 'linear';
end

ds_size = size(volume_ds);
if numel(ds_size) == 2
    ds_size(3) = 1;
end

scale_factors = target_size(1:3) ./ ds_size(1:3);

[x_ds, y_ds, z_ds] = ndgrid(1:ds_size(1), 1:ds_size(2), 1:ds_size(3));
[x_us, y_us, z_us] = ndgrid(1:target_size(1), 1:target_size(2), 1:target_size(3));

x_us_scaled = (x_us - 0.5) / scale_factors(1) + 0.5;
y_us_scaled = (y_us - 0.5) / scale_factors(2) + 0.5;
z_us_scaled = (z_us - 0.5) / scale_factors(3) + 0.5;

if strcmp(data_type, 'nearest')
    volume_us = interpn(x_ds, y_ds, z_ds, volume_ds, ...
        x_us_scaled, y_us_scaled, z_us_scaled, 'nearest', 0);
else
    volume_us = interpn(x_ds, y_ds, z_ds, volume_ds, ...
        x_us_scaled, y_us_scaled, z_us_scaled, 'linear', 0);
end

fprintf('Upsampled from %dx%dx%d to %dx%dx%d\n', ...
    ds_size(1), ds_size(2), ds_size(3), ...
    target_size(1), target_size(2), target_size(3));
end

%% Helper function for plotting iteration progress
function plot_iteration_progress(iter_info, output_path)

if isempty(iter_info) || isempty([iter_info.iteration])
    return;
end

iterations = [iter_info.iteration];
changes = [iter_info.unit_change];
times = [iter_info.time_sec];
conf_values = [iter_info.mean_confidence];
thr_value = iter_info(1).conf_threshold;

if isfield(iter_info, 'change_threshold')
    change_thr_value = iter_info(1).change_threshold;
else
    if numel(changes) > 2
        change_thr_value = mean(changes(1:min(3, numel(changes)))) * 0.3;
    else
        change_thr_value = min(changes) * 0.5;
    end
end

if numel(iterations) == 1
    iterations = [iterations, iterations];
    changes = [changes, changes];
    times = [times, times];
    conf_values = [conf_values, conf_values];
end

fig = figure('Visible', 'off');
set(fig, 'Position', [100, 100, 800, 800]);

subplot(3,1,1);
plot(iterations, changes, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(change_thr_value, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Change Threshold');
xlabel('Iteration');
ylabel('Unit Change (%)');
title('Assignment Change per Iteration');
grid on;
xlim([min(iterations), max(iterations)]);
ylim([0, max([changes, change_thr_value]) * 1.1]);
legend('Location', 'best');

subplot(3,1,2);
bar(iterations, times, 'FaceColor', [0.5, 0.5, 0.8]);
xlabel('Iteration');
ylabel('Time (sec)');
title('Computation Time per Iteration');
grid on;
xlim([min(iterations)-0.5, max(iterations)+0.5]);

subplot(3,1,3);
plot(iterations, conf_values, 'g-s', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(thr_value, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Confidence Threshold');
xlabel('Iteration');
ylabel('Confidence Ratio');
title(sprintf('Mean Confidence Ratio (Threshold: %.2f)', thr_value));
grid on;
xlim([min(iterations), max(iterations)]);
ylim([0, max([conf_values, thr_value]) * 1.1]);
legend('Location', 'best');

saveas(fig, fullfile(output_path, 'iteration_progress.png'));
close(fig);
fprintf('Saved iteration progress plot\n');
end

%% Helper function for plotting FC heatmap
function plot_FC_heatmap(FC_matrix, network_labels, output_path)

fig = figure('Position', [100, 100, 800, 700], 'Color', 'white');

imagesc(FC_matrix, [-1, 1]);
colormap(jet(256));
colorbar;

num_nets = length(network_labels);
set(gca, 'XTick', 1:num_nets, 'XTickLabel', network_labels, ...
         'YTick', 1:num_nets, 'YTickLabel', network_labels, ...
         'FontSize', 10);

xtickangle(45);

title('Network Functional Connectivity Matrix', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Networks', 'FontSize', 12);
ylabel('Networks', 'FontSize', 12);

grid on;

if num_nets <= 15
    [x, y] = meshgrid(1:num_nets, 1:num_nets);
    textStrings = num2str(FC_matrix(:), '%.2f');
    textStrings = strtrim(cellstr(textStrings));
    text(x(:), y(:), textStrings, 'HorizontalAlignment', 'center', ...
         'FontSize', 8, 'Color', 'white');
end

axis equal tight;

heatmap_filename = fullfile(output_path, 'Network_FC_heatmap.png');
saveas(fig, heatmap_filename);
fprintf('Saved FC heatmap to: %s\n', heatmap_filename);

heatmap_highres = fullfile(output_path, 'Network_FC_heatmap.fig');
saveas(fig, heatmap_highres);
fprintf('Saved high-res FC heatmap to: %s\n', heatmap_highres);

close(fig);
end
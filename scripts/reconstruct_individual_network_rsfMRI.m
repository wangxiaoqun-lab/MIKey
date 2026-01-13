function [individual_network_map, iter_info, max_corr_map] = reconstruct_individual_network_rsfMRI(...
    individual_bold, group_final_network, Gmask_head, percent_top, ...
    output_path, max_iter, voxel_change_thr, prior_label_file, varargin)
%% Iterative Individual Network Reconstruction using Prior Regions
% Reconstructs individual network through iterative refinement at region level
%
% Required Parameters:
%   individual_bold      : 4D individual BOLD data [x,y,z,time]
%   group_final_network  : 3D group network labels [x,y,z]
%   Gmask_head           : Header for binary mask
%   percent_top          : Top percentage threshold (0-1)
%   output_path          : Output directory path
%   max_iter             : Maximum number of iterations
%   voxel_change_thr     : Region change percentage threshold (0-1)
%   prior_label_file     : File path to prior region labels (e.g., 'Label_Mouse_604_v38.nii')
%
% Optional Parameters:
%   TR                   : Sampling interval (for filtering)
%   filter_band          : [lowFreq, highFreq] for bandpass filtering
%
% Output:
%   individual_network_map : Final individual network map
%   iter_info             : Structure with iteration details
%   max_corr_map          : Maximum correlation values per region (mapped to voxels)

%% Validate required parameters
if nargin < 8
    error('Insufficient input arguments: Missing required parameters');
end
if percent_top < 0 || percent_top > 1
    error('percent_top must be between 0 and 1');
end
if voxel_change_thr < 0 || voxel_change_thr > 1
    error('voxel_change_thr must be between 0 and 1');
end

%% Parse optional parameters
TR = [];
filter_band = [];
if nargin >= 9 && ~isempty(varargin{1})
    TR = varargin{1};
end
if nargin >= 10 && ~isempty(varargin{2})
    filter_band = varargin{2};
end

%% Handle filtering parameters
apply_filter = false;
if ~isempty(filter_band) && ~isempty(TR)
    lowFreq = filter_band(1);
    highFreq = filter_band(2);
    fs = 1/TR;
    nyquist = fs/2;
    if lowFreq >= 0 && highFreq > lowFreq && highFreq < nyquist
        apply_filter = true;
        [b, a] = butter(2, [lowFreq, highFreq]/(fs/2), 'bandpass');
    end
end

%% Load and validate mask
Gmask = spm_read_vols(Gmask_head);
if ~isequal(size(Gmask), size(individual_bold(:,:,:,1)))
    error('Mask dimensions mismatch');
end

%% Load prior region labels
prior_head = spm_vol(prior_label_file);
prior_label = spm_read_vols(prior_head);
if ~isequal(size(prior_label), size(individual_bold(:,:,:,1)))
    error('Prior label dimensions mismatch');
end

%% Extract region information
all_regions = unique(prior_label(prior_label > 0));
num_regions = numel(all_regions);
fprintf('Loaded %d prior regions from: %s\n', num_regions, prior_label_file);

%% Initialize region network labels using group network
region_net_labels = zeros(num_regions, 1);
for i = 1:num_regions
    region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
    net_in_region = group_final_network(region_mask);
    net_in_region = net_in_region(net_in_region > 0); % Exclude background
    if ~isempty(net_in_region)
        region_net_labels(i) = mode(net_in_region);
    end
end

%% Data preprocessing - Extract region time series
fprintf('Extracting region time series...\n');
region_ts = zeros(num_regions, size(individual_bold, 4));

% Apply mask to BOLD data
masked_bold = individual_bold .* repmat(Gmask, [1,1,1,size(individual_bold,4)]);

% Extract time series for each region
for i = 1:num_regions
    region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
    if any(region_mask(:))
        region_voxels = masked_bold(repmat(region_mask, [1,1,1,size(masked_bold,4)]));
        region_voxels = reshape(region_voxels, [], size(masked_bold,4));
        region_ts(i,:) = mean(region_voxels, 1);
    end
end

% Apply temporal filtering if enabled
if apply_filter
    fprintf('Applying bandpass filter [%.3f-%.3f Hz] to region time series...\n', lowFreq, highFreq);
    region_ts = double(region_ts);
    parfor i = 1:size(region_ts, 1)
        region_ts(i,:) = filtfilt(b, a, region_ts(i,:));
    end
end

%% Identify valid networks
valid_nets = unique(region_net_labels(region_net_labels > 0));
num_nets = numel(valid_nets);
fprintf('Identified %d valid networks for iteration\n', num_nets);

%% Initialize iteration variables
current_net_labels = region_net_labels;
changed_regions = num_regions; % Initialize to 100% change
iter_idx = 0;
iter_info = struct('iteration', [], 'region_change', [], 'time_sec', []);

% Create output directory
if ~exist(output_path, 'dir'), mkdir(output_path); end

%% Main iteration loop
fprintf('\n===== Starting Region-Level Iterative Reconstruction =====\n');
fprintf('Max iterations: %d | Region change threshold: %.2f%%\n', ...
    max_iter, voxel_change_thr*100);

while iter_idx < max_iter && changed_regions > voxel_change_thr * num_regions
    iter_idx = iter_idx + 1;
    tic;
    fprintf('\n----- Iteration %d/%d -----\n', iter_idx, max_iter);
    
    % Create iteration directory
    iter_dir = fullfile(output_path, sprintf('Iter_%d', iter_idx));
    if ~exist(iter_dir, 'dir'), mkdir(iter_dir); end
    
    %% Step 1: Calculate network time series from current labels
    fprintf('Calculating network time series from %d regions...\n', num_regions);
    net_ts = zeros(num_nets, size(region_ts, 2));
    for n = 1:num_nets
        member_regions = (current_net_labels == valid_nets(n));
        if sum(member_regions) > 0
            net_ts(n, :) = mean(region_ts(member_regions, :), 1);
        else
            net_ts(n, :) = zeros(1, size(region_ts, 2));
        end
    end
    
    %% Step 2: Compute region-network correlations
    fprintf('Computing region-network correlations...\n');
    region_net_corr = corr(region_ts', net_ts');
    
    %% Step 3: Apply top percentage threshold and assign networks
    fprintf('Assigning regions with %.0f%% threshold...\n', percent_top*100);
    new_net_labels = zeros(num_regions, 1);
    max_corr = zeros(num_regions, 1); % Store max correlation per region
    
    parfor r = 1:num_regions
        corr_vals = region_net_corr(r, :);
        [max_corr(r), max_idx] = max(corr_vals);
        
        % Apply top percentage threshold
        [~, sorted_idx] = sort(corr_vals, 'descend');
        top_n = max(1, round(percent_top * num_nets));
        candidate_nets = valid_nets(sorted_idx(1:top_n));
        
        % Among top networks, select the one with highest correlation
        [~, idx_in_candidate] = max(corr_vals(sorted_idx(1:top_n)));
        new_net_labels(r) = candidate_nets(idx_in_candidate);
    end
    
    %% Step 4: Calculate region changes
    changed_mask = (new_net_labels ~= current_net_labels);
    changed_regions = sum(changed_mask);
    change_percent = 100 * changed_regions / num_regions;
    
    % Update labels for next iteration
    prev_net_labels = current_net_labels;
    current_net_labels = new_net_labels;
    
    %% Step 5: Save iteration results
    % Create 3D network map
    iter_network_map = zeros(size(Gmask));
    for i = 1:num_regions
        region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
        iter_network_map(region_mask) = current_net_labels(i);
    end
    
    % Save network map
    vol_out = Gmask_head;
    vol_out.fname = fullfile(iter_dir, 'individual_network_map.nii');
    spm_write_vol(vol_out, iter_network_map);
    
    % Save max correlation map (mapped to regions)
    region_corr_map = zeros(size(Gmask));
    for i = 1:num_regions
        region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
        region_corr_map(region_mask) = max_corr(i);
    end
    vol_out.fname = fullfile(iter_dir, 'max_correlation_value.nii');
    vol_out.dt = [16, 0]; % Float32 precision
    spm_write_vol(vol_out, region_corr_map);
    
    % Save changed regions map
    changed_map = zeros(size(Gmask));
    for i = 1:num_regions
        if changed_mask(i)
            region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
            changed_map(region_mask) = 1;
        end
    end
    vol_out.fname = fullfile(iter_dir, 'changed_regions.nii');
    spm_write_vol(vol_out, changed_map);
    
    % Save correlation matrix
    save(fullfile(iter_dir, 'region_network_correlations.mat'), ...
        'region_net_corr', 'max_corr', 'net_ts', 'valid_nets');
    
    %% Record iteration info
    iter_time = toc;
    iter_info(iter_idx).iteration = iter_idx;
    iter_info(iter_idx).region_change = change_percent;
    iter_info(iter_idx).time_sec = iter_time;
    
    fprintf('Region change: %.2f%% | Time: %.1f sec\n', change_percent, iter_time);
    
    % Check stopping condition
    if change_percent <= voxel_change_thr * 100
        fprintf('Stopping criterion met (change <= %.2f%%)\n', voxel_change_thr*100);
        break;
    end
end

%% Final output
fprintf('\n===== Reconstruction Completed =====\n');
fprintf('Total iterations: %d | Final region change: %.2f%%\n', ...
    iter_idx, iter_info(end).region_change);

% Create final network map
individual_network_map = zeros(size(Gmask));
for i = 1:num_regions
    region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
    individual_network_map(region_mask) = current_net_labels(i);
end

% Create final correlation value map
max_corr_map = zeros(size(Gmask));
for i = 1:num_regions
    region_mask = (prior_label == all_regions(i)) & (Gmask > 0);
    max_corr_map(region_mask) = max_corr(i);
end

% Save final results
final_dir = fullfile(output_path, 'Final_Parcellation');
if ~exist(final_dir, 'dir'), mkdir(final_dir); end

% Save final network map
vol_out = Gmask_head;
vol_out.fname = fullfile(final_dir, 'individual_network_map.nii');
spm_write_vol(vol_out, individual_network_map);

% Save max correlation map
vol_out.fname = fullfile(final_dir, 'max_corr_value.nii');
vol_out.dt = [16, 0]; % Float32 precision
spm_write_vol(vol_out, max_corr_map);

% Save region labels and assignments
region_info = table(all_regions, current_net_labels, max_corr, ...
    'VariableNames', {'RegionID', 'Network', 'MaxCorrelation'});
writetable(region_info, fullfile(final_dir, 'region_assignments.csv'));

% Save iteration summary
save(fullfile(output_path, 'reconstruction_summary.mat'), ...
    'iter_info', 'percent_top', 'max_iter', 'voxel_change_thr');

% Plot iteration progress
plot_iteration_progress(iter_info, output_path);

fprintf('Results saved to: %s\n', output_path);
end

%% Helper function for plotting iteration progress
function plot_iteration_progress(iter_info, output_path)
fig = figure('Visible', 'off');
set(fig, 'Position', [100, 100, 800, 600]);

% Extract data
iterations = [iter_info.iteration];
changes = [iter_info.region_change];
times = [iter_info.time_sec];

% Plot change percentage
subplot(2,1,1);
plot(iterations, changes, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Iteration');
ylabel('Region Change (%)');
title('Region Assignment Change per Iteration');
grid on;
xlim([1, max(iterations)]);
ylim([0, max(changes)*1.1]);

% Plot time
subplot(2,1,2);
bar(iterations, times, 'FaceColor', [0.5, 0.5, 0.8]);
xlabel('Iteration');
ylabel('Time (sec)');
title('Computation Time per Iteration');
grid on;
xlim([0.5, max(iterations)+0.5]);

% Save figure
saveas(fig, fullfile(output_path, 'iteration_progress.png'));
close(fig);
fprintf('Saved iteration progress plot to: %s\n', fullfile(output_path, 'iteration_progress.png'));
end
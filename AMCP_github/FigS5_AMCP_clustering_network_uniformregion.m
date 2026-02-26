clc; clear

%% Preparation
WholePath = '/newdatc/home/wanglab45/AMCP/AMCP_MRI';
codepath = fullfile(WholePath,'zyj_MRI_code');
templatepath = fullfile(WholePath,'Mouse_Template_38');
template = fullfile(templatepath,'Template_Mouse_v38.nii,1');
Gmask = spm_read_vols(spm_vol(fullfile(templatepath,'lmask_Mouse_v38.nii')));

cd(codepath);
addpath(genpath(codepath));

Excel = fullfile(WholePath,'Exp_recording_AMCP_BOLD.xlsx');
BOLD_ses = 4;
sheet = 'RawData';

[~, ~, CellData] = xlsread(Excel, sheet);
ExpTable = cell2table(CellData(2:end, 1), 'VariableNames', CellData(1, 1));

img_type = {
    'R_12rp_250pc_snrsmoBOLD_top.nii';
    'R_12rp_250pc_gs_snrsmoBOLD_top.nii'
    };

for img = 1:numel(img_type)
    % Updated parameter grid
    num_roi_list = [500, 750, 1000, 1200, 1500, 2000];
    k_clusters_list = 2:30;
    n_repeats = 5;
    percent_top = 0.1;
    smoothing_fwhm = 0.3;
    block_size = 2000;
    
    % Load mask
    Gmask_head = spm_vol(fullfile(templatepath, 'AMCP_temp', 'AMCP_GMWM_mask.nii'));
    Gmask = spm_read_vols(Gmask_head);
    Gmask = logical(Gmask);
    voxel_indices = find(Gmask);
    [xx, yy, zz] = meshgrid(1:size(Gmask, 2), 1:size(Gmask, 1), 1:size(Gmask, 3));
    coordinates = [xx(Gmask), yy(Gmask), zz(Gmask)];
    
    % Preload subject data with memory mapping
    fprintf('Preloading BOLD data using memory mapping...\n');
    time_paths = ExpTable.path;
    valid_subs = {};
    
    for idx = 1:size(time_paths, 1)
        func_files = dir(fullfile(WholePath, cell2mat(time_paths(idx)), 'func', img_type{img}));
        if ~isempty(func_files)
            valid_subs{end+1} = time_paths{idx};
        end
    end
    
    n_subs = numel(valid_subs);
    
    % Preload all BOLD data
    all_bold_data = cell(n_subs, BOLD_ses);
    
    parfor sub_idx = 1:n_subs
        for s = 1:BOLD_ses
            func_files = dir(fullfile(WholePath, valid_subs{sub_idx}, 'func', ...
                [strrep(valid_subs{sub_idx}, 'sub', 'sub-') '*run-' num2str(s) '*' img_type{img}]));
            
            if isempty(func_files)
                continue;
            end
            
            filepath = fullfile(func_files(1).folder, func_files(1).name);
            vol = spm_vol(filepath);
            all_img = spm_read_vols(vol);
            all_img = single(all_img);
            all_img_flat = reshape(all_img, [], size(all_img,4));
            all_bold_data{sub_idx, s} = all_img_flat(voxel_indices, :)';
        end
    end
    
    % Setup results structure
    results = struct();
    results.param_combinations = [];
    results.mean_similarity = [];
    results.std_similarity = [];
    results.elapsed_times = [];
    
    % Parameter optimization loop
    total_combinations = length(num_roi_list) * length(k_clusters_list);
    combo_idx = 1;
    
    % Create parallel pool
    if isempty(gcp('nocreate'))
        parpool('local');
    end
    
    % Create output directory for network maps
    netmap_dest = fullfile(WholePath, '2nd_results', 'BOLD', 'clutering network', img_type{img});
    if ~exist(netmap_dest, 'dir')
        mkdir(netmap_dest);
    end
    
    for nri = 1:length(num_roi_list)
        num_roi = num_roi_list(nri);
        fprintf('== Processing num_roi = %d (%d/%d) ==\n', num_roi, nri, length(num_roi_list));
        
        % Generate ROI centers
        fprintf('  Generating %d ROIs...\n', num_roi);
        [~, roi_centers] = kmeans(coordinates, num_roi, 'Replicates', 3, 'Options', statset('UseParallel', true));
        roi_indices = dsearchn(coordinates, roi_centers);
        
        % Precompute binary matrices with block processing
        fprintf('  Computing binary matrices for %d subjects (block size: %d)...\n', n_subs, block_size);
        all_binary_mats = cell(n_subs, BOLD_ses);
        
        for sub_idx = 1:n_subs
            for s = 1:BOLD_ses
                bold_data = all_bold_data{sub_idx, s};
                if isempty(bold_data)
                    continue;
                end
                
                % Block processing for large matrices
                n_voxels = size(bold_data, 2);
                binary_matrix = zeros(n_voxels, num_roi, 'single');
                
                for block_start = 1:block_size:n_voxels
                    block_end = min(block_start+block_size-1, n_voxels);
                    block_idx = block_start:block_end;
                    current_block_size = length(block_idx);
                    
                    partial_corr = corr(bold_data(:, block_idx), bold_data(:, roi_indices));
                    
                    [~, sorted_idx] = sort(partial_corr, 2, 'descend');
                    top_n = round(percent_top * num_roi);
                    
                    % Preallocate binary matrix for this block
                    block_binary = zeros(current_block_size, num_roi, 'single');
                    
                    % Create linear indices directly
                    m = current_block_size;
                    linear_ind = (1:m)' + (sorted_idx(:, 1:top_n) - 1) * m;
                    block_binary(linear_ind) = 1;
                    
                    binary_matrix(block_idx, :) = block_binary;
                end
                
                all_binary_mats{sub_idx, s} = binary_matrix;
            end
        end
        
        for kci = 1:length(k_clusters_list)
            k_clusters = k_clusters_list(kci);
            fprintf('    Testing k_clusters = %d (%d/%d)...\n', k_clusters, kci, length(k_clusters_list));
            
            tic;
            similarity_scores = zeros(n_repeats, 1);
            
            % Parallel loop with network map saving
            parfor rep = 1:n_repeats
                try
                    % Random split (50/50)
                    split_mask = randperm(n_subs);
                    group1_subs = split_mask(1:floor(n_subs/2));
                    group2_subs = split_mask(floor(n_subs/2)+1:end);
                    
                    % Compute group matrices
                    group1_mat = zeros(size(all_binary_mats{1,1}), 'single');
                    group2_mat = zeros(size(all_binary_mats{1,1}), 'single');
                    
                    for i = group1_subs
                        for s = 1:BOLD_ses
                            if ~isempty(all_binary_mats{i,s})
                                group1_mat = group1_mat + all_binary_mats{i,s};
                            end
                        end
                    end
                    
                    for i = group2_subs
                        for s = 1:BOLD_ses
                            if ~isempty(all_binary_mats{i,s})
                                group2_mat = group2_mat + all_binary_mats{i,s};
                            end
                        end
                    end
                    
                    % Compute network maps
                    net_map1 = compute_clustering_network_map(group1_mat, Gmask, voxel_indices, ...
                        num_roi, smoothing_fwhm, k_clusters, numel(group1_subs)*BOLD_ses);
                    
                    net_map2 = compute_clustering_network_map(group2_mat, Gmask, voxel_indices, ...
                        num_roi, smoothing_fwhm, k_clusters, numel(group2_subs)*BOLD_ses);
                    
                    % Save network maps
                    save_network_map(net_map1, Gmask_head, netmap_dest, ...
                        sprintf('netmap_roi%d_k%d_rep%03d_group1.nii', num_roi, k_clusters, rep));
                    
                    save_network_map(net_map2, Gmask_head, netmap_dest, ...
                        sprintf('netmap_roi%d_k%d_rep%03d_group2.nii', num_roi, k_clusters, rep));
                    
                    % Calculate similarity
                    similarity_scores(rep) = dice_coefficient(net_map1, net_map2, Gmask);
                catch ME
                    fprintf('Error in repeat %d: %s\n', rep, ME.message);
                    similarity_scores(rep) = NaN;
                end
            end
            
            % Process results
            valid_scores = similarity_scores(~isnan(similarity_scores));
            if isempty(valid_scores)
                error('All repetitions failed for num_roi=%d, k_clusters=%d', num_roi, k_clusters);
            end
            
            elapsed_time = toc;
            mean_sim = mean(valid_scores);
            std_sim = std(valid_scores);
            
            % Store results
            results.param_combinations(combo_idx, :) = [num_roi, k_clusters];
            results.mean_similarity(combo_idx, 1) = mean_sim;
            results.std_similarity(combo_idx, 1) = std_sim;
            results.elapsed_times(combo_idx, 1) = elapsed_time;
            cd(netmap_dest);
            save('results.mat', 'results');
            fprintf('      Mean Similarity: %.4f ¡À %.4f | Time: %.1f sec\n', mean_sim, std_sim, elapsed_time);
            combo_idx = combo_idx + 1;
        end
        
        % Clear variables to free memory
        clear all_binary_mats;
        java.lang.System.gc();
    end
    
    % Find optimal parameters
    [best_sim, best_idx] = max(results.mean_similarity);
    best_num_roi = results.param_combinations(best_idx, 1);
    best_k_clusters = results.param_combinations(best_idx, 2);
    
    % Setup destination
    dest = fullfile(WholePath, '2nd_results', 'BOLD', 'clutering network', img_type{img}, 'parameter_optimization');
    if ~exist(dest, 'dir')
        mkdir(dest);
    end
    cd(dest);
    
    % Save optimization results
    save('parameter_optimization_results.mat', 'results');
    
    % Visualization
    figure('Color', 'w', 'Position', [10, 10, 2000, 1000]);
    
    % 3D surface plot
    ax1 = subplot('Position', [0.07, 0.1, 0.28, 0.8]);
    [X, Y] = meshgrid(num_roi_list, k_clusters_list);
    Z = griddata(results.param_combinations(:,1), results.param_combinations(:,2), ...
        1 - results.mean_similarity, X, Y);
    surf(X, Y, Z, 'FaceAlpha', 0.8);
    xlabel('Number of ROIs');
    ylabel('Number of Clusters');
    zlabel('Instability');
    title('Network Instability');
    grid on;
    colormap(jet);
    colorbar;
    view(-50, 30);
    
    % Computation time bar plot
    ax2 = subplot('Position', [0.40, 0.58, 0.55, 0.35]);
    bar(results.elapsed_times);
    set(gca, 'XTick', 1:length(results.elapsed_times), ...
        'XTickLabel', arrayfun(@(i) sprintf('%d-%d', results.param_combinations(i,1), results.param_combinations(i,2)), ...
        1:length(results.elapsed_times), 'UniformOutput', false));
    xtickangle(90);
    ylabel('Computation Time (sec)');
    title('Computation Time per Parameter Set');
    ax2.XAxis.FontSize = ax2.XAxis.FontSize * 0.8;
    
    % Instability plot
    ax3 = subplot('Position', [0.40, 0.10, 0.55, 0.35]);
    Instability = 1 - results.mean_similarity;
    plot(Instability);
    set(gca, 'XTick', 1:length(Instability), ...
        'XTickLabel', arrayfun(@(i) sprintf('%d-%d', results.param_combinations(i,1), results.param_combinations(i,2)), ...
        1:length(Instability), 'UniformOutput', false));
    xtickangle(90);
    ylabel('Instability');
    xlabel('Parameter Combination (ROIs-Clusters)');
    title('Network Stability');
    grid on;
    ax3.XAxis.FontSize = ax3.XAxis.FontSize * 0.5;
    
    saveas(gcf, 'parameter_optimization_results.png');
    saveas(gcf, 'parameter_optimization_results.svg');
    
    % Generate final network with best parameters
    fprintf('\nGenerating final network with best parameters...\n');
    
    % Generate ROIs for best parameters
    [~, roi_centers] = kmeans(coordinates, best_num_roi, 'Replicates', 5);
    roi_indices = dsearchn(coordinates, roi_centers);
    
    % Compute full group binary matrix with block processing
    full_binary_mat = zeros(length(voxel_indices), best_num_roi, 'single');
    for sub_idx = 1:n_subs
        for s = 1:BOLD_ses
            bold_data = all_bold_data{sub_idx, s};
            if isempty(bold_data)
                continue;
            end
            
            % Block processing
            n_voxels = size(bold_data, 2);
            for block_start = 1:block_size:n_voxels
                block_end = min(block_start+block_size-1, n_voxels);
                block_idx = block_start:block_end;
                current_block_size = length(block_idx);
                
                partial_corr = corr(bold_data(:, block_idx), bold_data(:, roi_indices));
                
                [~, sorted_idx] = sort(partial_corr, 2, 'descend');
                top_n = round(percent_top * best_num_roi);
                
                % Preallocate binary matrix for this block
                block_binary = zeros(current_block_size, best_num_roi, 'single');
                
                % Create linear indices directly
                m = current_block_size;
                linear_ind = (1:m)' + (sorted_idx(:, 1:top_n) - 1) * m;
                block_binary(linear_ind) = 1;
                
                full_binary_mat(block_idx, :) = full_binary_mat(block_idx, :) + block_binary;
            end
        end
    end
    
    % Compute final network map
    final_network_map = compute_clustering_network_map(full_binary_mat, Gmask, voxel_indices, ...
        best_num_roi, smoothing_fwhm, best_k_clusters, n_subs*BOLD_ses);
    
    % Save final network
    vol_out = Gmask_head;
    vol_out.fname = fullfile(dest, sprintf('final_network_%drois_%dclusters.nii', best_num_roi, best_k_clusters));
    spm_write_vol(vol_out, final_network_map);
    
    fprintf('Optimization complete! Final network saved as: %s\n', vol_out.fname);
    
    % Clean up parallel pool
    delete(gcp('nocreate'));
end

function save_network_map(network_map, mask_vol, dest_dir, filename)
vol_out = mask_vol;
vol_out.fname = fullfile(dest_dir, filename);
spm_write_vol(vol_out, network_map);
end

function dice_val = dice_coefficient(map1, map2, mask)
map1_bin = map1 > 0;
map2_bin = map2 > 0;
intersection = sum(map1_bin(:) & map2_bin(:) & mask(:));
dice_val = 2 * intersection / (sum(map1_bin(:) & mask(:)) + sum(map2_bin(:) & mask(:)));
end

function net_map = compute_clustering_network_map(binary_mat, mask, voxel_idx, num_roi, fwhm, k, n_sessions)
binary_mat = binary_mat / n_sessions;

net_map = zeros(size(mask));

if fwhm > 0
    smoothed_mat = zeros(size(binary_mat));
    parfor v = 1:size(binary_mat,1)
        row_vec = zeros(1, size(binary_mat,2));
        row_vec(:) = binary_mat(v, :);
        kernel = fspecial('gaussian', [1, ceil(fwhm*3)], fwhm);
        smoothed_row = conv(row_vec, kernel, 'same');
        smoothed_mat(v, :) = smoothed_row;
    end
    binary_mat = smoothed_mat;
end
[cluster_idx, ~] = kmeans(binary_mat, k, 'Replicates', 10, 'MaxIter', 1000, 'Distance','sqeuclidean','Options', statset('UseParallel', true));
for v = 1:length(voxel_idx)
    net_map(voxel_idx(v)) = cluster_idx(v);
end
end
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
    'sub-*_space-template_desc-Regressedpc.nii';
    'sub-*_space-template_desc-RegressedpcGS.nii';
    'sub-*_space-template_desc-RegressedpcCSF.nii';
    'sub-*_space-template_desc-RegressedpcCSFGS.nii'
    };

atlas_files = {
    'Label_Mouse_214_v38.nii';
    'Label_Mouse_428_v38.nii';
    'Label_Mouse_604_v38.nii';
    'Label_Mouse_1184_v38.nii';
    };

num_roi_list = [];
atlas_roi_voxels = {};

Gmask_head = spm_vol(fullfile(templatepath, 'AMCP_temp', 'AMCP_GMWM_mask.nii'));
Gmask = logical(spm_read_vols(Gmask_head));
voxel_indices = find(Gmask);

for a = 1:numel(atlas_files)
    atlas_vol = spm_vol(fullfile(templatepath, 'AMCP_temp', atlas_files{a}));
    atlas_dat = spm_read_vols(atlas_vol);
    atlas_dat_inmask = atlas_dat(Gmask);
    
    roi_labels = unique(atlas_dat_inmask(:));
    roi_labels(roi_labels==0) = [];
    num_roi = numel(roi_labels);
    num_roi_list(end+1) = num_roi;
    
    roi_voxels = cell(num_roi,1);
    for r = 1:num_roi
        roi_voxels{r} = find(atlas_dat_inmask == roi_labels(r));
    end
    
    atlas_roi_voxels{a} = roi_voxels;
end

for img = 1:4
    k_clusters_list = 21;
    n_repeats = 5;
    percent_top = 0.1;
    smoothing_fwhm = 0.3;
    block_size = 2000;
    
    fprintf('Preloading BOLD data using memory mapping...\n');
    time_paths = ExpTable.path;
    valid_subs = {};
    
    for idx = 1:size(time_paths,1)
        func_path = dir(fullfile(WholePath, cell2mat(time_paths(idx)), 'func', img_type{img}));
        if ~isempty(func_path)
            valid_subs{end+1} = time_paths{idx};
        end
    end
    
    n_subs = numel(valid_subs);
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
    
    results = struct();
    results.param_combinations = [];
    results.mean_similarity = [];
    results.std_similarity = [];
    results.elapsed_times = [];
    
    combo_idx = 1;
    if isempty(gcp('nocreate'))
        parpool('local');
    end
    
    netmap_dest = fullfile(WholePath, '2nd_results', 'BOLD', 'clutering_label', img_type{img});
    if ~exist(netmap_dest, 'dir')
        mkdir(netmap_dest);
    end
    
    for nri = 1:numel(num_roi_list)
        num_roi = num_roi_list(nri);
        roi_voxels = atlas_roi_voxels{nri};
        fprintf('Processing num_roi = %d (%d/%d)\n', num_roi, nri, numel(num_roi_list));
        
        fprintf('Computing binary matrices...\n');
        all_binary_mats = cell(n_subs, BOLD_ses);
        
        for sub_idx = 1:n_subs
            for s = 1:BOLD_ses
                bold_data = all_bold_data{sub_idx, s};
                if isempty(bold_data)
                    continue;
                end
                
                roi_ts = zeros(size(bold_data,1), num_roi, 'single');
                for r = 1:num_roi
                    if ~isempty(roi_voxels{r})
                        roi_ts(:, r) = mean(bold_data(:, roi_voxels{r}), 2);
                    end
                end
                
                n_voxels = size(bold_data,2);
                binary_matrix = zeros(n_voxels, num_roi, 'single');
                
                for block_start = 1:block_size:n_voxels
                    block_end = min(block_start+block_size-1, n_voxels);
                    block_idx = block_start:block_end;
                    current_block_size = numel(block_idx);
                    
                    partial_corr = corr(bold_data(:,block_idx), roi_ts);
                    [~, sorted_idx] = sort(partial_corr, 2, 'descend');
                    top_n = round(percent_top*num_roi);
                    
                    block_binary = zeros(current_block_size, num_roi, 'single');
                    for i = 1:current_block_size
                        block_binary(i, sorted_idx(i, 1:top_n)) = 1;
                    end
                    
                    binary_matrix(block_idx, :) = block_binary;
                end
                all_binary_mats{sub_idx, s} = binary_matrix;
            end
        end
        
        for kci = 1:numel(k_clusters_list)
            k_clusters = k_clusters_list(kci);
            fprintf('Testing k_clusters = %d (%d/%d)\n', k_clusters, kci, numel(k_clusters_list));
            
            tic;
            similarity_scores = zeros(n_repeats, 1);
            
            for rep = 1:n_repeats
                try
                    split_mask = randperm(n_subs);
                    group1_subs = split_mask(1:floor(n_subs/2));
                    group2_subs = split_mask(floor(n_subs/2)+1:end);
                    
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
                    
                    net_map1 = compute_clustering_network_map(group1_mat, Gmask, voxel_indices, ...
                        num_roi, smoothing_fwhm, k_clusters, numel(group1_subs)*BOLD_ses);
                    net_map2 = compute_clustering_network_map(group2_mat, Gmask, voxel_indices, ...
                        num_roi, smoothing_fwhm, k_clusters, numel(group2_subs)*BOLD_ses);
                    
                    save_network_map(net_map1, Gmask_head, netmap_dest, ...
                        sprintf('netmap_roi%d_k%d_rep%03d_group1.nii', num_roi, k_clusters, rep));
                    save_network_map(net_map2, Gmask_head, netmap_dest, ...
                        sprintf('netmap_roi%d_k%d_rep%03d_group2.nii', num_roi, k_clusters, rep));
                    
                    similarity_scores(rep) = dice_coefficient(net_map1, net_map2, Gmask);
                catch ME
                    fprintf('Error in repeat %d: %s\n', rep, ME.message);
                    similarity_scores(rep) = NaN;
                end
            end
            
            valid_scores = similarity_scores(~isnan(similarity_scores));
            if isempty(valid_scores)
                error('All repetitions failed for num_roi=%d, k_clusters=%d', num_roi, k_clusters);
            end
            
            elapsed_time = toc;
            results.param_combinations(combo_idx, :) = [num_roi, k_clusters];
            results.mean_similarity(combo_idx, 1) = mean(valid_scores);
            results.std_similarity(combo_idx, 1) = std(valid_scores);
            results.elapsed_times(combo_idx, 1) = elapsed_time;
            
            cd(netmap_dest);
            save('final_results1.mat', 'results');
            fprintf('Mean Similarity: %.4f ¡À %.4f | Time: %.1f sec\n', ...
                mean(valid_scores), std(valid_scores), elapsed_time);
            combo_idx = combo_idx + 1;
        end
        
        clear all_binary_mats;
        java.lang.System.gc();
    end
    
    final_results = results;
    best_inst = 1 - max(final_results.mean_similarity);
    [best_sim, best_idx] = max(final_results.mean_similarity);
    best_num_roi = final_results.param_combinations(best_idx, 1);
    best_k_clusters = final_results.param_combinations(best_idx, 2);
    
    dest = fullfile(WholePath, '2nd_results', 'BOLD', 'clutering_label', img_type{img}, 'parameter_optimization');
    if ~exist(dest, 'dir')
        mkdir(dest);
    end
    cd(dest);
    
    save('parameter_optimization_final_results.mat', 'final_results');
    
    figure('Color', 'w', 'Position', [10, 10, 2000, 1000]);
    left_width = 1/3;
    right_width = 2/3;
    
    ax1 = subplot('Position', [0.07, 0.1, 0.28, 0.8]);
    [X, Y] = meshgrid(num_roi_list, k_clusters_list);
    Z = griddata(final_results.param_combinations(:,1), final_results.param_combinations(:,2), ...
        1 - final_results.mean_similarity, X, Y);
    surf(X, Y, Z, 'FaceAlpha', 0.8);
    xlabel('Number of ROIs');
    ylabel('Number of Clusters');
    zlabel('Instability');
    title('Network Instability');
    grid on;
    colormap(jet);
    colorbar;
    view(-50, 30);
    
    ax2 = subplot('Position', [0.40, 0.58, 0.55, 0.35]);
    bar(final_results.elapsed_times);
    set(gca, 'XTick', 1:length(final_results.elapsed_times), ...
        'XTickLabel', arrayfun(@(i) sprintf('%d-%d', final_results.param_combinations(i,1), final_results.param_combinations(i,2)), ...
        1:length(final_results.elapsed_times), 'UniformOutput', false));
    xtickangle(90);
    ylabel('Computation Time (sec)');
    title('Computation Time per Parameter Set');
    ax2.XAxis.FontSize = ax2.XAxis.FontSize * 0.8;
    
    ax3 = subplot('Position', [0.40, 0.10, 0.55, 0.35]);
    Instability = 1 - final_results.mean_similarity;
    plot(Instability);
    set(gca, 'XTick', 1:length(Instability), ...
        'XTickLabel', arrayfun(@(i) sprintf('%d-%d', final_results.param_combinations(i,1), final_results.param_combinations(i,2)), ...
        1:length(Instability), 'UniformOutput', false));
    xtickangle(90);
    ylabel('Instability');
    xlabel('Parameter Combination (ROIs-Clusters)');
    title('Network Stability');
    grid on;
    ax3.XAxis.FontSize = ax3.XAxis.FontSize * 0.5;
    
    saveas(gcf, 'parameter_optimization_final_results.png');
    saveas(gcf, 'parameter_optimization_final_results.svg');
    
    fprintf('\n===== OPTIMIZATION RESULTS =====\n');
    fprintf('Best parameters: num_roi = %d, k_clusters = %d\n', best_num_roi, best_k_clusters);
    fprintf('Minimum instability: %.4f +- %.4f\n', best_inst, final_results.std_similarity(best_idx));
    
    fprintf('\nGenerating final network with best parameters...\n');
    roi_voxels = atlas_roi_voxels{find(num_roi_list == best_num_roi, 1)};
    
    full_binary_mat = zeros(length(voxel_indices), best_num_roi, 'single');
    for sub_idx = 1:n_subs
        for s = 1:BOLD_ses
            bold_data = all_bold_data{sub_idx, s};
            if isempty(bold_data)
                continue;
            end
            
            roi_ts = zeros(size(bold_data,1), best_num_roi, 'single');
            for r = 1:best_num_roi
                if ~isempty(roi_voxels{r})
                    roi_ts(:, r) = mean(bold_data(:, roi_voxels{r}), 2);
                end
            end
            
            n_voxels = size(bold_data,2);
            for block_start = 1:block_size:n_voxels
                block_end = min(block_start+block_size-1, n_voxels);
                block_idx = block_start:block_end;
                current_block_size = numel(block_idx);
                
                partial_corr = corr(bold_data(:,block_idx), roi_ts);
                [~, sorted_idx] = sort(partial_corr, 2, 'descend');
                top_n = round(percent_top*best_num_roi);
                
                block_binary = zeros(current_block_size, best_num_roi, 'single');
                for i = 1:current_block_size
                    block_binary(i, sorted_idx(i, 1:top_n)) = 1;
                end
                
                full_binary_mat(block_idx, :) = full_binary_mat(block_idx, :) + block_binary;
            end
        end
    end
    
    final_network_map = compute_clustering_network_map(full_binary_mat, Gmask, voxel_indices, ...
        best_num_roi, smoothing_fwhm, best_k_clusters, n_subs*BOLD_ses);
    
    vol_out = Gmask_head;
    vol_out.fname = fullfile(dest, sprintf('final_network_%drois_%dclusters.nii', best_num_roi, best_k_clusters));
    spm_write_vol(vol_out, final_network_map);
    fprintf('Optimization complete! Final network saved as: %s\n', vol_out.fname);
    
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
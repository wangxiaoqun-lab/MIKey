function reconstruct_individual_network_dti(con_matrix, xyz, nlabel, mask_head, outfolder, perc_voxel_thr, max_iterations)
% FUNCTION: calculate_dti_individual_network_parcellation
% PURPOSE: Performs iterative optimization of brain parcellation using structural connectivity data
% INPUTS:
%   con_matrix: Connectivity matrix (voxels x whole-brain connectivity)
%   xyz: Voxel coordinates in image space (0-based indexing)
%   nlabel: Initial label image
%   mask_img: Brain mask image
%   perc_voxel_thr: (Optional) Termination threshold for voxel label change percentage (default=0.1)
%   max_iterations: (Optional) Maximum number of iterations (default=50)

% DEPENDENCIES:
%   Requires SPM or NIfTI I/O tools for load_untouch_nii/save_untouch_nii
if ~exist(outfolder, 'dir')
    mkdir(outfolder)
end

%% Create final results folder
final_outfolder = fullfile(outfolder, 'Final_parcellation');
if ~exist(final_outfolder, 'dir')
    mkdir(final_outfolder)
end

%% Handle optional parameters
if nargin < 6 || isempty(perc_voxel_thr)
    perc_voxel_thr = 0.01;  % Default threshold: 1% voxel change
end

if nargin < 7 || isempty(max_iterations)
    max_iterations = 50;   % Default maximum iterations
end

mask_img = spm_read_vols(mask_head);
mask_bin = mask_img > 0;  % Binary mask

%% Apply mask and clean label data
nlabel = nlabel .* mask_img;
nlabel(isnan(nlabel)) = 0;

%% Initialization
ROI_LABEL = 1:max(nlabel(:));  % Use colon operator for efficiency
n_roi_voxel = size(con_matrix, 1);
n_brain_voxel = size(con_matrix, 2);
n_roi_label = length(ROI_LABEL);

% Extract labels at xyz coordinates
label = zeros(size(xyz, 1), 1);
for i = 1:size(xyz, 1)
    % MATLAB uses 1-based indexing (xyz coordinates are 0-based)
    x = xyz(i, 1) + 1;
    y = xyz(i, 2) + 1;
    z = xyz(i, 3) + 1;
    
    % Ensure coordinates are within image dimensions
    if x <= size(nlabel, 1) && y <= size(nlabel, 2) && z <= size(nlabel, 3)
        label(i) = nlabel(x, y, z);
    else
        label(i) = 0;  % Assign background to out-of-bound voxels
    end
end

%% Save initial labels (Iteration 0) in Iter_0 folder
iter0_folder = fullfile(outfolder, 'Iter_0');
if ~exist(iter0_folder, 'dir')
    mkdir(iter0_folder)
end
n_iteration = 0;
save(fullfile(iter0_folder, 'label_iter_0.mat'), 'label', '-v7.3');
map_label_to_nii(mask_head, iter0_folder, n_iteration, label, xyz);

%% Initialize reference connectivity matrix
roi_ref_con_matrix = zeros(n_roi_label, n_brain_voxel);
for j = 1:n_roi_label
    mask = (label == ROI_LABEL(j));
    if any(mask)
        roi_ref_con_matrix(j, :) = mean(con_matrix(mask, :), 1);
    end
end
roi_ref_con_matrix(isnan(roi_ref_con_matrix)) = 0;

%% Iterative optimization
perc_voxel = inf;  % Initialize to ensure loop entry
iter_count = 0;
last_max_corr = [];  % Store last iteration's max correlation

while perc_voxel > perc_voxel_thr && iter_count < max_iterations
    iter_count = iter_count + 1;
    n_iteration = n_iteration + 1;
    
    % Create iteration-specific folder
    current_iter_folder = fullfile(outfolder, sprintf('Iter_%d', n_iteration));
    if ~exist(current_iter_folder, 'dir')
        mkdir(current_iter_folder);
    end
    
    % 1. Compute voxel-to-ROI correlation matrix
    fprintf('Iteration %d: Computing correlation matrix...\n', n_iteration);
    corr_matrix = zeros(n_roi_voxel, n_roi_label);
    parfor i = 1:n_roi_voxel
        for j = 1:n_roi_label
            r = corrcoef(con_matrix(i, :), roi_ref_con_matrix(j, :));
            corr_matrix(i, j) = r(1, 2);
        end
    end
    corr_matrix(isnan(corr_matrix)) = 0;
    
    % Calculate and save max correlation values
    max_corr = max(corr_matrix, [], 2);  % Max correlation per voxel
    last_max_corr = max_corr;  % Store for final save
    
    % Save max correlation volume to current iteration folder
    max_corr_vol = funmask(max_corr, mask_bin);
    mask_head.fname = fullfile(current_iter_folder, sprintf('max_corr_iter_%d.nii', n_iteration));
    spm_write_vol(mask_head, max_corr_vol);
    
    % 2. Assign optimal ROI labels
    fprintf('Iteration %d: Assigning labels...\n', n_iteration);
    label0 = label;  % Preserve previous labels
    [~, max_idx] = max(corr_matrix, [], 2);
    label = ROI_LABEL(max_idx)';
    
    % 3. Compute new ROI mean connectivity
    fprintf('Iteration %d: Computing mean connectivity...\n', n_iteration);
    roi_mean_con_matrix = zeros(n_roi_label, n_brain_voxel);
    for j = 1:n_roi_label
        mask = (label == ROI_LABEL(j));
        if any(mask)
            roi_mean_con_matrix(j, :) = mean(con_matrix(mask, :), 1);
        end
    end
    roi_mean_con_matrix(isnan(roi_mean_con_matrix)) = 0;
    
    % 4. Update reference connectivity matrix
    fprintf('Iteration %d: Updating reference matrix...\n', n_iteration);
    roi_ref_con_matrix = 0.9 * roi_ref_con_matrix + 0.1 * roi_mean_con_matrix;
    
    % 5. Calculate label change percentage
    changed_voxels = sum(label ~= label0);
    perc_voxel = changed_voxels / n_roi_voxel;
    
    % Save iteration results to current iteration folder
    save(fullfile(current_iter_folder, sprintf('label_iter_%d.mat', n_iteration)), 'label', '-v7.3');
    map_label_to_nii(mask_head, current_iter_folder, n_iteration, label, xyz);
    
    fprintf('Iteration %d complete: %.2f%% voxels changed labels\n', n_iteration, perc_voxel*100);
end

%% Save final results to Final_parcellation folder
% Map final labels to B0 space
final_nlabel = mask_img * 0;  % Initialize label image

for i = 1:size(xyz, 1)
    x = xyz(i, 1) + 1;
    y = xyz(i, 2) + 1;
    z = xyz(i, 3) + 1;
    
    if x <= size(final_nlabel, 1) && y <= size(final_nlabel, 2) && z <= size(final_nlabel, 3)
        final_nlabel(x, y, z) = label(i);
    end
end
mask_head.fname = fullfile(final_outfolder, 'label_final.nii');
spm_write_vol(mask_head, final_nlabel);

% Save final max correlation map
final_max_corr_vol = funmask(last_max_corr, mask_bin);
mask_head.fname = fullfile(final_outfolder, 'final_max_corr.nii');
mask_head.dt=[16,0];
spm_write_vol(mask_head, final_max_corr_vol);

% Save additional outputs
save(fullfile(final_outfolder, 'roi_mean_con_matrix.mat'), 'roi_mean_con_matrix', '-v7.3');
save(fullfile(final_outfolder, 'perc_voxel_change.mat'), 'perc_voxel', '-v7.3');
fprintf('Parcellation complete! Final iteration: %d\n', n_iteration);
end


function map_label_to_nii(mask_head, outfolder, iter, label, xyz)
mask_img = spm_read_vols(mask_head);
label_img = mask_img * 0;
for i = 1:size(xyz, 1)
    label_img(xyz(i, 1)+1, xyz(i, 2)+1, xyz(i, 3)+1) = label(i);
end
mask_head.fname = fullfile(outfolder, sprintf('label_iter_%d.nii', iter));
mask_head.dt=[4,0];
spm_write_vol(mask_head, label_img);
end

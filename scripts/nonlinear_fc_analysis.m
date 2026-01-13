function [LIN_ICNs_path, ENL_ICNs_path] = nonlinear_fc_analysis(data_subjects, mask_path, output_dir)
% Input:
%   data_subjects: Cell array {1*N_subjects} with each element being a cell array {1*N_runs} of 4D nifti paths
%   mask_path: Path to brain mask nifti file
%   output_dir: Directory to save results
% Output:
%   Paths to group-level linear and nonlinear ICNs

% Create output directory
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Load brain mask
mask_vol = spm_vol(mask_path);
mask_data = spm_read_vols(mask_vol);
mask_indices = find(mask_data > 0);
V = numel(mask_indices);

% Preprocessing: Read and process all subjects' data
N = numel(data_subjects);
all_subjects_data = cell(1, N);

for subj = 1:N
    fprintf('\nProcessing subject %d/%d\n', subj, N);
    runs = data_subjects{subj};
    num_runs = numel(runs);
    all_runs_data = [];
    
    for r = 1:num_runs
        fprintf('  Reading run %d: %s\n', r, runs{r});
        vol = spm_vol(runs{r});
        data_4d = spm_read_vols(vol);
        
        % Reshape to timepoints × voxels
        [x, y, z, t] = size(data_4d);
        data_2d = reshape(data_4d, [], t)';
        masked_data = data_2d(:, mask_indices);
        
        % Detrend and concatenate runs
        masked_data = detrend(masked_data, 'linear');
        all_runs_data = [all_runs_data; masked_data]; 
    end
    
    % Z-score normalization
    all_subjects_data{subj} = zscore(all_runs_data);
end

% Calculate FC matrices - SERIAL PROCESSING
LIN_wFC = cell(1, N);
NL_wFC = cell(1, N);
ENL_wFC = cell(1, N);

fprintf('\nCalculating functional connectivity matrices (SERIAL)\n');
for subj = 1:N
    try
        fprintf('  Subject %d/%d: Starting\n', subj, N);
        data = all_subjects_data{subj};
        
        % Linear FC
        fprintf('    Linear FC\n');
        LIN_wFC{subj} = calculate_LIN_wFC(data);
        
        % Nonlinear FC
        fprintf('    Nonlinear FC\n');
        NL_wFC{subj} = calculate_NL_wFC(data);
        
        % Explicit nonlinear FC
        fprintf('    Explicit nonlinear FC\n');
        ENL_wFC{subj} = calculate_ENL_wFC(NL_wFC{subj}, LIN_wFC{subj});
        
        % Clear large variables to save memory
        clear data NL_wFC{subj} LIN_wFC{subj}
        fprintf('  Subject %d/%d: Completed\n', subj, N);
        
    catch ME
        fprintf('ERROR processing subject %d: %s\n', subj, ME.message);
        fprintf('Stack trace:\n');
        for k = 1:length(ME.stack)
            fprintf('  File: %s\n  Function: %s\n  Line: %d\n', ...
                    ME.stack(k).file, ...
                    ME.stack(k).name, ...
                    ME.stack(k).line);
        end
        rethrow(ME);
    end
end

% Group-level independent component analysis
fprintf('\nPerforming group-level ICA\n');
[LIN_ICNs_path, ENL_ICNs_path] = group_level_ICA(LIN_wFC, ENL_wFC, 20, mask_vol, mask_indices, output_dir);

fprintf('\nAnalysis complete! Results saved to: %s\n', output_dir);
end

%% ======================== FUNC 1: Linear FC ========================
function LIN_wFC = calculate_LIN_wFC(data)
% Input: data [T×V] fMRI time series
% Output: LIN_wFC [V×V] covariance matrix
LIN_wFC = cov(data);
end

%% ======================== FUNC 2: Nonlinear FC ========================
function NL_wFC = calculate_NL_wFC(data)
% Input: data [T×V] fMRI time series
% Output: NL_wFC [V×V] distance correlation matrix
[T, V] = size(data);
NL_wFC = zeros(V, V);
block_size = 100;  % Conservative block size for memory
num_blocks = ceil(V / block_size);

fprintf('    Size: %d voxels | Blocks: %dx%d\n', V, num_blocks, num_blocks);

for b1 = 1:num_blocks
    idx1 = (b1-1)*block_size+1:min(b1*block_size, V);
    
    for b2 = b1:num_blocks
        idx2 = (b2-1)*block_size+1:min(b2*block_size, V);
        
        block_data1 = data(:, idx1);
        block_data2 = data(:, idx2);
        block_dcor = zeros(length(idx1), length(idx2));
        
        % Process block
        for i = 1:length(idx1)
            for j = 1:length(idx2)
                block_dcor(i, j) = distcorr(block_data1(:, i), block_data2(:, j));
            end
        end
        
        NL_wFC(idx1, idx2) = block_dcor;
        NL_wFC(idx2, idx1) = block_dcor';
    end
    fprintf('    Completed block %d/%d\n', b1, num_blocks);
end
end

function dCor = distcorr(x, y)
% Distance correlation (Székely et al., 2007)
n = length(x);
a = pdist2(x, x);
b = pdist2(y, y);

A = a - mean(a, 2) - mean(a, 1) + mean(a(:));
B = b - mean(b, 2) - mean(b, 1) + mean(b(:));

dCov2 = sum(sum(A .* B)) / (n^2);
dVarX = sum(sum(A .* A)) / (n^2);
dVarY = sum(sum(B .* B)) / (n^2);

if dVarX <= 0 || dVarY <= 0
    dCor = 0;
else
    dCor = sqrt(dCov2) / sqrt(sqrt(dVarX * dVarY));
end
end

%% ======================== FUNC 3: Explicit Nonlinear FC ========================
function ENL_wFC = calculate_ENL_wFC(NL_wFC, LIN_wFC)
% Input: NL_wFC and LIN_wFC [V×V]
% Output: ENL_wFC [V×V] residual connectivity
vec_NL = NL_wFC(:);
vec_LIN = LIN_wFC(:);

a = vec_LIN \ vec_NL;
residuals = vec_NL - a * vec_LIN;
ENL_wFC = reshape(residuals, size(NL_wFC));
end

%% ======================== FUNC 4: Group-Level ICA ========================
function [LIN_ICNs_path, ENL_ICNs_path] = group_level_ICA(LIN_wFC, ENL_wFC, numComp, mask_vol, mask_indices, output_dir)
% Group-level ICA analysis
N = numel(LIN_wFC);
V = size(LIN_wFC{1}, 1);

% Prepare feature matrices
fprintf('  Preparing feature matrices\n');
feat_LIN = zeros(N, V*V);
feat_ENL = zeros(N, V*V);

for i = 1:N
    feat_LIN(i, :) = LIN_wFC{i}(:);
    feat_ENL(i, :) = ENL_wFC{i}(:);
end

% PCA dimensionality reduction
fprintf('  Performing PCA reduction\n');
[~, score_LIN] = pca(feat_LIN, 'NumComponents', 30);
[~, score_ENL] = pca(feat_ENL, 'NumComponents', 30);

[~, group_LIN] = pca(score_LIN, 'NumComponents', numComp);
[~, group_ENL] = pca(score_ENL, 'NumComponents', numComp);

% FastICA (requires FastICA toolbox)
fprintf('  Running FastICA\n');

LIN_ICNs = fastica(group_LIN', 'numOfIC', numComp, 'verbose', 'off');
ENL_ICNs = fastica(group_ENL', 'numOfIC', numComp, 'verbose', 'off');

% Save group ICNs as 4D NIfTI
fprintf('  Saving group networks\n');
LIN_ICNs_path = save_4d_components(LIN_ICNs, mask_vol, mask_indices, output_dir, 'LIN');
ENL_ICNs_path = save_4d_components(ENL_ICNs, mask_vol, mask_indices, output_dir, 'ENL');
end

function output_path = save_4d_components(components, mask_vol, mask_indices, output_dir, prefix)
% Save components as 4D NIfTI file
num_components = size(components, 1);
[x, y, z] = size(mask_vol.private.dat);
vol_data = zeros(x, y, z, num_components);

% Create new NIfTI header
vol = mask_vol(1);
vol.fname = fullfile(output_dir, [prefix '_group_ICNs.nii']);
vol.dt = [16, 0];  % float32
vol.n = [num_components, 1];  % 4D file

% Map components to brain space
for comp = 1:num_components
    comp_map = zeros(x, y, z);
    comp_map(mask_indices) = components(comp, :);
    vol_data(:, :, :, comp) = comp_map;
end

% Write 4D file
spm_write_vol_4d(vol, vol_data);
output_path = vol.fname;
end
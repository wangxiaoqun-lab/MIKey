function [mean_sSNR, sSNR, mean_tSNR, tSNR_map, noise_std] = calculate_SNR(fMRI_data, lmask_head, varargin)
% CALCULATE_SNR Compute sSNR and/or tSNR metrics for fMRI data with ROI-based sSNR mapping
% Inputs:
%   fMRI_data     - 3D or 4D matrix [x,y,z,t] 
%   lmask_head    - Filename of the head mask NIfTI file
% Optional Name-Value Pairs:
%   percent       - Proportion of noise voxels to use as background (default: 0.005)
%   compute_tSNR  - Flag to enable tSNR calculation (default: true for 4D data)
%   plotHistogram - Flag to plot tSNR histogram (default: false)
%   histogramName - Filename for saving histogram (default: 'tSNR_histogram.png')
%   roi_number    - Number of ROIs to divide the brain into (default: 50)
%   save_path     - Directory path to save output NIfTI files (default: current directory)
%   smooth_fwhm   - FWHM for spatial smoothing of sSNR map (default: 8 mm)
% Outputs:
%   mean_sSNR - Mean spatial SNR
%   mean_tSNR - Mean temporal SNR (NaN if not calculated)
%   tSNR_map  - 3D temporal SNR map (NaN if not calculated)

%% Input Validation and Parameter Parsing
p = inputParser;
addRequired(p, 'fMRI_data', @(x) validateattributes(x, {'numeric'}, {'nonempty'}));
addRequired(p, 'lmask_head', @(x) validateattributes(x, {'char'}, {'nonempty'}));

% Add optional parameters with defaults
addParameter(p, 'percent', 0.005, @(x) validateattributes(x, {'numeric'}, {'scalar', '>=',0, '<=',1}));
addParameter(p, 'compute_tSNR', [], @islogical);
addParameter(p, 'plotHistogram', false, @islogical);
addParameter(p, 'histogramName', 'tSNR_histogram.png', @(x) ischar(x)||isstring(x));
addParameter(p, 'roi_number', 50, @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}));
addParameter(p, 'save_path', pwd, @(x) ischar(x)||isstring(x));
addParameter(p, 'smooth_fwhm', 8, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));

parse(p, fMRI_data, lmask_head, varargin{:});

% Extract parameters
percent = p.Results.percent;
compute_tSNR = p.Results.compute_tSNR;
plotHistogram = p.Results.plotHistogram;
histogramName = p.Results.histogramName;
roi_number = p.Results.roi_number;
save_path = p.Results.save_path;
smooth_fwhm = p.Results.smooth_fwhm;

% Read head mask using SPM
[head_mask, head_vol] = spm_read_vols(spm_vol(lmask_head));
head_mask = logical(head_mask);

% Auto-detect tSNR computation if not specified
if isempty(compute_tSNR)
    compute_tSNR = (ndims(fMRI_data) == 4 && size(fMRI_data,4) > 1);
end

% Handle 3D data by adding singleton time dimension
if ndims(fMRI_data) == 3
    fMRI_data = reshape(fMRI_data, [size(fMRI_data), 1]); 
end

% Validate mask dimensions
validateattributes(head_mask, {'logical'}, {'size', size(fMRI_data(:,:,:,1))});

%% Core Computation
% ================= Spatial SNR Calculation =================
[mean_sSNR, sSNR, ~, noise_std] = compute_spatial_snr(fMRI_data, head_mask, percent);

% ================= ROI-based sSNR Mapping =================
sSNR_map = compute_roi_based_ssnr(fMRI_data, head_mask, noise_std, roi_number, smooth_fwhm);

% ================= Temporal SNR Calculation =================
if compute_tSNR && size(fMRI_data,4) > 1
    [tSNR_map, mean_tSNR] = compute_temporal_snr(fMRI_data, head_mask);
else
    tSNR_map = NaN(size(head_mask));
    mean_tSNR = NaN;
    if compute_tSNR
        warning('tSNR calculation requires 4D data with timepoints > 1');
    end
end

%% Save NIfTI files
save_nii_files(sSNR_map, tSNR_map, head_vol, save_path);

%% Visualization
if plotHistogram && ~isnan(mean_tSNR)
    visualize_tSNR(tSNR_map, head_mask, histogramName);
end
end

%% Helper Functions
function [mean_sSNR, sSNR, final_noise_mask, noise_std] = compute_spatial_snr(data, signal_mask, percent)
% Flatten data to 2D
data_2D = reshape(data, [], size(data,4));

% Extract signal voxels
signal_voxels = data_2D(signal_mask(:), :);

% Process noise mask
noise_mask = create_noise_mask(signal_mask);
noise_voxels = data_2D(noise_mask(:), :);

% Select lowest intensity noise voxels
noise_intensity = mean(noise_voxels, 2);
sorted_intensity = sort(noise_intensity, 'ascend');
select_idx = max(1, floor(numel(noise_intensity)*percent));
intensity_threshold = sorted_intensity(select_idx);

final_noise_mask = noise_mask;
final_noise_mask(noise_mask) = noise_intensity <= intensity_threshold;
valid_noise = data_2D(final_noise_mask(:), :);

% Calculate SNR metrics
signal_mean = mean(signal_voxels, 1, 'omitnan');
noise_std = std(valid_noise, 0, 1, 'omitnan');
sSNR = signal_mean ./ noise_std;
sSNR(isinf(sSNR)) = 0;
mean_sSNR = mean(sSNR, 'omitnan');
end

function [tSNR_map, mean_tSNR] = compute_temporal_snr(data, mask)
data_2D = reshape(data, [], size(data,4));
time_mean = mean(data_2D, 2, 'omitnan');
time_std = std(data_2D, 0, 2, 'omitnan');
tSNR_values = time_mean ./ time_std;
tSNR_values(isinf(tSNR_values) | isnan(tSNR_values)) = 0;
tSNR_map = reshape(tSNR_values, size(data(:,:,:,1)));
mean_tSNR = mean(tSNR_map(mask), 'omitnan');
end

function noise_mask = create_noise_mask(signal_mask)
% Generate annular noise mask
noise_mask = ~signal_mask;

% Morphological erosion
se = strel('sphere',3);
noise_mask = imerode(noise_mask, se);

% Remove small connected components
noise_mask = bwareaopen(noise_mask, 500);
end

function sSNR_map = compute_roi_based_ssnr(data, head_mask, noise_std, roi_number, smooth_fwhm)
% Get coordinates of brain voxels
[x, y, z] = ind2sub(size(head_mask), find(head_mask));
coords = [x, y, z];

% Use k-means to partition brain into ROIs
fprintf('Partitioning brain into %d ROIs using k-means...\n', roi_number);
[idx, ~] = kmeans(coords, roi_number, 'Replicates', 3, 'MaxIter', 1000);

% Reshape data to 2D
data_2D = reshape(data, [], size(data,4));

% Initialize sSNR map
sSNR_map = zeros(size(head_mask));

% For each time frame
for t = 1:size(data,4)
    fprintf('Processing frame %d/%d...\n', t, size(data,4));
    
    % For each ROI
    for r = 1:roi_number
        % Get voxel indices for this ROI
        roi_voxels = find(head_mask);
        roi_voxels = roi_voxels(idx == r);
        
        % Calculate mean signal for this ROI
        roi_mean = mean(data_2D(roi_voxels, t), 'omitnan');
        
        % Calculate sSNR for this ROI (signal / noise_std for this frame)
        roi_ssnr = roi_mean / noise_std(t);
        
        % Assign sSNR value to all voxels in this ROI
        sSNR_map(roi_voxels) = sSNR_map(roi_voxels) + roi_ssnr;
    end
end

% Average across frames
sSNR_map = sSNR_map / size(data,4);

% Apply spatial smoothing
if smooth_fwhm > 0
    fprintf('Smoothing sSNR map with FWHM = %.1f mm...\n', smooth_fwhm);
    sSNR_map = smooth_volume(sSNR_map, smooth_fwhm);
end
end

function smoothed_vol = smooth_volume(vol, fwhm)
% Smooth volume using SPM
voxsize = [2 2 2]; % Assuming 2mm isotropic voxels, adjust if needed
s = fwhm ./ voxsize ./ sqrt(8*log(2)); % Convert FWHM to sigma
smoothed_vol = zeros(size(vol));
spm_smooth(vol, smoothed_vol, s);
end

function save_nii_files(sSNR_map, tSNR_map, head_vol, save_path)
% Save sSNR map
ssnr_vol = head_vol;
ssnr_vol.fname = fullfile(save_path, 'mean_sSNR_map.nii');
ssnr_vol.dt = [16 0]; % Float32 data type
spm_write_vol(ssnr_vol, sSNR_map);

% Save tSNR map if it exists
if ~all(isnan(tSNR_map(:)))
    tsnr_vol = head_vol;
    tsnr_vol.fname = fullfile(save_path, 'tSNR_map.nii');
    tsnr_vol.dt = [16 0]; % Float32 data type
    spm_write_vol(tsnr_vol, tSNR_map);
end

fprintf('NIfTI files saved to: %s\n', save_path);
end

function visualize_tSNR(tSNR_map, mask, fname)
fig = figure('Visible','off', 'Color','w', 'Position',[100 100 800 400]);

% Histogram plot
subplot(1,2,1);
tSNR_values = tSNR_map(mask);
h = histogram(tSNR_values, 'BinMethod','fd', 'FaceColor',[0.4 0.6 0.8]);
xlabel('tSNR'), ylabel('Frequency'), title('tSNR Distribution')
grid on, box off

% Add median line
hold on;
med_val = median(tSNR_values);
yl = ylim;
plot([med_val med_val], yl, 'r--', 'LineWidth',1.5);
text(med_val+0.1*diff(xlim), yl(2)*0.9,...
    sprintf('Median: %.1f', med_val),...
    'Color','r', 'FontSize',10);

% Spatial distribution plot
subplot(1,2,2);
slice_view = squeeze(tSNR_map(:,:,round(end/2)));
imagesc(slice_view);
axis equal off, colorbar, title('Central Slice tSNR');

% Save figure
saveas(fig, fname);
close(fig);
fprintf('tSNR visualization saved to: %s\n', fname);
end
function plot_fc_matrix_214_regions(scans_avg, corlor_bar, save_name, save_path)
% Validate input matrix size
if ~isequal(size(scans_avg), [214, 214])
    error('Input matrix must be 214x214 in size');
end
% A = scans_avg;
% indices = 1:214;
% indices([39, 214]) = indices([214, 39]);
% A = A(indices, indices);
% scans_avg=A;
% Calculate valid region mask
mask_valid = ~all( (scans_avg == 0) | isnan(scans_avg), 2 );
scans_avg_valid = scans_avg(mask_valid, mask_valid);
scans_avg_valid(isnan(scans_avg_valid)) = 0; % Replace NaN with 0

% Define brain region structure (left hemisphere only)
regions = {
    {'Isocortex',        1,39},...
    {'Olfactory',       40,50},...
    {'Hippocampal Formation',51,61},...
    {'Cortical Subplate',62,68},...
    {'Striatum',        69,80},...
    {'Pallidum',        81,88},...
    {'Thalamus',        89,123},...
    {'Hypothalamus',    124,143},...
    {'Midbrain',        144,164},...
    {'Pons',            165,177},...
    {'Medulla',         178,202},...
    {'Cerebellum',      203,214}
    };

% Define region names and base colors
color_names = {
    'Isocortex', 'Olfactory', 'Hippocampal Formation',...
    'Cortical Subplate', 'Striatum', 'Pallidum',...
    'Thalamus', 'Hypothalamus', 'Midbrain',...
    'Pons', 'Medulla', 'Cerebellum'
    };

base_colors = [
    0.9 0.2 0.2;      % Red
    0.2 0.9 0.2;      % Green
    0.2 0.2 0.9;      % Blue
    0.9 0.9 0.2;      % Yellow
    0.9 0.2 0.9;      % Magenta
    0.2 0.9 0.9;      % Cyan
    1.0 0.5 0.0;      % Orange
    0.5 0.0 1.0;      % Purple
    0.4 0.7 0.2;      % Olive
    0.7 0.4 0.2;      % Brown
    0.2 0.4 0.7;      % Navy
    1 0.6 0.8         % Pink
    ];

% Create color mapping
color_map = containers.Map();
for i = 1:length(color_names)
    color_map(color_names{i}) = base_colors(i,:);
end

% Create full region color matrix
full_color = zeros(214,3);
for r = 1:length(regions)
    reg = regions{r};
    name = reg{1};
    start_idx = reg{2};
    end_idx = reg{3};
    color = color_map(name);
    
    % Ensure indices are within bounds
    start_idx = max(1, min(start_idx,213));
    end_idx = max(1, min(end_idx,213));
    
    full_color(start_idx:end_idx,:) = repmat(color, end_idx-start_idx+1,1);
end

full_color_valid = full_color(mask_valid,:);
full_color_rgb = reshape(full_color_valid, [size(full_color_valid,1), 1, 3]);

% Create figure
fig = figure('Position', [0 0 600 600], 'Color', 'w');

% Main heatmap axes
main_ax = axes('Position', [0.3 0.15 0.6 0.6]);
% Display heatmap
    imagesc(scans_avg_valid);
    
    % ============== UNIFIED COLOR BAR HANDLING ==============
    % Handle different corlor_bar input types (2 or 4 elements)
    if numel(corlor_bar) == 4
        % Threshold mode: [min, neg_threshold, pos_threshold, max]
        c_min = corlor_bar(1);
        neg_threshold = corlor_bar(2);
        pos_threshold = corlor_bar(3);
        c_max = corlor_bar(4);
        
        % Create custom colormap (blue-white-red)
        N = 256;
        total_range = c_max - c_min;
        p_neg = (neg_threshold - c_min) / total_range;
        p_mid = (pos_threshold - neg_threshold) / total_range;
        p_pos = (c_max - pos_threshold) / total_range;
        n_neg = round(N * p_neg);
        n_mid = round(N * p_mid);
        n_pos = N - n_neg - n_mid;
        
        jet_cmap = jet(N);
        cmap = ones(N, 3);
        
        % Blue section
        if n_neg > 0
            jet_blue_indices = round(linspace(1, round(N/3), n_neg));
            cmap(1:n_neg, :) = jet_cmap(jet_blue_indices, :);
        end
        
        % White section
        if n_mid > 0
            cmap(n_neg+1:n_neg+n_mid, :) = repmat([1 1 1], n_mid, 1);
        end
        
        % Red section
        if n_pos > 0
            jet_red_indices = round(linspace(round(2*N/3), N, n_pos));
            cmap(n_neg+n_mid+1:end, :) = jet_cmap(jet_red_indices, :);
        end
        
        % Apply colormap
        colormap(main_ax, cmap);
        caxis([c_min, c_max]);
        
        % Set colorbar ticks
        key_ticks = [c_min, neg_threshold, 0, pos_threshold, c_max];
        valid_ticks = key_ticks(key_ticks >= c_min & key_ticks <= c_max);
        
    elseif numel(corlor_bar) == 2
        % Standard mode: [min, max]
        c_min = corlor_bar(1);
        c_max = corlor_bar(2);
        
        % Use standard jet colormap
        colormap(main_ax, jet);
        caxis([c_min, c_max]);
        
        % Set linear colorbar ticks
        valid_ticks = linspace(c_min, c_max, 5);
        
    else
        error('corlor_bar must contain 2 or 4 elements');
    end
    
    % Add colorbar
    cb = colorbar('Position', [0.92 0.15 0.02 0.6]);
    cb.Ticks = valid_ticks;
    cb.TickLabels = arrayfun(@(x) sprintf('%.2f', x), valid_ticks, 'UniformOutput', false);
    cb.Label.String = 'Effect Size';
    % ============== END COLOR BAR HANDLING ==============

% Top region colorbar (columns)
top_ax = axes('Position', [0.3 0.75 0.6 0.02]);
top_color = permute(full_color_rgb, [2, 1, 3]);
image(1:size(full_color_valid,1), 1, top_color);
axis off;
set(top_ax, 'XTick', [], 'YTick', []);

% Left region colorbar (rows)
left_ax = axes('Position', [0.28 0.15 0.02 0.6]);
image(1:size(full_color_valid,1), 1, reshape(full_color_valid, [size(full_color_valid,1), 1, 3]));
axis off;
set(left_ax, 'XTick', [], 'YTick', []);

% ================== ADD Y-AXIS LABELS ==================
valid_indices = find(mask_valid);

% Prepare tick positions and labels
tick_positions = [];
tick_labels = {};

% For each region in left hemisphere
for r = 1:numel(regions)
    reg = regions{r};
    name = reg{1};
    start_idx = reg{2};
    end_idx = reg{3};
    
    % Get original indices for this region
    orig_idx = start_idx:end_idx;
    
    % Find which of these indices are valid
    [tf, loc] = ismember(orig_idx, valid_indices);
    valid_loc = loc(tf);
    
    if isempty(valid_loc)
        continue;
    end
    
    % Calculate midpoint of this region in valid space
    y_min = min(valid_loc);
    y_max = max(valid_loc);
    y_mid = (y_min + y_max)/2;
    
    % Store position and label
    tick_positions(end+1) = y_mid;
    tick_labels{end+1} = name;
    
    % Add horizontal line at region boundary
    if r < numel(regions)
        line(main_ax, [0.5, size(scans_avg_valid, 2)+0.5], [y_max+0.5, y_max+0.5], ...
            'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
    end
end

% Sort tick positions and corresponding labels
[tick_positions_sorted, sort_indices] = sort(tick_positions);
tick_labels_sorted = tick_labels(sort_indices);

% Set Y-axis ticks and labels
set(main_ax, 'YTick', tick_positions_sorted, 'YTickLabel', tick_labels_sorted, ...
    'TickLength', [0 0], 'FontSize', 8, 'FontWeight', 'bold');

% Hide X-axis
set(main_ax, 'XTick', []);

% Add title
title_ax = axes('Position', [0.4 0.8 0.5 0.05], 'Visible', 'off');
text(0.5, 0.5, save_name, ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

% Save image
cd(save_path);
print('-dsvg', '-r300',[save_name,'.svg']);
print(fig,'-djpeg', '-r300',[save_name,'.jpg']);
%close all;
end
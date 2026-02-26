%% Mouse Functional Network Metrics Analysis and Functional Fingerprint Calculation
clear all; close all; clc;
wholepath='/newdatc/home/wanglab41/MCP_mice_MRI/net11_mean_ind_behv/';
%% 0. Create output directory
outputDir =fullfile(wholepath, 'results');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
figDir = fullfile(wholepath,'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Define network names and abbreviations
full_names = {'Thalamus Network', 'Olfactory-Limbic Network', 'Sensorimotor Network', ...
              'Brainstem Network', 'Limbic-prefrontal Network', 'Extended Salience Network', ...
              'Extended Amygdala-Hypothalamic-Olfactory Network', 'Cerebellar-Basal Ganglia-Motor Network', ...
              'Extended Hypothalamic-Basal Forebrain Network', 'Medial Cortical-Sensorimotor Network', 'Sensory-Hippocampa-Integration Network'};

abbrev_names = {'TN', 'OLN', 'SMN', 'BSN', 'LPN', 'ESN', 'EAHON', 'CBMN', 'EHBN', 'MCSN', 'SHIN'};

% Save network names
save(fullfile(outputDir, 'network_names.mat'), 'full_names', 'abbrev_names');

%% 1. Load and preprocess behavioral data
cd(wholepath);
data_table = readtable('AMCP_behv_measure.csv');
behavior_names = data_table.Properties.VariableNames(3:end);
beh_all_mat = data_table{:, 3:end};

% Remove outliers using 3-sigma rule
for i = 1:size(beh_all_mat, 2)
    col_data = beh_all_mat(:, i);
    col_data(col_data == 0) = NaN; % Treat zeros as missing data
    mean_val = nanmean(col_data);
    std_val = nanstd(col_data);
    outliers = col_data < (mean_val - 3*std_val) | col_data > (mean_val + 3*std_val);
    col_data(outliers) = NaN;
    beh_all_mat(:, i) = col_data;
end

% Use all behaviors without filtering
beh_indices = 1:size(beh_all_mat, 2);
fprintf('Using all %d behaviors for analysis.\n', length(beh_indices));

% Save the list of selected behaviors
save(fullfile(outputDir, 'selected_behaviors.mat'), 'beh_indices', 'behavior_names');

%% 2. Load FC data and extract features
cd(wholepath);
FC_data = struct();
load('Average_network_timeseries.mat');
[n_roi, n_time, n_run, n_sub] = size(network_ts);
sub_connectivity_matrices = zeros(n_sub, n_roi, n_roi);
for sub = 1:n_sub
    sub_data = squeeze(network_ts(:, :, :, sub));
    sub_run_connectivity = zeros(n_roi, n_roi, n_run);
    for run = 1:n_run
        ts_run = squeeze(sub_data(:, :, run));
        pearson_corr = corr(ts_run');
        pearson_corr(isnan(pearson_corr)) = 0;
        pearson_corr = min(max(pearson_corr, -0.9999), 0.9999);
        pearson_corr(1:n_roi+1:end) = 0;
        fc_matrix_z = atanh(pearson_corr);
        
        sub_run_connectivity(:, :, run) = fc_matrix_z;
    end
    sub_mean_connectivity = mean(sub_run_connectivity, 3, 'omitnan');
    sub_connectivity_matrices(sub, :, :) = sub_mean_connectivity;
end
FC_data.mean =   sub_connectivity_matrices;

load('Individual_network_timeseries.mat');
[n_roi, n_time, n_run, n_sub] = size(network_ts);
sub_connectivity_matrices = zeros(n_sub, n_roi, n_roi);
for sub = 1:n_sub
    sub_data = squeeze(network_ts(:, :, :, sub));
    sub_run_connectivity = zeros(n_roi, n_roi, n_run);
    for run = 1:n_run
        ts_run = squeeze(sub_data(:, :, run));
        pearson_corr = corr(ts_run');
        pearson_corr(isnan(pearson_corr)) = 0;
        pearson_corr = min(max(pearson_corr, -0.9999), 0.9999);
        pearson_corr(1:n_roi+1:end) = 0;
        fc_matrix_z = atanh(pearson_corr);
        
        sub_run_connectivity(:, :, run) = fc_matrix_z;
    end
    sub_mean_connectivity = mean(sub_run_connectivity, 3, 'omitnan');
    sub_connectivity_matrices(sub, :, :) = sub_mean_connectivity;
end
FC_data.parcel =   sub_connectivity_matrices;

% Calculate similarity and ICC
mean_MCP = squeeze(mean(FC_data.mean, 1, 'omitnan'));
mean_parcel = squeeze(mean(FC_data.parcel, 1, 'omitnan'));
[n_roi, ~] = size(mean_MCP);
triu_idx = triu(true(n_roi), 1);
vec_MCP = mean_MCP(triu_idx);
vec_parcel = mean_parcel(triu_idx);
[corr_value, p_value] = corr(vec_MCP, vec_parcel);
n_sub = size(FC_data.mean, 1);
n_connections = sum(triu_idx(:));
icc_values = zeros(n_connections, 1);
for conn = 1:n_connections
    mcp_vals = zeros(n_sub, 1);
    parcel_vals = zeros(n_sub, 1);
    
    for sub = 1:n_sub
        fc_mcp = squeeze(FC_data.mean(sub, :, :));
        fc_parcel = squeeze(FC_data.parcel(sub, :, :));
        
        vec_mcp = fc_mcp(triu_idx);
        vec_parcel = fc_parcel(triu_idx);
        
        mcp_vals(sub) = vec_mcp(conn);
        parcel_vals(sub) = vec_parcel(conn);
    end
    
    data_matrix = [mcp_vals, parcel_vals];
    icc_values(conn) = calculate_ICC(data_matrix);
end
figure('Position', [100, 100, 1200, 500]);
subplot(1, 2, 1);
scatter(vec_MCP, vec_parcel, 30, 'filled', 'MarkerFaceAlpha', 0.6);
lsline;
xlabel('MCP FC (Fisher Z)');
ylabel('Parcel FC (Fisher Z)');
if p_value < 0.001
    p_text = 'p < 0.001';
else
    p_text = sprintf('p = %.3f', p_value);
end
title(sprintf('FC Similarity\nr = %.3f, %s', corr_value, p_text));
grid on;
axis equal;
subplot(1, 2, 2);
histogram(icc_values, 30, 'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.7);
xlabel('ICC Values');
ylabel('Frequency');
title(sprintf('ICC Distribution\nMean = %.3f', mean(icc_values, 'omitnan')));
grid on;
saveas(gcf, 'FC_Analysis_Combined.png', 'png');
saveas(gcf, 'FC_Analysis_Combined.pdf', 'pdf');
close(gcf);


fc_types = fieldnames(FC_data);
% Precompute FC features for each type
FC_features = struct();
for i = 1:length(fc_types)
    type = fc_types{i};
    data = FC_data.(type);
    n_subs = size(data, 1);
    features = zeros(n_subs, n_features);
    for sub = 1:n_subs
        fc_matrix = squeeze(data(sub, :, :));
        features(sub, :) = fc_matrix(mask);
    end
    FC_features.(type) = features;
end

% Create network connection labels
network_labels = cell(n_features, 1);
[idx_i, idx_j] = find(mask);
for f = 1:n_features
    network_labels{f} = sprintf('%s-%s', abbrev_names{idx_j(f)}, abbrev_names{idx_i(f)});
end

% Save FC features
save(fullfile(outputDir, 'FC_features.mat'), 'FC_features', 'fc_types', 'mask', 'network_labels');

%% 3. Correlation analysis
alpha = 0.05;
corr_results = struct();
for i = 1:length(fc_types)
    type = fc_types{i};
    features = FC_features.(type);
    corr_matrix = zeros(n_features, length(beh_indices));
    p_values = zeros(n_features, length(beh_indices));
    
    for b = 1:length(beh_indices)
        beh_col = beh_indices(b);
        y = beh_all_mat(:, beh_col);
        valid = ~isnan(y);
        for f = 1:n_features
            x = features(valid, f);
            y_valid = y(valid);
            [rho, p] = corr(x, y_valid, 'rows', 'complete');
            corr_matrix(f, b) = rho;
            p_values(f, b) = p;
        end
    end
    
    % FDR correction
    [h, crit_p, adj_p] = fdr_bh(p_values(:), alpha, 'dep');
    h = reshape(h, size(p_values));
    corr_results.(type).corr_matrix = corr_matrix;
    corr_results.(type).p_values = p_values;
    corr_results.(type).significant = h;
    corr_results.(type).adj_p = reshape(adj_p, size(p_values));
    
    % Count significant correlations
    n_sig = sum(h(:));
    fprintf('%s: %d significant correlations found (FDR corrected, alpha=%.3f)\n', type, n_sig, alpha);
end

% Save correlation results
save(fullfile(outputDir, 'correlation_results.mat'), 'corr_results', 'beh_indices', 'behavior_names', 'network_labels');

% Plot number of significant correlations for each FC type
sig_counts = zeros(length(fc_types), 1);
for i = 1:length(fc_types)
    type = fc_types{i};
    sig_counts(i) = sum(corr_results.(type).significant(:));
end

figure;
bar(sig_counts, 'FaceColor', [0.5 0.5 0.5]);
set(gca, 'XTickLabel', fc_types, 'XTickLabelRotation', 45);
ylabel('Number of significant correlations');
title('Significant correlations between FC and behavior (FDR corrected)');
saveas(gcf, fullfile(figDir, 'sig_correlations.png'));
saveas(gcf, fullfile(figDir, 'sig_correlations.pdf'));
close;

%% 4. Prediction analysis with ridge regression (using only significant features)
lambdas = logspace(-3, 3, 10);
n_folds = 10;
performance = NaN(length(beh_indices), length(fc_types)); % Initialize with NaN
permutation_pvalues = NaN(length(beh_indices), length(fc_types)); % Store permutation p-values
predicted_values = cell(length(beh_indices), length(fc_types));
true_values = cell(length(beh_indices), 1);
n_permutations = 1000; % Number of permutations

% Create a directory for prediction data
predDataDir = fullfile(outputDir, 'prediction_data');
if ~exist(predDataDir, 'dir')
    mkdir(predDataDir);
end

for b = 1:length(beh_indices)
    beh_col = beh_indices(b);
    y = beh_all_mat(:, beh_col);
    valid = ~isnan(y);
    y_valid = y(valid);
    
    % Skip behaviors with insufficient data
    if length(y_valid) < 2
        fprintf('Skipping behavior %d: insufficient data (%d valid samples)\n', b, length(y_valid));
        continue;
    end
    
    y_valid_z = (y_valid - mean(y_valid)) / std(y_valid);
    true_values{b} = y_valid;
    
    for fc = 1:length(fc_types)
        type = fc_types{fc};
        X = FC_features.(type);
        X_valid = X(valid, :);
        
        % Select only significant features for this behavior
        sig_features = find(corr_results.(type).significant(:, b));
        if isempty(sig_features)
            % If no significant features, use all features
            X_selected = X_valid;
        else
            X_selected = X_valid(:, sig_features);
        end
        
        X_selected_z = (X_selected - mean(X_selected)) ./ std(X_selected);
        
        try
            cv = cvpartition(length(y_valid_z), 'KFold', n_folds);
            y_pred = zeros(length(y_valid_z), 1);
            
            for fold = 1:n_folds
                train_idx = cv.training(fold);
                test_idx = cv.test(fold);
                X_train = X_selected_z(train_idx, :);
                y_train = y_valid_z(train_idx);
                X_test = X_selected_z(test_idx, :);
                
                % Inner CV for lambda selection
                inner_cv = cvpartition(length(y_train), 'KFold', 5);
                mse = zeros(length(lambdas), 1);
                for l = 1:length(lambdas)
                    mse_fold = zeros(inner_cv.NumTestSets, 1);
                    for inner_fold = 1:inner_cv.NumTestSets
                        inner_train = inner_cv.training(inner_fold);
                        inner_test = inner_cv.test(inner_fold);
                        X_inner_train = X_train(inner_train, :);
                        y_inner_train = y_train(inner_train);
                        X_inner_test = X_train(inner_test, :);
                        y_inner_test = y_train(inner_test);
                        
                        beta = ridge(y_inner_train, X_inner_train, lambdas(l), 0);
                        y_inner_pred = [ones(size(X_inner_test,1),1) X_inner_test] * beta;
                        mse_fold(inner_fold) = mean((y_inner_pred - y_inner_test).^2);
                    end
                    mse(l) = mean(mse_fold);
                end
                [~, best_idx] = min(mse);
                best_lambda = lambdas(best_idx);
                
                % Train with best lambda
                beta = ridge(y_train, X_train, best_lambda, 0);
                y_test_pred = [ones(size(X_test,1),1) X_test] * beta;
                y_pred(test_idx) = y_test_pred;
            end
            
            % Calculate real prediction performance
            real_corr = corr(y_valid_z, y_pred);
            performance(b, fc) = real_corr;
            predicted_values{b, fc} = y_pred * std(y_valid) + mean(y_valid);
            
            % Permutation test
            perm_corrs = zeros(n_permutations, 1);
            for perm = 1:n_permutations
                % Randomly shuffle behavioral data
                y_perm = y_valid_z(randperm(length(y_valid_z)));
                y_perm_pred = zeros(length(y_valid_z), 1);
                
                for fold = 1:n_folds
                    train_idx = cv.training(fold);
                    test_idx = cv.test(fold);
                    X_train = X_selected_z(train_idx, :);
                    y_train = y_perm(train_idx);
                    X_test = X_selected_z(test_idx, :);
                    
                    % Use the same lambda
                    beta = ridge(y_train, X_train, best_lambda, 0);
                    y_test_pred = [ones(size(X_test,1),1) X_test] * beta;
                    y_perm_pred(test_idx) = y_test_pred;
                end
                
                perm_corrs(perm) = corr(y_perm, y_perm_pred);
            end
            
            % Calculate p-value
            permutation_pvalues(b, fc) = sum(perm_corrs >= real_corr) / n_permutations;
            
        catch ME
            fprintf('Error predicting behavior %d with method %s: %s\n', b, type, ME.message);
            performance(b, fc) = NaN;
            permutation_pvalues(b, fc) = NaN;
            predicted_values{b, fc} = NaN;
        end
    end
    
    % Save individual behavior prediction data
    beh_name = behavior_names{b};
    [~, safe_name] = fileparts(beh_name);
    safe_name = regexprep(safe_name, '[^a-zA-Z0-9_]', '_');
    
    % Save data for this behavior
    pred_data = struct();
    pred_data.behavior_name = beh_name;
    pred_data.true_values = true_values{b};
    pred_data.predicted_values = predicted_values(b, :);
    pred_data.performance = performance(b, :);
    pred_data.permutation_pvalues = permutation_pvalues(b, :);
    pred_data.fc_types = fc_types;
    
    save(fullfile(predDataDir, sprintf('prediction_%s.mat', safe_name)), 'pred_data');
    
    if mod(b, 10) == 0
        fprintf('Completed prediction for %d/%d behaviors\n', b, length(beh_indices));
        
        % Save intermediate results
        save(fullfile(outputDir, 'prediction_performance_interim.mat'), 'performance', 'permutation_pvalues', 'predicted_values', 'true_values', 'beh_indices', 'fc_types');
    end
end

% Save final performance results
save(fullfile(outputDir, 'prediction_performance.mat'), 'performance', 'permutation_pvalues', 'predicted_values', 'true_values', 'beh_indices', 'fc_types');

%% 5. Compare FC processing methods
mean_performance = mean(performance, 1, 'omitnan');
std_performance = std(performance, 0, 1, 'omitnan');
fprintf('Performance comparison (correlation between predicted and actual behavior):\n');
for i = 1:length(fc_types)
    fprintf('%s: Mean = %.3f, SD = %.3f\n', fc_types{i}, mean_performance(i), std_performance(i));
end

% Statistical comparison (paired t-test between methods)
valid_behaviors = ~all(isnan(performance), 2);
[p_12, ~] = ttest(performance(valid_behaviors,1), performance(valid_behaviors,2));
[p_13, ~] = ttest(performance(valid_behaviors,1), performance(valid_behaviors,3));
[p_14, ~] = ttest(performance(valid_behaviors,1), performance(valid_behaviors,4));
fprintf('Paired t-tests (mean vs others):\n');
fprintf('Mean vs run12: p = %.4f\n', p_12);
fprintf('Mean vs run34: p = %.4f\n', p_13);
fprintf('Mean vs run1234: p = %.4f\n', p_14);

% Find the best performing method
[~, best_method] = max(mean_performance);
fprintf('Best performing method: %s\n', fc_types{best_method});

% Save comparison results
save(fullfile(outputDir, 'method_comparison.mat'), 'mean_performance', 'std_performance', 'p_12', 'p_13', 'p_14', 'best_method');

% Plot prediction performance for each method
figure;
boxplot(performance, 'Labels', fc_types);
ylabel('Prediction correlation (r)');
title('Prediction performance across FC methods');
colormap(gray(length(fc_types)));
saveas(gcf, fullfile(figDir, 'prediction_performance_boxplot.png'));
saveas(gcf, fullfile(figDir, 'prediction_performance_boxplot.pdf'));
close;

figure;
bar(mean_performance, 'FaceColor', [0.5 0.5 0.5]);
hold on;
errorbar(1:length(mean_performance), mean_performance, std_performance, 'k.', 'LineWidth', 1.5);
set(gca, 'XTickLabel', fc_types, 'XTickLabelRotation', 45);
ylabel('Mean prediction correlation (r)');
title('Mean prediction performance with standard deviation');
saveas(gcf, fullfile(figDir, 'prediction_performance_bar.png'));
saveas(gcf, fullfile(figDir, 'prediction_performance_bar.pdf'));
close;

%% 6. Create comprehensive figures for behaviors with significant FC correlations
best_method_name = fc_types{best_method};
best_corr_results = corr_results.(best_method_name);
best_FC_features = FC_features.(best_method_name);

% Find behaviors that have at least one significant correlation
sig_behaviors = any(best_corr_results.significant, 1);
sig_beh_indices = beh_indices(sig_behaviors);
sig_behavior_names = behavior_names(sig_beh_indices);

% Save significant behaviors and their p-values for filtering
behavior_pvalues = zeros(length(sig_beh_indices), 1);
for i = 1:length(sig_beh_indices)
    beh_idx = sig_beh_indices(i);
    beh_pred_idx = find(beh_indices == beh_idx);
    [~, most_sig_feature] = max(abs(best_corr_results.corr_matrix(:, beh_pred_idx)));
    behavior_pvalues(i) = best_corr_results.p_values(most_sig_feature, beh_pred_idx);
end
save(fullfile(outputDir, 'behavior_pvalues.mat'), 'sig_behavior_names', 'behavior_pvalues');

fprintf('Behaviors with at least one significant correlation for %s:\n', best_method_name);
for i = 1:length(sig_behavior_names)
    fprintf('%s (p=%.4f)\n', sig_behavior_names{i}, behavior_pvalues(i));
end

% Save significant behaviors
save(fullfile(outputDir, 'significant_behaviors.mat'), 'sig_behavior_names', 'best_method_name', 'behavior_pvalues');

% Create a directory for comprehensive behavior figures
compFigDir = fullfile(figDir, 'comprehensive_behavior_figures');
if ~exist(compFigDir, 'dir')
    mkdir(compFigDir);
end

% Create a directory for comprehensive behavior data (for Python plotting)
compDataDir = fullfile(outputDir, 'comprehensive_behavior_data');
if ~exist(compDataDir, 'dir')
    mkdir(compDataDir);
end

% For each behavior with significant correlations, create a comprehensive figure
for b = 1:length(sig_beh_indices)
    beh_idx = sig_beh_indices(b);
    beh_name = sig_behavior_names{b};
    
    % Skip if this behavior wasn't successfully predicted
    beh_pred_idx = find(beh_indices == beh_idx);
    if isnan(performance(beh_pred_idx, best_method))
        fprintf('Skipping comprehensive figure for %s: no prediction data\n', beh_name);
        continue;
    end
    
    % Create a new figure with larger size
    fig = figure('Position', [100, 100, 1400, 1000]);
    
    % 1. Scatter plot: Behavior vs most significant FC feature
    [~, most_sig_feature] = max(abs(best_corr_results.corr_matrix(:, beh_pred_idx)));
    fc_feature_values = best_FC_features(:, most_sig_feature);
    beh_values = beh_all_mat(:, beh_idx);
    
    % Remove NaN values
    valid_idx = ~isnan(beh_values) & ~isnan(fc_feature_values);
    fc_feature_values = fc_feature_values(valid_idx);
    beh_values = beh_values(valid_idx);
    
    subplot(2, 3, 1);
    scatter(fc_feature_values, beh_values, 50, 'filled', 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerFaceAlpha', 0.6);
    xlabel('FC Feature Value');
    ylabel('Behavior Value');
    title(sprintf('Behavior vs Most Significant FC Feature\nr = %.3f, p = %.4f', ...
        best_corr_results.corr_matrix(most_sig_feature, beh_pred_idx), ...
        best_corr_results.p_values(most_sig_feature, beh_pred_idx)));
    grid on;
    
    % Add correlation line
    hold on;
    p = polyfit(fc_feature_values, beh_values, 1);
    x_range = [min(fc_feature_values), max(fc_feature_values)];
    y_fit = polyval(p, x_range);
    plot(x_range, y_fit, 'k-', 'LineWidth', 2);
    hold off;
    
    % 2. FC Matrix Heatmap (using jet colormap, only significant connections)
    sig_features_for_beh = best_corr_results.significant(:, beh_pred_idx);
    corr_coeffs = best_corr_results.corr_matrix(:, beh_pred_idx);
    
    % Create an empty 11x11 matrix
    fc_matrix = zeros(n_nodes, n_nodes);
    
    % Fill the matrix with correlation coefficients using the mask
    fc_matrix(mask) = corr_coeffs;
    
    % Make the matrix symmetric
    fc_matrix = fc_matrix + fc_matrix' - diag(diag(fc_matrix));
    
    % Create a mask for significant connections
    sig_mask = false(n_nodes, n_nodes);
    sig_mask(mask) = sig_features_for_beh;
    sig_mask = sig_mask | sig_mask'; % Make symmetric
    
    % Set non-significant connections to NaN for visualization
    fc_matrix_vis = fc_matrix;
    fc_matrix_vis(~sig_mask) = NaN;
    
    subplot(2, 3, 2);
    imagesc(fc_matrix_vis);
    colorbar;
    caxis([-0.5 0.5]); % Set colorbar range to [-0.5, 0.5]
    colormap(jet);
    title('FC Matrix (Significant Connections Only)');
    xlabel('Brain Region');
    ylabel('Brain Region');
    
    % Add network names as tick labels
    set(gca, 'XTick', 1:n_nodes, 'XTickLabel', abbrev_names, 'XTickLabelRotation', 45);
    set(gca, 'YTick', 1:n_nodes, 'YTickLabel', abbrev_names);
    
    % Add grid
    hold on;
    for i = 1:n_nodes+1
        plot([0.5, n_nodes+0.5], [i-0.5, i-0.5], 'k-', 'LineWidth', 0.5);
        plot([i-0.5, i-0.5], [0.5, n_nodes+0.5], 'k-', 'LineWidth', 0.5);
    end
    hold off;
    
    % 3. Prediction Accuracy Plot
    true_vals = true_values{beh_pred_idx};
    pred_vals = predicted_values{beh_pred_idx, best_method};
    
    % Get permutation test p-value
    perm_pval = permutation_pvalues(beh_pred_idx, best_method);
    
    subplot(2, 3, 3);
    scatter(true_vals, pred_vals, 50, 'filled', 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerFaceAlpha', 0.6);
    xlabel('True Behavior Value');
    ylabel('Predicted Behavior Value');
    title(sprintf('Prediction Accuracy\nr = %.3f, p = %.4f', performance(beh_pred_idx, best_method), perm_pval));
    grid on;
    
    % Add identity line
    hold on;
    min_val = min([true_vals; pred_vals]);
    max_val = max([true_vals; pred_vals]);
    plot([min_val, max_val], [min_val, max_val], 'k--', 'LineWidth', 2);
    hold off;
    
    % 4. Top 5 significant FC features bar plot
    sig_feature_indices = find(best_corr_results.significant(:, beh_pred_idx));
    [~, sort_idx] = sort(abs(best_corr_results.corr_matrix(sig_feature_indices, beh_pred_idx)), 'descend');
    top_features = sig_feature_indices(sort_idx(1:min(5, length(sig_feature_indices))));
    
    subplot(2, 3, 4);
    bar(abs(best_corr_results.corr_matrix(top_features, beh_pred_idx)), 'FaceColor', [0.5 0.5 0.5]);
    
    % Use network connection names as x-axis labels
    top_labels = network_labels(top_features);
    set(gca, 'XTickLabel', top_labels, 'XTickLabelRotation', 45);
    xlabel('FC Feature');
    ylabel('Absolute Correlation');
    title('Top 5 Significant FC Features');
    
    % 5. Distribution of behavior values
    subplot(2, 3, 5);
    histogram(beh_values, 20, 'FaceColor', [0.5 0.5 0.5]);
    xlabel('Behavior Value');
    ylabel('Frequency');
    title('Distribution of Behavior Values');
    
    % 6. Distribution of most significant FC feature values
    subplot(2, 3, 6);
    histogram(fc_feature_values, 20, 'FaceColor', [0.5 0.5 0.5]);
    xlabel('FC Feature Value');
    ylabel('Frequency');
    title('Distribution of Most Significant FC Feature');
    
    % Add overall title
    sgtitle(sprintf('Comprehensive Analysis for %s\n(%s method)', strrep(beh_name, '_', '\_'), best_method_name), 'FontSize', 16);
    
    % Save figure in both PNG and PDF formats
    [~, safe_name] = fileparts(beh_name);
    safe_name = regexprep(safe_name, '[^a-zA-Z0-9_]', '_');
    saveas(fig, fullfile(compFigDir, sprintf('comprehensive_%s.png', safe_name)));
    saveas(fig, fullfile(compFigDir, sprintf('comprehensive_%s.pdf', safe_name)));
    
    % Save comprehensive data for Python plotting
    comp_data = struct();
    comp_data.behavior_name = beh_name;
    comp_data.fc_feature_values = fc_feature_values;
    comp_data.beh_values = beh_values;
    comp_data.fc_matrix_vis = fc_matrix_vis;
    comp_data.true_vals = true_vals;
    comp_data.pred_vals = pred_vals;
    comp_data.top_features = top_features;
    comp_data.top_correlations = abs(best_corr_results.corr_matrix(top_features, beh_pred_idx));
    comp_data.top_labels = top_labels;
    comp_data.p_value = behavior_pvalues(b);
    comp_data.correlation_coeff = best_corr_results.corr_matrix(most_sig_feature, beh_pred_idx);
    comp_data.prediction_corr = performance(beh_pred_idx, best_method);
    comp_data.permutation_pval = perm_pval;
    comp_data.network_names = abbrev_names;
    
    save(fullfile(compDataDir, sprintf('comprehensive_data_%s.mat', safe_name)), 'comp_data');
    
    close(fig);
end

%% 7. Create FC-behavior heatmaps for top behaviors
% 7.1 Top 20 behaviors with highest absolute correlation with FC
mean_corr_per_behavior = mean(abs(best_corr_results.corr_matrix), 1);
[~, top_corr_idx] = sort(mean_corr_per_behavior, 'descend');
top20_corr_behaviors = top_corr_idx(1:min(20, length(top_corr_idx)));

% Create heatmap
figure('Position', [100, 100, 1000, 800]);
imagesc(best_corr_results.corr_matrix(:, top20_corr_behaviors)');
colormap(jet);
colorbar;
caxis([-0.5 0.5]); % Set colorbar range to [-0.5, 0.5]
xlabel('FC Features');
ylabel('Behaviors');
set(gca, 'YTick', 1:length(top20_corr_behaviors));
set(gca, 'YTickLabel', behavior_names(beh_indices(top20_corr_behaviors)), 'YTickLabelRotation', 45);
title('Top 20 Behaviors with Highest Absolute Correlation with FC');
saveas(gcf, fullfile(figDir, 'top20_corr_behaviors_heatmap.png'));
saveas(gcf, fullfile(figDir, 'top20_corr_behaviors_heatmap.pdf'));
close;

% Save heatmap data
heatmap_data = struct();
heatmap_data.corr_matrix = best_corr_results.corr_matrix(:, top20_corr_behaviors);
heatmap_data.behavior_names = behavior_names(beh_indices(top20_corr_behaviors));
heatmap_data.network_labels = network_labels;
save(fullfile(outputDir, 'top20_corr_behaviors_heatmap_data.mat'), 'heatmap_data');

% 7.2 Top 20 behaviors with highest prediction performance
[~, top_pred_idx] = sort(abs(performance(:, best_method)), 'descend');
top20_pred_behaviors = top_pred_idx(1:min(20, length(top_pred_idx)));

% Create heatmap
figure('Position', [100, 100, 1000, 800]);
imagesc(best_corr_results.corr_matrix(:, top20_pred_behaviors)');
colormap(jet);
colorbar;
caxis([-0.5 0.5]); % Set colorbar range to [-0.5, 0.5]
xlabel('FC Features');
ylabel('Behaviors');
set(gca, 'YTick', 1:length(top20_pred_behaviors));
set(gca, 'YTickLabel', behavior_names(beh_indices(top20_pred_behaviors)), 'YTickLabelRotation', 45);
title('Top 20 Behaviors with Highest Prediction Performance');
saveas(gcf, fullfile(figDir, 'top20_pred_behaviors_heatmap.png'));
saveas(gcf, fullfile(figDir, 'top20_pred_behaviors_heatmap.pdf'));
close;

% Save heatmap data
heatmap_data2 = struct();
heatmap_data2.corr_matrix = best_corr_results.corr_matrix(:, top20_pred_behaviors);
heatmap_data2.behavior_names = behavior_names(beh_indices(top20_pred_behaviors));
heatmap_data2.network_labels = network_labels;
save(fullfile(outputDir, 'top20_pred_behaviors_heatmap_data.mat'), 'heatmap_data2');

% Save all variables for future reference
save(fullfile(outputDir, 'all_results.mat'));

fprintf('Analysis complete. Results saved in %s, figures saved in %s.\n', outputDir, figDir);
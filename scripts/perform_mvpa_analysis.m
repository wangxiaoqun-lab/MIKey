function results = perform_mvpa_analysis(ExpTable, cond, img_type, WholePath, Time, medulla_indices, output_path)
    % Perform multivariate pattern analysis
    
    results = struct();
    
    % Load time series data
    [pre_signals, run_signals, subject_ids] = load_time_series_data(ExpTable, cond, img_type, WholePath, Time);
    
    if isempty(pre_signals)
        results.status = 'No data available';
        return;
    end
    
    n_subjects = length(pre_signals);
    n_medulla = length(medulla_indices);
    
    % Extract medulla time series features
    features_pre = zeros(n_subjects, n_medulla);
    features_run = zeros(n_subjects, n_medulla);
    
    for s = 1:n_subjects
        % Use variance of medulla region time series as features
        medulla_pre = pre_signals{s}(medulla_indices, :);
        medulla_run = run_signals{s}(medulla_indices, :);
        
        features_pre(s, :) = std(medulla_pre, 0, 2)';
        features_run(s, :) = std(medulla_run, 0, 2)';
    end
    
    % Classification analysis: distinguish pre vs run states
    labels = [zeros(n_subjects, 1); ones(n_subjects, 1)]; % 0=pre, 1=run
    all_features = [features_pre; features_run];
    
    % Use simple LDA classification
    cv = cvpartition(labels, 'KFold', 5);
    accuracy = zeros(cv.NumTestSets, 1);
    
    for i = 1:cv.NumTestSets
        train_idx = cv.training(i);
        test_idx = cv.test(i);
        
        % Train LDA classifier
        lda_model = fitcdiscr(all_features(train_idx, :), labels(train_idx));
        
        % Predict
        predictions = predict(lda_model, all_features(test_idx, :));
        accuracy(i) = sum(predictions == labels(test_idx)) / length(predictions);
    end
    
    mean_accuracy = mean(accuracy);
    
    % Permutation test
    n_permutations = 1000;
    null_accuracies = zeros(n_permutations, 1);
    
    for p = 1:n_permutations
        shuffled_labels = labels(randperm(length(labels)));
        
        perm_accuracy = zeros(cv.NumTestSets, 1);
        for i = 1:cv.NumTestSets
            train_idx = cv.training(i);
            test_idx = cv.test(i);
            
            lda_model = fitcdiscr(all_features(train_idx, :), shuffled_labels(train_idx));
            predictions = predict(lda_model, all_features(test_idx, :));
            perm_accuracy(i) = sum(predictions == shuffled_labels(test_idx)) / length(predictions);
        end
        
        null_accuracies(p) = mean(perm_accuracy);
    end
    
    p_value = sum(null_accuracies >= mean_accuracy) / n_permutations;
    
    results.accuracy = mean_accuracy;
    results.p_value = p_value;
    results.chance_level = 0.5;
    results.significant = p_value < 0.05;
    
    % Plot MVPA results
    figure('Position', [100, 100, 800, 400]);
    
    subplot(1,2,1);
    bar([mean_accuracy, 0.5], 'FaceColor', [0.2, 0.6, 0.2]);
    set(gca, 'XTickLabel', {'Actual Accuracy', 'Chance Level'});
    ylabel('Classification Accuracy');
    title(sprintf('MVPA Classification Accuracy: %.3f', mean_accuracy));
    grid on;
    
    subplot(1,2,2);
    histogram(null_accuracies, 30, 'FaceColor', [0.7, 0.7, 0.7]);
    hold on;
    plot([mean_accuracy, mean_accuracy], ylim, 'r-', 'LineWidth', 2);
    xlabel('Permutation Test Accuracy');
    ylabel('Frequency');
    title(sprintf('Permutation Test: p = %.4f', p_value));
    legend('Null Distribution', 'Actual Accuracy');
    grid on;
    
    saveas(gcf, fullfile(output_path, 'mvpa_analysis.png'));
    close gcf;
    
    fprintf('  MVPA analysis completed: accuracy=%.3f, p=%.4f\n', mean_accuracy, p_value);
end
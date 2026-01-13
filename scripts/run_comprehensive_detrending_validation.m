function results = run_comprehensive_detrending_validation(ExpTable, cond, img_file, WholePath, Time, output_path, brain_atlas)
    % Comprehensive spatial detrending validation for SCI publication
    
    results = struct();
    results.timestamp = datestr(now);
    results.condition = cond;
    
    % 1. Load all available 4D data
    fprintf('  1. Loading all 4D data...\n');
    [all_original_data, all_detrended_data, subject_info, metadata] = load_all_4d_data_comprehensive(ExpTable, cond, img_file, WholePath, Time);
    
    if isempty(all_original_data)
        error('No valid 4D data found for condition: %s', cond);
    end
    
    results.n_subjects = length(all_original_data);
    results.subject_info = subject_info;
    results.metadata = metadata;
    
    fprintf('    Processing %d subjects with %d time points each\n', results.n_subjects, metadata.typical_timepoints);
    
    % 2. Comprehensive basic principles validation
    fprintf('  2. Validating basic principles with rigorous statistical tests...\n');
    basic_principles = validate_basic_principles_comprehensive(all_original_data, all_detrended_data, output_path);
    results.basic_principles = basic_principles;
    
    % 3. Advanced alternative methods comparison
    fprintf('  3. Comparing advanced detrending methods...\n');
    method_comparison = compare_detrending_methods_advanced(all_original_data, output_path);
    results.method_comparison = method_comparison;
    
    % 4. Rigorous sensitivity and robustness analysis
    fprintf('  4. Performing sensitivity and robustness analysis...\n');
    sensitivity_results = perform_rigorous_sensitivity_analysis(all_original_data, all_detrended_data, output_path);
    results.sensitivity_analysis = sensitivity_results;
    
    % 5. Comprehensive biological plausibility validation
    fprintf('  5. Validating biological plausibility with neuroanatomical reference...\n');
    biological_validation = validate_biological_plausibility_comprehensive(all_detrended_data, brain_atlas, output_path);
    results.biological_validation = biological_validation;
    
    % 6. Statistical summary and effect sizes
    fprintf('  6. Computing comprehensive statistical summaries...\n');
    statistical_summary = compute_statistical_summary(all_original_data, all_detrended_data, basic_principles, sensitivity_results);
    results.statistical_summary = statistical_summary;
    
    % Save complete results
    save(fullfile(output_path, 'comprehensive_validation_results.mat'), 'results', '-v7.3');
    
    fprintf('  Comprehensive validation completed for %d subjects\n', results.n_subjects);
end
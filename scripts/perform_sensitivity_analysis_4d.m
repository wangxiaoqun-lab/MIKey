function sensitivity_results = perform_sensitivity_analysis_4d(original_4d, detrended_4d, output_path)
    % 3. Sensitivity analysis
    
    sensitivity_results = struct();
    
    figure('Position', [100, 100, 1200, 800]);
    
    %% 3.1 Parameter sensitivity (polynomial order)
    subplot(2, 3, 1);
    orders = 1:5;
    sensitivity_metrics = zeros(length(orders), 3);
    
    for i = 1:length(orders)
        test_detrended = polynomial_spatial_detrend_3d_4d(original_4d, orders(i));
        sensitivity_metrics(i, 1) = compute_morans_i(mean(test_detrended, 4));
        sensitivity_metrics(i, 2) = compute_snr_4d(test_detrended);
        sensitivity_metrics(i, 3) = compute_medulla_effect_size_4d(test_detrended);
    end
    
    plot(orders, sensitivity_metrics);
    xlabel('Polynomial Order');
    ylabel('Metric Value');
    legend({'Spatial Autocorrelation', 'Signal-to-Noise Ratio', 'Medulla Effect'}, 'Location', 'best');
    title('Parameter Sensitivity Analysis');
    grid on;
    
    %% 3.2 Data stability (resampling)
    subplot(2, 3, 2);
    stability_results = test_data_stability(original_4d, detrended_4d);
    bar(stability_results);
    ylabel('Stability Metric');
    title('Data Stability Test');
    
    %% 3.3 Noise robustness
    subplot(2, 3, 3);
    noise_levels = 0.01:0.01:0.1;
    robustness = test_noise_robustness(original_4d, detrended_4d, noise_levels);
    plot(noise_levels, robustness);
    xlabel('Noise Level');
    ylabel('Effect Preservation Rate');
    title('Noise Robustness Analysis');
    grid on;
    
    %% 3.4 Spatial scale sensitivity
    subplot(2, 3, 4);
    scale_sensitivity = test_spatial_scale_sensitivity(original_4d, detrended_4d);
    plot(scale_sensitivity.scales, scale_sensitivity.effects);
    xlabel('Spatial Scale (mm)');
    ylabel('Effect Size');
    title('Spatial Scale Sensitivity');
    grid on;
    
    %% 3.5 Time point sensitivity
    subplot(2, 3, 5);
    time_sensitivity = test_time_point_sensitivity(original_4d, detrended_4d);
    plot(time_sensitivity);
    xlabel('Time Point');
    ylabel('Detrending Effect');
    title('Time Point Sensitivity');
    grid on;
    
    %% 3.6 Overall sensitivity score
    subplot(2, 3, 6);
    overall_sensitivity = compute_overall_sensitivity(sensitivity_metrics, robustness, stability_results);
    pie([overall_sensitivity, 100-overall_sensitivity]);
    legend({'Robust', 'Sensitive'}, 'Location', 'best');
    title(sprintf('Overall Sensitivity: %.1f%%', overall_sensitivity));
    
    saveas(gcf, fullfile(output_path, 'sensitivity_analysis.png'));
    close gcf;
    
    sensitivity_results.overall_score = overall_sensitivity;
    save(fullfile(output_path, 'sensitivity_results.mat'), 'sensitivity_results');
end

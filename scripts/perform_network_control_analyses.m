function results = perform_network_control_analyses(fc_changes, regions, medulla_indices, output_path)
    % Perform various network control analyses
    
    results = struct();
    n_regions = size(fc_changes, 2);
    n_subjects = size(fc_changes, 1);
    
    % Analysis 1: Random region control
    fprintf('    Performing random region control analysis...\n');
    n_medulla = length(medulla_indices);
    n_iterations = 1000;
    
    % Calculate true medulla effect
    true_effect = compute_region_set_effect(fc_changes, medulla_indices);
    
    % Random sampling
    random_effects = zeros(n_iterations, 1);
    for i = 1:n_iterations
        random_indices = randperm(n_regions, n_medulla);
        random_effects(i) = compute_region_set_effect(fc_changes, random_indices);
    end
    
    % Calculate p-value
    p_value = sum(random_effects >= true_effect) / n_iterations;
    
    results.random_control.true_effect = true_effect;
    results.random_control.random_mean = mean(random_effects);
    results.random_control.random_std = std(random_effects);
    results.random_control.p_value = p_value;
    results.random_control.effect_size = (true_effect - mean(random_effects)) / std(random_effects);
    
    % Plot random control analysis
    figure('Position', [100, 100, 1200, 400]);
    
    subplot(1,3,1);
    histogram(random_effects, 50, 'FaceColor', [0.7, 0.7, 0.7]);
    hold on;
    plot([true_effect, true_effect], ylim, 'r-', 'LineWidth', 3);
    xlabel('Random Region Set Effect');
    ylabel('Frequency');
    title('Random Control Analysis');
    legend('Random Distribution', 'True Medulla Effect');
    grid on;
    
    % Analysis 2: Size-matched control
    fprintf('    Performing size-matched control analysis...\n');
    size_matched_effects = zeros(length(regions), 1);
    region_sizes = zeros(length(regions), 1);
    
    for r = 1:length(regions)
        region_indices = regions{r}{2}:regions{r}{3};
        region_sizes(r) = length(region_indices);
        if region_sizes(r) == n_medulla % Size-matched regions
            size_matched_effects(r) = compute_region_set_effect(fc_changes, region_indices);
        end
    end
    
    results.size_matched.effects = size_matched_effects;
    results.size_matched.regions = regions;
    
    subplot(1,3,2);
    valid_effects = size_matched_effects(size_matched_effects ~= 0);
    valid_regions = {};
    for r = 1:length(regions)
        if size_matched_effects(r) ~= 0
            valid_regions{end+1} = regions{r}{1};
        end
    end
    
    if ~isempty(valid_effects)
        bar(1:length(valid_effects), valid_effects);
        set(gca, 'XTickLabel', valid_regions);
        xtickangle(45);
        ylabel('Average FC Change');
        title('Size-Matched Region Comparison');
        grid on;
    else
        text(0.5, 0.5, 'No size-matched regions found', 'HorizontalAlignment', 'center');
        title('Size-Matched Region Comparison');
    end
    
    % Analysis 3: Connection density control
    fprintf('    Performing connection density control analysis...\n');
    density_results = analyze_connection_density(fc_changes, medulla_indices, n_iterations);
    results.density_control = density_results;
    
    subplot(1,3,3);
    
    % Ê¹ÓÃÃÜ¶È·ÖÎö½á¹ûÖÐµÄ¿ÉÓÃ×Ö¶Î
    if isfield(density_results, 'sampled_densities') && isfield(density_results, 'sampled_effects')
        % »æÖÆÃÜ¶È-Ð§Ó¦É¢µãÍ¼
        plot(density_results.sampled_densities, density_results.sampled_effects, '.', ...
             'MarkerSize', 8, 'Color', [0.7, 0.7, 0.7]);
        hold on;
        
        % ±ê¼ÇÑÓËèµã
        if isfield(density_results, 'medulla_density') && isfield(density_results, 'medulla_effect')
            plot(density_results.medulla_density, density_results.medulla_effect, 'ro', ...
                 'MarkerSize', 10, 'MarkerFaceColor', 'r');
        end
        
        xlabel('Connection Density');
        ylabel('Average Effect');
        title('Density-Effect Relationship');
        
        if isfield(density_results, 'medulla_density')
            legend('Random Samples', 'Medulla', 'Location', 'best');
        else
            legend('Random Samples', 'Location', 'best');
        end
        grid on;
        
    elseif isfield(density_results, 'density_matched_effects')
        % Èç¹ûÓÐÃÜ¶ÈÆ¥ÅäÐ§Ó¦£¬»æÖÆÖ±·½Í¼
        if ~isempty(density_results.density_matched_effects)
            histogram(density_results.density_matched_effects, 30, 'FaceColor', [0.7, 0.7, 0.7]);
            hold on;
            plot([true_effect, true_effect], ylim, 'r-', 'LineWidth', 2);
            xlabel('Density-Matched Effects');
            ylabel('Frequency');
            title('Density-Matched Control');
            legend('Density-Matched', 'Medulla Effect');
            grid on;
        else
            text(0.5, 0.5, 'No density-matched data', 'HorizontalAlignment', 'center');
            title('Density Control Analysis');
        end
    else
        text(0.5, 0.5, 'Density analysis data not available', 'HorizontalAlignment', 'center');
        title('Density Control Analysis');
    end
    
    saveas(gcf, fullfile(output_path, 'network_control_analyses.png'));
    close gcf;
    
    fprintf('  Network control analysis completed\n');
end
function plot_parameter_selection(param_results, dest)
    figure('Position', [100, 100, 1200, 800], 'Visible', 'off');
    
    atlases = unique({param_results.atlas});
    colors = lines(length(atlases));
    
    for a = 1:length(atlases)
        atlas_mask = strcmp({param_results.atlas}, atlases{a});
        atlas_data = param_results(atlas_mask);
        
        lambda1 = [atlas_data.lambda1];
        lambda2 = [atlas_data.lambda2];
        acc = [atlas_data.accuracy];
        num_roi = [atlas_data.num_roi];
        
        subplot(2, 2, a);
        scatter(lambda1, lambda2, 150, acc*100, 'filled');
        xlabel('Lambda1 (log scale)');
        ylabel('Lambda2 (log scale)');
        title(sprintf('%s Atlas (%d ROIs)', atlases{a}, num_roi(1)));
        set(gca, 'XScale', 'log', 'YScale', 'log');
        colormap(jet);
        colorbar;
        grid on;
    end
    
    saveas(gcf, fullfile(dest, 'parameter_selection.png'));
    close(gcf);
end

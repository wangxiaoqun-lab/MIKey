%% Helper function to plot iteration progress
function plot_iteration_progress(iter_info, output_path)
fig = figure('Color', 'w', 'Position', [100, 100, 800, 400]);
plot([iter_info.iteration], [iter_info.voxel_change], 'o-', 'LineWidth', 2);
xlabel('Iteration');
ylabel('Voxel Change (%)');
title('Individual Network Reconstruction Progress');
grid on;

% Save plot
saveas(fig, fullfile(output_path, 'reconstruction_progress.png'));
saveas(fig, fullfile(output_path, 'reconstruction_progress.svg'));
close(fig);
end
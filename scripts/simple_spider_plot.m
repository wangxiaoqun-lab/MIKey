% If spider_plot function is not available, use this alternative
function simple_spider_plot(metrics, labels)
    % Simple alternative to spider plot
    n_metrics = length(metrics);
    angles = linspace(0, 2*pi, n_metrics+1);
    angles = angles(1:end-1);
    
    % Normalize metrics to [0, 1] range
    normalized_metrics = (metrics - min(metrics)) / (max(metrics) - min(metrics));
    
    % Create polygon
    x = normalized_metrics .* cos(angles);
    y = normalized_metrics .* sin(angles);
    
    % Close the polygon
    x(end+1) = x(1);
    y(end+1) = y(1);
    
    plot(x, y, 'b-', 'LineWidth', 2);
    hold on;
    fill(x, y, 'b', 'FaceAlpha', 0.3);
    
    % Add labels
    for i = 1:n_metrics
        label_x = 1.1 * cos(angles(i));
        label_y = 1.1 * sin(angles(i));
        text(label_x, label_y, labels{i}, 'HorizontalAlignment', 'center');
    end
    
    axis equal;
    grid on;
end
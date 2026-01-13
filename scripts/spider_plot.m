% Helper function for spider plot (if not available)
function spider_plot(data, labels)
    % Simple spider plot implementation
    n = length(data);
    angles = linspace(0, 2*pi, n+1);
    
    % Normalize data to [0, 1] for spider plot
    normalized_data = (data - min(data)) / (max(data) - min(data));
    normalized_data = [normalized_data, normalized_data(1)]; % Close the polygon
    angles = [angles, angles(1)]; % Close the circle
    
    % Plot spider web
    polarplot(angles, ones(size(angles)), 'k--');
    hold on;
    
    % Plot data
    polarplot(angles, normalized_data, 'r-', 'LineWidth', 2);
    
    % Add labels
    for i = 1:n
        text(angles(i), 1.1, labels{i}, 'HorizontalAlignment', 'center');
    end
end
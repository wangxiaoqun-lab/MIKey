function fc_matrix = compute_fc_matrix(data)
    % Calculate functional connectivity matrix
    
    % Remove mean
    data_demeaned = data - mean(data, 2);
    
    % Calculate correlation matrix
    fc_matrix = corr(data_demeaned');
    
    % Ensure symmetry
    fc_matrix = (fc_matrix + fc_matrix') / 2;
    
    % Set diagonal to 0
    n = size(fc_matrix, 1);
    fc_matrix(1:n+1:end) = 0;
end
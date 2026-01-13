
function data_residual = regress_spatial_gradient(data, spatial_gradient)
    % Regress out spatial gradient from whole-brain data
    
    [n_voxels, n_timepoints] = size(data);
    data_residual = zeros(size(data));
    
    fprintf('Performing whole-brain spatial gradient regression...\n');
    
    for t = 1:n_timepoints
        % Current time point data
        y = data(:, t);
        
        % Linear regression
        X = [ones(n_voxels, 1), spatial_gradient];
        beta = X \ y;
        
        % Calculate residuals
        data_residual(:, t) = y - X * beta;
        
        if mod(t, 50) == 0
            fprintf('  Time point %d/%d\n', t, n_timepoints);
        end
    end
end
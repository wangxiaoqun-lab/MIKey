function detrended_vol = polynomial_3d_detrend_optimized(vol, order, voxel_size)
    % Optimized 3D polynomial detrending with physical coordinates
    
    [ny, nx, nz] = size(vol);
    
    % Create physical coordinate system
    [X, Y, Z] = meshgrid(1:nx, 1:ny, 1:nz);
    X = X * voxel_size(1); % Convert to mm
    Y = Y * voxel_size(2);
    Z = Z * voxel_size(3);
    
    x = X(:); y = Y(:); z = Z(:);
    vol_flat = vol(:);
    
    % Remove non-finite values
    valid_idx = isfinite(vol_flat) & (vol_flat ~= 0);
    x_valid = x(valid_idx); y_valid = y(valid_idx); z_valid = z(valid_idx);
    vol_valid = vol_flat(valid_idx);
    
    if length(vol_valid) < 1000
        detrended_vol = vol;
        return;
    end
    
    % Build polynomial design matrix (optimized)
    A = build_polynomial_matrix(x_valid, y_valid, z_valid, order);
    
    % Regularized least squares to avoid overfitting
    lambda = 1e-6; % Regularization parameter
    coefficients = (A' * A + lambda * eye(size(A, 2))) \ (A' * vol_valid);
    
    % Reconstruct trend for all voxels
    A_all = build_polynomial_matrix(x, y, z, order);
    trend = A_all * coefficients;
    trend_vol = reshape(trend, size(vol));
    
    % Remove trend
    detrended_vol = vol - trend_vol;
end
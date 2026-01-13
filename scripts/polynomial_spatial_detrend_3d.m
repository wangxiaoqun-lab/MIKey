function detrended_vol = polynomial_spatial_detrend_3d(vol, order)
    % 3D polynomial spatial detrending
    [x, y, z] = meshgrid(1:size(vol,2), 1:size(vol,1), 1:size(vol,3));
    x = x(:); y = y(:); z = z(:);
    vol_flat = vol(:);
    
    % Remove NaN and Inf values
    valid_idx = isfinite(vol_flat);
    x_valid = x(valid_idx); y_valid = y(valid_idx); z_valid = z(valid_idx);
    vol_valid = vol_flat(valid_idx);
    
    % Build polynomial design matrix
    A = [];
    for i = 0:order
        for j = 0:(order-i)
            for k = 0:(order-i-j)
                if i + j + k <= order
                    A = [A, x_valid.^i .* y_valid.^j .* z_valid.^k];
                end
            end
        end
    end
    
    % Add constant term
    A = [ones(size(x_valid)), A];
    
    % Fit polynomial trend
    if size(A, 2) > size(A, 1)
        coefficients = pinv(A) * vol_valid;
    else
        coefficients = A \ vol_valid;
    end
    
    % Reconstruct trend surface
    A_all = [];
    for i = 0:order
        for j = 0:(order-i)
            for k = 0:(order-i-j)
                if i + j + k <= order
                    A_all = [A_all, x.^i .* y.^j .* z.^k];
                end
            end
        end
    end
    A_all = [ones(size(x)), A_all];
    
    trend = A_all * coefficients;
    trend_vol = reshape(trend, size(vol));
    
    % Remove trend
    detrended_vol = vol - trend_vol;
end


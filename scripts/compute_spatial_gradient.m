function gradient = compute_spatial_gradient(vol)
    % Calculate spatial gradient
    [gx, gy, gz] = gradient(vol);
    gradient = sqrt(gx.^2 + gy.^2 + gz.^2);
end
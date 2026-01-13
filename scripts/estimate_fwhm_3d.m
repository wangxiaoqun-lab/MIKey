function fwhm = estimate_fwhm_3d(vol)
    % Simple FWHM estimation using spatial autocorrelation
    [gx, gy, gz] = gradient(vol);
    gradient_magnitude = sqrt(gx.^2 + gy.^2 + gz.^2);
    
    % Estimate FWHM from gradient (simplified approach)
    fwhm = 2.355 * std(gradient_magnitude(:)) / sqrt(2 * log(2));
end
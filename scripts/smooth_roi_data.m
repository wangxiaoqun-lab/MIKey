function smoothed_data = smooth_roi_data(data, voxel_indices, mask, fwhm)
    % Create temporary 3D volume
    temp_vol = zeros(size(mask));
    smoothed_vol = zeros(size(mask));
    
    % Smooth each ROI separately
    for roi = 1:size(data, 2)
        % Create 3D volume for this ROI
        temp_vol(:) = 0;
        temp_vol(voxel_indices) = data(:, roi);
        
        % Smooth the volume
        spm_smooth(temp_vol, smoothed_vol, [fwhm fwhm fwhm]);
        
        % Extract smoothed data
        data(:, roi) = smoothed_vol(voxel_indices);
    end
    
    smoothed_data = data;
end

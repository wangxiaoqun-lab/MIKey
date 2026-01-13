function spatial_gradient = compute_whole_brain_spatial_gradient(lable, Gmask)
    % Calculate whole-brain spatial gradient
    
    % Get 3D volume dimensions
    dims = size(lable);
    
    % Create spatial coordinate grid
    [X, Y, Z] = meshgrid(1:dims(1), 1:dims(2), 1:dims(3));
    
    % Convert coordinates to vectors
    coords_3d = [X(:), Y(:), Z(:)];
    
    % Keep only voxels within brain mask
    brain_voxels = find(Gmask(:) > 0);
    brain_coords = coords_3d(brain_voxels, :);
    
    % Use anterior-posterior direction (Y-axis) as main spatial gradient
    spatial_gradient = brain_coords(:, 2); % Y coordinate
    
    % Standardize
    spatial_gradient = (spatial_gradient - mean(spatial_gradient)) / std(spatial_gradient);
    
    fprintf('Whole-brain spatial gradient calculated: range [%.2f, %.2f], voxels: %d\n', ...
        min(spatial_gradient), max(spatial_gradient), length(brain_voxels));
end
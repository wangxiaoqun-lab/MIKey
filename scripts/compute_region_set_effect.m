% Helper function to compute region set effect
function effect = compute_region_set_effect(fc_changes, indices)
    % Calculate average effect for a set of regions
    
    n_subjects = size(fc_changes, 1);
    n_regions = length(indices);
    
    if n_subjects == 0 || n_regions == 0
        effect = NaN;
        return;
    end
    
    subject_effects = zeros(n_subjects, 1);
    
    for s = 1:n_subjects
        % Extract submatrix for these regions
        region_fc = squeeze(fc_changes(s, indices, indices));
        
        % Exclude diagonal (self-connections)
        region_fc(logical(eye(n_regions))) = NaN;
        
        % Calculate mean effect
        subject_effects(s) = nanmean(region_fc(:));
    end
    
    % Average across subjects
    effect = nanmean(subject_effects);
end
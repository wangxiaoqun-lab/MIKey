%% Dice Coefficient - Improved similarity metric
function dice = dice_coefficient(net_map1, net_map2, mask)
    % Only consider voxels within the mask
   mask=logical(mask);
    map1 = net_map1(mask);
    map2 = net_map2(mask);
    
    % Get unique cluster labels
    clusters1 = unique(map1);
    clusters2 = unique(map2);
    
    % Remove background (0) if present
    clusters1(clusters1 == 0) = [];
    clusters2(clusters2 == 0) = [];
    
    % Initialize total dice score
    total_dice = 0;
    pair_count = 0;
    
    % Compare each cluster in map1 with each cluster in map2
    for i = 1:length(clusters1)
        cluster_id1 = clusters1(i);
        best_dice = 0;
        
        for j = 1:length(clusters2)
            cluster_id2 = clusters2(j);
            
            % Create binary masks for current clusters
            mask1 = (map1 == cluster_id1);
            mask2 = (map2 == cluster_id2);
            
            % Calculate Dice coefficient
            intersection = sum(mask1 & mask2);
            union_size = sum(mask1) + sum(mask2);
            
            if union_size > 0
                current_dice = 2 * intersection / union_size;
                
                % Track best match for this cluster
                if current_dice > best_dice
                    best_dice = current_dice;
                end
            end
        end
        
        % Accumulate best match score
        total_dice = total_dice + best_dice;
        pair_count = pair_count + 1;
    end
    
    % Calculate average Dice coefficient
    if pair_count > 0
        dice = total_dice / pair_count;
    else
        dice = 0;
    end
end




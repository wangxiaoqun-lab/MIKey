function dice = dice_coefficient_H(map1, map2, mask)
    % Only consider voxels within the mask
    mask=logical(mask);
    map1 = map1(mask);
    map2 = map2(mask);
    
    % Find overlapping clusters using Hungarian algorithm
    cost_matrix = zeros(max(map1(:)), max(map2(:)));
    for i = 1:max(map1(:))
        for j = 1:max(map2(:))
            overlap = sum((map1 == i) & (map2 == j));
            cost_matrix(i, j) = -overlap; % Negative for maximization
        end
    end
    
    % Find optimal assignment
%     [assignment, ~] = munkres(cost_matrix);
    [assignment, ~] = matchpairs(cost_matrix, Inf);
    % Calculate Dice coefficient based on optimal matching
    dice_sum = 0;
    for i = 1:size(assignment, 1)
        if assignment(i) > 0
            cluster1 = (map1 == i);
            cluster2 = (map2 == assignment(i));
            dice_sum = dice_sum + 2 * nnz(cluster1 & cluster2) / (nnz(cluster1) + nnz(cluster2));
        end
    end
    
    dice = dice_sum / size(assignment, 1);
end
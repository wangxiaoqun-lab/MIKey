%% Alternative similarity metric: Normalized Mutual Information
function nmi = normalized_mutual_information(labels1, labels2)
    % Ensure both label sets are from the same voxels
    valid_mask = (labels1 ~= 0) & (labels2 ~= 0);
    labels1 = labels1(valid_mask);
    labels2 = labels2(valid_mask);
    
    % Convert to column vectors
    labels1 = labels1(:);
    labels2 = labels2(:);
    
    % Get unique labels
    [~, ~, label1_ids] = unique(labels1);
    [~, ~, label2_ids] = unique(labels2);
    
    k1 = max(label1_ids);
    k2 = max(label2_ids);
    
    % Create joint probability matrix
    joint_count = accumarray([label1_ids, label2_ids], 1, [k1, k2]);
    joint_prob = joint_count / sum(joint_count(:));
    
    % Marginal probabilities
    prob1 = sum(joint_prob, 2);
    prob2 = sum(joint_prob, 1);
    
    % Calculate mutual information
    mi = 0;
    for i = 1:k1
        for j = 1:k2
            if joint_prob(i,j) > 0
                log_term = log(joint_prob(i,j) / (prob1(i) * prob2(j)));
                mi = mi + joint_prob(i,j) * log_term;
            end
        end
    end
    mi = max(0, mi); % Ensure non-negative
    
    % Calculate entropies
    entropy1 = -sum(prob1 .* log(prob1 + eps));
    entropy2 = -sum(prob2 .* log(prob2 + eps));
    
    % Normalized mutual information
    if entropy1 > 0 && entropy2 > 0
        nmi = mi / sqrt(entropy1 * entropy2);
    else
        nmi = 0;
    end
end
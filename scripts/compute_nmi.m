function nmi = compute_nmi(idx1, idx2)
    contingency = histcounts2(idx1, idx2);
    joint_prob = contingency / sum(contingency(:));
    marginal1 = sum(joint_prob, 2);
    marginal2 = sum(joint_prob, 1);
    
    h1 = -sum(marginal1 .* log2(marginal1 + eps));
    h2 = -sum(marginal2 .* log2(marginal2 + eps));
    mi = sum(sum(joint_prob .* log2((joint_prob + eps) ./ (marginal1 * marginal2 + eps))));
    
    nmi = mi / sqrt(h1 * h2);
end
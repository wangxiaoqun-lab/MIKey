function [full_cluster_labels, coeff] = perform_sc_clustering(sc_mat, k_clusters)
    % Remove ROIs with NaN values
    valid_rows = ~any(isnan(sc_mat), 2);
    sc_mat_clean = sc_mat(valid_rows, valid_rows);
    num_valid = sum(valid_rows);
    
    if num_valid < k_clusters
        error('Valid ROIs (%d) < k_clusters (%d)', num_valid, k_clusters);
    end
    
    % PCA and clustering
    [coeff, score] = pca(sc_mat_clean, 'Centered', false);
    reduced_data = score(:, 1:min(50, size(score,2)));
    [cluster_labels, ~] = kmeans(reduced_data, k_clusters, 'Replicates', 10, 'MaxIter', 1000);
    
    % Full label vector (0 for invalid ROIs)
    full_cluster_labels = zeros(size(sc_mat,1), 1);
    full_cluster_labels(valid_rows) = cluster_labels;
end

% Also need to fix the scatter call in the gradient calculation function
function [gradients, lambda] = diffusion_map_gradients(fc_matrix, n_components, alpha)
    % Diffusion mapping for functional connectivity gradients
    
    if nargin < 3
        alpha = 0.5; % Normalization parameter
    end
    
    % Ensure symmetric matrix
    fc_matrix = (fc_matrix + fc_matrix') / 2;
    
    % Remove diagonal
    n_regions = size(fc_matrix, 1);
    fc_matrix(1:n_regions+1:end) = 0;
    
    % Handle NaN/Inf
    if any(isnan(fc_matrix(:))) || any(isinf(fc_matrix(:)))
        fc_matrix(isnan(fc_matrix)) = 0;
        fc_matrix(isinf(fc_matrix)) = 0;
    end
    
    % Convert to similarity matrix (ensure non-negative)
    similarity = (fc_matrix + 1) / 2; % Map correlation range [-1,1] to [0,1]
    similarity = max(similarity, 0); % Ensure non-negative
    
    % Calculate degree matrix
    D = diag(sum(similarity, 2));
    
    % Normalization
    D_alpha = diag(diag(D).^(-alpha));
    W_normalized = D_alpha * similarity * D_alpha;
    D_normalized = diag(sum(W_normalized, 2));
    
    % Calculate normalized Laplacian
    L = D_normalized - W_normalized;
    
    % Eigen decomposition
    opts.tol = 1e-6;
    opts.maxit = 1000;
    [V, lambda] = eigs(L, n_components + 1, 'smallestreal', opts);
    
    % Sort and exclude first eigenvector
    [lambda, idx] = sort(diag(lambda), 'ascend');
    V = V(:, idx);
    
    gradients = V(:, 2:n_components+1);
    lambda = lambda(2:n_components+1);
end
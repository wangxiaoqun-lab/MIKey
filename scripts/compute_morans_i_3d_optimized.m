% Keep the core computational functions
function morans_i = compute_morans_i_3d_optimized(vol)
    [ny, nx, nz] = size(vol);
    
    if nx * ny * nz > 50000
        downsampling_factor = ceil((nx * ny * nz / 50000)^(1/3));
        vol = downsample_volume(vol, downsampling_factor);
        [ny, nx, nz] = size(vol);
    end
    
    n = numel(vol);
    
    max_neighbors = n * 6;
    row_inds = zeros(max_neighbors, 1);
    col_inds = zeros(max_neighbors, 1);
    
    count = 0;
    indices = reshape(1:n, size(vol));
    
    for i = 1:ny
        for j = 1:nx
            for k = 1:nz
                idx = indices(i, j, k);
                
                neighbors = [
                    i-1, j, k; i+1, j, k;
                    i, j-1, k; i, j+1, k;
                    i, j, k-1; i, j, k+1
                ];
                
                for n_idx = 1:size(neighbors, 1)
                    ni = neighbors(n_idx, 1);
                    nj = neighbors(n_idx, 2);
                    nk = neighbors(n_idx, 3);
                    
                    if ni >= 1 && ni <= ny && nj >= 1 && nj <= nx && nk >= 1 && nk <= nz
                        count = count + 1;
                        row_inds(count) = idx;
                        col_inds(count) = indices(ni, nj, nk);
                    end
                end
            end
        end
    end
    
    row_inds = row_inds(1:count);
    col_inds = col_inds(1:count);
    values = ones(count, 1);
    
    W = sparse(row_inds, col_inds, values, n, n);
    W = max(W, W');
    
    vol_flat = double(vol(:));
    mean_val = mean(vol_flat);
    deviations = vol_flat - mean_val;
    
    sum_W = sum(W(:));
    numerator = full(sum(sum(W .* (deviations * deviations'))));
    denominator = sum(deviations.^2);
    
    if denominator == 0
        morans_i = 0;
    else
        morans_i = (n / sum_W) * (numerator / denominator);
    end
end
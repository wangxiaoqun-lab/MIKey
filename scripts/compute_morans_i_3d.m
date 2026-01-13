function morans_i = compute_morans_i_3d(vol)
    % Actual Moran's I implementation for 3D volumes
    
    [ny, nx, nz] = size(vol);
    n = numel(vol);
    
    % Create spatial weights matrix (queen contiguity)
    W = zeros(n, n);
    indices = reshape(1:n, size(vol));
    
    for i = 1:ny
        for j = 1:nx
            for k = 1:nz
                idx = indices(i, j, k);
                
                % 26-connected neighborhood (3D queen contiguity)
                for di = -1:1
                    for dj = -1:1
                        for dk = -1:1
                            if di == 0 && dj == 0 && dk == 0
                                continue;
                            end
                            
                            ni = i + di; nj = j + dj; nk = k + dk;
                            if ni >= 1 && ni <= ny && nj >= 1 && nj <= nx && nk >= 1 && nk <= nz
                                nidx = indices(ni, nj, nk);
                                W(idx, nidx) = 1;
                            end
                        end
                    end
                end
            end
        end
    end
    
    % Convert to sparse for efficiency
    W = sparse(W);
    
    % Calculate Moran's I
    vol_flat = vol(:);
    mean_val = mean(vol_flat);
    deviations = vol_flat - mean_val;
    variance = sum(deviations.^2) / n;
    
    numerator = 0;
    denominator = 0;
    
    for i = 1:n
        for j = 1:n
            if W(i, j) > 0
                numerator = numerator + W(i, j) * deviations(i) * deviations(j);
            end
        end
        denominator = denominator + deviations(i)^2;
    end
    
    sum_W = sum(W(:));
    morans_i = (n / sum_W) * (numerator / denominator);
end

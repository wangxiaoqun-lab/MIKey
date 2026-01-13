function downsampled_vol = downsample_volume(vol, factor)
    [ny, nx, nz] = size(vol);
    new_ny = ceil(ny / factor);
    new_nx = ceil(nx / factor);
    new_nz = ceil(nz / factor);
    downsampled_vol = zeros(new_ny, new_nx, new_nz);
    
    for i = 1:new_ny
        for j = 1:new_nx
            for k = 1:new_nz
                i_start = (i-1)*factor + 1;
                i_end = min(i*factor, ny);
                j_start = (j-1)*factor + 1;
                j_end = min(j*factor, nx);
                k_start = (k-1)*factor + 1;
                k_end = min(k*factor, nz);
                block = vol(i_start:i_end, j_start:j_end, k_start:k_end);
                downsampled_vol(i, j, k) = mean(block(:));
            end
        end
    end
end
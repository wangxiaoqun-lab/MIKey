function snr = compute_snr_4d_optimized(data_4d)
    n_voxels = numel(data_4d) / size(data_4d, 4);
    if n_voxels > 10000
        n_sample = 10000;
        sampled_voxels = randperm(n_voxels, n_sample);
        data_2d = reshape(data_4d, n_voxels, size(data_4d, 4));
        sampled_data = data_2d(sampled_voxels, :);
        signal_power = mean(sampled_data(:).^2);
        noise_power = mean(var(sampled_data, 0, 2));
    else
        signal_power = mean(data_4d(:).^2);
        noise_power = mean(var(reshape(data_4d, [], size(data_4d, 4)), 0, 2));
    end
    
    if noise_power == 0
        snr = 0;
    else
        snr = 10 * log10(signal_power / noise_power);
    end
end
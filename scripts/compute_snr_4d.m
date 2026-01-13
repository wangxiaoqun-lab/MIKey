function snr = compute_snr_4d(data_4d)
    % Calculate signal-to-noise ratio for 4D data
    signal_power = mean(data_4d(:).^2);
    noise_power = var(reshape(data_4d, [], size(data_4d,4)), 0, 2);
    noise_power = mean(noise_power);
    snr = 10 * log10(signal_power / noise_power);
end

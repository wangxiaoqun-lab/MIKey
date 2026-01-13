function low_freq = extract_low_frequency_spatial(vol, cutoff)
    % Extract low-frequency spatial components (using Gaussian filter)
    low_freq = imgaussfilt(vol, cutoff);
end
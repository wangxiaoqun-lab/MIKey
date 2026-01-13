function all_roi_filter = Matrix_Filter(all_roi, TR, High, Low)
    [rows, cols] = size(all_roi); 
    Freq_res = 1 / (TR * cols); 
    freq = (-0.5:Freq_res:0.5 - Freq_res); 
    Fre_low_lim = ceil(Low / Freq_res);
    Fre_up_lim = floor(High / Freq_res);
    filter_window = zeros(1, cols); 
    hamming_length = 2 * Fre_up_lim + 1; 
    hamming_window = hamming(hamming_length);
    filter_window(round(cols/2) - Fre_up_lim:round(cols/2) + Fre_up_lim) = hamming_window;
    filter_window_matrix = repmat(filter_window, rows, 1);
    all_roi_fft = fftshift(fft(all_roi, [], 2));
    all_roi_fft_filtered = all_roi_fft .* filter_window_matrix;
    all_roi_filter = real(ifft(ifftshift(all_roi_fft_filtered), [], 2)); 
end
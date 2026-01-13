function plot_coherence_spectrum(CORT_ts, global_signal_windowed, TR, window_size, step_size)
    % ¼ÆËãCORT_tsºÍÈ«¾ÖÐÅºÅÖ®¼äµÄÏà¸ÉÐÔÆ×
    % ÊäÈë:
    %   - CORT_ts: Æ¤ÖÊÍªÊ±¼äÐòÁÐ
    %   - global_signal_windowed: ´°¿Ú»¯È«¾ÖÐÅºÅ
    %   - TR: Ê±¼ä·Ö±æÂÊ (Ãë)
    %   - window_size: ´°¿Ú´óÐ¡ (Ê±¼äµãÊý)
    %   - step_size: ²½³¤ (Ê±¼äµãÊý)
    
    % È·±£ÊäÈëÊÇÁÐÏòÁ¿
    if size(CORT_ts, 1) == 1
        CORT_ts = CORT_ts';
    end
    if size(global_signal_windowed, 1) == 1
        global_signal_windowed = global_signal_windowed';
    end
    
    % È¥³ý¾ùÖµ
    CORT_ts_detrend = detrend(CORT_ts);
    global_signal_detrend = detrend(global_signal_windowed);
    
    % ÉèÖÃ²ÎÊý
    fs = 1/(step_size * TR); % ²ÉÑùÆµÂÊ (Hz)
    nfft = max(256, 2^nextpow2(length(CORT_ts_detrend))); % FFTµãÊý
    
    % ¼ÆËãÏà¸ÉÐÔ
    [Cxy, F] = mscohere(CORT_ts_detrend, global_signal_detrend, ...
                        hamming(round(length(CORT_ts_detrend)/4)), ...
                        round(length(CORT_ts_detrend)/8), nfft, fs);
    
    % ¼ÆËã¹¦ÂÊÆ×ÃÜ¶È
    [Pxx, F_psd] = pwelch(CORT_ts_detrend, hamming(round(length(CORT_ts_detrend)/4)), ...
                          round(length(CORT_ts_detrend)/8), nfft, fs);
    [Pyy, F_psd] = pwelch(global_signal_detrend, hamming(round(length(CORT_ts_detrend)/4)), ...
                          round(length(CORT_ts_detrend)/8), nfft, fs);
    
    % ´´½¨Í¼ÐÎ
    figure('Position', [100, 100, 1200, 800]);
    
    % »æÖÆÏà¸ÉÐÔÆ×
    subplot(2, 2, 1);
    plot(F, Cxy, 'b-', 'LineWidth', 2);
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    title('Coherence Spectrum');
    grid on;
    
    % ±ê¼ÇµäÐÍµÍÆµ²¨¶Î (0.01-0.1 Hz)
    hold on;
    x_low = [0.01, 0.01, 0.1, 0.1];
    y_low = [0, 1, 1, 0];
    patch(x_low, y_low, 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    text(0.055, 0.9, 'Low-frequency band (0.01-0.1 Hz)', 'HorizontalAlignment', 'center');
    
    % ¼ÆËã²¢ÏÔÊ¾µÍÆµ²¨¶ÎµÄÆ½¾ùÏà¸ÉÐÔ
    low_freq_idx = F >= 0.01 & F <= 0.1;
    mean_coherence_lf = mean(Cxy(low_freq_idx));
    line([0.01, 0.1], [mean_coherence_lf, mean_coherence_lf], 'Color', 'r', 'LineWidth', 2);
    text(0.055, mean_coherence_lf+0.05, sprintf('Mean = %.3f', mean_coherence_lf), ...
         'HorizontalAlignment', 'center', 'Color', 'r');
    
    % »æÖÆ¹¦ÂÊÆ×ÃÜ¶È
    subplot(2, 2, 2);
    plot(F_psd, 10*log10(Pxx), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(F_psd, 10*log10(Pyy), 'r-', 'LineWidth', 1.5);
    xlabel('Frequency (Hz)');
    ylabel('Power/frequency (dB/Hz)');
    title('Power Spectral Density');
    legend('CORT Index', 'Global Signal');
    grid on;
    xlim([0, 0.15]);
    
    % ±ê¼ÇµÍÆµ²¨¶Î
    hold on;
    patch(x_low, [min(ylim), max(ylim), max(ylim), min(ylim)], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    
    % »æÖÆÊ±¼äÐòÁÐ
    subplot(2, 2, 3);
    plot(CORT_ts_detrend, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(global_signal_detrend, 'r-', 'LineWidth', 1.5);
    xlabel('Time (windows)');
    ylabel('Amplitude');
    title('Detrended Time Series');
    legend('CORT Index', 'Global Signal');
    grid on;
    
    % ¼ÆËã²¢ÏÔÊ¾Ïà¹ØÐÔ
    [corr_coef, p_value] = corr(CORT_ts, global_signal_windowed);
    
    % »æÖÆÉ¢µãÍ¼
    subplot(2, 2, 4);
    scatter(CORT_ts, global_signal_windowed, 50, 'filled', 'MarkerFaceAlpha', 0.6);
    xlabel('CORT Index');
    ylabel('Global Signal');
    title(sprintf('Correlation: r = %.3f, p = %.4f', corr_coef, p_value));
    grid on;
    
    % Ìí¼ÓÇ÷ÊÆÏß
    hold on;
    p = polyfit(CORT_ts, global_signal_windowed, 1);
    x_fit = linspace(min(CORT_ts), max(CORT_ts), 100);
    y_fit = polyval(p, x_fit);
    plot(x_fit, y_fit, 'r-', 'LineWidth', 2);
    
    % Ìí¼ÓÎÄ±¾ÐÅÏ¢
    annotation('textbox', [0.15, 0.02, 0.7, 0.05], 'String', ...
        sprintf('Window size: %d TR, Step size: %d TR, TR: %.2f s, N windows: %d', ...
                window_size, step_size, TR, length(CORT_ts)), ...
        'FitBoxToText', 'on', 'BackgroundColor', 'white', 'FontSize', 10, ...
        'HorizontalAlignment', 'center');
    
    % ±£´æÍ¼ÐÎ
    %saveas(gcf, 'coherence_spectrum_plot.png');
end

function [snr_original, snr_detrended, stats] = compute_snr_improvement(original_data, detrended_data)
    n_subjects = length(original_data);
    snr_original = zeros(n_subjects, 1);
    snr_detrended = zeros(n_subjects, 1);
    
    for s = 1:n_subjects
        snr_original(s) = compute_snr_4d_optimized(original_data{s});
        snr_detrended(s) = compute_snr_4d_optimized(detrended_data{s});
    end
    
    [h, p, ci, stats_ttest] = ttest(snr_original, snr_detrended);
    effect_size = compute_cohens_d(snr_original, snr_detrended);
    
    stats = struct();
    stats.p_value = p;
    stats.effect_size = effect_size;
end
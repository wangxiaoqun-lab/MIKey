function [morans_i_original, morans_i_detrended, stats] = compute_morans_i_comprehensive(original_data, detrended_data)
    n_subjects = length(original_data);
    morans_i_original = zeros(n_subjects, 1);
    morans_i_detrended = zeros(n_subjects, 1);
    
    for s = 1:n_subjects
        avg_original = mean(original_data{s}, 4);
        avg_detrended = mean(detrended_data{s}, 4);
        
        morans_i_original(s) = compute_morans_i_3d_optimized(avg_original);
        morans_i_detrended(s) = compute_morans_i_3d_optimized(avg_detrended);
    end
    
    [h, p, ci, stats_ttest] = ttest(morans_i_original, morans_i_detrended);
    effect_size = compute_cohens_d(morans_i_original, morans_i_detrended);
    
    stats = struct();
    stats.p_value = p;
    stats.confidence_interval = ci;
    stats.t_statistic = stats_ttest.tstat;
    stats.df = stats_ttest.df;
    stats.effect_size = effect_size;
    stats.mean_original = mean(morans_i_original);
    stats.mean_detrended = mean(morans_i_detrended);
end
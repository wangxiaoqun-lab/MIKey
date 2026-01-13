
function save_for_stimul_pre_analysis(fc_matrix, ~, runpath, run_num, analysis_type)
    % Save data for stimul-pre analysis
    % Follows the format of your original region_FC_new.mat
    
    pearson_corr = fc_matrix;
    pearson_corr_z = atanh(pearson_corr); % Fisher Z transformation
    
    result_file = fullfile(runpath, sprintf('region_FC_%s_%d.mat', analysis_type, run_num));
    
    save(result_file, 'pearson_corr', 'pearson_corr_z');
    
    fprintf('Saved %s FC data: %s\n', analysis_type, result_file);
end
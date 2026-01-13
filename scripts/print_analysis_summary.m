% Print analysis summary
function print_analysis_summary(consistency_results, connection_results, cond)
    fprintf('\n=== %s: Comprehensive Analysis Summary ===\n', cond);
    
    fprintf('Gradient Change Consistency:\n');
    for g = 1:length(consistency_results.gradient_consistency)
        sig_str = '';
        if consistency_results.significant(g)
            direction = 'INCREASE';
            if consistency_results.positive_proportion(g) < 0.5
                direction = 'DECREASE';
            end
            sig_str = sprintf(' *** SIGNIFICANT %s ***', direction);
        end
        fprintf('  Gradient %d: consistency=%.3f, positive=%.1f%%, p=%.4f%s\n', ...
                g, consistency_results.gradient_consistency(g), ...
                consistency_results.positive_proportion(g)*100, ...
                consistency_results.binomial_p(g), sig_str);
    end
    
    fprintf('Medulla Connection Changes:\n');
    fprintf('  Internal: mean=%.4f, p=%.4f\n', ...
            connection_results.internal_change_mean, connection_results.internal_p);
    fprintf('  External: mean=%.4f, p=%.4f\n', ...
            connection_results.external_change_mean, connection_results.external_p);
end
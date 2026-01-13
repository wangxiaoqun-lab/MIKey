%% Add fdr_bh implementation to helper functions
function [h, crit_p, adj_p] = fdr_bh(pvals, q, method, report)
    % FDR_BH Benjamini-Hochberg false discovery rate procedure
    %   [h, crit_p, adj_p] = fdr_bh(pvals, q, method, report)
    %
    %   Inputs:
    %       pvals - vector of p-values
    %       q     - false discovery rate level (default: 0.05)
    %       method - 'pdep' or 'dep' (default: 'pdep')
    %       report - whether to print reports (default: false)
    %
    %   Outputs:
    %       h      - binary vector of hypotheses tests
    %       crit_p - critical p-value
    %       adj_p  - adjusted p-values

    if nargin < 2 || isempty(q)
        q = 0.05;
    end
    
    if nargin < 3 || isempty(method)
        method = 'pdep';
    end
    
    if nargin < 4 || isempty(report)
        report = false;
    end

    pvals = pvals(:); % Ensure pvals is a column vector
    m = length(pvals); % Number of tests
    
    % Sort p-values
    [p_sorted, sort_ids] = sort(pvals);
    
    % Adjust p-values
    if strcmpi(method, 'dep')
        % For dependent tests
        adj_p_sorted = p_sorted / sum(1./(1:m));
    else
        % For independent tests
        adj_p_sorted = p_sorted * m ./ (1:m)';
    end
    
    % Ensure adjusted p-values don't decrease
    adj_p_sorted = min(adj_p_sorted, 1);
    for i = m-1:-1:1
        if adj_p_sorted(i) > adj_p_sorted(i+1)
            adj_p_sorted(i) = adj_p_sorted(i+1);
        end
    end
    
    % Revert to original order
    adj_p = zeros(size(p_sorted));
    adj_p(sort_ids) = adj_p_sorted;
    
    % Determine significant tests
    crit_p = max(p_sorted(adj_p_sorted <= q));
    if isempty(crit_p)
        crit_p = 0;
    end
    h = pvals <= crit_p;
    
    if report
        fprintf('FDR_BH: %d/%d tests significant at FDR = %g\n', sum(h), m, q);
    end
end
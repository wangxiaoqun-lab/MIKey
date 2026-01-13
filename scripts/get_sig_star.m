% Helper function to get significance stars
function star = get_sig_star(p)
    if p < 0.001
        star = '***';
    elseif p < 0.01
        star = '**';
    elseif p < 0.05
        star = '*';
    else
        star = 'ns';
    end
end
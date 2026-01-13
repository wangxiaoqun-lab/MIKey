function orthviews(img, opts)
    if nargin < 2
        opts = struct;
    end
    if ~isfield(opts, 'interp')
        opts.interp = 1;
    end
    
    spm_figure('Clear', 'Graphics');
    spm_orthviews('Image', img, [0.05, 0.05, 0.9, 0.45]);
    spm_orthviews('Interp', opts.interp);
    spm_orthviews('Redraw');
end
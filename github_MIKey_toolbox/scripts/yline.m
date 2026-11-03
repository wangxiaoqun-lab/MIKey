function yline(varargin)
% YLINE Compatibility function for older MATLAB versions
%   Provides yline functionality for MATLAB versions before R2018b

    if nargin == 0
        return;
    end
    
    y_value = varargin{1};
    line_style = 'k-';
    line_width = 0.5;
    
    % Parse additional arguments
    for i = 2:2:nargin
        if i+1 <= nargin
            switch lower(varargin{i})
                case {'color', 'linecolor'}
                    line_style = [varargin{i+1} '-'];
                case 'linestyle'
                    line_style = ['-' varargin{i+1}];
                case 'linewidth'
                    line_width = varargin{i+1};
            end
        end
    end
    
    hold on;
    x_limits = xlim;
    plot(x_limits, [y_value y_value], line_style, 'LineWidth', line_width);
    hold off;
end
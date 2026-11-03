function root = MIKey_paths()
%MIKEY_PATHS Pin the supported layout and reject root-level legacy duplicates.
root = fileparts(fileparts(mfilename('fullpath')));
code = fullfile(root,'scripts');
% MATLAB's Current Folder takes priority over addpath. Old root helpers must
% not survive an overlay update, even when scripts has been added first.
implementation = dir(fullfile(code,'MIKey*.m'));
legacy = {};
for i = 1:numel(implementation)
    old = fullfile(root,implementation(i).name);
    if exist(old,'file') == 2, legacy{end+1} = old; end %#ok<AGROW>
end
if ~isempty(legacy)
    error('MIKey:LegacyLayout', ...
        ['Old root-level MATLAB helpers remain: %s. ' ...
        'Move only these duplicate source files out of the toolbox root after verifying their scripts copies. ' ...
        'Keep MIKey.m, configurations, templates, data and derivatives. ' ...
        'Restart MATLAB after updating classes. See docs/CODE_LAYOUT.md.'],strjoin(legacy,', '));
end
addpath(root,'-begin');
addpath(code,'-begin');
end

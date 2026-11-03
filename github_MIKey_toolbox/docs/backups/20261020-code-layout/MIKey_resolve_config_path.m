function filename = MIKey_resolve_config_path(input, toolboxRoot)
% Resolve existing config files without depending on the caller's directory.
% Relative paths: current directory, toolbox root, then examples for bare names.
if nargin<2,toolboxRoot=fileparts(mfilename('fullpath'));end
if isstring(input) && isscalar(input),input=char(input);end
if ~ischar(input) || ~isrow(input) || isempty(input)
    error('MIKey:ConfigFile','Specify one configuration .m filename.');
end
provided=java.io.File(input);
if provided.isAbsolute()
    candidates={input};
else
    candidates={fullfile(pwd,input),fullfile(toolboxRoot,input)};
    if isempty(fileparts(input))
        candidates{end+1}=fullfile(toolboxRoot,'examples',input);
    end
end
attempted=cell(size(candidates));
for i=1:numel(candidates)
    file=java.io.File(candidates{i});attempted{i}=char(file.getCanonicalPath());
    if exist(attempted{i},'file')==2
        filename=attempted{i};return;
    end
end
error('MIKey:ConfigFile', ...
    'Configuration file not found: %s. Current directory: %s. Checked: %s. Supply the full filename if the file is elsewhere.', ...
    input,pwd,strjoin(unique(attempted,'stable'),' | '));
end

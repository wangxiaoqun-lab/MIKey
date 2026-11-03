function cfg = MIKey_load_config_function(filename)
% Load the exact selected .m function, with no persistent path/cwd changes.
if isstring(filename) && isscalar(filename),filename=char(filename);end
if ~ischar(filename) || ~isrow(filename) || isempty(filename)
    error('MIKey:ConfigFile','Specify one configuration .m filename.');
end
filename=MIKey_resolve_config_path(filename);
[folder,name,extension]=fileparts(filename);
if ~strcmpi(extension,'.m') || ~isvarname(name) || exist(filename,'file')~=2
    error('MIKey:ConfigFile','Use an existing .m configuration function with a valid MATLAB filename: %s',filename);
end
reserved={'MIKey','MIKey_config','MIKey_defaults','MIKey_run','run_mikey', ...
    'MIKey_export_config','MIKey_load_config_function'};
if any(strcmpi(name,reserved))
    error('MIKey:ConfigFile','Choose a configuration filename distinct from toolbox entry points: %s',name);
end
oldPath=path;oldDirectory=pwd;
cleanup=onCleanup(@()restore(oldPath,oldDirectory)); %#ok<NASGU>
addpath(folder,'-begin');cd(folder);
% Reload edits to the same exported function rather than a cached definition.
refreshConfiguration(name);
resolved=which(name);selected=java.io.File(resolved);
resolved=char(selected.getCanonicalPath());
if ispc,matches=strcmpi(resolved,filename);else,matches=strcmp(resolved,filename);end
if ~matches
    error('MIKey:ConfigFile','Configuration resolves to another file: %s (requested %s).',resolved,filename);
end
cfg=feval(name);
if ~isstruct(cfg) || ~isscalar(cfg)
    error('MIKey:ConfigType','Configuration function must return one scalar cfg struct: %s',filename);
end
end

function restore(oldPath,oldDirectory)
cd(oldDirectory);path(oldPath);
end

function refreshConfiguration(configName)
% Isolate clear so configuration filenames cannot clear loader variables.
clear(configName);
rehash;
end

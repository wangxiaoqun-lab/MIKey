function test_mikey_config_paths
% Server-only regression for root/examples/other current directories.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work)); %#ok<NASGU>
addpath(root);toolbox=fullfile(work,'toolbox');examples=fullfile(toolbox,'examples');
mkdir(examples);elsewhere=fullfile(work,'elsewhere');mkdir(elsewhere);
filename=fullfile(examples,'mikey_config_gui.m');fid=fopen(filename,'w');assert(fid>=0);
fprintf(fid,'function cfg=mikey_config_gui\ncfg=struct();\nend\n');fclose(fid);
expected=canonical(filename);
for folder={toolbox,examples,elsewhere}
    cd(folder{1});
    assert(strcmp(MIKey_resolve_config_path(fullfile('examples','mikey_config_gui.m'),toolbox),expected));
    assert(strcmp(MIKey_resolve_config_path('mikey_config_gui.m',toolbox),expected));
    assert(strcmp(MIKey_resolve_config_path(expected,toolbox),expected));
end
% A missing absolute filename must never fall back to the matching examples file.
missing=fullfile(elsewhere,'mikey_config_gui.m');failed=false;
try,MIKey_resolve_config_path(missing,toolbox);
catch ME,failed=strcmp(ME.identifier,'MIKey:ConfigFile');end
assert(failed);
% An existing file relative to the current directory keeps normal precedence.
fid=fopen(missing,'w');assert(fid>=0);fclose(fid);
assert(strcmp(MIKey_resolve_config_path('mikey_config_gui.m',toolbox),canonical(missing)));
disp('MIKEY_CONFIG_PATHS_PASS');
end
function filename=canonical(filename)
file=java.io.File(filename);filename=char(file.getCanonicalPath());
end
function restore(oldPath,oldDirectory,work)
cd(oldDirectory);path(oldPath);
target=canonical(work);parent=canonical(tempdir);
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

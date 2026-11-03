function test_mikey_code_layout
% Server-only layout/path checks: no GUI, SPM computation or child processes.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work)); %#ok<NASGU>
addpath(fullfile(root,'scripts'));actual=MIKey_paths();
assert(strcmp(canonical(actual),canonical(root)));
rootFiles=dir(fullfile(root,'*.m'));assert(isequal({rootFiles.name},{'MIKey.m'}));
for name={'MIKey_config','MIKey_defaults','MIKey_setup','MIKeyRunControl','MIKeyBatchState','MIKey_run'}
    expected=fullfile(root,'scripts',[name{1} '.m']);
    assert(strcmp(canonical(which(name{1})),canonical(expected)));
end
assert(strcmp(canonical(which('MIKey')),canonical(fullfile(root,'MIKey.m'))));
report=MIKey_check_runtime();assert(strcmp(report.status,'passed'));
cd(work);cfg=MIKey_defaults();
assert(strcmp(canonical(cfg.templatePath),canonical(fullfile(root,'share_temp'))));
assert(strcmp(canonical(cfg.codePath),canonical(fullfile(root,'scripts'))));
config=MIKey_resolve_config_path('mikey_config_example.m');
assert(strcmp(canonical(config),canonical(fullfile(root,'examples','mikey_config_example.m'))));
addpath(fullfile(root,'examples'));example=mikey_config_example();
assert(strcmp(canonical(example.codePath),canonical(fullfile(root,'scripts'))));
% Simulate an overlay duplicate only in an isolated fake installation.
fixture=fullfile(work,'fixture');mkdir(fixture);mkdir(fullfile(fixture,'scripts'));
source=fileread(fullfile(root,'scripts','MIKey_paths.m'));
source=strrep(source,'function root = MIKey_paths()','function root = MIKey_layout_fixture_paths()');
writeText(fullfile(fixture,'scripts','MIKey_layout_fixture_paths.m'),source);
writeText(fullfile(fixture,'scripts','MIKey_fixture_old.m'),'% New source fixture');
writeText(fullfile(fixture,'MIKey_fixture_old.m'),'% Legacy root source fixture');
addpath(fullfile(fixture,'scripts'));
expect(@()MIKey_layout_fixture_paths(),'MIKey:LegacyLayout');
disp('MIKEY_CODE_LAYOUT_PASS');
end
function value=canonical(filename)
value=char(java.io.File(filename).getCanonicalPath());
end
function writeText(filename,value)
fid=fopen(filename,'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',value);
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end
function restore(oldPath,oldDirectory,work)
cd(oldDirectory);path(oldPath);target=canonical(work);parent=canonical(tempdir);
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

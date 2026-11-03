function test_mikey_config_export
% Run on the server only; no SPM processing or imaging data are required.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));
cfg=MIKey_defaults();cfg.steps=1;cfg.bidsPath=work;
cfg.subjectFilter='sub-001,sub-002';cfg.fdMethod='power';cfg.fdRadius=75;
cfg.parcellationMode='concatenated';cfg.dryRun=true;cfg.failFast=false;
cfg.logDir=fullfile(work,['quote' char(39) 'path']);
cfg.fcLabel=NaN;cfg.customPCCounts={true,[0 3],struct('unused',{{'text',[]}})};
cfg.networkCustomPath=char([65 10 20013 25991]);
expected=MIKey_config(cfg);
filename=MIKey_export_config(fullfile(work,'mikey_exported_test.m'),cfg);
startDirectory=pwd;startPath=path;
loaded=MIKey_config(filename);assert(isequaln(loaded,expected));
assert(strcmp(pwd,startDirectory) && strcmp(path,startPath));
source=fileread(filename);
assert(contains(source,'function cfg = mikey_exported_test()'));
assert(~contains(source,'MIKey_defaults(') && ~contains(source,'mikey_config_example('));
% Re-exporting the same filename must reload new settings in this MATLAB session.
cfg.subjectFilter='sub-003';MIKey_export_config(filename,cfg);
loaded=MIKey_config(filename);assert(strcmp(loaded.subjectFilter,'sub-003'));
expect(@()MIKey_export_config(fullfile(work,'run_mikey.m'),cfg),'MIKey:ConfigExport');
expect(@()MIKey_export_config(fullfile(work,'bad-name.m'),cfg),'MIKey:ConfigExport');
assert(~exist(fullfile(work,'bad-name.m'),'file'));
disp('MIKEY_CONFIG_EXPORT_PASS');
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end
function restore(oldPath,oldDirectory,work)
cd(oldDirectory);path(oldPath);
target=char(java.io.File(work).getCanonicalPath());parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

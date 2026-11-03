function test_mikey_failure_reports(spmPath, syntheticDirectory)
% Follow-up on the retained fixture from test_mikey_batch.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);addpath(fullfile(root,'scripts'));
loaded=load(fullfile(syntheticDirectory,'config.mat'));
cfg=loaded.config;
cfg.spmPath=spmPath;
cfg.subjectFilter='sub-01';
cfg.steps=[4 13];
cfg.logDir=fullfile(syntheticDirectory,'failure-report-tests');
mkdir(cfg.logDir);
cfg.failFast=true;
runFailure(cfg);
cfg.failFast=false;
runFailure(cfg);
disp('MIKEY_FAILURE_REPORTS_PASS');
end

function runFailure(cfg)
before=dir(fullfile(cfg.logDir,'tp*'));
failed=false;
try
    MIKey_run(cfg);
catch ME
    assert(strcmp(ME.identifier,'MIKey:RunFailed'),getReport(ME));
    failed=true;
end
assert(failed);
after=dir(fullfile(cfg.logDir,'tp*'));
names=setdiff({after.name},{before.name}); assert(numel(names)==1);
loaded=load(fullfile(cfg.logDir,names{1},'report.mat'));
report=loaded.report;
assert(strcmp(report.status,'failed'));
assert(strcmp(report.stages(1).identifier,'MIKey:Prerequisite'));
assert(~isempty(report.stages(1).error));
assert(strcmp(report.config.subjectFilter,'sub-01'));
assert(numel(report.environment.sourceManifest)>100);
if cfg.failFast
    assert(numel(report.stages)==1);
else
    assert(numel(report.stages)==2 && strcmp(report.stages(2).status,'completed'));
end
end

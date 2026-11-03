function run_real_demo_pipeline(label,runFilter)
% Real SPM only. All image writes are confined to the independent demo copy.
if nargin<1,label='baseline';end
if nargin<2,runFilter='*';end
root='K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';folder=fileparts(mfilename('fullpath'));
oldPath=path;oldDirectory=pwd;oldVisible=get(groot,'DefaultFigureVisible');oldRng=rng;
global defaults;oldDefaults=defaults;
cleanup=onCleanup(@()restoreSession(oldPath,oldDirectory,oldVisible,oldDefaults,oldRng)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));addpath('D:/Program Files/MATLAB/mytoolbox/spm12');
clear spm_jobman;
assert(strcmpi(which('spm_jobman'),'D:\Program Files\MATLAB\mytoolbox\spm12\spm_jobman.m'),'Real SPM job manager required.');
workspace=jsondecode(fileread(fullfile(folder,'workspace.json')));assert(strcmp(workspace.status,'ready'));
cfg=MIKey_defaults();cfg.bidsPath=workspace.bidsPath;
cfg.spmPath='D:/Program Files/MATLAB/mytoolbox/spm12';cfg.subjectFilter='sub-001';
cfg.templatePath=fullfile(workspace.workspace,'templates');cfg.voxelScaleFactor=20;
cfg.steps=[6 7];cfg.minTimepoints=20;cfg.failFast=false;cfg.runFilter=runFilter;
cfg.logDir=fullfile(workspace.workspace,'logs',label);
result=struct('label',label,'status','running','spmJobman',which('spm_jobman'), ...
    'bidsPath',cfg.bidsPath,'config',cfg,'started',datestr(now,30));
writeResult(folder,label,result);progress(folder,['START ' label ' real SPM Steps 6/7']);
started=tic;
try
    report=MIKey_run(cfg);
    result.status=report.status;result.runDirectory=report.runDirectory;result.stages=report.stages;
catch ME
    result.status='failed';result.identifier=ME.identifier;result.error=getReport(ME,'extended','hyperlinks','off');
    reports=dir(fullfile(cfg.logDir,'*','report.mat'));
    if ~isempty(reports)
        saved=load(fullfile(reports(end).folder,reports(end).name));
        result.runDirectory=saved.report.runDirectory;result.stages=saved.report.stages;
    end
    progress(folder,result.error);
end
result.seconds=toc(started);result.finished=datestr(now,30);
writeResult(folder,label,result);progress(folder,sprintf('END %s %s %.3f seconds',label,result.status,result.seconds));
end

function writeResult(folder,label,result)
fid=fopen(fullfile(folder,[label '-result.json']),'w','n','UTF-8');cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(result));
end

function progress(folder,message)
fid=fopen(fullfile(folder,'real-spm-progress.log'),'a','n','UTF-8');cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s %s\n',datestr(now,30),message);fprintf('%s\n',message);
end

function restoreSession(oldPath,oldDirectory,oldVisible,oldDefaults,oldRng)
global defaults;defaults=oldDefaults;rng(oldRng);path(oldPath);cd(oldDirectory);set(groot,'DefaultFigureVisible',oldVisible);
end

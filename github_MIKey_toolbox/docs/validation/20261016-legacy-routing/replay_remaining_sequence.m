function replay_remaining_sequence
% Replay without diagnostic breakpoints; preserve the existing MATLAB session.
root='K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';
oldPath=path;oldDirectory=pwd;oldBreakpoints=dbstatus('-completenames');
oldDiary=get(0,'Diary');oldDiaryFile=get(0,'DiaryFile');oldRng=rng;
oldVisible=get(groot,'DefaultFigureVisible');
global defaults;
oldDefaults=defaults;
cleanup=onCleanup(@()restoreSession(oldPath,oldDirectory,oldBreakpoints,oldDiary,oldDiaryFile,oldRng,oldVisible,oldDefaults)); %#ok<NASGU>
diary(fullfile(fileparts(mfilename('fullpath')),'uninstrumented-sequence.log'));
dbclear all;
figuresBefore=findall(groot,'Type','figure');
started=tic;result=struct('status','running','stages',{{}});
try
    addpath(root);addpath(fullfile(root,'tests'));
    rng(0);
    fprintf('MIKEY_UNINSTRUMENTED_BEGIN %s\n',datestr(now,30));
    stage=tic;
    test_mikey_bids_spm_routing('D:/Program Files/MATLAB/mytoolbox/spm12');
    result.stages{end+1}=struct('name','legacy_routing_without_breakpoints','seconds',toc(stage));
    saveProgress(result,started);
    disp('MIKEY_UNINSTRUMENTED_ROUTING_PASS');
    stage=tic;
    test_mikey_registration_dispatch('D:/Program Files/MATLAB/mytoolbox/spm12',true);
    result.stages{end+1}=struct('name','registration_dispatch_with_GUI','seconds',toc(stage));
    saveProgress(result,started);
    disp('MIKEY_GUI_THEN_ROUTING_BEGIN');
    stage=tic;
    test_mikey_bids_spm_routing('D:/Program Files/MATLAB/mytoolbox/spm12');
    result.stages{end+1}=struct('name','legacy_routing_after_GUI','seconds',toc(stage));
    assert(all(isvalid(figuresBefore)) && numel(findall(groot,'Type','figure'))==numel(figuresBefore),'Existing figures changed.');
    result.status='passed';saveProgress(result,started);
    disp('MIKEY_ORIGINAL_SEQUENCE_REPLAY_PASS');
    disp('MIKEY_EXISTING_FIGURES_PRESERVED_PASS');
catch ME
    result.status='failed';result.identifier=ME.identifier;
    result.error=getReport(ME,'extended','hyperlinks','off');
    saveProgress(result,started);fprintf('%s\n',result.error);rethrow(ME);
end
end

function saveProgress(result,started)
result.seconds=toc(started);result.updated=datestr(now,30);
fid=fopen(fullfile(fileparts(mfilename('fullpath')),'replay-result.json'),'w','n','UTF-8');
cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(result));
end

function restoreSession(oldPath,oldDirectory,oldBreakpoints,oldDiary,oldDiaryFile,oldRng,oldVisible,oldDefaults)
global defaults;
defaults=oldDefaults;rng(oldRng);set(groot,'DefaultFigureVisible',oldVisible);
dbclear all;if ~isempty(oldBreakpoints),dbstop(oldBreakpoints);end
path(oldPath);cd(oldDirectory);
diary off;set(0,'DiaryFile',oldDiaryFile);set(0,'Diary',oldDiary);
end

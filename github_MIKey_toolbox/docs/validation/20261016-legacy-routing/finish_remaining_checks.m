function finish_remaining_checks
root='K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';
folder=fileparts(mfilename('fullpath'));
oldPath=path;oldDirectory=pwd;oldBreakpoints=dbstatus('-completenames');oldRng=rng;
oldVisible=get(groot,'DefaultFigureVisible');
global defaults;
oldDefaults=defaults;
cleanup=onCleanup(@()restoreSession(oldPath,oldDirectory,oldBreakpoints,oldRng,oldVisible,oldDefaults)); %#ok<NASGU>
figuresBefore=findall(groot,'Type','figure');dbclear all;
addpath(root);addpath(fullfile(root,'tests'));
started=tic;result=struct('status','running','stages',{{}});
try
    progress(folder,'START native Code Analyzer');
    probe=[tempname '.m'];fid=fopen(probe,'w');fprintf(fid,'function y=invalid_probe(\ny=;\nend\n');fclose(fid);
    probeCleanup=onCleanup(@()delete(probe)); %#ok<NASGU>
    negative=checkcode(probe,'-id','-config=factory');
    assert(any(ismember({negative.id},{'SYNER','EOLPAR'})),'Code Analyzer negative control failed.');
    clear probeCleanup;
    files=[dir(fullfile(root,'MIKey*.m'));dir(fullfile(root,'tests','test_mikey_registration*.m'));dir(fullfile(root,'tests','test_mikey_bids_spm_routing.m'))];
    analysis=struct('file',{},'messages',{});
    for i=1:numel(files)
        filename=fullfile(files(i).folder,files(i).name);messages=checkcode(filename,'-id','-config=factory');
        assert(~any(ismember({messages.id},{'PARSE','SYNER','EOLPAR'})),'Native syntax error: %s',filename);
        analysis(end+1)=struct('file',filename,'messages',messages); %#ok<AGROW>
    end
    save(fullfile(folder,'native-code-analysis-final.mat'),'analysis','negative');
    result.stages{end+1}=struct('name','native_code_analyzer','files',numel(files),'negativeControlPassed',true);
    progress(folder,'PASS native Code Analyzer and negative control');
    progress(folder,'START exact previously stalled synthetic dataset');
    result.retainedFixture=replay_stalled_fixture('D:/Program Files/MATLAB/mytoolbox/spm12', ...
        'C:/Users/Administrator/AppData/Local/Temp/tpc29470fc_3fc6_47a4_996d_75bffd0b4c86');
    progress(folder,'PASS exact previously stalled synthetic dataset; original bytes preserved');
    progress(folder,'START uninstrumented original GUI -> legacy routing sequence');
    replay_remaining_sequence;
    replay=jsondecode(fileread(fullfile(folder,'replay-result.json')));assert(strcmp(replay.status,'passed'));
    result.replay=replay;
    assert(all(isvalid(figuresBefore)) && numel(findall(groot,'Type','figure'))==numel(figuresBefore),'Original figures changed.');
    result.originalFiguresPreserved=true;result.status='passed';result.seconds=toc(started);
    writeResult(folder,result);progress(folder,'MIKEY_ALL_REMAINING_CHECKS_PASS');
catch ME
    result.status='failed';result.seconds=toc(started);result.identifier=ME.identifier;
    result.error=getReport(ME,'extended','hyperlinks','off');writeResult(folder,result);
    progress(folder,result.error);rethrow(ME);
end
end

function progress(folder,message)
fid=fopen(fullfile(folder,'final-progress.log'),'a','n','UTF-8');cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s %s\n',datestr(now,30),message);fprintf('%s\n',message);
end

function writeResult(folder,result)
fid=fopen(fullfile(folder,'final-result.json'),'w','n','UTF-8');cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(result));
end

function restoreSession(oldPath,oldDirectory,oldBreakpoints,oldRng,oldVisible,oldDefaults)
global defaults;
defaults=oldDefaults;rng(oldRng);set(groot,'DefaultFigureVisible',oldVisible);
dbclear all;if ~isempty(oldBreakpoints),dbstop(oldBreakpoints);end
path(oldPath);cd(oldDirectory);
end

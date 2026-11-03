function run_remaining_checks
% Isolated diagnostics: conditional breakpoints log and always evaluate false.
root='K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';
oldPath=path;oldDirectory=pwd;oldBreakpoints=dbstatus('-completenames');
oldDiary=get(0,'Diary');oldDiaryFile=get(0,'DiaryFile');
global defaults;
oldDefaults=defaults;
restore=onCleanup(@()restoreSession(oldPath,oldDirectory,oldBreakpoints,oldDiary,oldDiaryFile,oldDefaults)); %#ok<NASGU>
diary(fullfile(fileparts(mfilename('fullpath')),'existing-instance-trace.log'));
dbclear all;
figuresBefore=findall(groot,'Type','figure');
started=tic;
try
addpath(root);addpath(fullfile(root,'tests'));
fprintf('MIKEY_REMAINING_ENTERED %s\n',datestr(now,30));
probe=[tempname '.m'];fid=fopen(probe,'w');fprintf(fid,'function y=invalid_probe(\ny=;\nend\n');fclose(fid);
probeCleanup=onCleanup(@()delete(probe)); %#ok<NASGU>
negative=checkcode(probe,'-id');
assert(any(ismember({negative.id},{'SYNER','EOLPAR'})),'Code Analyzer negative control failed.');
clear probeCleanup;disp('MIKEY_CODE_ANALYZER_NEGATIVE_CONTROL_PASS');
files=[dir(fullfile(root,'MIKey*.m'));dir(fullfile(root,'tests','test_mikey_registration*.m'));dir(fullfile(root,'tests','test_mikey_bids_spm_routing.m'))];
results=struct('file',{},'messages',{});
for j=1:numel(files)
    filename=fullfile(files(j).folder,files(j).name);
    messages=checkcode(filename,'-id');
    results(end+1)=struct('file',filename,'messages',messages); %#ok<AGROW>
    assert(~any(ismember({messages.id},{'PARSE','SYNER','EOLPAR'})),'Parse error: %s',filename);
    fprintf('CODE_CHECK_PASS %s\n',files(j).name);
end
save(fullfile(fileparts(mfilename('fullpath')),'native-code-analysis.mat'),'results');
disp('MIKEY_REGISTRATION_CODE_ANALYZER_PASS');
traces=struct('file',{'MIKey','MIKey_registration_qc'}, ...
    'lines',{[1665 1672 1673 1682 1685 1686 1687 1688 1699 1707 1715 1717 1718 1720 1759 1772 1775 1776 1777], ...
    [22 23 25 27 75 79 112 119 121 145 147 148 151 154 158 161 162]});
for i=1:numel(traces)
    for line=traces(i).lines
        expression=sprintf('fprintf(1,''TRACE %s:%d\\n'')<0',traces(i).file,line);
        dbstop('in',traces(i).file,'at',num2str(line),'if',expression);
    end
end
rng(0);
test_mikey_bids_spm_routing('D:/Program Files/MATLAB/mytoolbox/spm12');
dbclear all;
assert(all(isvalid(figuresBefore)) && numel(findall(groot,'Type','figure'))==numel(figuresBefore),'Existing figures changed.');
result=struct('status','passed','seconds',toc(started),'completed',datestr(now,30));
writeResult(result);
disp('MIKEY_EXISTING_FIGURES_PRESERVED_PASS');
disp('MIKEY_REMAINING_CHECKS_PASS');
catch ME
    result=struct('status','failed','seconds',toc(started),'identifier',ME.identifier,'error',getReport(ME,'extended','hyperlinks','off'));
    writeResult(result);fprintf('%s\n',result.error);rethrow(ME);
end
end

function writeResult(result)
fid=fopen(fullfile(fileparts(mfilename('fullpath')),'session-result.json'),'w','n','UTF-8');
cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s',jsonencode(result));
end

function restoreSession(oldPath,oldDirectory,oldBreakpoints,oldDiary,oldDiaryFile,oldDefaults)
global defaults;
defaults=oldDefaults;
dbclear all;
if ~isempty(oldBreakpoints),dbstop(oldBreakpoints);end
path(oldPath);cd(oldDirectory);
diary off;set(0,'DiaryFile',oldDiaryFile);set(0,'Diary',oldDiary);
end

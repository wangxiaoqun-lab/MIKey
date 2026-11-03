function test_mikey_subject_selection
% Test exact multi-subject selection without reading MRI image contents.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,work)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));
for id={'sub-001','sub-002','sub-003','sub-0010','sub-01','sub-rest'}
    directory=fullfile(work,id{1},'anat');mkdir(directory);
    fid=fopen(fullfile(directory,[id{1} '_T2w.nii']),'w');assert(fid>=0);fclose(fid);
end
cfg=MIKey_defaults();cfg.bidsPath=work;cfg.steps=1;
cfg.subjectFilter='sub-001,sub-002';cfg=MIKey_config(cfg);
assertSubjects(cfg,{'sub-001','sub-002'});
% Duplicate/overlapping alternatives do not repeat any subject.
cfg.subjectFilter=' sub-002 , sub-001 , sub-002 ';
cfg=MIKey_config(cfg);assert(strcmp(cfg.subjectFilter,'sub-002,sub-001,sub-002'));
assertSubjects(cfg,{'sub-001','sub-002'});
cfg.subjectFilter='sub-00?,sub-rest';cfg=MIKey_config(cfg);
assertSubjects(cfg,{'sub-001','sub-002','sub-003','sub-rest'});
cfg.subjectFilter='sub-001,sub-00?';assertSubjects(cfg,{'sub-001','sub-002','sub-003'});
cfg.subjectFilter='sub-001';assertSubjects(cfg,{'sub-001'});
cfg.subjectFilter='sub-*';assert(numel(MIKey_subjects(cfg))==6);
cfg.subjectFilter='sub-missing,sub-absent';assert(isempty(MIKey_subjects(cfg)));
% The existing GUI-to-script map carries the whole list unchanged.
cfg.subjectFilter='sub-001,sub-002';state=MIKeyBatchState(cfg,-1);
assert(strcmp(state.UserData.subjectsEdit.Value,cfg.subjectFilter));
config=cfg;save(fullfile(work,'selection.mat'),'config');
loaded=MIKey_config(fullfile(work,'selection.mat'));assertSubjects(loaded,{'sub-001','sub-002'});
fid=fopen(fullfile(work,'selection.json'),'w');assert(fid>=0);
fprintf(fid,'%s',jsonencode(cfg));fclose(fid);
loaded=MIKey_config(fullfile(work,'selection.json'));assertSubjects(loaded,{'sub-001','sub-002'});
% Do not silently interpret empty list entries as a wildcard.
for filter={'',',sub-001','sub-001,','sub-001,,sub-002','sub-001,002', ...
        'sub-001/sub-002','sub-001\sub-002','sub-001,sub- 002'}
    bad=cfg;bad.subjectFilter=filter{1};failed=false;
    try,MIKey_config(bad);catch ME
        failed=~isempty(strfind(ME.message,'subjectFilter')); %#ok<STREMP>
    end
    assert(failed,['Expected subjectFilter validation error for: ' filter{1}]);
end
% Subject lists still combine with independent session/task/run filtering.
for id={'sub-001','sub-002','sub-003'}
    directory=fullfile(work,id{1},'ses-01','func');mkdir(directory);
    name=[id{1} '_ses-01_task-rest_run-01_bold.nii'];
    fid=fopen(fullfile(directory,name),'w');assert(fid>=0);fclose(fid);
end
cfg.steps=10;cfg.sessionFilter='01';cfg.taskFilter='rest';cfg.runFilter='01';
assertSubjects(cfg,{'sub-001','sub-002'});
cfg.runFilter='02';assert(isempty(MIKey_subjects(cfg)));
disp('MIKEY_SUBJECT_SELECTION_PASS');
end

function assertSubjects(cfg,expected)
scopes=MIKey_subjects(cfg);actual=sort({scopes.subjectID});
assert(isequal(actual,sort(expected)));
end

function restore(oldPath,work)
path(oldPath);
target=char(java.io.File(work).getCanonicalPath());
parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));
if exist(target,'dir'),rmdir(target,'s');end
end

function test_mikey_submissions
% Server-only, prepare-only checks. Does not call sbatch/qsub or process images.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'examples'));
for id={'sub-001','sub-002'}
    folder=fullfile(work,id{1},'anat');mkdir(folder);touch(fullfile(folder,[id{1} '_T2w.nii']));
    folder=fullfile(work,id{1},'func');mkdir(folder);touch(fullfile(folder,[id{1} '_task-rest_run-01_bold.nii']));
end
a=MIKey_defaults();a.bidsPath=work;a.steps=1;a.subjectFilter='sub-001';
b=a;b.subjectFilter='sub-002';MIKey_check_parallel_configs({a,b});
expect(@()MIKey_check_parallel_configs({a,a}),'MIKey:ParallelOutputs');
cohort=a;cohort.steps=11;dependent=b;dependent.steps=12;
expect(@()MIKey_check_parallel_configs({cohort,dependent}),'MIKey:ParallelOutputs');
reader=a;reader.steps=12;MIKey_check_parallel_configs({reader,dependent});
priorA=a;priorA.steps=[13 14];priorA.useInterSubjectVar=false;
priorB=b;priorB.steps=[13 14];priorB.useInterSubjectVar=false;
MIKey_check_parallel_configs({priorA,priorB});
priorA.useInterSubjectVar=true;priorB.useInterSubjectVar=true;
try
    MIKey_check_parallel_configs({priorA,priorB});
catch ME
    assert(strcmp(ME.identifier,'MIKey:ParallelOutputs'));
    assert(contains(ME.message,'useInterSubjectVar=true'));
    assert(contains(ME.message,'No jobs were submitted'));
end
expect(@()MIKey_check_parallel_configs({priorA,priorB}),'MIKey:ParallelOutputs');
missing=b;missing.subjectFilter='sub-absent';
expect(@()MIKey_check_parallel_configs({a,missing}),'MIKey:SubmissionSelection');
first=MIKey_export_config(fullfile(work,'mikey_first.m'),a);
second=MIKey_export_config(fullfile(work,'mikey_second.m'),b);
for scheduler={'slurm','pbs','sge'}
    jobs=submit_mikey_configs({first,second},scheduler{1},{},false);
    assert(numel(jobs)==2 && all(strcmp({jobs.status},'prepared')));
    assert(~strcmp(jobs(1).script,jobs(2).script));
    for i=1:numel(jobs)
        assert(exist(jobs(i).script,'file')==2 && exist(jobs(i).configSnapshot,'file')==2);
        snapshot=MIKey_config(jobs(i).configSnapshot);
        if i==1,expected=a;else,expected=b;end
        assert(strcmp(snapshot.subjectFilter,expected.subjectFilter));
        source=fileread(jobs(i).script);
        assert(contains(source,'run_mikey(getenv(''MIKEY_JOB_CONFIG''))'));
        assert(contains(source,'MIKEY_ROOT') && contains(source,'MIKEY_JOB_CONFIG'));
        assert(contains(source,fullfile(matlabroot,'bin','matlab')));
        if strcmp(scheduler{1},'sge')
            assert(contains(source,'#$ -S /bin/bash') && contains(source,'#$ -V'));
            assert(~contains(source,'#PBS') && ~contains(source,'#SBATCH'));
            assert(contains(jobs(i).submitCommand,'''-terse'''));
            assert(contains(jobs(i).submitCommand,'''-b'' ''n'''));
            assert(contains(source,'-singleCompThread'));
        end
        [status,message]=system(['bash -n ' quote(jobs(i).script)]);
        assert(status==0,message);
    end
end
parallel=submit_mikey_configs(first,'sge',{'-pe','site_parallel_environment','4'},false);
assert(~contains(fileread(parallel.script),'-singleCompThread'));
assert(contains(parallel.submitCommand,'''-pe'' ''site_parallel_environment'' ''4'''));
disp('MIKEY_SUBMISSIONS_PREPARE_PASS');
end
function result=quote(value)
q=char(39);result=[q strrep(value,q,[q char(34) q char(34) q]) q];
end
function touch(filename)
fid=fopen(filename,'w');assert(fid>=0);fclose(fid);
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

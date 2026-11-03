function jobs = submit_mikey_configs(configFiles, scheduler, schedulerArgs, submit)
% One independent Slurm/PBS/SGE job per .m configuration, with frozen settings.
% jobs=submit_mikey_configs({'examples/a.m','examples/b.m'},'slurm',{'--partition=compute'});
% Pass false as argument 4 to prepare scripts without submitting them.
if nargin<2,error('MIKey:Submission','Specify slurm, pbs or sge.');end
if nargin<3,schedulerArgs={};end
if nargin<4,submit=true;end
if ispc,error('MIKey:Submission','Run this submission helper on the Linux server.');end
if isstring(scheduler) && isscalar(scheduler),scheduler=char(scheduler);end
if ~ischar(scheduler) || ~isrow(scheduler) || ~any(strcmpi(scheduler,{'slurm','pbs','sge'}))
    error('MIKey:Submission','Scheduler must be slurm, pbs or sge.');
end
scheduler=lower(scheduler);
if ~islogical(submit) || ~isscalar(submit),error('MIKey:Submission','submit must be true or false.');end
if ischar(configFiles),configFiles={configFiles};elseif isstring(configFiles),configFiles=cellstr(configFiles(:));end
if ~iscell(configFiles) || isempty(configFiles) || ~isvector(configFiles)
    error('MIKey:Submission','Supply a nonempty cell array of configuration .m filenames.');
end
if isstring(schedulerArgs),schedulerArgs=cellstr(schedulerArgs(:));end
if ~iscell(schedulerArgs) || (~isempty(schedulerArgs) && ~isvector(schedulerArgs))
    error('MIKey:Submission','Scheduler options must be a cell array, one argument per element.');
end
for i=1:numel(schedulerArgs)
    if isstring(schedulerArgs{i}) && isscalar(schedulerArgs{i}),schedulerArgs{i}=char(schedulerArgs{i});end
    if ~ischar(schedulerArgs{i}) || ~isrow(schedulerArgs{i}) || any(schedulerArgs{i}==0)
        error('MIKey:Submission','Each scheduler option must be a character vector without NUL.');
    end
end
root=fileparts(fileparts(mfilename('fullpath')));addpath(root,'-begin');
configs=cell(1,numel(configFiles));sources=cell(size(configs));
for i=1:numel(configs)
    sources{i}=MIKey_resolve_config_path(configFiles{i},root);
    if any(strcmp(sources{i},sources(1:i-1)))
        error('MIKey:Submission','The same configuration was listed twice: %s',sources{i});
    end
    raw=MIKey_load_config_function(sources{i});
    if ~isfield(raw,'steps'),error('MIKey:Submission','Configuration has no steps: %s',sources{i});end
    selected=MIKey_config(struct('steps',raw.steps));
    if ismember(1,selected.steps) && numel(selected.steps)>1
        error('MIKey:MaskPreparationRequired','Run Step 1 alone, prepare masks, then change steps in %s.',sources{i});
    end
    configs{i}=MIKey_config(raw);
end
% Validate all configurations and their output scopes before queueing any job.
MIKey_check_parallel_configs(configs,sources);
if strcmp(scheduler,'slurm'),program='sbatch';else,program='qsub';end
if submit
    % Use a known POSIX shell even when MATLAB inherited csh/tcsh as SHELL.
    probe=['command -v ' program ' >/dev/null 2>&1'];
    [status,~]=system(['/bin/sh -c ' shellQuote(probe)]);
    if status~=0
        error('MIKey:Submission', ...
            ['MATLAB cannot find scheduler command %s in its inherited PATH (%s requested). ' ...
            'No jobs were submitted. Confirm the actual cluster scheduler and use its submission node/environment; ' ...
            'choosing slurm does not install sbatch. ' ...
            'If the command is available in your terminal but not MATLAB, launch MATLAB from that configured terminal. ' ...
            'To generate scripts without queueing, use submit_mikey_configs(files,scheduler,{},false), then submit their recorded commands from the configured terminal.'], ...
            program,scheduler);
    end
end
first=configs{1};
if isempty(first.logDir),logRoot=fullfile(first.bidsPath,'derivatives','MIKey','logs');else,logRoot=first.logDir;end
parent=fullfile(logRoot,'submissions');
if ~exist(parent,'dir'),[ok,message]=mkdir(parent);if ~ok,error('MIKey:Submission','%s',message);end,end
batchDirectory=tempname(parent);[ok,message]=mkdir(batchDirectory);
if ~ok,error('MIKey:Submission','%s',message);end
manifestPath=fullfile(batchDirectory,'submission.json');
empty=struct('sourceConfig','','configSnapshot','','script','','stdout','','stderr','', ...
    'scheduler',scheduler,'submitCommand','','status','prepared','jobId','','schedulerResponse','');
jobs=repmat(empty,1,numel(configs));
for i=1:numel(configs)
    snapshot=fullfile(batchDirectory,sprintf('mikey_job_%03d.m',i));
    MIKey_export_config(snapshot,configs{i});
    script=fullfile(batchDirectory,sprintf('job_%03d.sh',i));
    output=fullfile(batchDirectory,sprintf('job_%03d.stdout.log',i));
    errors=fullfile(batchDirectory,sprintf('job_%03d.stderr.log',i));
    body={'#!/usr/bin/env bash'};
    if strcmp(scheduler,'slurm')
        body=[body {'#SBATCH --cpus-per-task=4','#SBATCH --mem=16G','#SBATCH --time=04:00:00'}];
        args={'sbatch','--parsable',['--job-name=MIKey_' sprintf('%03d',i)],['--output=' output],['--error=' errors]};
    elseif strcmp(scheduler,'pbs')
        body=[body {'#PBS -l select=1:ncpus=4:mem=16gb','#PBS -l walltime=04:00:00','#PBS -V'}];
        args={'qsub','-N',sprintf('MIKey_%03d',i),'-o',output,'-e',errors};
    else
        % SGE uses its own directives/options, not PBS resource syntax.
        % Queue, PE names and memory complexes are site-specific: do not guess.
        body=[body {'#$ -S /bin/bash','#$ -cwd','#$ -V'}];
        args={'qsub','-terse','-b','n','-S','/bin/bash','-cwd','-V', ...
            '-N',sprintf('MIKey_%03d',i),'-o',output,'-e',errors};
    end
    matlabExecutable=fullfile(matlabroot,'bin','matlab');
    matlabOptions=' -nodisplay -nosplash';
    % SGE defaults to one computational thread unless a parallel environment
    % was explicitly requested. Site PE requests use the third argument.
    if strcmp(scheduler,'sge') && ~any(strcmp(schedulerArgs,'-pe'))
        matlabOptions=[matlabOptions ' -singleCompThread'];
    end
    body=[body {'set -euo pipefail', ...
        '# Add the site MATLAB module setup here if it is not inherited.', ...
        ['export MIKEY_ROOT=' shellQuote(root)], ...
        ['export MIKEY_JOB_CONFIG=' shellQuote(snapshot)], ...
        ['export MIKEY_MATLAB=' shellQuote(matlabExecutable)], ...
        'cd "$MIKEY_ROOT"', ...
        'if [[ ! -x "$MIKEY_MATLAB" ]]; then echo "MATLAB executable unavailable: $MIKEY_MATLAB" >&2; exit 127; fi', ...
        ['"$MIKEY_MATLAB"' matlabOptions ' -r "try, addpath(fullfile(getenv(''MIKEY_ROOT''),''examples'')); run_mikey(getenv(''MIKEY_JOB_CONFIG'')); catch ME, disp(getReport(ME,''extended'',''hyperlinks'',''off'')); exit(1); end; exit(0);"']}];
    writeText(script,strjoin(body,sprintf('\n')));
    args=[args reshape(schedulerArgs,1,[]) {script}];
    command=cellfun(@shellQuote,args,'UniformOutput',false);
    jobs(i).sourceConfig=sources{i};jobs(i).configSnapshot=snapshot;
    jobs(i).script=script;jobs(i).stdout=output;jobs(i).stderr=errors;
    jobs(i).submitCommand=strjoin(command,' ');
end
writeManifest(manifestPath,jobs);
fprintf('Prepared %d independent jobs. Submission record: %s\n',numel(jobs),manifestPath);
if ~submit
    for i=1:numel(jobs),fprintf('Prepared script: %s\n',jobs(i).script);end
    return;
end
for i=1:numel(jobs)
    [status,response]=system(jobs(i).submitCommand);
    jobs(i).schedulerResponse=response;
    if status~=0
        jobs(i).status='submission_failed';writeManifest(manifestPath,jobs);
        accepted=sum(strcmp({jobs.status},'submitted'));
        if strcmp(scheduler,'sge') && contains(lower(response),'not a submit host')
            error('MIKey:SubmissionHost', ...
                ['SGE rejected submission from this host: %s ' ...
                'This host is not authorized to call qsub. Submit from a site-authorized submit host, ' ...
                'or execute run_mikey(configFile) directly in your existing MATLAB/approved script-launch workflow. ' ...
                'Earlier jobs successfully submitted by this call: %d. Submission record: %s.'], ...
                strtrim(response),accepted,manifestPath);
        end
        error('MIKey:Submission', ...
            'Submission failed for %s: %s. Earlier jobs successfully submitted by this call: %d; inspect %s before retrying.', ...
            sources{i},response,accepted,manifestPath);
    end
    jobs(i).status='submitted';jobs(i).jobId=strtrim(response);
    writeManifest(manifestPath,jobs);
    fprintf('Submitted %s: %s\n',sources{i},strtrim(response));
end
end

function text=shellQuote(value)
quote=char(39);replacement=[quote char(34) quote char(34) quote];
text=[quote strrep(value,quote,replacement) quote];
end
function writeText(filename,text)
fid=fopen(filename,'w','n','UTF-8');
if fid<0,error('MIKey:Submission','Cannot write %s',filename);end
cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',text);
end
function writeManifest(filename,jobs)
temporary=[tempname(fileparts(filename)) '.json'];
cleanup=onCleanup(@()removeTemporary(temporary)); %#ok<NASGU>
record=struct('updated',datestr(now,30),'jobs',jobs);
writeText(temporary,jsonencode(record));
[ok,message]=movefile(temporary,filename,'f');
if ~ok,error('MIKey:Submission','Cannot save submission record: %s',message);end
end
function removeTemporary(filename)
if exist(filename,'file'),delete(filename);end
end

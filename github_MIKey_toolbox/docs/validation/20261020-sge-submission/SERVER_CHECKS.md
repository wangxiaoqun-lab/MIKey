# SGE submission: server checks

Status: prepared, not executed locally. No local MATLAB, syntax checker, tests, UI or scheduler commands were run. No actual jobs were submitted by the agent.

Evidence from user's server Bash:

- sbatch: absent from PATH
- qsub: /opt/sge-8.1.9/bin/lx-amd64/qsub
- bsub: absent from PATH

This identifies the Grid Engine installation, not PBS. SGE queues, PE names and resource complexes have not been supplied; none are invented by the helper.

After uploading the whole original folder, run the prepare-only server check:

```matlab
cd('/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main');
addpath(pwd); addpath('examples'); addpath('tests');
test_mikey_submissions
```

Expected marker: MIKEY_SUBMISSIONS_PREPARE_PASS. The test generates scripts for Slurm/PBS/SGE and invokes bash -n; it does not call sbatch/qsub. For SGE it checks native directives, -terse, -b n, absolute MATLAB path, default single computational thread, and propagation of an explicit PE argument. It retains collision checks. All execution remains pending on the server.

For the two user configs, first decide the scientific setting:

- Independent single-subject parcellation without inter-subject variability: set cfg.useInterSubjectVar=false in each original config function.
- Retain inter-subject variability: one config must select the entire intended cohort. Two single-subject jobs cannot estimate or share this cohort map safely. The helper does not silently change this setting.

In server MATLAB, from the toolbox root (path resolution also supports examples):

```matlab
files={'examples/mikey_config_sub001_14.m','examples/mikey_config_sub002_14.m'};
% After explicitly selecting independent analysis without inter-subject variability:
jobs=submit_mikey_configs(files,'sge',{},false);
disp(jobs(1).submitCommand);
disp(fileread(jobs(1).script));
% To actually submit one job per config after inspection:
% jobs=submit_mikey_configs(files,'sge');
```

The final commented call submits actual jobs; the agent has not run it. The prepared scripts use #$ directives and qsub -terse -b n -S /bin/bash -cwd -V, with site defaults for queue/resources. MATLAB's executable comes from the submitting MATLAB's matlabroot, which must also be accessible on compute nodes. It defaults to -singleCompThread without an explicit -pe request. Site PE names come from qconf -spl and resource definitions from site policy; an explicit worker pool requires corresponding slots. Do not pass PBS select/ncpus syntax to SGE. Check submitted job IDs with qstat -u wanglab41 in Bash.

If MATLAB cannot find qsub while Bash can, start MATLAB from the configured SGE terminal so SGE_ROOT/SGE_CELL/PATH and related environment are inherited. Script preparation remains available without qsub. Queue acceptance, compute-node executable visibility, licensing and real Step 13/14 results need actual server validation.

Reference: https://gridscheduler.sourceforge.net/htmlman/htmlman1/qsub.html (-terse, -b, -S, -cwd, -V, -pe). Original target has no Git checkout; source-snapshot.json identifies the revision in place of a commit.

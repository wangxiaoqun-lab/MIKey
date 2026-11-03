# Server checks: submission diagnostics

Pending; no local tests or scheduler calls were executed.

In the server terminal, inspect actual scheduler availability:

```bash
command -v sbatch
command -v qsub
command -v bsub
```

A command name alone does not establish the site's queue policy or scheduler variant; use the site's documented scheduler. In MATLAB, inspect the exact submission environment without queueing anything:

```matlab
getenv('PATH')
system('/bin/sh -c ''command -v sbatch; command -v qsub; command -v bsub''')
```

If the terminal sees the correct scheduler but MATLAB does not, launch MATLAB from the configured submission terminal. If neither sees it, the scheduler environment/node or scheduler choice needs correction. Do not assume Slurm from the examples.

For independent subjects in Steps 13-14 without cohort variability, explicitly set cfg.useInterSubjectVar=false in each original configuration function. Retain true only when running one configuration selecting the complete intended cohort. No scientific settings were automatically changed.

Prepare-only checks with no submission:

```matlab
cd('/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main');
addpath(pwd); addpath('examples'); addpath('tests');
test_mikey_submissions
files={'examples/mikey_config_sub001_14.m','examples/mikey_config_sub002_14.m'};
% Only after explicitly choosing independent analysis without Inter-Subj Var:
jobs=submit_mikey_configs(files,'slurm',{},false);
```

Expected synthetic check marker: MIKEY_SUBMISSIONS_PREPARE_PASS. This authored test remains unexecuted locally. The prepare-only call must work even when sbatch is absent, but still rejects output collisions. To actually submit later, use the correct scheduler from its configured submission environment; inspect generated script MATLAB module setup and recorded commands first.

# Server-only multi-configuration submission checks

Implementation has not been tested locally. No MATLAB, shell syntax check or scheduler submission was run by the agent.

In server MATLAB, from the toolbox root:

```matlab
addpath(pwd); addpath('examples'); addpath('tests');
test_mikey_config_paths;
test_mikey_config_export;
test_mikey_submissions; % Prepare-only synthetic checks; no sbatch/qsub submission.
```

The prepare-only test writes isolated temporary config/job files, checks selection conflicts, reads snapshots and runs bash -n on generated scripts. It requires Linux Bash and MATLAB; it does not require SPM processing or an active scheduler.

Then export two real configurations with disjoint subjects. Prepare jobs for review if desired:

```matlab
files={'examples/config_sub001.m','examples/config_sub002.m'};
jobs=submit_mikey_configs(files,'slurm',{},false);
```

For actual Slurm submission:

```matlab
jobs=submit_mikey_configs(files,'slurm');
```

For PBS, replace slurm with pbs and supply site queue/account flags as documented in README. Each actual job invokes run_mikey with its own frozen .m configuration; processing parameters remain in the original user config files. Actual job output and scheduler status must be assessed on the server.

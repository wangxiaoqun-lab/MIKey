# Direct node execution with the confirmed mrun alias

Status: source changes implemented; server validation pending. No local MATLAB, syntax checker, tests, scripts or child processes were launched by the agent.

The user supplied: mrun is aliased to matlab2019 -nodesktop -nosplash -r, launching MATLAB R2019b (9.7.0.1190202) on Linux. This is a direct MATLAB entry, not an SGE submit command. Exact resource allocation policy outside this wrapper was not inferred.

Single-configuration execution already works through the existing run_mikey function, without this new multi-process feature:

```bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main/examples
mrun "try, run_mikey('mikey_config_sub001_14.m'); catch ME, disp(getReport(ME,'extended','hyperlinks','off')); exit(1); end; exit(0);"
```

After uploading the complete updated original toolbox, prepare-only server checks (no child MATLAB/process or scheduler starts):

```matlab
cd('/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main');
addpath(pwd);addpath('examples');addpath('tests');
test_mikey_submissions
```

Expected marker: MIKEY_SUBMISSIONS_PREPARE_PASS. The extended test prepares scripts in all four modes, checks local nohup launch commands, native mode separation, traps, empty prelaunch PID/exit file and runs bash -n. This test is authored but has not been run locally.

For independent selected subjects without cohort variability correction, set cfg.useInterSubjectVar=false explicitly in each config file before a two-config launch. If retaining this correction, use one config selecting the intended cohort. The helper changes no processing option.

```matlab
files={'examples/mikey_config_sub001_14.m','examples/mikey_config_sub002_14.m'};
jobs=submit_mikey_configs(files,'local',{},false); % preparation only
% After inspecting the prepared scripts and choosing the scientific settings:
% jobs=submit_mikey_configs(files,'local'); % starts real MATLAB processes
```

Manual server smoke: first launch one intended config in local mode, inspect its stdout/stderr paths and wait for exitCodeFile. An exit code of 0 means the child run succeeded; nonzero means failure. Then check the actual MIKey run report and image/FC/parcellation results. For two disjoint configs, verify distinct wrapper PIDs/logs/snapshots, concurrency on the current node, no qsub/sbatch calls, no output collisions and exit codes. Do not infer completion from status=launched or missing exit-code files. Abrupt process termination can prevent status writing.

Each local command starts a detached Bash wrapper through nohup using POSIX-shell quoting, redirects stdin/stdout/stderr before backgrounding, returns the wrapper PID, and writes the child command's exit status via an EXIT trap. It uses the submitting MATLAB's absolute executable. The controller prepares and checks all configs before starting any process, and keeps already-started processes if a later launch fails. submission.json records starts; it is not a live monitor or cluster job record. This does not distribute tasks across nodes or reserve scheduler resources. The third argument must be empty for local mode.

Original delivery folder is not a Git checkout. source-snapshot.json supplies exact source identity instead of a commit; no archives were generated. Existing user configs and GUI layout remain unchanged.

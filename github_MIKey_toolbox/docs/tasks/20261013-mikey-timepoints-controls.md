# Minimum BOLD duration and GUI task control

Date: 2026-10-13. Status: implemented and assertion-tested on MATLAB R2018a/SPM12 using synthetic data only.

Requested behavior:
- Top-row Min Time Points (N) excludes raw BOLD runs with T < N. Equality is retained; 0 disables filtering. Anatomy and fieldmap dependencies are retained. GUI, struct/MAT/JSON configuration and MIKEY_MIN_TIMEPOINTS cluster override share minTimepoints.
- Selection is shared by preprocessing, regression, FC, group analysis, variability and concatenation. Header-only counting supports .nii/.nii.gz without unpacking full raw scans. Preflight records excludedBold; execution logs short runs. Nonzero N is part of the group/concatenation selection key, preserving older zero-threshold paths.
- Pause/Resume/Stop control one active GUI task. Other controls are locked while busy and their prior states are restored afterward. Pause waits at cooperative checkpoints; Stop unwinds through processing catches, retains completed outputs, prevents subsequent files/steps and permits another run in the same MATLAB session. Closing a busy window requests Stop and defers deletion until cleanup.
- Native SPM/MEX calls cannot be forcibly interrupted by these controls; requests take effect after a call returns. Checkpoints cover files/strategies and optional parcellation iterations. GUI event pumping is limited to roughly 20 Hz outside status updates. No PCT dependency or external worker was added.

Validation:
1. test_mikey_timepoint_filter: endian-aware header counts, negative count rejection, gzip headers, five-frame exclusion, exact T=N retention, threshold configuration validation/import, actual Step 1 outputs and Step 11 estimates. An old five-frame regression-result file is excluded from group estimates. The parcellation callback propagates MIKey:Stopped. MIKEY_TIMEPOINT_FILTER_PASS; launcher exit 0.
2. test_mikey_run_controls: timers invoke actual GUI Pause/Resume/Stop buttons during scaling; output count remains fixed while paused, all files finish after Resume, Stop retains exactly one completed file and never starts selected Step 8. A subsequent Run succeeds without restarting MATLAB. MIKEY_RUN_CONTROLS_PASS.
3. Existing GUI layout/filter and Step 2/3 diagnostics passed; all root MATLAB files have no Code Analyzer PARSE errors. MIKEY_CONTROLS_FINAL_CHECK_PASS. MISS_HIT parsing also passed the changed core parcellation helper and all modified production/test files.
4. The outer MATLAB launcher returned exit status 1 after all GUI PASS markers and saving the result MAT, with no reported MATLAB error stack. This exit-status discrepancy remains a validation limitation; the assertions and Code Analyzer checks did pass.

MATLAB startup was delayed. One duplicate test process started by this task was stopped only after its exact PID and command line were verified; no user MATLAB process was stopped. No user research/demo images were processed or modified. No server experiment, native screenshot or Git commit was made. Prior source files are in ../backups/20261013-timepoints-controls/.

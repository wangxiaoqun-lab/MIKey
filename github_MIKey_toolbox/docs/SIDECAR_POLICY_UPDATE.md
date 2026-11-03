# Intermediate MAT sidecar update

Upload the complete current local `MIKey_toolbox_main` folder to the server while MATLAB is idle, then start a fresh MATLAB session. The folder already includes this update, the selectable FD methods and all dependencies. No update archive or new parameter is needed; existing GUI controls are unchanged.

On subsequent runs, a successfully completed image-producing stage omits redundant image-paired MAT files when their only numeric mat array exactly repeats the NIfTI header affine or contains SPM zero fallbacks. Real per-volume transforms and unknown content remain. Image bytes/headers are unchanged. Only pairs created or updated in that stage are eligible; skipped old outputs are not retroactively cleaned. No recursive or wildcard MAT deletion is performed.

PC, FD/DVARS/CC, group/best strategy, FC, normalization-transform and run-record MAT files remain because they are analysis inputs/results or audit information. This does not mean every MAT file will disappear. A status message reports the policy's actions when pairs are affected. There is no need to repeat completed preprocessing merely to remove old files; this change applies automatically to future writes.

Validation and exact source identity: `runs/20261019-sidecar-policy/RUN_REPORT.md`.

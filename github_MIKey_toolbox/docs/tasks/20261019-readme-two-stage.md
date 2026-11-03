# Two-stage general-script server instructions

Status: completed, 2026-10-19.

Updated the English README to make `examples/mikey_config_example.m` the sole editable processing configuration and `examples/run_mikey.m` the shared entry for both stages. It now documents Step 1, manual functional/anatomical masks on scaled images, changing only `cfg.steps` to `2:10`, and repeating the identical server command. Added the same-entry Slurm submission and clarified the optional saved MAT/JSON interface separately. Scheduler parameters are distinguished from processing parameters.

Validation: every documented Bash block passed Git Bash syntax checking; the three general-entry commands are identical and passed native R2018a syntax checking. All README relative file links resolve and fences are balanced. All 230 source/configuration checksums remain unchanged. No MATLAB computation was required for this documentation-only change. Backup and focused diff/check results are under `docs/backups/20261019-readme-two-stage/` and `docs/validation/20261019-readme-two-stage/`.

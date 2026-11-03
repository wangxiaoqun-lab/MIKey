# Multiple configuration jobs

Implemented one independent Slurm/PBS job per .m configuration via submit_mikey_configs, with frozen settings, separate scripts/logs, within-batch output collision checks and prepare-only mode. Source config files remain the sole user-editable processing settings.

No local testing or actual submission. User server validation is pending; see docs/validation/20261020-multi-config-jobs/SERVER_CHECKS.md.

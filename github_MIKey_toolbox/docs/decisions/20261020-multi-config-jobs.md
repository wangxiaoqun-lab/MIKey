# Independent jobs from multiple configuration functions

Keep run_mikey focused on one configuration and expose a separate submit_mikey_configs helper for simultaneous queue submission. Generate one Bash worker and one frozen .m snapshot per config; record responses in JSON without generating intermediate MAT files. Validate the complete batch before submitting, conservatively reject same-subject outputs and shared group writers/readers, and preserve already submitted jobs on partial failure. Do not imply collision protection against unrelated external submissions.

Support Slurm and PBS with explicit scheduler selection. Runtime site/resource flags are job settings, not a second processing-parameter block. All validation remains server-only at the user request.

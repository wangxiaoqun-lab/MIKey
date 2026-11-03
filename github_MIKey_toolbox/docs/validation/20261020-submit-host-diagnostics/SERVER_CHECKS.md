# Server submission-host diagnosis

Evidence: SGE qsub rejected the user's first and only job with host node02 is not a submit host. The request reached SGE; its submission-host policy rejected it. The prepared scripts and snapshot are not evidence of a queued job. The first-job failure confirms no earlier jobs were submitted by this call.

No local MATLAB, syntax checker, tests or scheduler jobs were run. Existing source was inspected only. The helper now gives MIKey:SubmissionHost for this SGE rejection, prints the actual number of earlier successful submissions, and keeps the failure in submission.json. No automatic SSH, permission changes, scheduler fallback or user analysis-setting changes are made.

Immediate direct execution, in the user's already-open server MATLAB:

```matlab
addpath('/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main/examples');
report=run_mikey('examples/mikey_config_sub001_14.m');
```

This uses the existing noninteractive processing entry without a scheduler. Existing settings and selected inputs still apply. In particular, a single subject cannot estimate inter-subject variability; retain that scientific option only with an intended cohort selection.

A site-provided mrun wrapper may execute MATLAB directly or perform other site-specific actions. Its implementation is not available locally. The user has been asked to run type mrun in Bash and provide a previously successful complete command before a specific mrun integration is prescribed. The existing mikey_cluster_job.m script can already read a .m configuration via MIKey_config, but its documented environment overrides and a wrapper's environment/working-directory behavior must be considered.

Pending server checks: direct run_mikey on the selected config; inspect type mrun and a working invocation; if queue submission is desired, use the site's authorized submission host and inspect qstat. The previous error must not be treated as an algorithm failure. No full processing success has been established. The original folder has no Git checkout; source-snapshot.json identifies the revision instead of a commit.

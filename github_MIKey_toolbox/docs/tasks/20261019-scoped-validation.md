# Comprehensive selected-step parameter validation

Status: completed, 2026-10-19.

Request: audit the general script and all MIKey_config validation so Steps 1 / 2-10 are not blocked by unused later-stage settings. Preserve the GUI layout and user parameter assignments.

Implemented one 50-field conditional usage map; scoped validation, preflight, batch control adaptation and stage prerequisites/metadata; aggregate active-field errors; retain unused values; preserve the general two-phase mask workflow. Updated regression fixtures, README scope table and deployment instructions.

Validation: 448 unused field/type combinations, 17 stage routes, active type checks for all 50 fields, the unchanged user's two phase configurations, MAT/JSON/batch/metadata tests, representative real-SPM synthetic Steps 1/2/8/10/11/12/13 and 20-file native/parser checks passed. Two outdated test assumptions were fixed and rerun; both failures are recorded. GUI construction and user configuration bytes are unchanged. Full evidence: `../../runs/20261019-scoped-validation/RUN_REPORT.md`.

# MIKey registration failure gates

Date: 2026-10-15. Scope: original MIKey toolbox, Stages 6 and 7 only; keep the existing English three-column GUI.

## Implementation

- Stage 6 checks realigned BOLD against masked T2w before estimation, then checks the resliced T2w against mean BOLD. SPM receives a private anatomical copy so failed estimation cannot change the source affine. A failed private anatomical candidate is retained under registration_qc/failed_candidates when possible.
- Stage 7 checks the actual default or custom template against coregistered T2w before estimation, then checks normalized T2w and BOLD against the template. BOLD volume counts and anatomical/BOLD grids must agree.
- Cached results undergo the same checks. Candidates are published only after QC. Registration failures escape per-subject handling and stop later selected steps/subjects in GUI and script, including failFast=false. English status messages identify paths and suggested geometry/mask/template checks.
- JSON records include limits, world-space geometry, foreground coverage, overlap and diagnostic NMI. No header correction or registration optimizer changes are applied. See README for thresholds and interpretation.

## Validation environment and commands

Windows; MATLAB R2018a at D:/Program Files/MATLAB/R2018a; SPM12 at D:/Program Files/MATLAB/mytoolbox/spm12. No Git repository exists in the target toolbox, so no commit or branch was created. Pre-edit files are retained in docs/backups/20261015-registration-qc. No server experiment was performed; no raw/demo image was changed.

MATLAB was started with -wait -nosplash -nodesktop -singleCompThread -sd C:/Users/Administrator/AppData/Local/Temp/MIKeyRegistrationStartup and a per-run -logfile. Geometry-only invocation additionally used -nojvm.

Geometry command in MATLAB:

```matlab
addpath('K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main/tests');
test_mikey_registration_qc('D:/Program Files/MATLAB/mytoolbox/spm12');
```

Integration command in MATLAB:

```matlab
test_mikey_registration_dispatch('D:/Program Files/MATLAB/mytoolbox/spm12',true);
test_mikey_bids_spm_routing('D:/Program Files/MATLAB/mytoolbox/spm12');
files=dir('K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main/MIKey*.m');
for j=1:numel(files)
    messages=checkcode(fullfile(files(j).folder,files(j).name),'-id');
    assert(~any(strcmp({messages.id},'PARSE')));
end
```

Static check: python -m miss_hit_core.mh_style --no-style --brief --single --matlab 2018a (MIKey.m uses --input-encoding gb18030).

## Results

- Geometry suite: PASS, launcher exit 0. Real SPM image I/O and sampling cover multimodal alignment, differing voxel resolution with matching physical geometry, valid storage flips/permutations, scale/center/orientation failures, blank/constant images, later blank BOLD frames, near-singular affine, frame counts and grid mismatches including large world origins. SPM warned that QFORM0 was rounded for the deliberately near-singular synthetic test.
- Dispatch and GUI callback assertions: PASS (MIKEY_REGISTRATION_DISPATCH_PASS, MIKEY_REGISTRATION_GUI_STOP_PASS). Valid Stage 6/7 dispatch, bad cached outputs, failed candidates, unsafe initial scale before the estimator, estimator errors, failFast=false stopping and restored GUI controls all passed. The subsequent copy-only naming regression stalled after Starting Coregistration and was terminated after its exact command line was verified (test core 19500). Its cause remains undetermined. It has no PASS marker; native Code Analyzer was after that test and was not reached. The combined launcher exited 1 after this deliberate termination. These two checks are NOT reported as passing. The intentional blank-output exception stack in the log is expected test evidence, not an unhandled suite failure.
- Failed candidate retention: PASS. A failed Stage 6 review image exists at the JSON reviewImage path after private workspace cleanup, and no canonical coregistered T2w was published. See failed-candidate-retention.json and retention-validation.log.
- Static parser: PASS for all 8 changed MATLAB files; see static-parser.log.

- Startup failures/empty logs are retained. Two stalled test cores (13324, 10128) were stopped only after their command lines were verified to identify this task's exact log paths. The user's pre-existing MATLAB process was not terminated. A later startup completed; the first dispatch attempt then exposed a MATLAB R2018a parser conflict between a local variable named path and the earlier path function call. Renaming that test variable to funcPath fixed the harness; static parsing passed before retry.

## Limits

Synthetic tests exercise gates and control flow, not real-acquisition registration quality. Dispatch tests use an explicit COPY-ONLY SPM fixture, never a shadowing executable fixture in the toolbox. They do not validate the scientific behavior of SPM coregistration/old normalization. GUI callback assertions do not constitute physical pointer-click testing. Computer-use helper initialization timed out; the user's existing MATLAB window was not inspected.

Thresholds are conservative heuristics, not cohort-calibrated guarantees. Partial FOV, unusual contrast, pathology or inaccurate masks can trigger rejection; symmetric left/right mistakes and subtle local failures can pass. Use SPM Check Reg for visual review. Correct geometry/masks/template before retrying; do not interpret an automatic pass as certification.

Computer Use retry after the user opened MATLAB/MIKey: the @oai/sky initialization again timed out and reset its kernel. No window state, screenshot or control action was obtained. The user's MATLAB instance was preserved. Source manifests were refreshed from the known 221 source entries; an unnecessarily broad recursive manifest scan was stopped and replaced by explicit source-file reads.

Latest Computer Use recovery: module import eventually succeeded with a longer timeout, but both list_apps and list_windows returned computer-use request timed out. No target window, screenshot or input action was obtained.

## Final validation boundary

Targeted geometry and registration dispatch/GUI-stop assertions passed. The broader legacy naming regression did not finish; native Code Analyzer was not reached. The 8 changed MATLAB files passed the MATLAB 2018a static parser. The combined launcher's exit 1 reflects terminating the stalled extra regression, and is not an all-tests-pass exit status. No real-acquisition optimizer experiment or physical pointer-click validation was completed. Only this task's verified test process was stopped; the user's MATLAB process (16048, opened before the test launch) remained running.

Source hashes: 221 known source files refreshed and verified; focused and cumulative patches regenerated. Static parser output, geometry log, the dispatch log including PASS markers and expected intentional failure stack, earlier startup failures, and candidate-retention evidence are preserved in docs/validation/20261015-registration-qc/.


## 2026-10-16 follow-up

The remaining legacy routing and native Code Analyzer checks have now passed, including exact retained-input replay and the original GUI-to-routing order. See 20261016-legacy-routing.md and ../validation/20261016-legacy-routing/final-result.json. The old incomplete launch remains recorded above; its original stall was not reproduced. A new launch was independently blocked by License Manager Error -8, and final tests ran in the already licensed instance with the user's temporary local automation service restored afterward.

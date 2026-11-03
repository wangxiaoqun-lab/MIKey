# Finish legacy-path routing and code-analysis validation

Date: 2026-10-16.

User request: investigate the stalled legacy-path regression, finish remaining tests, fix issues directly in the original toolbox, preserve the GUI layout.

Prior evidence: the combined 2026-10-15 process passed geometry/dispatch/GUI-stop assertions but stopped producing output after Starting Coregistration in test_mikey_bids_spm_routing. No Stage 6 QC JSON was written. Native Code Analyzer was placed after that test and never reached. The stalled process was deliberately terminated; the old combined run remains an incomplete result.

Investigation: rerun the original source in an isolated MATLAB preference/startup directory, execute native Code Analyzer first, then use conditional MATLAB breakpoints that print a location and always evaluate false to locate the stalled operation without modifying production code. Breakpoint semantics were checked against the installed R2018a dbstop.m documentation. No Windows UI automation is required. Existing user MATLAB processes are preserved.

Environment: MATLAB R2018a, D:/Program Files/MATLAB/R2018a; SPM12, D:/Program Files/MATLAB/mytoolbox/spm12. Exact diagnostic source/commands and results are retained in docs/validation/20261016-legacy-routing/. Test launcher uses -wait -nosplash -nodesktop -singleCompThread, an isolated -sd, and a process-scoped MATLAB_PREFDIR. No global preferences are changed. No Git repository exists in the target toolbox; review uses pre-edit copies, patches and SHA256 records. No raw/demo data or workspace business file is modified.

Status: completed. All remaining executable checks passed in the existing licensed MATLAB session; the historical process stall itself was not reproduced.

## Findings and limits

1. The fresh isolated test process did not reach its entry marker. UI Automation exposed a License Manager Error -8 dialog (MATLAB license checkout failed, -8,523). This explains the new empty-log launch, not retrospectively the older process that had already executed Stages 4/5. No license file, key, HostID, system preference or activation setting was edited. The blocked test core was identified by its exact command line and stopped; the user's process remained open. The outer launcher ultimately returned 0 despite no test execution, so exit code alone is not an adequate success oracle.
2. The old legacy-path stall is not reproduced: the exact retained six-image synthetic dataset, fresh deterministic fixtures, and the original GUI-test-to-routing sequence all completed. No production path-resolution loop or reproducible registration-QC defect was found. The old terminated process has no captured stack/dump sufficient to assign its original stall a definite cause. Do not label the historical stall a license failure based on the new startup observation.
3. The existing MATLAB instance cached the pre-edit MIKey/test functions. A nominal pass before refreshing did not validate the newly added logs. A targeted `clear MIKey test_mikey_bids_spm_routing; rehash path` refreshed those functions without clearing the user workspace. The final rerun then emitted the new QC/grid/SPM-start messages and passed; only this final result is used for the final-source validation.
4. The old Code Analyzer gate checking only PARSE was incomplete for R2018a. Deliberately malformed temporary code produced SYNER/EOLPAR, and the native executable returned exit 0 even for that input. New runners assert the negative control and inspect native message IDs. All diagnostics are retained; a syntax pass does not mean a warning-free codebase. Existing warnings, including PC supplied by a legacy dynamic load, were left outside this scoped fix.

## Changes made directly in the toolbox

- MIKey.m: four English status statements before pre/post QC, grid QC and the Stage 6/7 SPM calls. They expose the current input paths and phase without changing geometry thresholds, processing choices, or GUI component code.
- tests/test_mikey_bids_spm_routing.m: fixed/restored RNG state, explicit legacy-path fallback assertions, COPY-ONLY fixture selection checks, and stage begin/completion/timing output.
- README.md: empty-log/checkout troubleshooting, loaded-function cache guidance, explicit legacy-routing invocation and native analysis caveats.
- Prior versions: docs/backups/20261016-legacy-routing/. Focused patch: validation/20261016-legacy-routing/CHANGES.patch. The cumulative patch and 221 source SHA256 entries were refreshed and verified.

## Execution and final evidence

The user enabled the existing instance's AutomationServer, reporting its previous state as logical 0. The local COM API was then used to execute the validation scripts in MATLAB R2018a (9.4.0.813654), with SPM12 at D:/Program Files/MATLAB/mytoolbox/spm12. Window capture timed out; no physical pointer-click test is claimed. No replacement MATLAB instance could execute tests because of the license error.

Final command executed through the local MATLAB API:

```matlab
clear MIKey test_mikey_bids_spm_routing;
rehash path;
run('K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main/docs/validation/20261016-legacy-routing/finish_in_session.m');
```

The PowerShell COM adapter and MATLAB validation scripts are saved beside the results. The retained fixture is copied before replay; SHA256 checks prove the original six images were unchanged. Native Code Analyzer checks root MIKey functions and the three relevant test files; a separate installed mlint.exe scan provides independent diagnostics. MATLAB 2018a MISS_HIT parsing passed the two changed business/test files and each new MATLAB runner after editing.

The deliberate blank-output failure printed in final-com-response.log is the expected failure-injection case in test_mikey_registration_dispatch. That test catches MIKey:RunFailed and verifies full-run stopping even with failFast=false; it is not an unhandled suite failure. COM Execute may return only that stderr text, so authoritative results are final-result.json, replay-result.json and the explicitly written final-progress.log.

### Final results after function-cache refresh

- Native Code Analyzer: PASS, 38 files and a malformed-code negative control.
- Exact retained stalled fixture: PASS in 2.755 s; all original image hashes unchanged.
- legacy_routing_without_breakpoints: PASS in 2.746 s.
- registration_dispatch_with_GUI: PASS in 17.944 s.
- legacy_routing_after_GUI: PASS in 4.980 s.
- Whole final validation: PASS in 33.809 s, without diagnostic breakpoints.
- Source GUI component block: byte-identical to the pre-edit version; existing figure handle/count assertions passed. See gui-preservation.json.
- Session restored: original working directory, path, diary, breakpoints and existing MIKey window preserved; automation interface explicitly returned to 0. Only original MATLAB process 16048 remained. See session-restoration.log.

SPM transform jobs in these routing/dispatch fixtures are COPY-ONLY; real SPM NIfTI I/O/QC is exercised, but this does not certify real-acquisition optimizer accuracy, whole-toolbox performance or full BIDS Validator compliance. No server experiment or commit was created.

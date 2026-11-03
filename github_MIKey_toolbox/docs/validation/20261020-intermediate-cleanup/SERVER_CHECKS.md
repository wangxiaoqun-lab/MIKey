# Server checks: intermediate cleanup

Status: NOT RUN. No local MATLAB, syntax checker, synthetic test, cleanup execution or server job was launched. No actual dataset files were deleted.

Use the exact source-snapshot.json after whole-folder upload. The original toolbox has no Git checkout, so no commit identifier exists. Target: MATLAB R2019b/Linux. SPM is not needed for the synthetic test.

## Server Bash command

~~~bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
mrun "addpath('scripts'); addpath('tests'); try, checkcode('scripts/MIKey_cleanup_guard.m'); checkcode('scripts/MIKey_cleanup_classify.m'); checkcode('scripts/MIKey_cleanup_inventory.m'); checkcode('scripts/MIKey_cleanup_keep.m'); checkcode('scripts/MIKey_cleanup_delete.m'); checkcode('scripts/MIKey_cleanup_dialog.m'); checkcode('MIKey.m'); test_mikey_cleanup; catch ME, disp(getReport(ME,'extended')); exit(1); end; exit(0)"
~~~

Expected marker: MIKEY_CLEANUP_SYNTHETIC_PASS. Record release, command, source snapshot, elapsed time, marker/exit code and full failures in the run report. This unexecuted test operates only on its own temporary synthetic tree. It covers all 17 classifications, desc-orig eligibility, protected raw/mask/unknown files, sidecar pairing, Step 12 marker invalidation, confirmation gating, traversal/wildcard rejection, stale inventories, fixture deletion and audit output.

## GUI acceptance: use a disposable BIDS copy

1. Open MIKey normally. Existing controls must keep their positions; the new English Clean Intermediate Files button is beside the bottom configuration controls.
2. The cleanup scope must explicitly identify derivatives/MIKey and all subjects/sessions/runs, independent of main GUI filters. Opening must keep every file. The inventory must expose paths, step, size and Keep checkbox. The second tab must explain Steps 1-17 outputs.
3. Unchecking a desc-orig NIfTI must also uncheck matching JSON/affine sidecars. Rechecking must retain the group. Masks and unknown files must resist unchecking. Raw BIDS files must not appear as deletion candidates.
4. Apply keep steps 12:17, inspect the actual file selection, then adjust individually. Shared tSNR/inter-subject variability must be labelled shared Steps 14-16. Main processing must refuse to start while cleanup is open, and cleanup must refuse during an active run.
5. Uncheck a canonical Step 12 image and a legacy image in turn. Its run completion marker advancedRegressionResults.mat must become unchecked; another run's marker must stay checked.
6. Preview must require acknowledgement that other jobs stopped, show every deletion path/count/size and state permanent deletion. Cancel/close before final confirmation must change no files. Closing cleanup/the main window before confirmation must cancel its pending review without deletion.
7. Confirm a small synthetic selection. Only the reviewed files and displayed cache invalidations must disappear. Raw acquisitions, masks, retained outputs and logs must remain. Check logs/cleanup-*.jsonl for reviewed/deleting/deleted/finished records and actual counts.
8. Create/change a file after the inventory opens. Confirmation must reject the stale view before any deletion. Reopen to rescan. Test an unwritable fixture: the first failure must stop remaining deletion and record partial outcomes; an error is not success.
9. On Linux, put symbolic links to an external file/directory inside the disposable derivative tree. They must be excluded and external targets preserved. Test Windows junctions separately if needed. Remove the disposable links manually after inspection.

## Limits

The acknowledgement does not detect or stop independent jobs. Stop those jobs yourself. Size/mtime checks protect against a stale view, not simultaneous filesystem writers. Deletion is permanent, without recycle bin or backup; directories are not removed. Unknown outputs remain protected until supported naming rules exist. Deleting prerequisites may prevent subsequent steps/reruns. No processing quality or regression output has been verified by these unexecuted checks.

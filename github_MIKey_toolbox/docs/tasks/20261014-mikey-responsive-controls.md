# Responsive Pause/Stop during Stage 1

Date: 2026-10-14. User reported Pause/Stop not responding during Stage 1.

Implemented directly in K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main. Original English GUI layout is preserved. Backup: ../backups/20261014-responsive-controls/.

Cause addressed: Stage 1 previously read and wrote an entire 4D BOLD run without a checkpoint; the custom 4D writer's time-volume loop also did not yield. Button requests could not execute during that interval. The old tests only requested control after a whole file completed and did not cover this case. A live screenshot of the user's existing MATLAB process was unavailable, so the diagnosis is based on the code and synthetic execution, not a claim to have inspected that window.

Changes:
- Scale BOLD one volume at a time using the same voxel/affine operations and SPM types/scales. Check controls before/after reading and writing volumes; report throttled frame progress.
- Copy/decompress Stage 1 raw inputs in bounded Java NIO transfers with checkpoints, supporting .nii and .nii.gz. Existing callers without a checkpoint retain their old copy behavior.
- Publish only complete temporary images/transfers. Stop during a run removes its temporary NIfTI/MAT files and retains completed outputs. Streams close before deletion on Windows.
- Yield both drawnow and a short pause at throttled checkpoints. Explicitly set Interruptible/BusyAction where the installed MATLAB UI release supports them. Original synchronous entry points and task cleanup remain in place.

Validation environment: Windows, MATLAB R2018a, SPM12. Temporary synthetic data only; no bundled demo/research images were processed or modified. No Git repository exists at the target, and no Git initialization/commit/history operation was performed. This is not a server experiment.

Executed validation:
1. test_mikey_streaming_scaling passed actual NIfTI volume count, voxel equality, scaled geometry, raw byte preservation, chunked .nii/.nii.gz copying, interruption after the first volume and interruption during transfer. Both cancellations left no partial output. MIKEY_STREAMING_SCALING_PASS.
2. test_mikey_batch passed real-SPM stages 1/2/8/12/13 and expected corrupt-input error handling. MIKEY_SMOKE_PASS and MIKEY_RESPONSIVE_IO_PASS; outer launcher exit 0. Log: mikey-responsive-streaming-final.log.
3. test_mikey_run_controls passed Pause/Resume while the first BOLD run is incomplete, no new completed outputs while paused, Stop before that run is published, no selected Step 8 after Stop, restored controls and restarting in the same MATLAB session. MIKEY_RUN_CONTROLS_PASS and MIKEY_RESPONSIVE_GUI_PASS. These tests invoke the GUI function handles from an observer timer; they are not physical pointer-click/screenshot verification. The outer launcher returned 1 after all PASS markers, without a MATLAB error stack; this discrepancy remains recorded.
4. MISS_HIT MATLAB 2018a parsing passed all changed production and test files. MIKey.m retains its original GB18030/CRLF encoding.

Failed attempts and limits:
- The first transfer-cancellation test found a Windows cleanup ordering issue (file still open when deleting it). This was corrected by closing streams and removing the partial file in the same cleanup callback; final tests passed.
- A prototype placed the entire computation in a long single-shot timer callback. R2018a control tests showed that the observer could not execute during that computation. That design was rejected and completely removed; the corresponding failed logs are retained.
- Optional matlab.uitest button-event testing in nodesktop mode failed because MATLAB Connector was not running. It is not reported as passing. The first desktop retry could dispatch the Execute event, but the UI test framework rejects nested test gestures from within HG/timer callbacks. That harness failed and is not reported as passing. The optional test was corrected to use UITest only for execution-button events, with Pause/Resume/Stop function handles invoked from the observer timer.
- Windows computer-use skill was initialized, but list_apps timed out twice and again after a reset/reinitialization. The user's existing window was not captured or controlled. No alternative Windows UI automation was used to bypass that failure.
- Cooperative control still cannot preempt a running native SPM/MEX call. Reopen the MIKey window after updating code. If an older running callback is unresponsive, Ctrl+C in the MATLAB Command Window can interrupt it before reopening MIKey; exiting MATLAB is unnecessary.

Reproduction: addpath(toolboxRoot); addpath(fullfile(toolboxRoot,'tests')); test_mikey_streaming_scaling(spmPath); test_mikey_batch(spmPath); test_mikey_run_controls(spmPath). Optional event-level check in a desktop test session: test_mikey_run_controls(spmPath,true). Tests were launched in separate processes with matlab.exe -wait -nosplash -nodesktop (or -desktop for the optional event test), -logfile <log>, and try/catch exit(1)/exit(0) around the test commands.

Final desktop validation:
- In a fresh desktop MATLAB process, the corrected test dispatched Execute and Run Selected Steps through matlab.uitest button events. The observer timer invoked Pause/Resume/Stop handlers during the active execution-button callback. Assertions passed for a paused first run, resumed completion, mid-run Stop with no partial published image/no Step 8, restored controls and restarting. MIKEY_RESPONSIVE_UI_DESKTOP_PASS. This is stronger than a direct execution-function test, but still does not verify physical mouse clicks on the Pause/Resume/Stop buttons or the user's already-open window.
- The final source includes the original cross-volume orientation check before streaming. All root MIKey MATLAB files passed native Code Analyzer with no PARSE diagnostics: MIKEY_RESPONSIVE_CODE_ANALYZER_PASS.
- The final desktop outer launcher returned 1 despite all PASS markers and no MATLAB error stack. No claim of a clean GUI-launcher exit is made. Both successful assertions and this unresolved exit-status limitation are retained.
- No long-computation timer scheduler remains. Changes are limited to bounded I/O, checkpoints, control callback properties, tests and documentation. Review diff: ../validation/20261014-responsive-controls/CHANGES.patch. Source provenance: ../SOURCE_SHA256.json.

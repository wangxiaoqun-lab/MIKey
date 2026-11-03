# Server fieldmap runtime path and orphaned GUI state (2026-10-16)

User reports: Step 3 completes run-01, then MIKeyRunControl.checkpoint and MIKey_write_derivative_metadata cannot resolve; Pause/Stop and GUI close remain pending on the server.

Confirmed source defect: GUI launch did not pin its root, while Step 3 changed cwd immediately before reporting completion. A Current-Folder-only launch can therefore lose helper/class method resolution. Cleanup also depended on control.finish(), allowing an orphaned Active flag if class methods cannot resolve. The executeStage error path could mask the first error with a metadata error. Duplicate/partial server installs and cached classes remain possible; server which/pwd output requested asynchronously and not yet received.

Changed directly in original package: pin root on entry; pre-run runtime consistency check; direct-property cleanup and cwd restoration; rollback partial startup; independent executing-callback flag with idle-orphan recovery/close; absolute Step 3 cleanup paths; preserve original error with metadata failure as a cause. GUI component layout unchanged. All UI/README text remains English.

Validation: MATLAB-2018a parser and native R2018a Code Analyzer syntax checks passed; malformed negative control detected; original GB18030/CRLF preserved; component function compared with backup (only the new state field differs). No local MATLAB process is running, and prior fresh-process startup failed License Error -8. New GUI/headless regressions are supplied but NOT EXECUTED. No new real fieldmap estimation, no remote-server test, and no MRI data modifications in this turn.

Delivery: docs/releases/MIKey-source-20261016-runtime-path.zip, complete tracked source and critical documentation with verified archive CRC/source SHA-256. Server recovery/update/test commands: docs/SERVER_RUNTIME_RECOVERY.md. Backups: docs/backups/20261016-runtime-path. Focused/cumulative patches and source manifest refreshed.

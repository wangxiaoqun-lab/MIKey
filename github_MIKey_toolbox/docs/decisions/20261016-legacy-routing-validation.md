# Validate source actually loaded, separate startup from execution

Date: 2026-10-16.

Decision: finish the stalled legacy-path checks using the already licensed MATLAB instance after the user enables its local AutomationServer. Restore that interface to its reported prior state (off), preserve the user's window/session, and never patch licensing files to make a new process start. A checkout error before the entry marker is a startup failure, not evidence of a MIKey processing loop.

Use a malformed-code negative control for native Code Analyzer checks; R2018a syntax IDs include SYNER/EOLPAR, and executable exit status alone is insufficient. Persist explicit result JSON and stage checkpoints because both the MATLAB launcher and COM output can obscure actual test state. An expected stderr stack from failure injection does not negate the test's later assertions.

Refresh only edited MATLAB functions and the path cache before final validation. Confirm new runtime messages to prove the loaded source matches the disk version. Retain the old failed/incomplete records and append the successful follow-up rather than replacing the evidence.

No reproducible algorithmic legacy-path defect was found. The exact old data and original GUI-to-routing order both pass. Do not claim the old process's root cause is known without its stack. Improve phase/path diagnostics and fixture determinism, preserve the registration algorithm and GUI layout, and keep the scientific-validation limits explicit.

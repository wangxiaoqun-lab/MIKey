# Selectable FD and global mean-absolute CC

Status: completed, 2026-10-19.

User confirmed original Power L1 versus Euclidean L2, both on backward frame differences with rotation conversion. Added scoped fdMethod/fdRadius, raw-rp FD, frame-aligned CC, method-aware cache invalidation, GUI settings without moving existing controls, complete-run/definition checks, and global mean(abs(CC)) minimization in Step 11. Preserved existing regression basis and user settings. Updated single-file configuration and English documentation.

Formula/configuration/flow tests, real-SPM synthetic Steps 10-12, actual GUI callback/geometry checks and 17-file native/parser gates passed. Full report: ../../runs/20261019-fd-methods/RUN_REPORT.md. Backup and focused patch are in the matching dated backup/validation directories. No original/demo data or Git history changed.

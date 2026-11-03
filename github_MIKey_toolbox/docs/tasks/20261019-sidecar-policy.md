# Stop retaining redundant intermediate image MAT files

Status: completed, 2026-10-19.

Added selected-output snapshots and exact-affine sidecar compaction to the original stage dispatcher. Newly written/updated redundant SPM companions are removed; required transforms, unknown content, raw/unchanged data and analysis MAT files are preserved. No GUI or configuration changes. Existing FD functionality remains included.

Real-SPM affine/SHA-256 invariance and retention/cancellation tests passed twice; synthetic Steps 1/2/8/12/13 and configuration flow passed. Six-file native/parser gates passed with a detected malformed control. See ../../runs/20261019-sidecar-policy/RUN_REPORT.md. Original/demo data were not modified.

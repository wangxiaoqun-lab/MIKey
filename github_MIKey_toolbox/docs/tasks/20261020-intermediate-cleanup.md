# GUI intermediate cleanup

Request: a GUI button listing outputs from all 17 steps; checked files are kept, other generated files deleted. Clarification: desc-orig copies in derivatives may be removed, raw BIDS acquisitions stay untouched.

Implemented in the original folder: bottom button, separate English inventory and stage guide, per-file/bulk keep selection, exact deletion preview, guarded individual-file deletion and audit, protected masks/config/logs/unknown files, paired image sidecars and Step 12 completion invalidation. Existing processing controls are unmoved.

Pending: server syntax checks, synthetic fixture test and GUI acceptance. No local tests or actual cleanup ran.

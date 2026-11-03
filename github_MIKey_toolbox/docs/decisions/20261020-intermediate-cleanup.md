# Cleanup scope and retained-file selection

Date: 2026-10-20

User authorization explicitly covers desc-orig duplicate images within derivatives/MIKey, while keeping raw BIDS acquisition folders. The inventory covers the full derivative tree, independently of run-selection filters, and says so. All files start kept; only recognized generated outputs are eligible. Hand-drawn masks, configurations/source scripts, dataset metadata, logs and unknown files are protected; redirected paths are excluded. Full paths/count/size are reviewed before permanent deletion.

Paired image/JSON/affine files share selection. Deleting a Step 12 image also clears its run completion MAT. Shared Step 14-16 outputs are identified. Analytical MAT results are not assumed unnecessary, and missing prerequisites may require rerunning stages.

No recursive directory deletion or automatic dataset cleanup occurs. Independent server jobs must be stopped by the operator; no cross-process lock is claimed. Source snapshot replaces an unavailable Git commit. Original processing GUI positions remain unchanged.

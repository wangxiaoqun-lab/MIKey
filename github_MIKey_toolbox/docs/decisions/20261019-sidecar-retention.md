# Remove only provably redundant image companions

The user's request concerns unnecessary intermediate MAT files. SPM image companions can carry distinct per-volume affines that one NIfTI header cannot encode, while PC/CC/strategy matrices are downstream inputs. Blanket suppression would change geometry or break processing.

Decision: compact only pairs created/updated by the current successful processing stage, only inside canonical MIKey derivative paths, and only when the MAT has one numeric mat array consisting of exact header duplicates or all-zero SPM fallback matrices. Preserve nonidentical transforms and all unknown content. Do not resample or modify images and do not clean old unchanged or raw files. Check cancellation during scans and between pairs. Keep analysis MAT files and run records. Validate exact per-volume affine and image-file hash invariance with real SPM.

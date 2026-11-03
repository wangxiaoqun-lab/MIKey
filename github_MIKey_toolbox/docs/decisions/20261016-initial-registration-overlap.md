# Reject disjoint registration initialization (2026-10-16)

Context: real SPM12 processing of the original demo geometry completed Step 6 estimation/reslicing but produced an empty anatomical candidate. Existing post QC correctly stopped the workflow and retained the candidate. Initial physical sizes/orientation were compatible, while the centers were 0.929 larger brain spans apart and both directional foreground coverages were zero. The previous one-span center limit admitted this unsafe initialization.

Decision: in both Steps 6 and 7 pre QC, additionally measure directional world-space foreground coverage. Reject when BOTH coverages are <0.01 AND center separation is >0.5 larger brain spans. Do not recenter, rescale or reorient production input headers automatically. Keep the existing one-span distance, size, orientation and final-quality checks.

Why combined: a center threshold alone would reject some overlapping, potentially recoverable offsets. Requiring disjoint support as well targets the observed failure without imposing a general half-span limit. Focused MATLAB tests reject a short-axis nonoverlapping 20-unit offset and permit an equally large long-axis overlapping offset. Valid storage flips, axis permutations and resolutions remain supported.

Limits: foreground masks are derived from intensity heuristics and coarse samples. Cropped/unusual images can be rejected; local and left/right errors can escape these checks. A pass remains a safety screen, not scientific certification. Users must inspect their inputs/outputs and deliberately correct geometry if needed.

Validation uses a separate C:/MIKeyRealSPM/20261016-958dc7c6 demo copy. Explicit test-only center initialization is recorded separately and never applied to the original demo or built into MIKey. Original GUI source/layout is unchanged in this task.

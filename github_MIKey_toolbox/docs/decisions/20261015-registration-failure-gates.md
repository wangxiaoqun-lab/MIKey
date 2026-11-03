# Stop the pipeline on unsafe registration

Date: 2026-10-15.

User requirement: detect Stage 6/7 registration failures caused by inconsistent scale, orientation or distant centers; stop and explain the failure.

Decision: add mandatory pre/post safety gates to both GUI and script dispatch, leaving the existing SPM estimation options unchanged. Evaluate foreground geometry in world coordinates rather than interpreting affine determinant sign as an error. Compare PCA extents/centers and reliable long-axis orientation before estimation; evaluate bidirectional physical-space foreground coverage, extent/center/orientation and output grids/counts afterward. Keep NMI as a diagnostic because multimodal NMI has no universal success cutoff. JSON records retain all limits and measurements.

Use stage-specific thresholds: Stage 6 compares functional/anatomical support; Stage 7 compares normalized support against the actual selected template. These heuristics are deliberately documented and can false-reject difficult data. They cannot guarantee detection of left/right mirroring or subtle local failures. Do not silently repair scale, origins or orientation: changing an affine without knowing acquisition conventions can produce plausible but incorrect results.

An estimator error, failed gate or failed report write stops the full selected run, even if script failFast=false. Cached outputs are checked before reuse. Stage 6 estimates on a private copy and retains failed anatomical candidates where possible; Stage 7 native candidates remain for inspection. Only validated candidates receive final canonical paths. No existing failed cached result is automatically deleted.

Primary references: [SPM coregistration tutorial](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri_preprocessing/coregistration/) and [SPM spatial preprocessing documentation](https://www.fil.ion.ucl.ac.uk/spm/doc/manual/spatial.htm). These support multimodal registration and inspection practice; the automatic thresholds here are MIKey implementation choices, not SPM-certified thresholds.

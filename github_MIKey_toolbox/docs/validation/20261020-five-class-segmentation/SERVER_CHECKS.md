# Step 17 five-class segmentation: server validation

Status: source changes implemented; execution pending. No local MATLAB, syntax checker, tests, GUI or SPM estimates were run. Local work was source comparison and read-only NIfTI header inspection.

## Original workflow and supplied helper

Reference: K:/AD_mice_MRI/Main2_AD_mice_MRI_1st.m, lines 1566-1610 (flag_stage 21). The originally referenced UN_get_segment_batch_struct was initially missing from that old code directory. The user then supplied its original version in the toolbox scripts folder; that supplied function is preserved without edits.

- Masked scaled T2 estimates old normalization; both masked and unmasked scaled T2 are resampled.
- The original old-normalization helper's interpolation 2, wrap [0 0 0], bounding box [-112.1098 -83.4413 -143.9985;113.8902 74.5587 152.0015], template-derived voxel sizes, preserve 0 and estimation settings are retained. Output working prefix n is followed by BIDS publication. SPM's display-window call is omitted for headless operation.
- Segmentation source is normalized unmasked T2, not the masked image.
- AMCP_TPM.nii volumes 1-5 are GM, WM, CSF, OT, AIR. Read-only source inspection found a 114x80x38x5 float NIfTI header; probabilities are not ROI integer labels.
- Supplied helper: ngaus [1 1 2 3 4], native [1 1] and warped [1 1] for all five classes, channel.write [1 1], biasreg .001, biasfwhm 60, mrf 1, cleanup 2, reg [0 .001 .5 .05 .2], affreg subj, fwhm 0, samp 1, warp.write [0 1].
- Only GM/WM/CSF mwc1-3 are smoothed. User-requested segSmoothFWHM replaces fixed [6 6 6], with that value as the default; Step 17 GUI field, scoped validation, config save/load/export and batch mapping are synchronized.

The user has deleted old three-class results and will not use them. New Step 17 does not call oldseg, require AMCP_GM/WM/CSF images, consume old three-class maps or use their existence to skip. The original source helper and original Main script were not modified by the agent.

## Focused server checks

Start fresh server MATLAB and establish the migrated root/scripts paths (old root-level helpers must be archived first per docs/CODE_LAYOUT.md):

```matlab
toolboxRoot='/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main';
spmPath='/newdatc/home/wanglab41/AD_mice_MRI/zyj_MRI_code/SPM';
addpath(toolboxRoot);addpath(fullfile(toolboxRoot,'scripts'));MIKey_paths();
addpath(spmPath);addpath(fullfile(toolboxRoot,'tests'));
test_mikey_config_scopes
test_mikey_config_export
test_mikey_tissue_segmentation(spmPath)
```

Expected routing marker: MIKEY_TISSUE_SEGMENTATION_ROUTING_PASS. This authored test uses real SPM NIfTI I/O with a COPY-ONLY spm_jobman fixture in an isolated temporary folder. It checks source selection, five prior channels, original outputs/parameters, FWHM propagation, full output naming, cache reuse/change invalidation, failed AIR-output detection without a completion marker, active/inactive parameter validation, export round trips and unmasked/smoothing metadata. The fake estimates do not establish true segmentation, normalization, smoothing accuracy or scientific quality. No test has been executed locally.

On a GUI-capable server node, run test_mikey_ui_layout and manually confirm Step 17 FWHM value/load/save/export (including loading a config exported while Step 17 was inactive), then execute an intended real Step 17 run. Only the new FWHM label/field/help were added next to the existing Step 17 button; existing control positions remain.

## Actual SPM run

Edit only the chosen config function, for example an existing GUI-exported config:

```matlab
cfg.steps = 17;
cfg.segSmoothFWHM = [6 6 6]; % choose desired finite nonnegative image-space values
```

In the same file, keep the intended subject/session filters and server paths. Scalar FWHM expands to three axes. Units are the enlarged image-space mm used by original processing. Then use the same generic entry:

```matlab
addpath(fullfile(toolboxRoot,'examples'));
report=run_mikey('examples/mikey_config_sub001_14.m');
```

The filename is an example selected config; its contents determine subject/steps, not the filename suffix. Do not add a second parameter block in run_mikey. Existing mrun and local multi-config commands remain available. This real run has not been performed by the agent.

Review GM/WM/CSF/OT/AIR c/rc/wc/mwc results, normalized unmasked T2 and overlay quality. Review only smoothed modulated GM/WM/CSF as the original VBM-style outputs. New results use label-* / desc-fiveClass* / probseg or statmap names in the selected anat derivatives; file existence alone does not establish correct tissue assignment. Inspect the GM probability JSON completion/contract record, smoothed-map FWHM sidecars and MIKey run report. The two SPM transform/model MAT files are retained; a new custom MAT result cache is not created.

Completion is written only after the expected files exist; input/helper hashes and FWHM must match to reuse. Changed/partial results recompute. Renamed image/MAT affine pairs are preserved, and a conflicting stale sidecar fails explicitly rather than silently overriding geometry. No broad data deletion is performed. Registration/segmentation scientific quality and compute performance remain for actual server validation. Original folder has no Git checkout; source-snapshot.json identifies this revision instead of a commit.

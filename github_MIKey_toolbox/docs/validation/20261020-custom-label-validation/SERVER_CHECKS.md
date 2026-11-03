# Server validation: Custom ROI/network labels

Status: prepared only; no local MATLAB, syntax checker, tests or jobs were run.

After uploading the complete original toolbox folder, close the old MIKey window and open MIKey again so its callbacks use the new source. In an idle server MATLAB session with real SPM already on the path:

```matlab
cd('/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main');
addpath(pwd); addpath(fullfile(pwd,'scripts')); addpath(fullfile(pwd,'tests'));
which MIKey -all
which MIKey_read_label -all
test_mikey_custom_labels
```

Expected success marker: MIKEY_CUSTOM_LABELS_PASS. The test reads all bundled label images with real SPM, checks sparse/signed IDs, hand-calculated ROI means, compressed inputs, strict rejection of fractional values (including small deviations), empty/nonfinite images, mismatched affine/dimensions and prior/network overlap errors. Synthetic files are confined to a temporary folder. It does not process subject data or prove scientific validity.

GUI checks:

1. Step 13: choose Custom and select share_temp/Label_Mouse_296_v38.nii, then repeat with the other bundled Label_Mouse_*_v38.nii files. The chooser must report actual present IDs, without requiring 1:n. Select the NIfTI file, not the folder or XLSX.
2. Step 14: Use Custom -> Network Prior selects share_temp/AMCP_temp/AMCP_428prior_11net.nii; ROI Label Atlas selects share_temp/Label_Mouse_428_v38.nii. Repeat ROI selection with 296/592 and an intentionally suitable network prior. Acceptance of a file does not establish scientific appropriateness of that pairing.
3. Run Step 13 using existing Step 12 outputs for one selected subject/run/strategy. Inspect the FC result: size(pearson_corr_z) must equal [numel(roi_ids),numel(roi_ids)], and roi_ids contains sorted original nonzero IDs. Legacy unmapped FC caches are recomputed. Custom FC names now include the atlas filename stem.
4. Run Step 14 using existing Step 12 outputs; test both individual and concatenated mode. Labels and networks must match the actual analysis mask/BOLD voxel grid. Invalid grid or no label overlap must produce a specific English error.

Steps 1-12 do not need to be rerun for this label-selection correction. Keep this source-snapshot.json alongside server logs, MATLAB/SPM versions and the exact configuration. There is no Git checkout in this original delivery folder, so the source snapshot identifies the revision instead of a commit.

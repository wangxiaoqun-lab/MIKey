# Template affine alignment and AMCP derivative names

Date: 2026-10-20

Completed the explicit request to assign all share_temp spatial images the affine of G:/AMCP_dataset_BIDS/derivatives/template/tpl-Mousev38_T2w.nii. All 16 NIfTI images have dimensions 114x80x38; AMCP_TPM has 5 volumes. Six float fields were changed: qoffset x/y/z and srow x/y/z translations. Direction, spacing, dimensions, voxel arrays and non-image label tables were preserved. Per-image before/after header records and payload hashes are in the validation directory. No full-image backups were created.

Step 17 previously used a fixed old-origin bounding box; it now computes the bounding box from the current template's voxel corners. Its translated-grid routing fixture was updated. All other original fitting options and the GUI layout remain unchanged. MATLAB execution/syntax tests were not run locally at the user's request.

The preceding database naming task also completed: 212 subjects, 848 preprocessed BOLD images renamed to space-template_desc-Regressedpc_bold.nii.gz, 2968 anat/func files relocated to derivatives/MIKey, 1697 JSON documents updated and 2120 BIDS references resolved. Original BOLD headers were not synchronized to the subsequently shifted toolbox templates. Joint spatial compatibility is therefore explicitly false; no unrequested BOLD/header/model adjustment was made.


## Superseded origin

The subsequent owner request restored the 16 toolbox headers and moved the database shared T2w header to the exact existing BOLD affine. See docs/validation/20261020-template-affine-bold/verification.json for current state. Earlier mismatch statements above describe the historical state.

# Modality-specific masks and compressed raw input

Date: 2026-10-12. User scope: separate functional/anatomical mask names, both .nii and .nii.gz for masks and raw BOLD/T2w/fieldmap images.

Implemented:
- Functional masks: `*_desc-boldbrain_mask.nii[.gz]`; anatomy masks: `*_desc-anatbrain_mask.nii[.gz]`. Steps 2 and 9 share functional-mask selection. GUI and batch share geometry/binary validation.
- Prefer modality-specific derivative masks, then corresponding raw-directory masks, then legacy derivative `*brainmask.nii[.gz]`. More than one distinct candidate is an explicit error; never use the other modality's mask.
- Raw input listing normalizes logical names to .nii while retaining the actual sourceName. Matching .nii/.nii.gz pairs count once and prefer .nii. Session selection and shared anatomy recognize compressed inputs.
- Step 1 decompresses input copies for SPM and preserves original files. Results remain .nii. Mask decompression uses isolated temporary directories; cleanup verifies resolved targets remain inside MATLAB tempdir. Dry run does not unpack images or create derivatives.
- Updated the existing GUI mask-help text without changing layout. README is English and documents format handling, naming, paths and troubleshooting.

Validation uses synthetic data, never user images. `test_mikey_compressed_inputs` covers compressed BOLD/shared T2w, mixed-format four-component fieldmap scaling, selected runs, distinct mask values, both mask formats, actual GUI callback masking, Step 9 PCs, compressed-source byte preservation, duplicate-format preference, ambiguity errors and affine mismatch. `test_mikey_batch` checks legacy .nii and *brainmask.nii execution. Additional GUI/diagnostic and Code Analyzer checks are recorded in `../validation/20261012/mikey-nifti-mask-final.log`.

No server job or scientific validation of acquired images was performed. The target has no Git repository; no history or commits were created. Prior main source/preflight/stage-check files are saved in `../backups/20261012-nifti-mask-inputs/`.

Validation results:
- `mikey-compressed-inputs.log`: MIKEY_COMPRESSED_INPUTS_PASS.
- `mikey-nifti-mask-final.log`: repeated compressed test passed, including GUI handling of gzip-only anatomical/functional masks. The following legacy test in the same process crashed natively in a MEX call during Step 1; the overall combined suite did NOT pass. Root cause is undetermined.
- `mikey-legacy-nifti-isolated.log`: fresh-process legacy test passed Steps 1/2/8/12/13 and its expected failure cases (MIKEY_SMOKE_PASS, MIKEY_LEGACY_NIFTI_ISOLATED_PASS). The native crash did not recur in this isolated run.
- MISS_HIT MATLAB 2018a parsing passed all eleven updated production MATLAB files.

Final GUI/Code Analyzer result: `mikey-nifti-mask-ui-check.log` passed Step 2/3 diagnostics, GUI filter mapping, UI geometry/PC callbacks and root MATLAB Code Analyzer parsing (MIKEY_NIFTI_MASK_UI_CHECK_PASS). Requested implementation is complete; user acquisition testing remains independent of these synthetic checks.

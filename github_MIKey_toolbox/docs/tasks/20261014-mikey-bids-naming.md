# BIDS derivative image naming

Date: 2026-10-14. Status: implemented in the original MIKey package; targeted synthetic checks passed with limitations below.

Requested behavior: use the appropriate imaging suffix at the end of derivative image names, including `_bold` for BOLD images. Preserve the existing English GUI and its layout.

Changes:
- One naming helper places processing/space entities before the imaging suffix. BOLD, T2w, fieldmap components, mean BOLD references, masks and parcellations retain the appropriate data type. Repeated desc labels are combined, preserving source distinctions.
- All relevant producer/consumer paths, stage prerequisites, cache checks, native SPM prefixes, 4D scan expansion and motion-parameter lookup were updated together. Newly produced images use canonical names; input lookup also accepts exact legacy paths. Existing images are not renamed/deleted.
- Registered anatomical T2w outputs are stored in anat; coregistration identifies the BOLD reference space. Parcellations end in dseg. Existing modulated tissue-density calculations are not relabeled as probability maps.
- A derivative dataset_description.json and missing JSON sidecars are written after a stage, including completed outputs when a stage is interrupted. Existing metadata is preserved. Raw ancestry, applicable timing/skull-stripping information and spatial references are recorded. JSON uses UTF-8 and file URIs use ASCII encoding.
- README documents the naming contract and compatibility. Backups: ../backups/20261014-bids-naming/.

Validation environment: Windows, MATLAB R2018a, SPM12 at D:/Program Files/MATLAB/mytoolbox/spm12. Tests use temporary synthetic fixtures; raw/demo research images were not processed or modified.

Validation and failures:
1. test_mikey_batch used real SPM image I/O and processing for stages 1/2/8/12/13. Output/data/affine/mask/regression/FC assertions passed, including expected invalid-input failure handling. MIKEY_SMOKE_PASS and MIKEY_BIDS_NAMING_SMOKE_PASS; launcher exit 0. Log: mikey-bids-names-smoke.log.
2. test_mikey_bids_names checked suffixes, idempotence, source desc specificity, legacy fallback, canonical preference, motion files, dataset metadata and sidecars. The final isolated metadata run after UTF-8/URI edits passed MIKEY_BIDS_METADATA_FINAL_PASS, launcher exit 0. Log: mikey-bids-metadata-final.log.
3. test_mikey_bids_spm_routing exercised actual MIKey dispatch for 4/5/6/7 with real NIfTI I/O but COPY-ONLY SPM transformations, checking native prefix handling and subsequent input lookup. These tests do not validate slice timing, motion correction or registration algorithms. The stub is a non-executable .fixture file; the test stages it only in its temporary directory, restores the path and checks the real spm_jobman is selected afterward. The initial routing fixture omitted TR metadata and failed; adding valid synthetic timing metadata fixed that fixture. Final routing assertions and root MATLAB Code Analyzer passed with MIKEY_BIDS_NAMING_LAST_CHECK_PASS, launcher exit 0.
4. Actual compressed-input stages 1/2/9 passed in mikey-bids-naming-final-validation.log, including .nii.gz modality masks and byte preservation of raw sources. The same combined run later had a native MATLAB access violation during GUI diagnostics. That combined suite FAILED and is not counted as a full-suite pass; the native crash report is retained if available. Root cause is unresolved.
5. A fresh process passed naming/routing, fieldmap and mask diagnostics, and GUI layout assertions (MIKEY_BIDS_FINAL_ISOLATED_PASS). The outer launcher returned 1 despite all PASS markers and no MATLAB error stack. This exit-status discrepancy remains unresolved. Log: mikey-bids-final-isolated.log.
6. MISS_HIT MATLAB 2018a parsing passed changed production helpers and MIKey.m (GB18030 encoding); MATLAB Code Analyzer found no root PARSE errors. Existing tests were adjusted for the new names; only tests listed above are claimed as executed for this change.

Reproduction: addpath(toolboxRoot); addpath(fullfile(toolboxRoot,'tests')); addpath(spmRoot); spm('defaults','fmri'); spm_jobman('initcfg'); then run test_mikey_bids_names, test_mikey_bids_spm_routing or test_mikey_batch as appropriate in separate fresh MATLAB processes. Launches used matlab.exe -wait -nosplash -nodesktop -logfile <log> -r "try, <test calls>; catch ME, disp(getReport(ME,'extended')); exit(1); end; exit(0);".

Limits: no complete official BIDS Validator run, no real-acquisition scientific validation, and no server experiment. Custom statistic/density maps, MAT/FIG caches and native work products remain MIKey-specific auxiliary outputs; suffix cleanup does not certify every file as a standardized BIDS derivative. No Git repository exists in this target folder; no initialization, commit or history change was made. Source hashes and a cumulative review patch are supplied instead of a commit.

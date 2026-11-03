# MIKey - Mouse Image Key Toolbox

MIKey provides a MATLAB/SPM12 mouse fMRI workflow with 17 processing steps. Open the original three-column GUI with `MIKey`, or run its processing functions without interactive dialogs using `MIKey_run(config)`.

## Installation and MATLAB Set Path

Use licensed MATLAB and SPM12. The current local validation environment is MATLAB R2018a with SPM12. Selected steps also require Statistics and Machine Learning Toolbox and Image Processing Toolbox. Parallel clustering is optional and requires Parallel Computing Toolbox when enabled.

In MATLAB, choose **Home > Set Path > Add Folder** and add the MIKey root, its `scripts` folder, and the SPM12 root. Add the SPM root only; do not recursively add all SPM subfolders. Check for conflicting installations with `which ... -all`.

```matlab
toolboxRoot = 'K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main';
spmPath = 'D:/Program Files/MATLAB/mytoolbox/spm12';
addpath(toolboxRoot);
environment = MIKey_setup(spmPath);
which MIKey -all
which spm -all
which Matrix_Filter -all
which spm_write_vol_4D -all
ver
```

`MIKey_setup` adds MIKey and its processing helpers and initializes SPM for noninteractive fMRI jobs. To retain paths in desktop MATLAB, use `savepath` or add these commands to your own `startup.m`. Every compute-node job must establish its own paths. Install the SPM MEX files appropriate for the compute-node operating system.

For interactive use:

```matlab
spm_get_defaults('cmdline', false);
MIKey
```

Select the BIDS working directory and configure Template, Code Path, Subject Filter, Ses, Task, Run, Min Time Points (N), and Steps. **Save Config** writes the GUI parameters; **Load Config** accepts current and legacy nested configuration MAT files. Copy the complete updated toolbox to a server, including its helper files. Replace Windows paths with server paths before running a saved configuration there.

## Server updates and recovery from stale GUI state

Launch MIKey with its **root on the MATLAB path**, not only as the Current Folder. Current MIKey pins its own root on entry, checks key helper/class definitions before GUI processing, restores the launch directory after a job, and clears running state without calling class cleanup methods. Copy the complete source package to the server, including `MIKeyRunControl.m`, `MIKey_check_runtime.m` and `MIKey_write_derivative_metadata.m`. Restart MATLAB after replacing class files; an already open GUI can retain old definitions.

A `Completed fieldmap correction` message followed by an undefined `checkpoint` method and metadata function can result from losing the MIKey root after a working-directory change. It does not establish that the corrected image itself is valid or invalid. Check the output image and frame count before reuse. Metadata failures no longer replace the original processing exception.

If Stop keeps reporting a request after an error, first press **Ctrl+C** and wait for MATLAB's `>>` prompt. Then close only MIKey windows directly, bypassing their stale CloseRequestFcn:

```matlab
delete(findall(groot,'Type','figure','Name','MIKey - Mouse Image Key Toolbox'));
```

Do not issue this recovery command while an actual processing callback is still running. An active native SPM/MEX call must return before cooperative Pause/Stop can run. See [server update, diagnostics and smoke tests](docs/SERVER_RUNTIME_RECOVERY.md). No input or derivative files need to be deleted for this path/state repair.

## Input layout and supported formats

Both `.nii` and `.nii.gz` are supported for raw BOLD, T2w and fieldmap inputs and for subject brain masks. Compressed images are decompressed temporarily for SPM; the compressed source is preserved. Processing derivatives use `.nii`. When the same logical image exists as both `.nii` and `.nii.gz`, MIKey counts it once and uses `.nii`.

```text
BIDS_work/
  sub-001/
    anat/sub-001_T2w.nii.gz
    func/sub-001_task-rest_run-01_bold.nii.gz
    func/sub-001_task-rest_run-01_bold.json
    fmap/sub-001_magnitude1.nii.gz
    fmap/sub-001_phase1.nii.gz
    fmap/sub-001_magnitude2.nii.gz
    fmap/sub-001_phase2.nii.gz
```

The same modalities can appear under `sub-001/ses-01/`. Derivatives preserve the subject/session hierarchy. A session without T2w can use subject-level anatomy. Subject directory names, filename subject identifiers and saved derivative directories should agree: `sub-01` and `sub-001` are distinct names. **Subject Filter matches raw directory names**, not derivative directory names.

This implementation uses BIDS naming conventions but is not a complete BIDS validator. T1w-only anatomy and other fieldmap representations require adaptation. JSON metadata inheritance is not implemented; provide a same-basename JSON for each BOLD run. Slice timing uses JSON `RepetitionTime` and `SliceTiming` when present; the configured TR/order/count are fallbacks. Final regression also uses the JSON TR when present.

### Independent subject, session, task and run selection

```matlab
cfg.subjectFilter = 'sub-001';
cfg.sessionFilter = '01,02';
cfg.taskFilter = 'rest';
cfg.runFilter = '01,03';
```

Session/task/run accept exact values, `*`/`?` patterns, and comma-separated alternatives. Entity prefixes such as `ses-01` are optional. `*` includes all supported values, including missing entities; `none` selects scans without that entity. Preserve zero padding: `01` does not match `1` or `010`. Selection dimensions combine with AND; alternatives within a dimension combine with OR. Task/run filters apply to BOLD scans. Anatomy and fieldmaps remain dependencies of the selected subject/session.

Group estimation and concatenation use the same selected scans. A nondefault session/task/run selection has its own group-results namespace. Inter-subject variability averages selected runs/sessions per biological subject before comparing subjects.

### Minimum BOLD time points

The top-row **Min Time Points (N)** field excludes BOLD runs whose temporal dimension is strictly less than N. A run with exactly N frames is retained. Default `0` disables this filter; set `6` or higher to exclude a five-frame topup acquisition from functional analysis.

```matlab
cfg.minTimepoints = 6;
```

The same filter applies to GUI/script execution, preprocessing, noise regression, FC, group estimation, inter-subject variability and concatenation. Anatomy and fieldmap dependencies are retained. Counts are read directly from `.nii` or gzip headers; filtering does not unpack or modify raw images. Logs report each excluded run with T and N, and preflight records `excludedBold`. Save/Load Config preserves the threshold. Changing N uses a separate group/concatenation namespace, so an earlier group strategy with another threshold is not reused.

### Pause, Resume and Stop

The top-row **Pause**, **Resume** and **Stop** buttons control the current GUI task. Parameters and other execution buttons are disabled while it runs, preventing overlapping tasks or selection changes. Pause waits at a checkpoint and Resume continues the same task. Stop leaves MATLAB open, retains completed outputs, restores controls and prevents subsequent files or selected steps from running. A new Run can then be started; existing completed outputs follow the usual skip rules.

Control is cooperative: file boundaries, regression/strategy loops and parcellation iterations check requests. Step 1 also checks between bounded copy/decompression chunks and each BOLD volume read/write, so a long run does not wait until the whole 4D image has finished. It writes to temporary files and publishes only complete images; Stop discards the current partial image while keeping completed outputs. A running native SPM/MEX call must return before its next checkpoint; these controls do not forcibly terminate that call. The status display distinguishes a requested pause/stop from task completion. Closing a running MIKey window requests Stop and closes the window after the task unwinds. Cluster/script jobs use the scheduler's cancellation mechanism rather than these GUI buttons. After updating the toolbox, close and reopen the MIKey window to load the new callbacks. If an older running callback remains unresponsive, use Ctrl+C in the MATLAB Command Window to interrupt it before reopening MIKey; MATLAB itself can stay open.

## Derivative image naming

New primary images use `<source-entities>[_space-<reference>]_desc-<processing>_<suffix>.nii`. The source imaging suffix is removed before processing entities are added, then the appropriate output suffix is appended. Examples:

| Output | Example |
|---|---|
| Scaled BOLD | `sub-001_task-rest_run-01_desc-scaled_bold.nii` |
| Masked BOLD | `sub-001_task-rest_run-01_desc-masked_bold.nii` |
| Smoothed BOLD | `sub-001_task-rest_run-01_space-template_desc-smoothed_bold.nii` |
| Regressed BOLD | `sub-001_task-rest_run-01_space-template_desc-Regressedpc_bold.nii` |
| Scaled T2w | `sub-001_desc-scaled_T2w.nii` |
| Scaled fieldmap magnitude | `sub-001_desc-scaled_magnitude1.nii` |
| Mean BOLD reference | `sub-001_task-rest_run-01_desc-mean_boldref.nii` |
| Individual parcellation | `sub-001_task-rest_run-01_space-template_desc-individualParcellation_dseg.nii` |

Coregistered/normalized anatomical images retain a T2w suffix and are stored in `anat`, including when their registration target is a BOLD run. The BOLD reference space is explicitly represented for coregistered T2w. Masks continue to end in `_mask`. Multiple desc components are combined into one alphanumeric label to avoid duplicate entities and collisions between raw and already-preprocessed source images.

GUI and script execution share the same naming and input lookup. Old names such as `..._bold_desc-scaled.nii` remain readable as inputs; new outputs always use the new name. Existing images are not automatically renamed or deleted. Native SPM temporary filenames are resolved from the actual chosen input, allowing mixed old/new inputs without guessing SPM prefixes.

The pipeline writes `derivatives/MIKey/dataset_description.json` with `DatasetType`, `GeneratedBy` and a raw-dataset link. New primary images receive JSON metadata, including skull-stripping state and relevant retained timing metadata. Raw ancestry is recorded separately in `MIKeyRawSources`; it is not incorrectly described as direct input at every processing stage. Template-space images identify their reference. Existing sidecars are preserved.

MAT/FIG analysis caches and native algorithm work products remain MIKey-specific. Statistic/density maps are custom auxiliary outputs, rather than tissue probabilities; the numerical algorithm is unchanged. Filename checks and synthetic execution tests are not a full BIDS Validator certification of every custom analysis file or of an input dataset.

Naming references: [BIDS Derivatives](https://bids-specification.readthedocs.io/en/stable/derivatives/introduction.html) and [imaging derivatives](https://bids-specification.readthedocs.io/en/stable/derivatives/imaging.html).

## Modality-specific brain masks

Step 2 applies an externally prepared mask; it does not create one. Put each mask in the corresponding scaled-image derivative directory:

```text
derivatives/MIKey/sub-001/func/sub-001_desc-boldbrain_mask.nii.gz
derivatives/MIKey/sub-001/anat/sub-001_desc-anatbrain_mask.nii.gz
```

Both filenames also work with `.nii`. For sessions, add `ses-01/` after the subject directory. Function images use `*_desc-boldbrain_mask`; anatomical images use `*_desc-anatbrain_mask`. Step 9 uses the same functional mask as Step 2.

Modality-specific masks in derivatives take precedence. If absent there, MIKey can read a modality-specific mask from the corresponding raw modality directory; it must still match the scaled image. Legacy derivative masks named `*brainmask.nii` or `.nii.gz` remain supported as a fallback. A `.nii`/`.nii.gz` pair counts as one mask. Multiple different candidates cause an explicit error rather than arbitrary selection.

Masks must be nonempty binary 0/1 3D images with dimensions and affine matching the corresponding **scaled** image. MIKey checks this in both GUI and script execution. It does not rescale a mask or infer its modality from image dimensions. One mask is used per subject/session/modality; run-specific masks are not automatically matched. If acquisition geometry differs between runs, prepare compatible input/masks before combining them.

## Script quick start

```matlab
addpath('/shared/software/MIKey');
cfg = MIKey_defaults();
cfg.spmPath = '/shared/software/spm12';
cfg.bidsPath = '/shared/project/BIDS_work';
cfg.subjectFilter = 'sub-*';
cfg.sessionFilter = '*';
cfg.taskFilter = '*';
cfg.runFilter = '*';
cfg.minTimepoints = 0; % Use 6 to exclude five-frame runs.
cfg.steps = 1;
cfg.voxelScaleFactor = 20;
cfg.dryRun = true;
report = MIKey_run(cfg);
cfg.dryRun = false;
report = MIKey_run(cfg);
```

Dry run checks configuration, dependencies, selected raw scans and required templates without creating derivatives or unpacking raw images. It does not verify all future intermediate files or registration quality. Runtime stage checks validate prerequisites after preceding stages have run.

```matlab
config = cfg;
save('/shared/project/config.mat', 'config');
report = MIKey_run('/shared/project/config.mat');
% A JSON configuration file is also accepted.
report = MIKey_run('/shared/project/config.json');
```

`MIKey_config` validates fields and values and supplies defaults. Unknown fields are rejected. Relative paths resolve against the calling MATLAB working directory; use absolute paths for cluster jobs. Steps accept numeric vectors or strings such as `'2,4:10'`, without evaluating MATLAB expressions. Execution preserves the supplied order and rejects duplicate steps.

See [examples/mikey_config_example.m](examples/mikey_config_example.m). Begin with Step 1, inspect the scaled images, prepare masks, and then continue. Do not run `1:17` blindly: manual preparation is required between Steps 1 and 2.

## Processing steps and prerequisites

| Step | Operation | Main prerequisites |
|---|---|---|
| 1 | Voxel Scaling | Raw BOLD/T2w/fieldmap; writes `_desc-scaled_bold.nii` / `_desc-scaled_T2w.nii`. Scaling changes the affine, not the voxel-array size. |
| 2 | Mask Data | Scaled images and modality-specific binary masks; writes `_desc-masked_bold.nii` / `_desc-masked_T2w.nii`. |
| 3 | Fieldmap Correction (optional) | Masked BOLD and scaled magnitude1/phase1/magnitude2/phase2 fieldmaps. |
| 4 | Slice Timing (optional) | Masked/fieldmap BOLD and acquisition timing metadata. |
| 5 | Realignment | Slice-timed, fieldmap-corrected or masked BOLD; writes realigned images and motion parameters. |
| 6 | Coregistration | Realigned BOLD and an unambiguous masked T2w. |
| 7 | Normalization | Step 6 and the default or custom normalization template. |
| 8 | Smoothing | Template-normalized BOLD. FWHM is in the scaled spatial units. |
| 9 | Non-brain Noise PCs Estimation | Scaled BOLD and its functional brain mask. |
| 10 | Noise Regression Strategy Estimation | Smoothed BOLD, PCs, motion parameters and template brain mask. |
| 11 | Optimal Noise Strategy | Selected runs' Step 10 estimates. |
| 12 | Final Noise Regression Strategy | Step 11 result, smoothed BOLD, PCs, motion parameters and template masks. |
| 13 | Region/Network FC | Selected Step 12 outputs and a label image. |
| 14 | Parcellation - Prior Label | Regressed BOLD, GMWM mask and network/ROI label images. |
| 15 | Parcellation - Clustering | Regressed BOLD, GMWM mask, group network and ROI count. |
| 16 | Parcellation - Voxel Mode | Regressed BOLD, GMWM mask, group network and downsample factor. |
| 17 | Tissue Segmentation | Scaled/masked T2w, normalization template and tissue priors. |

The existing fieldmap helper uses fixed echo times `[2.4 4.9]` ms, total readout time 23 ms and blip direction -1; confirm compatibility with your acquisition. These acquisition settings are not currently GUI parameters. Interpolation values in Steps 6/7 are 0 nearest neighbour, 1 trilinear, and 2-7 B-splines of the corresponding degree.

Typical staging: Step 1; prepare masks; Steps `[2 4 5 6 7 8 9 10]` (include 3 if appropriate); aggregate selected runs with 11; then `[12 13]` and optional parcellation/segmentation. Inspect registration and signal quality at each stage.

### PC strategy candidates

Step 10 defaults to candidate PC counts `0,20,40,...` up to the number available and `T-1`. Uncheck **Use default PC counts** to enter custom counts such as `0 5 10 20`, separated by spaces or commas.

```matlab
cfg.useDefaultPCStrategy = false;
cfg.customPCCounts = [0 5 10 20];
cfg.steps = [10 11 12];
```

Counts must be distinct nonnegative integers within each selected run's available range. Count 0 represents motion-only (`12rp`), alongside a separate no-regression baseline. Step 10 records actual counts and recomputes an estimate when its candidate list changes. Step 11 compares the intersection of candidates available across selected runs. Step 12 uses the chosen count. GUI ROI Num in Step 15 accepts one positive number (default 100); the script `clustROINums` interface retains support for multiple counts. K-means partitions the whole brain into N ROIs without guaranteeing equal ROI sizes.

### Group network templates

`share_temp/AMCP_temp` contains AMCP network templates, including 214/428/604/1184-ROI priors. These specific files are optional choices; users may supply their own valid group network.

```matlab
cfg.groupNetworkPath = '/shared/project/my_group_network.nii';
```

An explicit Group Network path takes precedence. Otherwise MIKey uses the custom network when selected, then the AMCP network corresponding to the Network dropdown. Step 14's custom prior uses both `networkCustomPath` and `labelCustomPath`. Network/label images must be suitable integer-label maps in the analysis space. Preflight requires only the selected template. The shipped templates and processing derivatives use uncompressed `.nii` paths.

## Configuration reference

`MIKey_defaults()` is the complete parameter source. All GUI controls map to these fields:

| Fields | Defaults / meaning |
|---|---|
| `bidsPath`, `spmPath` | Working BIDS directory; SPM root (or current MATLAB path). |
| `templatePath`, `codePath` | Toolbox `share_temp` and `scripts` folders. |
| `subjectFilter`, `sessionFilter`, `taskFilter`, `runFilter` | `sub-*`, `*`, `*`, `*`. |
| `steps` | `1`; explicitly choose subsequent steps. |
| `minTimepoints` | `0` disables filtering; exclude BOLD runs with fewer than N frames. |
| `voxelScaleFactor` | `20`; confirm spatial units against acquisition/templates. |
| `sliceTimingTR`, `sliceTimingNSlices`, `sliceTimingOrder` | `2`, `30`, `Auto-detect`; timing fallbacks. |
| `smoothFWHM`, `coregInterp`, `normInterp` | `[6 6 6]`, `2`, `2`. |
| `useDefaultTemplate`, `customTemplatePath` | `true`, empty. |
| `useDefaultPCStrategy`, `customPCCounts` | `true`, `[0 5 10 20]`. |
| `detrendFlag`, `filterFlag` | Both `true`. |
| `highFreq`, `lowFreq` | `0.1`, `0.01` Hz: upper/lower cutoff respectively. |
| `advRegressionPCOnly`, `advRegressionPCCSF`, `advRegressionPCGS`, `advRegressionPCCSFGS` | All `true`; requested output strategies. |
| `fcLabel`, `fcCustomPath` | `428`, empty; custom selection value is `Custom...`. |
| `parcNetwork`, `useCustomParc` | `428rois`, `false`. |
| `networkCustomPath`, `labelCustomPath`, `groupNetworkPath` | Empty; explicit user templates. |
| `clustROINums`, `voxelDownsampleFactor` | `100`, `2`. |
| `percentTop`, `maxIter`, `changeThr`, `confThr` | `0.8`, `30`, `0.001`, `2.5`. |
| `useTSNR`, `useInterSubjectVar`, `parcellationUseParallel` | All `false`. |
| `parcellationMode` | `individual` or `concatenated`; default `individual`. |
| `dryRun`, `failFast`, `strictWarnings` | `false`, `true`, `true`. |
| `logDir` | Empty: defaults to `derivatives/MIKey/logs`. |

Use `0 <= lowFreq < highFreq < 1/(2*TR)` for the actual acquisition TR. Defaults are not universal mouse-MRI acquisition settings. Several legacy processing stages skip existing outputs by filename without checking parameter provenance. Use a fresh working/output dataset after changing processing settings; Step 10 specifically checks its PC candidate list.

## Compute-node jobs

Edit [examples/submit_slurm.sh](examples/submit_slurm.sh) or [examples/submit_pbs.sh](examples/submit_pbs.sh), together with [examples/mikey_cluster_job.m](examples/mikey_cluster_job.m). Set absolute `MIKEY_ROOT` and `MIKEY_CONFIG`; optional overrides are `MIKEY_SUBJECT`, `MIKEY_STEPS`, `MIKEY_SESSION`, `MIKEY_TASK`, `MIKEY_RUN` and `MIKEY_MIN_TIMEPOINTS`.

For MATLAB R2019a or later:

```bash
matlab -batch "run('/shared/software/MIKey/examples/mikey_cluster_job.m')"
```

For R2018a, use the examples' `-nodisplay -nosplash -nodesktop -r` form with explicit `try/catch`, stack reporting and `exit(1)` on failure. Configure scheduler resources and licenses for your institution. Run per-subject preparation before a cohort-wide Step 11; then use the matching group selection for final regression. Concurrent jobs must not write the same subject/session outputs.

A real run saves effective configuration/environment/source hashes, `run.log` and `report.mat` in a unique run directory. A failed stage makes the run fail. `failFast=false` records failures and continues requested stages, but does not convert an unsuccessful run into success. Steps 6 and 7 are safety-critical exceptions: any failure in either step stops the selected pipeline even when failFast is false.

## Registration safety checks (Steps 6 and 7)

These checks run automatically in both the GUI and script interfaces, before estimation and before new results are published. Existing results are rechecked before being skipped. Step 6 compares masked T2w against realigned/mean BOLD; Step 7 compares coregistered T2w and normalized T2w/BOLD against the selected template. Missing or ambiguous inputs and estimator exceptions also stop the pipeline.

The checks validate finite, nonsingular affines, physical foreground size, center distance and gross long-axis orientation in SPM world coordinates. Different voxel resolutions, valid storage flips and axis permutations are allowed when their affines describe compatible physical geometry. The initial overlap gate rejects nearly disjoint foregrounds only when their centers also exceed half a larger brain span; an overlapping initial offset can still proceed to SPM. Step 6 also checks the cached mean BOLD grid. Post-registration checks evaluate bidirectional foreground coverage, residual center/axis/extent mismatch and blank or unreadable images. Normalized BOLD must retain the input volume count and share the T2w spatial grid. First, middle and last output frames are sampled for blank/corrupt data; this is not an exhaustive corruption scan of every voxel/frame.

The initial foreground is estimated on a bounded grid (up to 48 samples per axis), using the 2nd/98th intensity percentiles and an 8% range cutoff. Principal axes and robust foreground spans are computed in world space. NMI is recorded as a multimodal diagnostic; there is no universal NMI pass cutoff.

| Built-in check | Step 6 | Step 7 |
|---|---:|---:|
| Initial uniform physical-size mismatch | All principal-span ratios >2 or <0.5 | Same |
| Initial extreme extent mismatch | Any principal-span ratio >4 or <0.25 | Same |
| Initial center separation | >1 larger brain span | Same |
| Disjoint initial foregrounds | Both coverages <0.01 and centers >0.5 larger brain span | Same |
| Initial long-axis discrepancy | >75 degrees when both supports have eigenvalue anisotropy >=1.4 | Same |
| Minimum coverage in either direction | 0.20 | 0.25 |
| Minimum support overlap | 0.30 | 0.35 |
| Maximum final center separation | 0.45 larger brain span | 0.35 larger brain span |
| Maximum final long-axis discrepancy | 60 degrees when reliable | Same |
| Final principal-span ratio range | 1/1.8 to 1.8 | Same |
| BOLD/T2w grid tolerance | 0.001 voxel | 0.001 voxel |

Support overlap is the harmonic mean of the two directional foreground coverages; it is not a manually segmented brain Dice coefficient. These conservative heuristics screen gross geometry/registration failures, not every misregistration. Thresholds are centralized in MIKey_registration_qc.m and saved with each report. Partial fields of view, unusual contrast, severe pathology or a poor brain mask can cause a rejection that needs visual assessment. Left/right mistakes in nearly symmetric brains and subtle local misalignment can escape the checks. A pass is not a registration certificate; inspect overlays with [SPM Check Reg](https://www.fil.ion.ucl.ac.uk/spm/docs/tutorials/fmri_preprocessing/coregistration/).

On failure the GUI displays an English `Processing stopped` message with the step, files, likely causes and report path. The script exits as a failed run, including when failFast=false. Subsequent subjects/runs/selected steps are not processed. New failed candidates are not promoted to final derivative filenames; previously existing failed results are preserved for inspection and block reuse. A failed Step 6 candidate is copied to registration_qc/failed_candidates before its private workspace is cleaned; the JSON and error identify the review image. Step 7 native norm-prefixed candidates remain available at their reported paths until a later attempt overwrites them. Step 6 estimates on a private T2w copy so the masked anatomical input affine is not rewritten. No header is automatically recentered, rescaled or reoriented.

Reports are auxiliary JSON records in each selected functional derivative folder's `registration_qc/` directory. Pre/post reports contain reference/moving paths, affines, voxel sizes, foreground measurements, thresholds and reasons. Grid reports contain the input/output counts and grid-consistency result. In a batch job also read the first failed stage in run.log/report.mat. Correct the stated scale/origin/orientation/mask/template issue and deliberately regenerate or replace affected outputs before retrying; do not delete raw inputs to fix a derivative geometry problem. An old GUI window must be reopened after a code update.

## Troubleshooting

| Symptom | What to check |
|---|---|
| No matching scans / no files processed | Compare all four filters with raw directory/entity names. `sub-001` does not match a `sub-01` directory. Folder-selection counts are an inventory, not proof that current filters match. |
| Missing BOLD/T2w mask | Use the corresponding modality-specific mask in its `func`/`anat` derivative directory. Both `.nii` and `.nii.gz` work. |
| `MIKey:MaskGeometry` | Compare mask dimensions and affine with the scaled image; an original-space mask may be incompatible with voxel scaling. |
| `MIKey:MaskSelection` | Leave one unambiguous logical mask per modality/scope. A same-name compressed/uncompressed pair counts once. |
| `MIKey:RegistrationQC` / `MIKey:RegistrationFailed` | Read the registration_qc JSON and failed-stage log. Compare source/reference scaling, origin, orientation and masks in SPM Check Reg. Steps 6/7 stop even when failFast=false. |
| Step 3 missing masked BOLD | Complete Step 2 first. Four scaled fieldmap components are also required. |
| Missing SPM/helper function | Check `which <function> -all`, root/scripts paths and SPM root. |
| Missing `pca/strel/imerode/corr/kmeans` | Check `ver`, toolbox installation and license availability on the compute node. |
| `License checkout failed` | Verify license-server access from the compute node; MATLAB path changes do not resolve license access. |
| Empty test log / a waiting MATLAB launch | Check for a startup or license dialog before assuming a processing loop. A local attempt stopped at `License Manager Error -8` before entering the test. A launcher exit code alone does not prove test execution; require the test result/PASS marker. Use a working licensed MATLAB session or resolve the license configuration. |
| Changed code appears not to run | MATLAB can retain loaded functions/callbacks. Reopen MIKey after an update. For controlled script validation, refresh only the affected functions with `clear MIKey test_mikey_bids_spm_routing; rehash path`; do not clear the user workspace. |
| Configuration error | Check exact field spelling, allowed values, PC bounds and cutoff frequencies. |
| Missing template | Check the actually selected default/user image path. No fixed `final_network_428rois_12clusters.nii` is required. |
| Compression/read error | Confirm a valid, complete gzip/NIfTI input and sufficient temporary-disk space. Raw compressed inputs are not overwritten. |
| `MIKey:Prerequisite`, `ProcessingError`, `RunFailed` | Read the first error and full stack in the unique run's log/report, then resolve its stated missing input. |
| Windows SPM cannot write an existing directory | Shorten the output path; some SPM MEX operations encounter Windows path-length limits. |
| Scheduler killed the process / memory exhaustion | Inspect scheduler diagnostics; reduce scope or request sufficient memory. Concatenated runs increase memory demand. |
| Old outputs remain after a settings change | Some legacy stages skip existing filenames; use a fresh working dataset or deliberately regenerate affected outputs. |

For reproducibility, record the command, MATLAB/SPM versions, selection, configuration, first error/stack and source revision. Formal server experiments should run from an exact Git commit and record results in `runs/YYYYMMDD-experiment-name/RUN_REPORT.md`. This local target has not been initialized or committed to Git; source SHA-256 records are in `docs/SOURCE_SHA256.json`.

## Validation

Tests use synthetic images and do not process the bundled demonstration/research dataset. Run tests in a MATLAB environment with SPM and required toolboxes configured:

```matlab
addpath(fullfile(toolboxRoot,'tests'));
result = test_mikey_batch(spmPath);
compressed = test_mikey_compressed_inputs(spmPath);
test_mikey_fieldmap_diagnostics;
test_mikey_ui_layout;
threshold = test_mikey_timepoint_filter(spmPath);
controls = test_mikey_run_controls(spmPath);
test_mikey_streaming_scaling(spmPath);
test_mikey_registration_qc(spmPath);
test_mikey_registration_dispatch(spmPath);
test_mikey_bids_spm_routing(spmPath);
% Optional GUI callback stop-propagation check:
% test_mikey_registration_dispatch(spmPath, true);
% Optional: exercise Run/Execute through UITest in a desktop session
% Control requests are still invoked from timer callbacks in this test.
% test_mikey_run_controls(spmPath, true);
```

Additional tests cover configuration import, failure reports, subject/session/task/run selection, selected group/concatenation operations and custom PC strategies. See `docs/VALIDATION.md`, task records and `docs/validation/20261012/` logs. Small synthetic tests verify execution and routing; they do not establish scientific validity, real-acquisition registration quality, or performance on a cluster. Original files are preserved in `docs/backups/`.

The routing fixture uses COPY-ONLY SPM jobs with real NIfTI I/O; it does not estimate scientific registration quality. It fixes and restores its random state, verifies legacy input fallbacks, and prints a begin/completion marker and duration for each stage. Steps 6/7 also log the input paths before QC, grid checks and SPM estimation, so the last started operation is visible.

For automated R2018a Code Analyzer gates, inspect all `checkcode(...,'-id')` message IDs; syntax diagnostics include `SYNER` and `EOLPAR`, not just `PARSE`. Validate the gate with deliberately malformed temporary code. The completed legacy replay, GUI-to-legacy replay and 38-file native analysis are recorded in `docs/validation/20261016-legacy-routing/` and `docs/tasks/20261016-legacy-routing.md`.

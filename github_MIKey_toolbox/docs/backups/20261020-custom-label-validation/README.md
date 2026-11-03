# MIKey - Mouse Image Key Toolbox

MIKey provides a MATLAB/SPM12 mouse fMRI workflow with 17 processing steps. Open the original three-column GUI with `MIKey`, or run its processing functions without interactive dialogs using `MIKey_run(config)`.

## Updating the server copy

The original local `MIKey_toolbox_main` folder is the complete current toolbox. Upload this entire folder to the server for each update; no release ZIP or patch archive is required. Update while MATLAB is idle, then start a fresh MATLAB session. Keep parameters in one selected configuration function: `examples/mikey_config_example.m` by default, or the `.m` file exported from the GUI. `run_mikey` contains no editable processing parameters. Follow the two-stage workflow below: run Step 1, prepare masks manually, change only `cfg.steps` to `2:10`, and run the same general script again.

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

Select the BIDS working directory and configure Template, Code Path, Subject Filter, Ses, Task, Run, Min Time Points (N), and Steps. The green bottom-row **Save Config** button writes a MAT snapshot; **Load Config** accepts MAT/JSON snapshots and `.m` configuration functions, including legacy nested MAT files. **Export Config (.m)** writes all GUI settings as one editable MATLAB configuration function for `run_mikey`. Copy the complete updated toolbox to a server, including its helper files. Replace Windows paths with server paths before running a saved configuration there.

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

To process only specific subjects, enter `sub-001,sub-002` in the GUI **Subj Filter** field, or set `cfg.subjectFilter = 'sub-001,sub-002';` in `examples/mikey_config_example.m`. Use an ASCII comma; spaces around each entry are optional. The subjects are combined with OR, duplicates are processed once, and each name matches the full raw subject directory name. Single names and `sub-*`/`?` wildcard patterns remain supported; patterns can also be comma-separated. Keep the manual-mask boundary: run Step 1 for the selected subjects, prepare each subject's masks, then change only `cfg.steps` to `2:10` and rerun the same general script.

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

## Intermediate MAT files

After a successful image-producing step, MIKey checks image-paired SPM `.mat` files **created or updated during that step**. A paired file is omitted from the completed output when its only variable is a numeric `mat` array and every entry is either SPM's all-zero fallback or exactly the same affine as the NIfTI header. No image bytes, headers or voxel-to-world mappings are rewritten. This avoids retaining redundant transform copies at intermediate stages.

Different per-volume affines are retained, including small nonidentical differences. Unknown variables, unsupported/unreadable contents and files outside the selected MIKey derivatives are retained. Existing untouched pairs are not cleaned up by a skipped/reused step, and processing failures/cancellation skip this finalization. A stop during finalization is honored between files. Raw inputs are never cleaned. A log line reports redundant files removed and required/unclassified files retained when there are affected pairs.

Analysis MAT files remain because they are not duplicate images: `NBPCs.mat` supplies PCs to Steps 10/12; `regressionResults.mat` stores FD/DVARS/CC for Step 11; group/best-strategy MAT supplies Step 12; FC matrices, transform parameters and configuration/run reports retain analysis/provenance information. A `.nii` pathname can also cause SPM to read a required companion `.mat` implicitly. There is no directory-wide MAT deletion or resampling to force all files away.

## Modality-specific brain masks

Step 2 applies an externally prepared mask; it does not create one. Put each mask in the corresponding scaled-image derivative directory:

```text
derivatives/MIKey/sub-001/func/sub-001_desc-boldbrain_mask.nii.gz
derivatives/MIKey/sub-001/anat/sub-001_desc-anatbrain_mask.nii.gz
```

Both filenames also work with `.nii`. For sessions, add `ses-01/` after the subject directory. Function images use `*_desc-boldbrain_mask`; anatomical images use `*_desc-anatbrain_mask`. Step 9 uses the same functional mask as Step 2.

Modality-specific masks in derivatives take precedence. If absent there, MIKey can read a modality-specific mask from the corresponding raw modality directory; it must still match the scaled image. Legacy derivative masks named `*brainmask.nii` or `.nii.gz` remain supported as a fallback. A `.nii`/`.nii.gz` pair counts as one mask. Multiple different candidates cause an explicit error rather than arbitrary selection.

Masks must be nonempty binary 0/1 3D images with dimensions and affine matching the corresponding **scaled** image. MIKey checks this in both GUI and script execution. It does not rescale a mask or infer its modality from image dimensions. One mask is used per subject/session/modality; run-specific masks are not automatically matched. If acquisition geometry differs between runs, prepare compatible input/masks before combining them.

## Script quick start: two-stage server workflow

**Edit processing parameters only in [examples/mikey_config_example.m](examples/mikey_config_example.m). Run [examples/run_mikey.m](examples/run_mikey.m) for both stages.** The general entry reads that configuration function on each invocation; it has no second editable parameter block and needs no exported MAT/JSON configuration.

The commands below use `/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main` as the installed toolbox root. Replace it with your installation path if needed. Run MATLAB on an allocated compute node, or use the Slurm submission in [Compute-node jobs](#compute-node-jobs).

### 1. Configure and run Step 1

Open the only processing configuration file:

```bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
nano examples/mikey_config_example.m
```

Modify the existing assignments in that file; do not append duplicate assignments:

```matlab
cfg.spmPath = '/absolute/path/to/spm12'; % Server SPM12 directory containing spm.m.
cfg.bidsPath = '/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main/BIDS_demo';
cfg.subjectFilter = 'sub-002';          % Change the subject/pattern here.
cfg.sessionFilter = '*';
cfg.taskFilter = '*';
cfg.runFilter = '*';
cfg.steps = 1;                         % Run Step 1 alone.
cfg.minTimepoints = 100;               % Exclude BOLD runs shorter than 100 frames.
cfg.dryRun = false;
```

Set the actual SPM and BIDS paths, and review the remaining acquisition/template/processing parameters in the same configuration file. The example subject and minimum time points are editable settings, not requirements for every dataset. `MIKey_run` establishes the configured SPM/code paths automatically.

Save the file and launch the general script from the toolbox root:

```bash
matlab -nodisplay -nosplash -r "try, run('examples/run_mikey.m'); catch ME, disp(getReport(ME,'extended','hyperlinks','off')); exit(1); end; exit(0);"
```

This command supports MATLAB R2018a as well as later versions. It prints the resolved configuration file, subject selection and steps. MATLAB exits with a failure status and error stack when processing fails. Each real run also prints its unique report/log directory.

### 2. Prepare masks after Step 1 completes

Wait for successful Step 1 completion. Draw the masks manually on the **scaled images**, then save them in the corresponding derivative directories. For the example BIDS root and subject:

```text
BIDS_demo/derivatives/MIKey/sub-002/func/sub-002_desc-boldbrain_mask.nii.gz
BIDS_demo/derivatives/MIKey/sub-002/anat/sub-002_desc-anatbrain_mask.nii.gz
```

Both `.nii.gz` and `.nii` work. The functional and anatomical masks must separately match their corresponding scaled images in dimensions and affine, and contain binary 0/1 values. With sessions, insert the relevant `ses-*` directory after `sub-002`. See [Modality-specific brain masks](#modality-specific-brain-masks).

### 3. Change only steps, then run the same script

Reopen **the same** `examples/mikey_config_example.m`. After preparing the masks, change its existing step assignment from `cfg.steps = 1;` to:

```matlab
cfg.steps = 2:10;
```

Keep the same subject, BIDS directory and preprocessing settings. Save the configuration, return to the toolbox root and run **the identical general entry command**:

```bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
matlab -nodisplay -nosplash -r "try, run('examples/run_mikey.m'); catch ME, disp(getReport(ME,'extended','hyperlinks','off')); exit(1); end; exit(0);"
```

This invocation reads the updated configuration and starts at Step 2, continuing through Step 10. There is no second subject-specific script or configuration to create. Do not select `1:10` for this workflow: manual mask preparation separates Step 1 from Step 2. The general entry rejects Step 1 combined with subsequent steps.

For a preflight-only check, set `cfg.dryRun = true` in the same configuration file and run the same entry; restore `false` before actual processing. Dry run checks configuration, dependencies, selected raw scans and required templates without creating derivatives or unpacking raw images. It does not verify all future intermediate files or registration quality. Runtime stage checks validate prerequisites after preceding stages have run.

`MIKey_config` validates fields and values and supplies defaults. Unknown fields are rejected. Relative paths resolve against the calling MATLAB working directory; use absolute paths for cluster jobs. Steps accept numeric vectors or strings such as `'2,4:10'`, without evaluating MATLAB expressions. Execution preserves the supplied order and rejects duplicate steps.

Edit parameters only in [examples/mikey_config_example.m](examples/mikey_config_example.m), then run [examples/run_mikey.m](examples/run_mikey.m). The execution script loads this configuration and does not define a second parameter block. Processing stages are selected with `cfg.steps`; atlas/network values are not enable/disable switches. For example, keep `cfg.fcLabel='428'` and omit Step 13 to skip FC. Validation follows the selected steps for every stage-specific parameter, including types, numeric bounds, lists, switches, paths and choice membership. Unused values remain unchanged and are checked when their stages are selected later. For example, `fcLabel`, parcellation settings and Step 12 filter settings cannot block Steps 1 or 2-10. Invalid active parameters are listed together in one error; unknown field names and invalid step selections are always rejected. This example uses the explicit settings in the configuration function; it does not load the saved GUI MAT file. Begin with Step 1, inspect the scaled images, prepare masks, and then continue. Do not run `1:17` blindly: manual preparation is required between Steps 1 and 2.

### Export GUI settings to a command-line .m configuration

Set the BIDS folder, filters, Steps and processing parameters in the GUI, then choose the green **Export Config (.m)** button at the bottom. Save, for example, as `examples/mikey_config_gui.m`. All visible settings are exported, including FD settings and custom paths. Loaded nonvisual settings such as `spmPath`, `parcellationMode`, `dryRun`, `failFast`, `strictWarnings` and `logDir` are retained. When parcellation is selected, choose individual or concatenated mode before export. The currently resolved SPM directory is captured when no explicit saved SPM path exists.

The exported file is a MATLAB **function returning `cfg`**, with editable assignments for every parameter. It does not read the example configuration or a MAT snapshot. Edit parameters only in this selected file; leave `run_mikey.m` unchanged. Check all paths for the compute node, especially when exporting on a different operating system. Loading a `.m` configuration evaluates that selected MATLAB function.

From MATLAB, with the toolbox root as the current directory:

```matlab
addpath('examples');
run_mikey('examples/mikey_config_gui.m');
% Absolute configuration filenames are supported too.
% run_mikey(); % Uses examples/mikey_config_example.m instead.
```

Relative configuration filenames are searched in this order: the current MATLAB directory, the toolbox root, then its `examples` directory for a bare filename. Thus `run_mikey('examples/mikey_config_gui.m')` also works when MATLAB is currently inside `examples`; `run_mikey('mikey_config_gui.m')` can locate a file in the toolbox examples folder. An absolute filename selects exactly that file and never falls back to another copy. The resolved full path is printed before loading.

From the server shell (MATLAB R2018a or later):

```bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
matlab -nodisplay -nosplash -r "try, addpath('examples'); run_mikey('examples/mikey_config_gui.m'); catch ME, disp(getReport(ME,'extended','hyperlinks','off')); exit(1); end; exit(0);"
```

First export/select `cfg.steps = 1`. After preparing every selected subject's masks manually, edit **only the same exported file** to `cfg.steps = 2:10` and rerun the identical command. Step 1 combined with later steps is rejected by the general entry. For preprocessed data, export only the intended later steps. Export does not start processing. The existing no-argument entry and `run('examples/run_mikey.m')` commands retain the default example-configuration route.

### Optional saved-configuration API

MAT/JSON snapshots are supported separately by `MIKey_run`. They are not needed for the two-stage `run_mikey.m` workflow above. To export the parameters already defined in the same configuration function, from MATLAB with the toolbox root and `examples` on its path:

```matlab
config = MIKey_config(mikey_config_example());
save('/shared/project/config.mat', 'config');
report = MIKey_run('/shared/project/config.mat');
% A JSON configuration file is also accepted.
% report = MIKey_run('/shared/project/config.json');
```

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

`useDefaultPCStrategy=true` selects the default candidates; `false` selects the custom list. `customPCCounts` is used only when Step 10 is selected and `useDefaultPCStrategy=false`; it must then be a nonempty list of distinct nonnegative integers. Numeric `0` is a valid count (motion-only regression). Logical `false` is a switch rather than a count list and is rejected only when the custom list is actually used. With the default strategy, this unused field is preserved without validation (including old `false` or blank values).

```matlab
cfg.useDefaultPCStrategy = true;
cfg.customPCCounts = []; % Unused under the default strategy.
```

```matlab
cfg.useDefaultPCStrategy = false;
cfg.customPCCounts = [0 5 10 20];
cfg.steps = [10 11 12];
```

Counts must be distinct nonnegative integers within each selected run's available range. Count 0 represents motion-only (`12rp`), alongside a separate no-regression baseline. Step 10 records actual counts and recomputes an estimate when its candidate list changes. Step 11 compares the intersection of candidates available across selected runs. Step 12 uses the chosen count. GUI ROI Num in Step 15 accepts one positive number (default 100); the script `clustROINums` interface retains support for multiple counts. K-means partitions the whole brain into N ROIs without guaranteeing equal ROI sizes.

### FD methods and group strategy selection (Steps 10-11)

Edit these settings only in `examples/mikey_config_example.m`:

```matlab
cfg.fdMethod = 'euclidean'; % Default. Use 'power' for Power L1 FD.
cfg.fdRadius = 100;        % Scaled-space rotation radius: physical 5 mm * scale 20.
cfg.voxelScaleFactor = 20; % Must equal the actual Step 1 enlargement factor.
```

In the GUI, the small **FD...** button beside Step 10 opens the method/radius settings. Save/Load Config retains them. Existing controls keep their positions. These parameters are validated only for Step 10; Step 11 reads the definitions stored with each run's estimates.

For raw SPM motion parameters `rp`, compute backward frame differences, convert the three rotational differences from radians to displacement using `fdRadius`, and aggregate the resulting six changes `d`:

| Method | Formula |
| --- | --- |
| `power` | `FD_mm(t) = sum(abs(d(t,:))) / voxelScaleFactor` (L1); [Power et al., 2012](https://pmc.ncbi.nlm.nih.gov/articles/PMC3254728/) |
| `euclidean` | `FD_mm(t) = sqrt(sum(d(t,:).^2)) / voxelScaleFactor` (L2 in the six motion-parameter displacement components) |

The FD calculation uses raw `rp` backward differences rather than the old central `gradient`. Frame 1 has FD=0; Pearson FD-DVARS correlations use frames 2 through T because frame 1 has no preceding frame. FD settings change the evaluation metric; the existing regression design matrix is retained.

Saved `FD` is now in **physical mm**. Both methods divide the scaled-space displacement by `voxelScaleFactor`; multiply saved `FD` by 1000 for micrometers. For example, 0.318591844636042 scaled mm with scale 20 becomes 0.0159295922318021 physical mm (15.9296 micrometers). `fd_info.version=2` records `spatialUnits=mm`, the scale, the scaled-space radius and its physical-mm equivalent. Keep the GUI Step 1 **Scale** value / script `cfg.voxelScaleFactor` equal to the actual factor used to generate the selected runs, including when executing Step 10 alone. If an existing scaled-image JSON records a different Step 1 factor, Step 10 stops with a scale-conflict diagnostic; older outputs without that record use the configured factor.

`fdRadius` must use the same spatial units as SPM translations. The default 100 retains the previous rotation conversion radius; it is not a universal mouse brain radius. For example, a physical radius of 5 mm with image coordinates scaled by 20 corresponds to `fdRadius=100`. With unscaled coordinates, that same example requires `fdRadius=5`. Set the appropriate radius for the actual images; the original paper's human-head radius should not be copied automatically to mouse data. L2 is a different metric, not a demonstrated scientific improvement for every dataset.

Step 9 saves PCs in `*_bold_desc-NBPCs.mat`. Step 10 requires the Step 8 smoothed image, PCs and an `rp_*.txt` motion file, and saves `*_bold_desc-regressionResults.mat`. That MAT contains `pc_configs`, `FD`, `DVARS0`, `corr0`, candidate `DVARS1/corr1`, etc., the raw `rp_original`, and explicit `fd_info`. `corr0` is the no-regression baseline; `corrK` corresponds to `pc_configs(K)`. After Step 10, inspect a run in MATLAB with:

```matlab
[counts, CC, fdInfo] = MIKey_noise_result('/absolute/path/to/sub-001_task-rest_run-01_bold_desc-regressionResults.mat');
disp(CC(1)); % No-regression baseline.
disp(table(counts(:), CC(2:end)', 'VariableNames', {'PCCount','CC'}));
```

Step 10 recomputes old caches without the new definition metadata and caches whose PC list, FD method, radius, scale or raw motion has changed. Version-1 results in scaled-space units must be regenerated by Step 10; Step 11 rejects them. A positive unit conversion alone leaves Pearson CC unchanged. Step 11 requires valid results for **every selected run**, checks that their FD definitions match, and compares shared PC counts plus the no-regression baseline. It selects the **global minimum of `mean(abs(CC),1)` across runs**, with equal weight per run; ties retain the first strategy (baseline first, then increasing PC count). It no longer uses a local-trend heuristic. Missing runs, legacy FD results and mixed definitions stop the step with a diagnostic.

Group outputs are `group_level_noise_estimation.mat` and `best_regression_strategy.mat` under the selected `group_analysis[/selection-*]` directory. They retain run identifiers, CC matrices/means and the FD definition. Step 12 reads the chosen strategy and PCs to write the final regressed images. After updating, rerun Step 10 for all intended runs, then Step 11 and Step 12; complete Step 8 first if smoothed images are absent. Keep the same selection while aggregating. The image-paired SPM `.mat` sidecars can contain per-volume affine information and are read implicitly with `.nii`; PC/strategy MAT files contain analysis inputs/results, so these are not interchangeable file types to remove in bulk.

### Group network templates

Built-in ROI label choices are **214, 296, 428, 592, 604 and 1184** in the Step 13 FC Label menu and Step 14 ROI Atlas menu, with matching script values (`cfg.fcLabel='296'` / `'592'`, `cfg.parcNetwork='296rois'` / `'592rois'`). Saved MAT and exported `.m` configurations retain these choices. `share_temp` contains `Label_Mouse_296_v38.nii` and `Label_Mouse_592_v38.nii`.

`share_temp/AMCP_temp` supplies network initialization priors for 214/428/604/1184, but **does not contain a matching 296/592 AMCP network prior**. FC uses either new ROI atlas directly. For Step 14 with 296/592, select a suitable **Group Network** file (`cfg.groupNetworkPath`); MIKey combines that network initialization with the selected bundled ROI label image. The same explicit Group Network supports Steps 15-16 and inter-subject variability. Missing network input produces a diagnostic; no network map is inferred from ROI counts or silently substituted. Use Custom remains available when supplying both a separate network prior and a custom ROI label atlas.

```matlab
cfg.groupNetworkPath = '/shared/project/my_group_network.nii';
```

The **Parcellation Parameters (Steps 14-16)** block is placed above Step 17 and supplies Percent Top, Max Iter, Change Thr, Conf Thr, tSNR, inter-subject variability and parallel settings to Steps 14-16. **Group Network** is used by Steps 15-16 and by Step 14 when selecting 296/592 ROI labels or enabling **Use Inter-Subj Var**; the existing 214/428/604/1184 choices retain their bundled Step 14 initialization prior, while 296/592 use the explicitly selected Group Network for initialization. An explicit path takes precedence for these shared operations. Otherwise MIKey uses the custom network when selected, then the AMCP network corresponding to the Network dropdown.

For Step 14 **Use Custom**, **Network Prior** (`networkCustomPath`) selects the coarse group network-label NIfTI used to initialize networks, for example `AMCP_428prior_11net.nii`. **ROI Label Atlas** (`labelCustomPath`) selects the finer ROI-label NIfTI used by prior-based parcellation, for example `Label_Mouse_428_v38.nii`. Both must contain appropriate integer labels in the analysis/template space. The shipped templates and processing derivatives use uncompressed `.nii` paths.

## Configuration reference

The shared usage map is `MIKey_parameter_scope`. The same scope is used by configuration validation, preflight and nonvisual batch controls. Batch controls use safe placeholders for unused settings; these do not overwrite the requested configuration or get recorded as used processing parameters.

| Parameter group | When validated/required |
| --- | --- |
| BIDS/SPM/code/log paths, subject/session/task/run selection, minimum time points, steps and execution flags | All runs |
| Voxel scale | Step 1; Step 10 uses the same factor to return physical-mm FD |
| Slice timing count/order | Step 4 |
| TR fallback | Step 4; Step 12 with filtering enabled |
| Coregistration / normalization interpolation | Steps 6 / 7 respectively |
| Default/custom normalization template switch | Step 7; custom path only with the custom switch |
| Template root | Steps 3, 10, 12-17; Step 7 only with the default template |
| Smoothing FWHM | Step 8 |
| Default PC strategy switch / custom count list | Step 10 / Step 10 with default strategy disabled |
| FD method and rotation radius | Step 10; Step 11 checks stored run definitions |
| Detrending/filtering switches; filter cutoffs | Step 12; cutoffs only with filtering enabled |
| Regression output strategies | Steps 12-16 |
| FC atlas; custom atlas path | Step 13; path only for `Custom...` |
| Parcellation iteration/threshold/correction/mode/parallel options | Steps 14-16 |
| ROI counts / voxel downsampling | Steps 15 / 16 respectively |
| Prior network and custom prior paths | Step 14, or group-network fallback for Steps 14-16; custom paths only in custom mode |
| Explicit group network | Steps 15-16; Step 14 with inter-subject variability enabled |

File existence and installed dependencies are checked in preflight for selected steps. Step 1 does not require a template directory. Existing data/template/SPM prerequisites for the steps you select still apply. Use `cfg.steps=1`, prepare the masks manually, then change only `cfg.steps=2:10` in the same configuration function. Changing to a later step revalidates its previously unused values; unsupported atlases must use a custom-atlas configuration. The bundled 296/592 ROI labels are supported directly; parcellation additionally requires the network prior described above.

`MIKey_defaults()` is the complete parameter source. All GUI controls map to these fields:

| Fields | Defaults / meaning |
|---|---|
| `bidsPath`, `spmPath` | Working BIDS directory; SPM root (or current MATLAB path). |
| `templatePath`, `codePath` | Toolbox `share_temp` and `scripts` folders. |
| `subjectFilter`, `sessionFilter`, `taskFilter`, `runFilter` | `sub-*`, `*`, `*`, `*`. |
| `steps` | `1`; explicitly choose subsequent steps. |
| `minTimepoints` | `0` disables filtering; exclude BOLD runs with fewer than N frames. |
| `voxelScaleFactor` | `20`; Step 1 enlargement and Step 10 inverse scaling for physical-mm FD. |
| `sliceTimingTR`, `sliceTimingNSlices`, `sliceTimingOrder` | `2`, `30`, `Auto-detect`; timing fallbacks. |
| `smoothFWHM`, `coregInterp`, `normInterp` | `[6 6 6]`, `2`, `2`. |
| `useDefaultTemplate`, `customTemplatePath` | `true`, empty. |
| `useDefaultPCStrategy`, `customPCCounts` | `true`, `[0 5 10 20]`. |
| `fdMethod`, `fdRadius` | `euclidean` (`power` also available); `100` in SPM translation units. |
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

With Step 12 filtering enabled, use `0 <= lowFreq < highFreq < 1/(2*TR)` for the actual acquisition TR. Defaults are not universal mouse-MRI acquisition settings. Several legacy processing stages skip existing outputs by filename without checking parameter provenance. Use a fresh working/output dataset after changing processing settings; Step 10 specifically checks its PC candidate list.

## Compute-node jobs

For the single-configuration, two-stage workflow above, submit the **same job command for each stage**. Set `cfg.steps = 1` in `examples/mikey_config_example.m` before the first submission. Wait for that job to finish and prepare the masks manually; then change only that assignment to `cfg.steps = 2:10` and submit the same command again. Do not change the configuration while its job is queued or running, because the configuration is read when MATLAB starts.

Example Slurm submission from a login/management node:

```bash
sbatch <<'SH'
#!/usr/bin/env bash
#SBATCH --job-name=MIKey
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=MIKey-%j.log

set -euo pipefail
# Add your site's partition/account directives above and load its MATLAB module here if required.
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
matlab -nodisplay -nosplash -r "try, run('examples/run_mikey.m'); catch ME, disp(getReport(ME,'extended','hyperlinks','off')); exit(1); end; exit(0);"
SH
```

Adjust scheduler resources, partition/account and MATLAB environment to your institution. These job settings do not duplicate the processing parameters in `mikey_config_example.m`. A PBS job can invoke the same `matlab ... run('examples/run_mikey.m')` command after setting its working directory and site-specific resources. Run per-subject preparation before a cohort-wide Step 11; then use the matching group selection for final regression. Concurrent jobs must not write the same subject/session outputs.

### Multiple configurations: one independent job per file

Export/save each parameter set under its own `.m` name, for example `examples/config_sub001.m` and `examples/config_sub002.m`. Each file returns its own cfg and can define different subjects, steps and processing parameters. Do not duplicate processing parameters in the submission helper or job scripts.

On a Linux management/login node, in MATLAB at the toolbox root:

```matlab
addpath('examples');
files = {'examples/config_sub001.m', 'examples/config_sub002.m'};
% Slurm: submits one independent job for each configuration.
jobs = submit_mikey_configs(files, 'slurm');
% Optional site/resource options, one command-line argument per cell:
% jobs = submit_mikey_configs(files, 'slurm', {'--partition=compute','--account=lab'});
% PBS alternative:
% jobs = submit_mikey_configs(files, 'pbs', {'-q','workq','-A','lab'});
% Prepare scripts only, without submitting:
% jobs = submit_mikey_configs(files, 'slurm', {}, false);
```

From a Linux shell (Slurm example, MATLAB R2018a compatible):

```bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
matlab -nodisplay -nosplash -r "try, addpath('examples'); submit_mikey_configs({'examples/config_sub001.m','examples/config_sub002.m'},'slurm'); catch ME, disp(getReport(ME,'extended','hyperlinks','off')); exit(1); end; exit(0);"
```

Each configuration is checked before any job is queued. Every job gets a frozen `.m` parameter snapshot, its own `job_NNN.sh`, stdout/stderr files and a recorded scheduler response. Artifacts are placed in a unique `submissions` directory under the first configuration's log directory (by default `BIDS/derivatives/MIKey/logs/submissions/...`). Editing an original configuration after submission does not change the frozen settings for queued jobs. The jobs are independent MATLAB processes; the scheduler controls when resources allow them to run.

Generated scripts default to 4 CPUs, 16 GB and 4 hours. Set your site's queue/account/resource options in the third argument; scheduler command-line options take precedence over script directives. For site-specific MATLAB module setup, prepare with `false`, edit the generated `.sh` files and submit them with `sbatch`/`qsub`. `submission.json` records the exact commands and per-job status/IDs. If one submission fails, earlier queued jobs remain; inspect that record before retrying to avoid duplicates.

Within the batch, jobs that write the same subject outputs are rejected, even if their session/run filters differ, because some stages share anatomy and other subject-level files. Jobs that write/read the same group results while one is writing them are also rejected. Different subjects with Steps 1 or 2:10 can be submitted together. Run Step 11 as one intended-cohort configuration, then submit dependent Step 12 jobs after it finishes. For simultaneous parameter comparisons on the same subject, use separate working datasets/output trees. Checks cover this submitted batch, not unrelated jobs already running from another submission.

The Step 1/manual-mask boundary still applies to every configuration. Prepare all masks after the Step 1 batch finishes, then change the steps in the original configuration files and submit the next batch.

### Optional MAT/JSON cluster interface

The existing [examples/submit_slurm.sh](examples/submit_slurm.sh), [examples/submit_pbs.sh](examples/submit_pbs.sh) and [examples/mikey_cluster_job.m](examples/mikey_cluster_job.m) provide a separate interface for saved MAT/JSON snapshots. That interface reads absolute `MIKEY_ROOT` and `MIKEY_CONFIG`; optional overrides are `MIKEY_SUBJECT`, `MIKEY_STEPS`, `MIKEY_SESSION`, `MIKEY_TASK`, `MIKEY_RUN` and `MIKEY_MIN_TIMEPOINTS`. The single-configuration workflow above directly calls `run_mikey.m` and requires none of these environment variables or snapshots.

For MATLAB R2019a or later, the saved-configuration entry can be called with:

```bash
matlab -batch "run('/shared/software/MIKey/examples/mikey_cluster_job.m')"
```

For R2018a, use a `-nodisplay -nosplash -r` invocation with `try/catch`, stack reporting and `exit(1)` on failure, as in the general entry command above.

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


## Selected-step configuration regression checks

After updating the complete set of runtime files, these checks need MATLAB but do not run SPM processing or read research images:

```matlab
addpath(fullfile(toolboxRoot, 'tests'));
test_mikey_config_scopes;
test_mikey_pc_config;
test_mikey_config_choices;
test_mikey_config_flow;
```

They check Steps 1 and 2-10 with invalid unused values of several types, all 17 single-step validation routes, active validation of every public field, conditional defaults/custom settings, MAT/JSON import, batch adaptation and metadata writing on an isolated temporary dataset. GUI layout construction is unchanged. See `runs/20261019-scoped-validation/RUN_REPORT.md` for this revision's executed checks and limits.

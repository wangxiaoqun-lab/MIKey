# Step 2/3 diagnostics

2026-10-12: the user selected raw `sub-01` data while Subject Filter was `sub-001`. No subjects matched. Existing scaled derivatives were under `sub-001`, and no masked BOLD images existed. Existing `*_desc-boldbrain_mask.nii` masks do not match the required `*brainmask.nii` suffix.

Changes are limited to English Step 2/3 input diagnostics and completion reporting. Empty selections show all four filters and available raw subject directory names. Step 3 shows missing scaled fieldmap directories, missing fieldmap components and exact masked BOLD paths; missing SPM output is an error. Neither step reports a successful 0/0 completion. No GUI layout, raw data, derivative directory names or masks were changed.

MATLAB R2018a test uses temporary filename-only fixtures and the actual GUI callbacks. Empty selection, missing masks/fieldmaps/masked inputs and cached-output skipping passed; Code Analyzer reported no PARSE errors. This does not validate actual fieldmap correction on acquired images. Evidence: `../validation/20261012/mikey-mask-fieldmap-diagnostics.log`.

Launcher note: the outer `bin/matlab.exe -wait` returned status 1 despite both test PASS markers and no error stack in the log. Repeating the callback tests with `bin/win64/MATLAB.exe` produced all PASS markers and exited. This launch-status discrepancy is recorded separately from the callback assertions.

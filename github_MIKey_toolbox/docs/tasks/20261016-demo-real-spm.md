# Real SPM demo registration validation (2026-10-16)

User request: run Steps 6/7 with demo_BIDS_dataset and genuine SPM, inspect registration and failure stopping, fix original package without changing GUI layout.

- Original package: K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main (no Git metadata; original backups and SHA-256 records used).
- Existing licensed MATLAB R2018a process 16048, user enabled AutomationServer for this validation. Restore disabled on completion; retain original GUI/session.
- Real SPM: D:/Program Files/MATLAB/mytoolbox/spm12. No COPY-ONLY estimator fixtures permitted in these experiments.
- Independent full input copy: C:/MIKeyRealSPM/20261016-958dc7c6. Source/copy manifest: docs/validation/20261016-demo-real-spm/workspace.json.

Completed evidence:
- Actual baseline Step 6 estimation/reslicing returned a blank image; post QC stopped execution before Step 7 and retained its failed candidate.
- Original input centers are separated by 0.929 larger brain spans; initial foreground coverages are both zero. Existing precheck failed to detect this case.
- Added combined disjoint-foreground/center-distance precheck. Targeted native MATLAB QC tests passed, including disjoint short-axis offset rejection and overlapping long-axis offset acceptance.
- Script run with failFast=false and steps [6 7] now fails at Step 6 pre QC, without SPM estimation or Step 7.
- Explicit center initialization applied to independent test derivatives only. All 480 affine frames transformed together and samples verified unchanged.

Completed: real SPM Steps 6/7 on initialized run-01 (480 frames); numerical and visual review; script/GUI Step 6/7 failure stopping; restored-cache revalidation; 26 original input hashes and 11 initialized voxel-payload hashes; original GUI preserved and AutomationServer restored disabled. See final report for scope and residual local registration limitations.

See runs/20261016-demo-real-spm/RUN_REPORT.md and docs/validation/20261016-demo-real-spm/.

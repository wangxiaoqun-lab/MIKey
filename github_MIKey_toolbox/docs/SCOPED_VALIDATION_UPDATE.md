# Selected-step validation update (2026-10-19)

The original toolbox now validates all stage-specific fields according to the selected steps and conditional switches. Unknown field names, step syntax, shared paths/selection and execution flags remain strict. Active parameter errors are collected into one message. Unused values are preserved for future selection; they are not silently reset or validated.

`MIKey_parameter_scope.m` is the shared usage map. `MIKey_batch_controls.m` provides safe placeholders for unused nonvisual controls without altering `state.Config`. Each stage refreshes its controls for its own scope. Preflight, runtime prerequisites and metadata generation follow that scope too.

Upload the complete current local `MIKey_toolbox_main` folder to the server while MATLAB is idle. All current sources and dependencies are already updated in this folder; no update archive is required. Maintain your server paths and parameters in `examples/mikey_config_example.m`. Use a fresh MATLAB session after replacing class/runtime files.

Continue editing only `examples/mikey_config_example.m`:

```matlab
cfg.steps = 1;       % First run.
% Prepare functional/anatomical masks on the scaled images externally.
cfg.steps = 2:10;    % Subsequent run: edit the same line, then rerun run_mikey.
```

These are successive values of the same setting, not two parameter blocks. `examples/run_mikey.m` contains no duplicate editable settings. It prints the configuration function resolved on MATLAB's path and enforces the manual-mask boundary.

For Step 10, `useDefaultPCStrategy=true` selects default candidates and ignores `customPCCounts`. Set it to `false` only for an explicit numeric list such as `[0 5 10 20]`. FC atlases, parcellation and Step 12 filter settings are unused in Steps 1 / 2-10. Unsupported built-in atlas names remain invalid if their stages are selected later; use the supported custom-atlas paths then.

No GUI layout or user configuration values were changed. See the root README's scope table and regression commands, and `runs/20261019-scoped-validation/RUN_REPORT.md` for executed validation.

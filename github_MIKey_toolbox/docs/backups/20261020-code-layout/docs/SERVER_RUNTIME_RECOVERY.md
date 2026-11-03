# Server runtime path repair — 2026-10-16

The reported sequence is: one fieldmap result was produced; checkpoint method lookup then failed; metadata lookup failed too; Stop/close remained pending. This is consistent with the toolbox root being available only through Current Folder. The former Step 3 code changed cwd to the derivative folder immediately before the completion status/checkpoint. If the root was not explicitly on path, MATLAB could lose access to the run-control methods and metadata helper. Cleanup also called a class method, so that failure could leave Active=true. A partial copy, another MIKey version on path, or an old loaded class can give similar errors. Server diagnostics are needed to distinguish them.

## Recover the current old window

1. Press Ctrl+C once and wait for the MATLAB command prompt (`>>`). Repeated Stop clicks only set the same cooperative flag; they do not forcibly interrupt an SPM/MEX call or repair a missing method.
2. At the idle prompt, bypass only the MIKey windows' stale close callbacks:

```matlab
delete(findall(groot,'Type','figure','Name','MIKey - Mouse Image Key Toolbox'));
```

This does not delete data or close MATLAB. Do not execute it while processing is still active. If MATLAB never returns from native code even after Ctrl+C, the path repair cannot be applied inside that blocked callback; stop that particular server job/session through your normal server controls and restart it. Preserve logs and outputs first.

## Update coherently

Upload the complete current local `MIKey_toolbox_main` folder to the intended server location while MATLAB is idle. Current sources and all runtime dependencies are already in this folder; no update archive is required. Check server-specific paths and parameters in `examples/mikey_config_example.m`. Restart MATLAB after the update so previous class instances/definitions are gone.

Use server paths, with exact filename case on Linux:

```matlab
toolboxRoot = '/absolute/server/path/MIKey_toolbox_main';
spmPath = '/absolute/server/path/spm12';
cd(toolboxRoot);
addpath(toolboxRoot,'-begin');
MIKey_setup(spmPath);
which MIKey -all
which MIKeyRunControl -all
which MIKey_write_derivative_metadata -all
MIKey_check_runtime()
MIKey
```

The three MIKey files must resolve to that same root. Remove old toolbox copies from path (including startup.m entries) rather than combining releases. Add only the SPM root, not genpath(SPM). Each compute-node job needs its own explicit MIKey_setup call. After loading an older saved configuration, check Code Path, Template and BIDS paths again; do not leave them pointing at another installation.

## Focused regressions

These tests generate only temporary empty BIDS scopes/metadata and GUI state; they do not estimate fieldmaps or use research images:

```matlab
addpath(fullfile(toolboxRoot,'tests'));
test_mikey_runtime_path(false); % standard JVM MATLAB without a GUI
% Expected: MIKEY_RUNTIME_PATH_HEADLESS_PASS

test_mikey_runtime_path(true);  % management node with GUI support
% Expected: MIKEY_RUNTIME_PATH_AND_RECOVERY_PASS
```

Coverage: launch from Current Folder without an explicit root entry; pin root before a directory change; resolve checkpoint/metadata afterwards; handle a processing error plus a separate metadata JSON error without masking the original; clear active state and restore buttons/cwd; recover an idle orphan flag and close the GUI. The new tests were supplied but could not be executed locally: no MATLAB process is running and prior new-instance license checkout failed with Error -8. Native R2018a Code Analyzer and MATLAB-2018a parsing passed; the GUI component layout was compared against the backup and is unchanged.

After updating, inspect the already created fieldmap output and its number of volumes before reuse. The logged lookup failure happened after the first completion message, so do not equate it with a proven fieldmap estimation failure. Existing outputs are skipped by Step 3; remove or replace only a confirmed invalid derivative if regeneration is needed, never raw inputs for this path issue.

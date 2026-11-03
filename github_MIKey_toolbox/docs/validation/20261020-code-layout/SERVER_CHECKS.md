# Server validation: consolidated MATLAB source layout

Status: implemented, not executed. No local MATLAB, syntax checker, tests, scripts or compute processes were started. Source reading and filesystem inventory only were used locally.

The root now contains MIKey.m as its only .m file. The 52 former root helpers/classes are in scripts, with a new MIKey_paths bootstrap. The main GUI and examples bootstrap this folder; configuration/template resolution and runtime checks were adjusted. Config functions/general runners remain in examples. GUI control layout, algorithm parameters, template/data locations and saved settings are unchanged.

First complete the source-only overlay migration in docs/CODE_LAYOUT.md if old root helpers remain on the server. Keep user config functions, MIKey_BIDS_config.mat, data, templates and derivatives. Close old MATLAB sessions and restart after moving class files; do not try to refresh an active GUI in place.

Server MATLAB commands:

```matlab
toolboxRoot='/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main';
addpath(toolboxRoot);addpath(fullfile(toolboxRoot,'scripts'));
MIKey_paths();
which MIKey -all
which MIKey_defaults -all
which MIKeyRunControl -all
addpath(fullfile(toolboxRoot,'tests'));
test_mikey_code_layout
test_mikey_runtime_path(false)
test_mikey_config_scopes
test_mikey_config_paths
test_mikey_submissions
```

Expected layout marker: MIKEY_CODE_LAYOUT_PASS. It checks root/scripts separation, class/API resolution, defaults from unrelated cwd, examples config resolution and rejects a simulated stale-root source only in a temporary fake installation. The submission test only prepares scripts and checks Bash syntax; no queue or child process is launched. These checks have not been run locally.

On a GUI-capable server session, launch MIKey and confirm the same GUI layout/default template/code paths and loaded settings. Existing mrun/run_mikey commands still use examples; run the intended config for an actual SPM smoke test only after checking its user-selected parameters and valid prerequisites. Review full logs and source manifests. This migration does not establish scientific accuracy or completed server processing.

Read-only inventory found no destination filename collisions before moving; all move targets were verified direct children of scripts under the intended original toolbox. Unmodified moved files were transferred by rename. Modified originals are preserved in docs/backups/20261020-code-layout/. A prior literal-string replacement bug had damaged tests/test_mikey_submissions.m and duplicated a README fragment; both source defects were repaired during review, without claiming prior tests passed. Historical records/backups are preserved.

No Git checkout is present in the original delivery folder. source-snapshot.json records exact source identity instead of a commit. No archives were created.

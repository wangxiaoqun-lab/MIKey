# MATLAB source layout

The root now contains only one MATLAB entry file, MIKey.m. The former 52 root-level helpers/classes are under scripts with the existing processing algorithms. examples keeps the general runners and editable configuration functions. share_temp, data, derivatives, MIKey_BIDS_config.mat, tests and records retain their locations.

```text
MIKey_toolbox_main/
  MIKey.m                  GUI entry
  README.md
  MIKey_BIDS_config.mat    existing saved GUI configuration
  scripts/                core functions, classes and processing algorithms
  examples/               run_mikey, submit_mikey_configs, user config functions
  share_temp/             image templates and label/network maps
  demo_BIDS_dataset/      existing demo input/output tree
  tests/                  server-only checks
  docs/                   documentation and source migration list
  runs/                   experiment/change records
```

## Paths and commands

The GUI adds root/scripts paths before loading helpers/classes. run_mikey and submit_mikey_configs add them too; their existing commands and config locations are unchanged. The sample configuration only gains path bootstrapping; none of its processing values are reset. Exported user configs remain untouched.

For direct low-level API calls, first add scripts:

```matlab
toolboxRoot='/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main';
addpath(toolboxRoot);addpath(fullfile(toolboxRoot,'scripts'));
MIKey_paths();
MIKey_setup('/absolute/server/path/spm12');
which MIKey -all
which MIKey_defaults -all
which MIKeyRunControl -all
```

MIKey must resolve to the root. Helpers/classes must resolve to scripts. Do not use genpath on the whole toolbox: docs/backups contains old sources. Defaults/config resolution derive templates/examples from the parent of scripts; custom codePath still works, and run provenance includes both the core scripts and the selected extra code directory. No GUI control positions or processing algorithms are changed by the move.

## Updating an existing server folder without leaving old root helpers

A normal overlay upload can leave old root-level .m files behind. MATLAB searches Current Folder before added paths, so stale copies can still win. The new bootstrap explicitly rejects matching root duplicates with MIKey:LegacyLayout.

1. Finish/stop running MATLAB jobs normally and close MATLAB sessions using this toolbox, including old GUI windows. Class locations must not be changed in an active process.
2. Upload the entire updated folder to the existing location, preserving your server-specific configuration functions, saved MAT settings, data and derivatives. Verify those settings after the upload. No template or data location changes are required.
3. Only if updating an old overlay installation, archive the exact old source filenames listed in docs/code-layout-migration.json. The Bash/Python command below verifies that each new scripts copy exists, then moves only those old root sources into a unique server backup folder. It does not remove any data or configuration file. A fresh upload containing only the new layout needs no migration.

From the server Bash terminal, with no active toolbox MATLAB process:

```bash
cd /newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main
python - <<'PY'
import json
from pathlib import Path
from datetime import datetime
root = Path.cwd().resolve()
rows = json.loads((root / 'docs' / 'code-layout-migration.json').read_text())
pending = []
for row in rows:
    old = root / row['from']
    new = root / row['to']
    if old.resolve().parent != root or new.resolve().parent != root / 'scripts':
        raise RuntimeError('Unexpected migration path: ' + str(row))
    if old.exists():
        if not old.is_file() or not new.is_file():
            raise RuntimeError('Missing scripts copy or invalid source: ' + str(old))
        pending.append(old)
if not pending:
    print('No old root-level source helpers remain.')
else:
    backup = root / 'docs' / 'backups' / ('server-root-sources-' + datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    backup.mkdir(parents=True, exist_ok=False)
    for old in pending:
        destination = backup / old.name
        if destination.exists():
            raise RuntimeError('Refusing to overwrite: ' + str(destination))
        old.rename(destination)
    print('Archived {} old source files in {}'.format(len(pending), backup))
PY
```

The migration list contains only the 52 former implementation filenames. It does not include MIKey.m, example configs, MAT settings, NIfTI files or derivatives. Preserve the backup for recovery. The archive is a folder, not a release ZIP. This command is provided for server use and was not executed locally.

4. Start a fresh MATLAB session. Check which paths as above, then use the same GUI/run_mikey/mrun commands as before. Mixed old class definitions cannot be safely refreshed inside an active GUI.

## Server validation

No local MATLAB, syntax checker, tests or compute jobs were executed for this migration. Add the tests folder and run the focused checks on the server:

```matlab
addpath(fullfile(toolboxRoot,'tests'));
test_mikey_code_layout
test_mikey_runtime_path(false)
test_mikey_config_scopes
test_mikey_config_paths
test_mikey_submissions
```

The layout test expects MIKEY_CODE_LAYOUT_PASS, checks helper/class resolution, cwd-independent template/config paths and rejects an overlay duplicate in an isolated fake folder. The submission test only prepares scripts and checks their Bash syntax; it does not launch jobs. Its earlier malformed literal-text insertion was repaired while reviewing this migration. README's duplicated fragment from the same text-substitution issue was also repaired. These are source corrections, not claims of executed validation.

For a real SPM stage check, keep the selected config parameters in one file and execute the intended step using run_mikey. Existing results may be skipped; review the actual run log and source manifest. Validate GUI launch/default paths and Pause/Stop behavior in a fresh GUI-capable server session as appropriate. Source snapshot identifies this revision because the original delivery folder has no Git checkout.

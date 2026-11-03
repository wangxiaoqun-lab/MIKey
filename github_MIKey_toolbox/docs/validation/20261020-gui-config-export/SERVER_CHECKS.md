# Server-only checks for GUI configuration export

These checks are provided for the user to run on the server. No local MATLAB, GUI or code-check process was launched for this update.

In MATLAB at the toolbox root:

```matlab
addpath(pwd); addpath('examples'); addpath('tests');
test_mikey_config_export; % Configuration round trip, quotes, Unicode, inactive values, file refresh.
% Management node with GUI support:
test_mikey_ui_layout;   % Labels, shared block order, footer, control bounds and overlap.
```

Manual workflow: open MIKey, check Use Custom in Step 14 and the two English file labels, verify shared parameters appear above Step 17, select valid Steps and choose Export Config (.m). Save as examples/mikey_config_gui.m. The command printed in the status log includes the exact configuration filename. If parcellation is selected, choose its mode before export.

```matlab
addpath('examples');
run_mikey('examples/mikey_config_gui.m');
```

Use Step 1 alone, manually prepare masks, then edit only cfg.steps=2:10 in that same exported file and rerun. The README includes the MATLAB R2018a-compatible server shell command. Reopen the updated GUI in a fresh idle MATLAB session after copying the complete toolbox.

Validation status: pending user execution on server. No PASS markers are claimed for these changes.

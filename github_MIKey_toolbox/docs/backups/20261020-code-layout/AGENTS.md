# Toolbox delivery

- Edit this original toolbox folder directly and preserve the existing GUI layout except for explicit user-requested adjustments.
- The user uploads the entire folder to the server. Do not create release ZIPs, patch archives, or additional packaged copies unless the user explicitly requests them.
- Preserve compressed NIfTI (`.nii.gz`) images, templates, data, and user configuration. They are not release archives.
- Keep general-script parameters in one selected configuration function: `examples/mikey_config_example.m` by default, or the GUI-exported `.m` chosen by the user. Do not duplicate parameters in `run_mikey.m`.

- Validation is server-only by user request: do not run local tests or launch local MATLAB. The user performs server testing. Record requested changes and provide server commands instead.

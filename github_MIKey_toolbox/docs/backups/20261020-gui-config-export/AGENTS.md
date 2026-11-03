# Toolbox delivery

- Edit this original toolbox folder directly and preserve the existing GUI layout.
- The user uploads the entire folder to the server. Do not create release ZIPs, patch archives, or additional packaged copies unless the user explicitly requests them.
- Preserve compressed NIfTI (`.nii.gz`) images, templates, data, and user configuration. They are not release archives.
- General-script user parameters belong only in `examples/mikey_config_example.m`.

- Validation is server-only by user request: do not run local tests or launch local MATLAB. The user performs server testing. Record requested changes and provide server commands instead.

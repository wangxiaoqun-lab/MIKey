# Server-only 296/592 atlas checks

No local MATLAB, tests, code checks or GUI were launched for this update. Run on the server after copying the complete toolbox:

```matlab
addpath(pwd); addpath('tests');
test_mikey_atlases;
test_mikey_config_choices;
test_mikey_config_scopes;
test_mikey_config_export;
% On the GUI-capable management node:
test_mikey_gui_filters;
```

These checks cover menu/config choices, required paths, .m round trips, missing-network diagnostics and scoped parameters. They do not estimate FC or establish the scientific suitability of a selected network prior.

Reopen MIKey. Step 13 Label includes 296 and 592; Step 14 ROI Atlas includes 296rois and 592rois. FC reads the bundled ROI label file directly. For Step 14 with either new atlas, supply a suitable Group Network file: the AMCP_temp folder has no matching 296/592 network prior. Use Custom still permits a separate network prior and ROI label atlas.

Script values: cfg.fcLabel='296' or '592'; cfg.parcNetwork='296rois' or '592rois'. For parcellation with these atlases, set cfg.groupNetworkPath explicitly. Do not repeat preprocessing just to change the selected later-stage atlas.

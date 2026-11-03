MIKey Toolbox - GUI and Headless MATLAB/SPM12

The maintained guide is README.md in this directory.
It covers MATLAB Set Path, installation, all GUI parameters,
MIKey_run(config), BIDS layout limitations, Slurm/PBS submission,
logs, troubleshooting, and validation.

Quick start in MATLAB (edit SPM and BIDS paths):
  addpath('K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main');
  cfg = MIKey_defaults();
  cfg.spmPath = '/absolute/path/spm12';
  cfg.bidsPath = '/absolute/path/BIDS_work';
  cfg.steps = 1;
  cfg.dryRun = true;
  MIKey_run(cfg);

Use MIKey with no arguments to open the GUI.
Create masks externally between steps 1 and 2.
Original readme: docs/backups/20261012-headless/readme.txt.original

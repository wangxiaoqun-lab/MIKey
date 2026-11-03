# Restore physical FD units

Implementation completed in the original toolbox folder. The user will validate on the server; do not run further local tests.

Both FD metrics divide by the configured Step 1 factor and record physical-mm units and scale. Existing GUI Scale and cfg.voxelScaleFactor are reused. Old caches regenerate; conflicting Step 1 provenance is rejected. GUI layout and user assignments remain unchanged.

Already executed validation and the local MATLAB shutdown failure are recorded in runs/20261019-fd-physical-units/RUN_REPORT.md. The final independent no-GUI check exited 0. No server validation is claimed.

# Configuration path resolution

Implemented a shared resolver for run_mikey and .m configuration import. Fix duplicate examples/examples paths by resolving relative filenames from cwd, then the toolbox root, and bare filenames also from examples. Preserve exact absolute paths.

Server validation pending the user; no local tests or MATLAB. See runs/20261020-config-path-resolution/RUN_REPORT.md.

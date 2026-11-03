#!/usr/bin/env bash
#PBS -N MIKey
#PBS -l select=1:ncpus=4:mem=16gb
#PBS -l walltime=04:00:00
#PBS -j oe
#PBS -V
# Adapt resource syntax and add your site's queue/account directives.
set -euo pipefail
: "${MIKEY_ROOT:?Export an absolute toolbox path before qsub}"
: "${MIKEY_CONFIG:?Export an absolute MAT/JSON config path before qsub}"
cd "${PBS_O_WORKDIR:?PBS_O_WORKDIR is unavailable}"
# If required by your site: module load matlab/R2023b
command -v matlab >/dev/null
test -f "$MIKEY_ROOT/examples/mikey_cluster_job.m"
test -f "$MIKEY_CONFIG"
matlab -nodisplay -batch "run(fullfile(getenv('MIKEY_ROOT'),'examples','mikey_cluster_job.m'))"

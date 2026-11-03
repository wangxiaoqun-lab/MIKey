#!/usr/bin/env bash
#SBATCH --job-name=MIKey
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=slurm-%j.log
# Add your site's --partition/--account directives before submitting.
set -euo pipefail
: "${MIKEY_ROOT:?Export an absolute toolbox path before sbatch}"
: "${MIKEY_CONFIG:?Export an absolute MAT/JSON config path before sbatch}"
# If required by your site: module load matlab/R2023b
command -v matlab >/dev/null
test -f "$MIKEY_ROOT/examples/mikey_cluster_job.m"
test -f "$MIKEY_CONFIG"
matlab -nodisplay -batch "run(fullfile(getenv('MIKEY_ROOT'),'examples','mikey_cluster_job.m'))"

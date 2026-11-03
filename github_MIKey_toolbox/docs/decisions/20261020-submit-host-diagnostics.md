# Preserve the site's execution model

A MATLAB-capable compute node need not be an authorized SGE submit host. Do not conflate direct run_mikey execution with queue submission or attempt to bypass host policy. Use the existing direct entry when requested; inspect the site's mrun implementation before prescribing wrapper syntax. Report confirmed successful submission counts rather than assuming any earlier jobs exist.

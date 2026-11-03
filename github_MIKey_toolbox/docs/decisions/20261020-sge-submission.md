# Explicit Grid Engine support

The user's qsub belongs to SGE 8.1.9, which requires distinct flags from PBS. Expose sge explicitly rather than guessing a scheduler from the qsub executable name. Use native SGE job directives and site defaults; queues, PE names and resource complexes remain user/site inputs. Preserve complete-cohort requirements for inter-subject variability. Pin the current MATLAB executable for job startup.

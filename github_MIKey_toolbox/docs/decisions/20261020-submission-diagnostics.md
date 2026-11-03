# Cohort options and scheduler availability

Keep collision checks for cohort writers. Do not silently disable useInterSubjectVar to allow per-subject jobs. A user retaining that option selects the intended cohort in one job; individual jobs do not currently consume a separately estimated variability map. Select a scheduler only when its executable/environment exists; do not auto-fallback between scheduler families. Probe PATH through /bin/sh for consistent shell syntax.

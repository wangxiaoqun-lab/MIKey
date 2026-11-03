# FD definitions and group selection

After clarification, the user selected Power L1 and Euclidean L2 on backward differences of raw SPM motion parameters. Rotational differences in radians are converted using a configurable radius in the same units as translations. Default Euclidean follows the user's preference; radius 100 retains the old conversion scale. Pearson CC excludes the first frame with no predecessor. No claim of universal L2 superiority is made.

The existing regression basis is retained. Definition metadata and raw motion are saved and compared for cache reuse. Legacy and mixed definitions must be recomputed before group pooling. Step 11 requires every selected run and selects the global minimum of mean(abs(CC)); deterministic ties use existing strategy order. No local-trend heuristic remains. A compact GUI settings button adds the options without moving existing controls; scripts edit only the general configuration function.

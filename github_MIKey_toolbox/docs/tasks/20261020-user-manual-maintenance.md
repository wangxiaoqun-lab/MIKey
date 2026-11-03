# Bilingual manuals and public source maintenance

Completed: Chinese and English Word guides, each 16 pages, with all 17 steps, GUI use, GUI config import/edit/export then run_mikey, direct config editing, server/multi-config jobs, full parameter reference, masks, FD, outputs, cleanup, integrity and troubleshooting. Both latest renders were inspected on every page.

Removed 142 unreachable legacy custom functions from scripts at the user's request. The dependency roots include GUI, all MIKey public helpers, example runners/configs and tests. Literal string/comment references and case-insensitive matches are retained conservatively. The user explicitly requested deletion without backups; this turn's temporary backup was deleted. Existing historical records were not changed.

Retained 82 previous core/dependency functions and added MIKey_verify_installation.m (83 scripts). Published .m source remains readable. Protected 125 manifest-listed core/runners/tests/maintenance files and the manifest itself (126 read-only items on Windows). All four existing mikey_config*.m functions remain editable; data and saved configs are unchanged.

Validation completed: read-only filesystem dependency/reference review, retained-source checks, core SHA-256 agreement and Windows attributes. No local MATLAB launch, pipeline/syntax test, server experiment or scheduler submission. Server MATLAB validation of the new checker and post-removal functionality remains pending.

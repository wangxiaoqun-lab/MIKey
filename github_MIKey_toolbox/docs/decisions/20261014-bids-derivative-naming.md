# Derivative naming and compatibility

Date: 2026-10-14.

New primary images place source entities, spatial reference and processing description before the appropriate data-type suffix. A shared helper is used by writers and readers so downstream stages do not depend on the old misplaced suffix.

Input lookup prefers an existing canonical path, then its exact legacy path. Existing user outputs are not migrated automatically. Cache-existence checks and new writes use canonical paths, avoiding a mismatch in mixed old/new derivative folders. Native SPM filenames and rp files are resolved from the actual selected input name.

Coregistered anatomy keeps T2w semantics and lives in anat; mean functional references use boldref; discrete parcellations use dseg. Numeric modulated density maps keep their existing scientific meaning and are documented as custom auxiliary statistic maps, not probability segmentations.

Preserve existing sidecars. New metadata records raw ancestry separately from direct Sources, using direct raw Sources only for copy/scaling stages where supported by the actual operation. Do not infer that all intermediate outputs take raw data directly.

References: https://bids-specification.readthedocs.io/en/stable/derivatives/introduction.html and https://bids-specification.readthedocs.io/en/stable/derivatives/imaging.html . This implementation is not a full BIDS Validator certification of custom analysis artifacts.

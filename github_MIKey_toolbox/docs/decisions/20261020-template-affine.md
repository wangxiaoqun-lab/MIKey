# Explicit header-only translation of the template library

The owner requested all toolbox templates use the existing database shared-template affine. The 16 images have identical spatial dimensions/orientation/spacing, so only translations were transferred in both NIfTI qform and sform. The five-volume TPM shares the same affine across volumes. Label/probability/intensity payloads were not resampled, and tables without spatial headers were not changed. Original header bytes and payload hashes provide an exact compact record without copying full images.

The old and new NIfTI zero-based translations are [-112.10980224609375,-83.44133758544922,152.00149536132812] and [-113.443359375,-99.43016815185547,169.7859344482422]. Existing AMCP BOLD retains the old translation. The user's naming/space confirmation is recorded, but renaming is not new MIKey computation and does not make the newly shifted template spatially compatible. BOLD/images/transforms are not silently rebased or resampled.

To avoid new Step 17 results being written to a stale old-origin grid, normalization bounding-box bounds follow the actual template. Other fitting parameters stay as in the original five-class route. Bundled templates were added to the core integrity and read-only lists.


## Superseded origin

The subsequent owner request restored the 16 toolbox headers and moved the database shared T2w header to the exact existing BOLD affine. See docs/validation/20261020-template-affine-bold/verification.json for current state. Earlier mismatch statements above describe the historical state.

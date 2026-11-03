# FD spatial units

Step 10 saves FD in physical mm, obtained by dividing the L1 or L2 displacement in the enlarged SPM coordinate space by the actual Step 1 voxelScaleFactor. The GUI reuses its existing Scale field and the generic script reuses cfg.voxelScaleFactor, active for Steps 1 and 10. fdRadius retains its established meaning in enlarged SPM translation units; metadata additionally records physicalRotationRadius=fdRadius/voxelScaleFactor.

Version-2 fd_info records output mm, input coordinate convention and scale. Version-1 caches must be recomputed by Step 10; Step 11 rejects missing, obsolete or mixed definitions. Recorded Step 1 scale metadata must agree with the configured factor; older images without scale provenance use the user setting. Do not rewrite image headers, raw rp values or the regression design for this unit conversion. New metadata writing outside Step 1 must not attribute existing image geometry to the current FD scale setting.

Deliver the original updated folder without archives; preserve GUI layout and user configuration values.

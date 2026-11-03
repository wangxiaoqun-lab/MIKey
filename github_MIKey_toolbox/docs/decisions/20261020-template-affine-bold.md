# BOLD-matched template translation

Status: complete (header operation and payload verification); server SPM inspection pending.

On 2026-10-20, at the owner request, the database shared T2w template and all 16 toolbox share_temp NIfTI images were assigned the exact affine of the 848 BOLD images. NIfTI zero-based translation is [-112.10980224609375,-83.44133758544922,152.00149536132812]; the corresponding SPM one-based translation is [-114.10980224609375,-85.44133758544922,160.00149536132812]. Only qform/sform translations changed; voxel payloads, dimensions and spacing are unchanged. Header agreement is not a new registration or visual anatomical validation. The separate database tpl-Mousev38_desc-ROIAtlas296_dseg.nii was subsequently included by the owner and now uses the same BOLD affine. The 212 subject-specific space-DWI parcellations retain their valid DWI-space geometry and are not shared template-space atlases. Native functional masks retain their original geometry.

No business code or GUI layout changed. No Git checkout is present; source SHA-256 snapshot records the delivered state. No local MATLAB/tests were run, by user instruction.

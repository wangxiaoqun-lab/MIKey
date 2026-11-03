# Step 17 model and smoothing contract

Use the user-supplied original five-class unified-segmentation helper unchanged. Estimate initial normalization from masked scaled T2, apply to both images and segment normalized unmasked T2. TPM volumes 1-5 map to GM/WM/CSF/OT/AIR. Smooth only the first three modulated maps with independent segSmoothFWHM (default [6 6 6], original enlarged image-space units). Preserve original outputs and required SPM model/transform files. Do not use old three-class outputs or existence-only caches. Track complete results via JSON plus input/helper fingerprints.

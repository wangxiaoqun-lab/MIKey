# Server validation for shifted templates

Local MATLAB/SPM execution and syntax tests: NOT RUN, by user request. Only image-header parsing, exact byte ranges, full NIfTI payload hashes and source reading were performed locally.

The header verification checks 16 images against the database reference, preserving each payload SHA-256, dimensions, voxel spacing and datatype. AMCP_TPM remains 114x80x38x5. The six allowed float offsets are listed in template_header_plan.json; original headers are recorded there without a full-image backup.

After uploading the exact source-snapshot.json files, run in server MATLAB:

~~~matlab
addpath('/shared/software/MIKey_toolbox_main/scripts');
addpath('/shared/software/MIKey_toolbox_main/tests');
MIKey_setup('/shared/software/spm12');
r=MIKey_verify_installation(); assert(r.ok);
checkcode(which('MIKey_segment_t2'),'-id');
checkcode(which('test_mikey_tissue_segmentation'),'-id');
test_mikey_tissue_segmentation('/shared/software/spm12');
~~~

The routing test now uses a translated 4x5x3 fixture template with SPM affine translation [-10,20,30] and requires bounds [-8,22,38;-2,30,54], proving that the output extent follows the actual template origin rather than an obsolete constant. It is copy-only and does not establish real segmentation accuracy.

For real processing, inspect all new normalized/segmentation outputs against the newly shifted reference in SPM Check Reg and check output grids. Do not reuse old normalized BOLD/labels interchangeably. The existing 848 AMCP BOLD images remain in the prior affine and need a separately authorized spatial reconciliation before joint label/FC/parcellation analysis with the shifted library. Merely disabling strict warnings or changing names does not establish alignment. Reapply read-only permissions with maintenance/set_code_readonly.sh protect after upload.


## Superseded origin

The subsequent owner request restored the 16 toolbox headers and moved the database shared T2w header to the exact existing BOLD affine. See docs/validation/20261020-template-affine-bold/verification.json for current state. Earlier mismatch statements above describe the historical state.

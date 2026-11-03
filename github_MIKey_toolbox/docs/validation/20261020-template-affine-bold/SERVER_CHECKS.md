# Server SPM header check

Latest operation supersedes the earlier shared-template origin change.

```matlab
root = '/newdatc/home/wanglab41/mice_MRI_code_ref/MIKey_toolbox_main';
addpath(fullfile(root,'scripts'));
MIKey_setup('/path/to/spm12');
r = MIKey_verify_installation(); assert(r.ok);
V = spm_vol(fullfile(root,'share_temp','Template_Mouse_v38.nii'));
expected = [2 0 0 -114.10980224609375; 0 2 0 -85.44133758544922; 0 0 -8 160.00149536132812; 0 0 0 1];
assert(max(abs(V(1).mat(:)-expected(:))) < 1e-6);
```

Inspect representative BOLD, labels and template together in SPM Check Reg. Matching header matrices alone does not establish anatomical accuracy. Reapply maintenance/set_code_readonly.sh protect after upload. Local MATLAB and experiments were not run.

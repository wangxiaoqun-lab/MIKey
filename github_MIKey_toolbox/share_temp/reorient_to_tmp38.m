Label_head=spm_vol('Template_Mouse_v38.nii');

all_file=dir('*.nii');
for f=1:numel(all_file)
    h=spm_vol(all_file(f).name);
    vol=size(h,1);
    if vol==1
        data=spm_read_vols(h);
        h.mat=Label_head(1).mat;
        spm_write_vol(h,data);
    else
        data=spm_read_vols(h);
        for v=1:vol
            h(v).mat=Label_head(1).mat;
        end
        spm_write_vol_4D(h,data);
    end
end

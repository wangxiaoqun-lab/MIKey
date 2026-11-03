function EPI2Template_mlb=UN_get_default_oldnormalize_batch_struct(ref, source, other,interp)

     V = spm_vol(ref{:});
     M = V.mat;
     re_voxel = sqrt(sum(M(1:3,1:3).^2));

    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.subj.source = source;
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.subj.resample = other;
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 8;     
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 8;     
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.template = ref;
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'mni';
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;         
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 10;
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.roptions.bb =[NaN NaN NaN;NaN NaN NaN];% [-112.1098  -83.4413 -143.9985; 113.8902   74.5587  152.0015];
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.roptions.vox = re_voxel(:);
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.roptions.interp = interp;    
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [1 1 0];   
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.roptions.prefix = 'norm';
    EPI2Template_mlb{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
end
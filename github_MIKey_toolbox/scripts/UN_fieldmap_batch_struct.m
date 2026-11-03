function matlabbatch=UN_fieldmap_batch_struct(echo1_P,echo1_M,echo2_P,echo2_M,epi_first_vol,template,all_func)
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortphase = echo1_P;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.shortmag = echo1_M;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longphase = echo2_P;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.data.phasemag.longmag = echo2_M;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = [2.4 4.9];
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = -1;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 23;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = template;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.session.epi = epi_first_vol;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 1;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'run';
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 1;
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
matlabbatch{1}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;
%%
%%
matlabbatch{2}.spm.tools.fieldmap.applyvdm.data.scans = all_func; 
%%
matlabbatch{2}.spm.tools.fieldmap.applyvdm.data.vdmfile(1) = cfg_dep('Calculate VDM: Voxel displacement map', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{1}));
matlabbatch{2}.spm.tools.fieldmap.applyvdm.roptions.pedir = 2;
matlabbatch{2}.spm.tools.fieldmap.applyvdm.roptions.which = [2 1];
matlabbatch{2}.spm.tools.fieldmap.applyvdm.roptions.rinterp = 4;
matlabbatch{2}.spm.tools.fieldmap.applyvdm.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.tools.fieldmap.applyvdm.roptions.mask = 1;
matlabbatch{2}.spm.tools.fieldmap.applyvdm.roptions.prefix = 'fieldmap';
end
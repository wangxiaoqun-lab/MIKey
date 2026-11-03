function out = MIKey_tissue_paths(directory, base)
% Stable BIDS output names for the five-class Step 17 workflow.
stem=regexprep(base,'_T2w$','');out=struct();
out.normalized=MIKey_bids_path(directory,[base '_space-template_desc-segInput.nii']);
out.masked=MIKey_bids_path(directory,[base '_space-template_desc-segMasked.nii']);
out.labels={'GM','WM','CSF','OT','AIR'};
for i=1:5
    tissue=out.labels{i};
    out.native{i}=fullfile(directory,[stem '_space-template_label-' tissue '_desc-fiveClass_probseg.nii']);
    out.imported{i}=fullfile(directory,[stem '_space-segDartel_label-' tissue '_desc-fiveClass_probseg.nii']);
    out.warped{i}=fullfile(directory,[stem '_space-template_label-' tissue '_desc-fiveClassWarped_probseg.nii']);
    out.modulated{i}=fullfile(directory,[stem '_space-template_label-' tissue '_desc-fiveClassModulated_statmap.nii']);
    if i<=3
        out.smoothed{i}=fullfile(directory,[stem '_space-template_label-' tissue '_desc-fiveClassModulatedSmoothed_statmap.nii']);
    end
end
out.biasField=fullfile(directory,[stem '_space-template_desc-fiveClassBiasField_statmap.nii']);
out.biasCorrected=MIKey_bids_path(directory,[base '_space-template_desc-fiveClassBiasCorrected.nii']);
out.deformation=fullfile(directory,[stem '_from-segInput_to-template_mode-image_desc-fiveClass_xfm.nii']);
out.normalizationParameters=fullfile(directory,[stem '_from-scaledT2w_to-template_mode-image_desc-fiveClass_xfm.mat']);
out.segmentationParameters=fullfile(directory,[stem '_from-segInput_to-template_mode-image_desc-fiveClassModel_xfm.mat']);
out.complete=[out.native{1}(1:end-4) '.json'];
out.required=[{out.normalized,out.masked} out.native out.imported out.warped out.modulated out.smoothed ...
    {out.biasField,out.biasCorrected,out.deformation,out.normalizationParameters,out.segmentationParameters}];
end

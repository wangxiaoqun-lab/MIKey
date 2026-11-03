function [step, description, protected] = MIKey_cleanup_classify(relative)
% Recognize MIKey outputs only. Unrecognized/user-supplied files stay protected.
r=strrep(relative,'\','/'); [~,name,ext]=fileparts(r);
filename=[name ext]; step=0; description='Unrecognized file (protected)'; protected=true;
if startsWith(r,'logs/') || strcmp(r,'dataset_description.json') || ...
        ~isempty(regexpi(filename,'brainmask|brain_mask|_mask\.|config|\.m$|\.sh$','once'))
    description='Mask, configuration, log or dataset metadata (protected)'; return;
end
allowed=~isempty(regexpi(filename,'\.(nii(\.gz)?|mat|json|txt|tsv|csv|png|fig|pdf)$','once'));
if ~allowed, return; end
if startsWith(r,'group_analysis/')
    if ~isempty(regexp(filename,'^(best_regression_strategy|group_level_noise_estimation)([_.]|$)','once'))
        step=11; description='Cohort noise strategy / CC summaries';
    elseif startsWith(filename,'InterSubjectVariability')
        step=14; description='Shared Steps 14-16: inter-subject variability';
    end
elseif ~isempty(regexp(r,'^sub-[^/]+/(ses-[^/]+/)?(anat|func|fmap)/','once'))
    if contains(r,'/registration_qc/')
        token=regexp(filename,'_desc-step([67])','tokens','once');
        if ~isempty(token), step=str2double(token{1}); description='Registration QC report'; end
    elseif contains(r,'_parcellation_') || contains(r,'/concatenated') || startsWith(filename,'dice_cross_runs_')
        if contains(r,'_clust_') || contains(r,'/clust_'), step=15;
        elseif contains(r,'_voxel_') || contains(r,'/voxel_'), step=16;
        else, step=14; end
        description='Parcellation maps, FC, iteration / tSNR / concatenation results';
    elseif ~isempty(regexp(filename,'_desc-(fiveClass|segInput|segMasked)|_desc-(gmvol|wmvol|csfvol|modulatedDensity)','once'))
        step=17; description='Five-class segmentation / normalized inputs / SPM model';
    elseif contains(filename,'regionFC_')
        step=13; description='ROI functional connectivity and label IDs';
    elseif contains(filename,'_desc-advancedRegressionResults') || contains(filename,'_desc-Regressedpc')
        step=12; description='Final regressed BOLD / regression results';
    elseif contains(filename,'_desc-regressionResults') || ~isempty(regexp(filename,'_desc-regressed\d+pc','once'))
        step=10; description='Candidate PC regressions / FD-DVARS CC results';
    elseif contains(filename,'_desc-NBPCs')
        step=9; description='Non-brain principal components';
    elseif contains(filename,'_desc-smoothed')
        step=8; description='Smoothed BOLD';
    elseif contains(filename,'_desc-T2normalized') || contains(filename,'_desc-normalized') || endsWith(filename,'_sn.mat')
        step=7; description='Normalized images / normalization parameters';
    elseif contains(filename,'_desc-T2coreg')
        step=6; description='Coregistered T2w';
    elseif contains(filename,'_desc-realign') || contains(filename,'_desc-mean') || startsWith(filename,'rp_')
        step=5; description='Realigned BOLD / mean BOLD / motion rp';
    elseif contains(filename,'_desc-slicetimed')
        step=4; description='Slice-timing corrected BOLD';
    elseif contains(filename,'_desc-fieldmap') || ~isempty(regexp(filename,'^(vdm|fpm|sc|u).*sub-','once'))
        step=3; description='Fieldmap corrected BOLD / SPM fieldmap outputs';
    elseif contains(filename,'_desc-masked')
        step=2; description='Brain-masked BOLD / T2w';
    elseif contains(filename,'_desc-scaled') || contains(filename,'_desc-orig')
        step=1; description='Scaled image / desc-orig duplicate (raw BIDS retained)';
    elseif contains(filename,'_desc-tSNR')
        step=14; description='Shared Steps 14-16: tSNR map';
    end
end
protected=step==0;
end

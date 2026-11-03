function atlas = MIKey_atlas_catalog(choice)
% Single catalogue for FC ROI labels and prior-based parcellation choices.
labels={'214','296','428','592','604','1184'};
networks={'AMCP_214prior_11net.nii','','AMCP_428prior_11net.nii','', ...
    'AMCP_604prior_12net.nii','AMCP_1184prior_13net.nii'};
atlas=repmat(struct('label','','parcellation','','labelFile','','networkFile',''),1,numel(labels));
for i=1:numel(labels)
    atlas(i).label=labels{i};atlas(i).parcellation=[labels{i} 'rois'];
    atlas(i).labelFile=['Label_Mouse_' labels{i} '_v38.nii'];
    atlas(i).networkFile=networks{i};
end
if nargin==0,return;end
if isstring(choice) && isscalar(choice),choice=char(choice);end
if ~ischar(choice) || ~isrow(choice)
    error('MIKey:AtlasChoice','Specify a supported ROI label or parcellation choice.');
end
selected=strcmp(choice,{atlas.label}) | strcmp(choice,{atlas.parcellation});
if ~any(selected),error('MIKey:AtlasChoice','Unsupported atlas choice: %s',choice);end
atlas=atlas(selected);
end

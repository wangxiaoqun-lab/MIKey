function files = MIKey_sidecar_snapshot(cfg, checkpoint)
% Track image/MAT pairs within selected derivative modality directories only.
if nargin<2,checkpoint=@() [];end
files=struct('image',{},'imageBytes',{},'imageStamp',{},'matBytes',{},'matStamp',{});
if any(ismember(cfg.steps,[9 10 11 13])) && numel(cfg.steps)==1,return;end
scopes=MIKey_subjects(cfg);
root=fullfile(cfg.bidsPath,'derivatives','MIKey');
for i=1:numel(scopes)
    checkpoint();
    for modality={'func','anat','fmap'}
        images=dir(fullfile(root,scopes(i).name,modality{1},'**','*.nii'));
        for j=1:numel(images)
            checkpoint();
            image=fullfile(images(j).folder,images(j).name);
            sidecar=dir([image(1:end-4) '.mat']);
            if numel(sidecar)~=1 || sidecar.isdir,continue;end
            files(end+1)=struct('image',image,'imageBytes',images(j).bytes, ...
                'imageStamp',images(j).datenum,'matBytes',sidecar.bytes,'matStamp',sidecar.datenum); %#ok<AGROW>
        end
    end
end
end

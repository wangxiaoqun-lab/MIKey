function MIKey_write_derivative_metadata(cfg)
% Describe the derivative dataset and add JSON to newly named primary images.
root=fullfile(cfg.bidsPath,'derivatives','MIKey');
if ~exist(root,'dir'),mkdir(root);end
descriptionPath=fullfile(root,'dataset_description.json');description=struct();
if exist(descriptionPath,'file'),description=jsondecode(fileread(descriptionPath));end
if ~isfield(description,'Name'),description.Name='MIKey mouse MRI derivatives';end
if ~isfield(description,'BIDSVersion'),description.BIDSVersion='1.11.2';end
description.DatasetType='derivative';
if ~isfield(description,'GeneratedBy'),description.GeneratedBy=struct('Name','MIKey');end
generators=description.GeneratedBy;
if isstruct(generators),generators=num2cell(generators);end
if ~iscell(generators),generators={};end
if ~any(cellfun(@(x) isstruct(x) && isfield(x,'Name') && strcmp(x.Name,'MIKey'),generators))
    generators{end+1}=struct('Name','MIKey');
end
description.GeneratedBy=generators;
if ~isfield(description,'DatasetLinks'),description.DatasetLinks=struct();end
rawDirectory=java.io.File(cfg.bidsPath);
description.DatasetLinks.raw=char(rawDirectory.toURI().toASCIIString());
writeJSON(descriptionPath,description);
scopes=MIKey_subjects(cfg);
for i=1:numel(scopes)
    raw=fullfile(cfg.bidsPath,scopes(i).name);
    derived=fullfile(root,scopes(i).name);
    for modality={'func','anat','fmap'}
        rawFolder=fullfile(raw,modality{1});
        if strcmp(modality{1},'anat'),rawFolder=MIKey_anat_path(raw);end
        if strcmp(modality{1},'func'),sources=MIKey_bold_files(rawFolder,cfg);
        elseif strcmp(modality{1},'anat'),sources=MIKey_nifti_files(rawFolder,'*_T2w.nii');
        else,sources=MIKey_nifti_files(rawFolder);end
        images=dir(fullfile(derived,modality{1},'**','sub-*.nii'));
        for j=1:numel(images)
            name=images(j).name;
            if ~strcmp(name,MIKey_bids_name(name)),continue;end
            jsonPath=fullfile(images(j).folder,[name(1:end-4) '.json']);
            if exist(jsonPath,'file'),continue;end
            suffix=regexp(name,'_([A-Za-z0-9]+)\.nii$','tokens','once');
            if isempty(suffix),continue;end
            if strcmp(suffix{1},'mask'),continue;end % User-prepared inputs have their own provenance.
            matches=false(size(sources));
            specificity=zeros(size(sources));
            outputDesc=regexp(name,'_desc-([^_]+)','tokens','once');
            for k=1:numel(sources)
                referenceT2=~isempty(regexp(name,'_desc-T2(?:coreg|normalized)_T2w\.nii$','once'));
                keys={'sub','ses','task','acq','rec','dir','run','echo','part'};
                if referenceT2,keys={'sub','ses'};end
                matches(k)=compatible(name,sources(k).name,keys);
                sourceDesc=regexp(sources(k).name,'_desc-([^_]+)','tokens','once');
                if ~isempty(sourceDesc)
                    if isempty(outputDesc) || ~strncmp(outputDesc{1},sourceDesc{1},numel(sourceDesc{1}))
                        matches(k)=false;
                    else
                        specificity(k)=numel(sourceDesc{1});
                    end
                end
                if strcmp(modality{1},'fmap')
                    matches(k)=matches(k) && ~isempty(regexp(sources(k).name,['_' suffix{1} '\.nii$'],'once'));
                end
            end
            if any(matches & specificity>0),matches=matches & specificity==max(specificity(matches));end
            chosen=sources(matches);if isempty(chosen),continue;end
            metadata=struct();ancestry=cell(1,numel(chosen));
            for k=1:numel(chosen)
                source=fullfile(chosen(k).folder,chosen(k).sourceName);
                rawRoot=regexprep(cfg.bidsPath,'[\\/]+$','');
                relative=source(numel(rawRoot)+2:end);
                ancestry{k}=['bids:raw:' strrep(relative,'\','/')];
            end
            % Raw ancestry is explicit; do not pretend every raw image was a
            % directly used input to every subsequent processing operation.
            metadata.MIKeyRawSources=ancestry;
            descriptor=regexp(name,'_desc-([^_]+)','tokens','once');
            descriptorValue='';if ~isempty(descriptor),descriptorValue=descriptor{1};end
            rawCopy=~isempty(regexp(descriptorValue,'(?:orig|scaled)$','once'));
            if rawCopy,metadata.Sources=ancestry;end
            if any(strcmp(suffix{1},{'bold','T2w','magnitude1','magnitude2','phase1','phase2','phasediff','epi','boldref'}))
                metadata.SkullStripped=~rawCopy;
            elseif strcmp(suffix{1},'mask')
                metadata.Type='Brain';
            end
            if numel(chosen)==1
                sidecar=fullfile(chosen(1).folder,[chosen(1).name(1:end-4) '.json']);
                if exist(sidecar,'file')
                    original=jsondecode(fileread(sidecar));
                    fields={'EchoTime'};
                    if strcmp(suffix{1},'bold'),fields={'RepetitionTime','TaskName','EchoTime'};end
                    if strcmp(modality{1},'fmap'),fields={'EchoTime','EchoTime1','EchoTime2','Units'};end
                    for field=fields
                        if isfield(original,field{1}),metadata.(field{1})=original.(field{1});end
                    end
                    if rawCopy && isfield(original,'SkullStripped'),metadata.SkullStripped=original.SkullStripped;end
                end
            end
            if ~isempty(strfind(name,'_space-template_')) %#ok<STREMP>
                template=fullfile(cfg.templatePath,'Template_Mouse_v38.nii');
                if ~cfg.useDefaultTemplate && ~isempty(cfg.customTemplatePath),template=cfg.customTemplatePath;end
                templateFile=java.io.File(template);
                metadata.SpatialReference=char(templateFile.toURI().toASCIIString());
            elseif ~isempty(strfind(name,'_space-bold_')) %#ok<STREMP>
                references=MIKey_bold_files(fullfile(raw,'func'),cfg);
                for reference=1:numel(references)
                    base=references(reference).name(1:end-4);
                    if strcmp(name,MIKey_bids_name([base '_desc-T2coreg.nii']))
                        target=MIKey_bids_path(fullfile(derived,'func'),[base '_desc-mean.nii'],'input');
                        if exist(target,'file')
                            metadata.SpatialReference=['bids::' strrep(target(numel(root)+2:end),'\','/')];
                        end
                        break;
                    end
                end
            end
            metadata.MIKeyVoxelScaleFactor=cfg.voxelScaleFactor;
            writeJSON(jsonPath,metadata);
        end
    end
end
end

function matches=compatible(output,input,keys)
matches=true;
for key=keys
    expression=['(?:^|_)' key{1} '-([^_]+)'];
    a=regexp(output,expression,'tokens','once');b=regexp(input,expression,'tokens','once');
    if ~isempty(a) && ~isempty(b) && ~strcmp(a{1},b{1}),matches=false;return;end
end
end

function writeJSON(path,value)
folder=fileparts(path);temporary=[tempname(folder) '.json'];
fid=fopen(temporary,'w','n','UTF-8');if fid<0,error('MIKey:Metadata','Cannot write %s',path);end
closer=onCleanup(@() fclose(fid));
try
    fprintf(fid,'%s\n',jsonencode(value));clear closer;
    movefile(temporary,path,'f');
catch ME
    clear closer;
    if exist(temporary,'file'),delete(temporary);end
    rethrow(ME);
end
end

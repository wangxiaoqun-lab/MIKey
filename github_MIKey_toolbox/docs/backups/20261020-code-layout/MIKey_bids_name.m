function name = MIKey_bids_name(name)
% Put processing entities before the image suffix; preserve SPM work prefixes.
extension=regexp(name,'\.nii(?:\.gz)?(?:,\d+)?$','match','once');
if isempty(extension),return;end
stem=name(1:end-numel(extension));parts=strsplit(stem,'_');
suffix='';keep=true(size(parts));
known={'bold','T2w','T1w','magnitude1','magnitude2','phase1','phase2','phasediff','fieldmap','epi','dwi','boldref','mask','dseg','probseg','statmap'};
for i=1:numel(parts)
    if any(strcmp(parts{i},known)),suffix=parts{i};keep(i)=false;break;end
end
parts=parts(keep);descs={};entities={};
for i=1:numel(parts)
    if strncmp(parts{i},'desc-',5)
        descs{end+1}=parts{i}(6:end); %#ok<AGROW>
    elseif isempty(strfind(parts{i},'-')) && ~isempty(descs) %#ok<STREMP>
        descs{end}=[descs{end} parts{i}];
    else
        entities{end+1}=parts{i}; %#ok<AGROW>
    end
end
description=strjoin(descs,'');
if any(strcmp(descs,'mean')),suffix='boldref';end
if any(strcmp(descs,'T2coreg')) || any(strcmp(descs,'T2normalized')),suffix='T2w';end
if any(strcmp(descs,'T2coreg')) && ~any(cellfun(@(x) strncmp(x,'space-',6),entities))
    entities{end+1}='space-bold';
end
if ~isempty(strfind(description,'Parcellation')),suffix='dseg';end %#ok<STREMP>
if strncmp(description,'tSNR',4),suffix='statmap';end
for tissue={'gm','wm','csf'}
    if strcmp(description,[tissue{1} 'vol'])
        suffix='statmap';description='modulatedDensity';
        if ~any(cellfun(@(x) strncmp(x,'space-',6),entities)),entities{end+1}='space-template';end
        entities{end+1}=['label-' upper(tissue{1})];
    end
end
if isempty(suffix),return;end
% A source desc and a processing desc combine into one alphanumeric value.
if ~isempty(description),entities{end+1}=['desc-' regexprep(description,'[^A-Za-z0-9]','')];end
name=[strjoin([entities {suffix}],'_') extension];
end

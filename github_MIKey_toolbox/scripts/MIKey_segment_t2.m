function [out, skipped] = MIKey_segment_t2(masked, scaled, directory, base, templatePath, fwhm, checkpoint)
% Match Main2_AD_mice_MRI_1st flag_stage 21, with five-volume AMCP TPM.
if nargin<7,checkpoint=@()[];end
checked=MIKey_config(struct('steps',17,'segSmoothFWHM',fwhm));fwhm=checked.segSmoothFWHM;
out=MIKey_tissue_paths(directory,base);skipped=false;
template=fullfile(templatePath,'Template_Mouse_v38.nii');
tpm=fullfile(templatePath,'AMCP_temp','AMCP_TPM.nii');
for file={masked,scaled,template,tpm}
    if exist(file{1},'file')~=2,error('MIKey:SegmentationInput','Step 17 input missing: %s',file{1});end
end
checkpoint();tpmHead=spm_vol(tpm);
if numel(tpmHead)~=5
    error('MIKey:SegmentationTPM','AMCP_TPM.nii must contain exactly five volumes: GM, WM, CSF, OT, AIR; found %d.',numel(tpmHead));
end
source={[masked ',1']};other=[source;{[scaled ',1']}];ref={[template ',1']};
normalization=UN_get_default_oldnormalize_batch_struct(ref,source,other,2);
% Keep the original stage-21 fitting options; follow the actual template grid
% when its origin is changed instead of retaining an obsolete fixed box.
templateHead=spm_vol(template);templateHead=templateHead(1);
[x,y,z]=ndgrid([1 templateHead.dim(1)],[1 templateHead.dim(2)],[1 templateHead.dim(3)]);
world=templateHead.mat*[x(:)';y(:)';z(:)';ones(1,numel(x))];
normalization{1}.spm.tools.oldnorm.estwrite.roptions.bb= ...
    [min(world(1:3,:),[],2)';max(world(1:3,:),[],2)'];
normalization{1}.spm.tools.oldnorm.estwrite.roptions.wrap=[0 0 0];
normalization{1}.spm.tools.oldnorm.estwrite.roptions.prefix='n';
priors=cell(5,1);for i=1:5,priors{i}=sprintf('%s,%d',tpm,i);end
segmentation=UN_get_segment_batch_struct({[out.normalized ',1']},priors);
% The user-supplied original helper is preserved, including all five tissue
% native/warped outputs, bias outputs and the forward deformation field.
contract=struct('version',2,'algorithm','Main2_flag_stage_21_five_class', ...
    'TPMVolumes',{{'GM','WM','CSF','OT','AIR'}},'SmoothFWHM',fwhm, ...
    'normalization',normalization,'segmentation',segmentation);
contract.inputs=signatures({masked,scaled,template,tpm,which('UN_get_segment_batch_struct'), ...
    which('UN_get_default_oldnormalize_batch_struct'),which('MIKey_segment_t2'), ...
    which('MIKey_tissue_paths'),which('MY_get_default_smooth_batch_struct')},checkpoint);
contractKey=textHash(jsonencode(contract));
if exist(out.complete,'file')==2 && all(cellfun(@(p)exist(p,'file')==2,out.required))
    try
        previous=jsondecode(fileread(out.complete));
        if isfield(previous,'contractKey') && strcmp(previous.contractKey,contractKey)
            skipped=true;return;
        end
    catch
        % An incomplete/old result is recomputed, never accepted as five-class output.
    end
end
if exist(out.complete,'file')==2,delete(out.complete);end
checkpoint();spm_jobman('run',normalization);checkpoint();
publishImage(MIKey_prefixed_file('n',scaled),out.normalized);
publishImage(MIKey_prefixed_file('n',masked),out.masked);
writeImageMetadata(out.normalized,struct('Sources',{{asURI(scaled)}},'SpatialReference',asURI(template),'SkullStripped',false));
writeImageMetadata(out.masked,struct('Sources',{{asURI(masked)}},'SpatialReference',asURI(template),'SkullStripped',true));
[folder,name]=fileparts(masked);
publishFile(fullfile(folder,[name '_sn.mat']),out.normalizationParameters);
checkpoint();spm_jobman('run',segmentation);checkpoint();
% Only the first three modulated images are smoothed, as in stage 21.
modulated=cell(3,1);for i=1:3,modulated{i}=[MIKey_prefixed_file(['mwc' num2str(i)],out.normalized) ',1'];end
smoothing=MY_get_default_smooth_batch_struct(modulated,fwhm);
spm_jobman('run',smoothing);checkpoint();
for i=1:5
    checkpoint();
    publishImage(MIKey_prefixed_file(['c' num2str(i)],out.normalized),out.native{i});
    publishImage(MIKey_prefixed_file(['rc' num2str(i)],out.normalized),out.imported{i});
    publishImage(MIKey_prefixed_file(['wc' num2str(i)],out.normalized),out.warped{i});
    publishImage(MIKey_prefixed_file(['mwc' num2str(i)],out.normalized),out.modulated{i});
    if i<=3,publishImage(MIKey_prefixed_file(['smwc' num2str(i)],out.normalized),out.smoothed{i});end
end
publishImage(MIKey_prefixed_file('BiasField_',out.normalized),out.biasField);
publishImage(MIKey_prefixed_file('m',out.normalized),out.biasCorrected);
writeImageMetadata(out.biasCorrected,struct('Sources',{{asURI(out.normalized)}},'SpatialReference',asURI(out.normalized),'SkullStripped',false));
for i=1:3
    writeImageMetadata(out.smoothed{i},struct('Sources',{{asURI(out.modulated{i})}}, ...
        'SpatialReference',asURI(tpm),'FWHM',fwhm,'FWHMUnits','scaled image-space mm','Tissue',out.labels{i}, ...
        'Description','Smoothed modulated tissue density, not an unmodulated probability map.'));
end
publishImage(MIKey_prefixed_file('y_',out.normalized),out.deformation);
[folder,name]=fileparts(out.normalized);
publishFile(fullfile(folder,[name '_seg8.mat']),out.segmentationParameters);
if ~all(cellfun(@(p)exist(p,'file')==2,out.required))
    error('MIKey:SegmentationOutput','Five-class segmentation output set is incomplete.');
end
record=struct('Description','Five-class tissue segmentation; workflow matches original stage 21.', ...
    'contract',contract,'contractKey',contractKey,'outputs',out,'created',datestr(now,30));
record.Sources={asURI(out.normalized),asURI(tpm)};record.Tissue='GM';record.TPMVolume=1;
record.SpatialReference=asURI(out.normalized);
temporary=[tempname(directory) '.json'];cleanup=onCleanup(@()removeTemporary(temporary)); %#ok<NASGU>
fid=fopen(temporary,'w','n','UTF-8');if fid<0,error('MIKey:SegmentationOutput','Cannot write %s',temporary);end
closeFile=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(record));clear closeFile;
[ok,message]=movefile(temporary,out.complete,'f');if ~ok,error('MIKey:SegmentationOutput','%s',message);end
end
function value=asURI(filename)
file=java.io.File(filename);value=char(file.toURI().toASCIIString());
end
function writeImageMetadata(image,fields)
filename=[image(1:end-4) '.json'];value=struct();
if exist(filename,'file')==2
    try,value=jsondecode(fileread(filename));catch,value=struct();end
end
names=fieldnames(fields);for i=1:numel(names),value.(names{i})=fields.(names{i});end
temporary=[tempname(fileparts(image)) '.json'];cleanup=onCleanup(@()removeTemporary(temporary)); %#ok<NASGU>
fid=fopen(temporary,'w','n','UTF-8');if fid<0,error('MIKey:SegmentationOutput','Cannot write %s',temporary);end
closeFile=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(value));clear closeFile;
[ok,message]=movefile(temporary,filename,'f');if ~ok,error('MIKey:SegmentationOutput','%s',message);end
end
function value=textHash(text)
digest=java.security.MessageDigest.getInstance('SHA-256');digest.update(unicode2native(text,'UTF-8'));
value=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
end
function values=signatures(files,checkpoint)
% SPM can read image geometry from an accompanying MAT, not only the NIfTI.
originalCount=numel(files);
for i=1:originalCount
    [folder,base,extension]=fileparts(files{i});
    companion=fullfile(folder,[base '.mat']);
    if strcmpi(extension,'.nii') && exist(companion,'file')==2,files{end+1}=companion;end %#ok<AGROW>
end
values=struct('file',{},'sha256',{});
for i=1:numel(files)
    checkpoint();fid=fopen(files{i},'rb');if fid<0,error('MIKey:SegmentationInput','Cannot read %s',files{i});end
    closeFile=onCleanup(@()fclose(fid));digest=java.security.MessageDigest.getInstance('SHA-256');
    while ~feof(fid)
        bytes=fread(fid,1048576,'*uint8');digest.update(bytes);checkpoint();
    end
    clear closeFile;
    hash=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
    values(end+1)=struct('file',files{i},'sha256',hash); %#ok<AGROW>
end
end
function publishImage(source,destination)
side=[source(1:end-4) '.mat'];target=[destination(1:end-4) '.mat'];
if exist(target,'file')==2 && exist(side,'file')~=2
    error('MIKey:SegmentationSidecar','Stale image MAT sidecar requires review before replacing %s: %s',destination,target);
end
publishFile(source,destination);
if exist(side,'file')==2,publishFile(side,target);end
end
function publishFile(source,destination)
if exist(source,'file')~=2,error('MIKey:SegmentationOutput','SPM did not create expected output: %s',source);end
[ok,message]=movefile(source,destination,'f');if ~ok,error('MIKey:SegmentationOutput','%s',message);end
end
function removeTemporary(filename)
if exist(filename,'file'),delete(filename);end
end

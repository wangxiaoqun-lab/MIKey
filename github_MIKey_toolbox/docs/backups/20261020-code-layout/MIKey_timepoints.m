function count = MIKey_timepoints(source)
% Read temporal dimension from the NIfTI header, without unpacking a gzip image.
if numel(source)>=7 && strcmp(source(end-6:end),'.nii.gz')
    input=java.io.FileInputStream(source);
    inputCloser=onCleanup(@() input.close()); %#ok<NASGU>
    stream=java.util.zip.GZIPInputStream(input);
    closer=onCleanup(@() stream.close()); %#ok<NASGU>
    bytes=zeros(1,80,'uint8');
    for i=1:80
        value=stream.read();
        if value<0,error('MIKey:NIfTIHeader','Incomplete NIfTI header: %s',source);end
        bytes(i)=uint8(value);
    end
else
    fid=fopen(source,'rb');
    if fid<0,error('MIKey:NIfTIHeader','Cannot open NIfTI input: %s',source);end
    closer=onCleanup(@() fclose(fid)); %#ok<NASGU>
    bytes=fread(fid,80,'*uint8')';
end
if numel(bytes)<80,error('MIKey:NIfTIHeader','Incomplete NIfTI header: %s',source);end
little=number(bytes(1:4),true);
if ismember(little,[348 540])
    isLittle=true;headerSize=little;
else
    isLittle=false;headerSize=number(bytes(1:4),false);
end
if headerSize==348
    dimensions=number(bytes(41:42),isLittle);
    count=number(bytes(49:50),isLittle);
elseif headerSize==540
    dimensions=number(bytes(17:24),isLittle);
    count=number(bytes(49:56),isLittle);
else
    error('MIKey:NIfTIHeader','Unsupported or invalid NIfTI header: %s',source);
end
if dimensions<1 || dimensions>7,error('MIKey:NIfTIHeader','Invalid NIfTI dimensions: %s',source);end
if dimensions<4,count=1;end
if ~isfinite(count) || count<1 || count>flintmax || count~=fix(count)
    error('MIKey:NIfTIHeader','Invalid temporal dimension: %s',source);
end
end

function value=number(bytes,isLittle)
if ~isLittle,bytes=bytes(end:-1:1);end
value=sum(double(bytes).*256.^(0:numel(bytes)-1));
if bytes(end)>=128,value=value-256^numel(bytes);end
end

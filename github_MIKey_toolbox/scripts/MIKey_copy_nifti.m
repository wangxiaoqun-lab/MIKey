function MIKey_copy_nifti(source, destination, checkpoint)
% Copy/decompress an input into the existing uncompressed processing workflow.
if nargin >= 3
    copyWithCheckpoints(source, destination, checkpoint);
    return;
end
[readable,cleanup] = MIKey_readable_nifti(source); %#ok<ASGLU>
copyfile(readable,destination);
end

function copyWithCheckpoints(source, destination, checkpoint)
% Bounded Java NIO transfers also allow cancellation during gzip extraction.
checkpoint();
temporary = [tempname(fileparts(destination)) '.nii'];
input = javaObject('java.io.FileInputStream', source);
inputCleanup = onCleanup(@() input.close()); %#ok<NASGU>
if numel(source) >= 7 && strcmpi(source(end-6:end), '.nii.gz')
    input = javaObject('java.util.zip.GZIPInputStream', input);
    gzipCleanup = onCleanup(@() input.close()); %#ok<NASGU>
end
output = javaObject('java.io.FileOutputStream', temporary);
transferCleanup = onCleanup(@() closeTransfer(output,input,temporary)); %#ok<NASGU>
reader = javaMethod('newChannel', 'java.nio.channels.Channels', input);
writer = output.getChannel();
buffer = javaMethod('allocate', 'java.nio.ByteBuffer', 8*1024*1024);
while true
    checkpoint();
    count = reader.read(buffer);
    if count < 0, break; end
    buffer.flip();
    while buffer.hasRemaining(), writer.write(buffer); end
    buffer.clear();
end
output.close();
checkpoint();
movefile(temporary, destination, 'f');
end

function closeTransfer(output,input,temporary)
% Close before deletion, including during exception unwinding on Windows.
output.close();
input.close();
if exist(temporary, 'file'), delete(temporary); end
end

function [filename, cleanup] = MIKey_readable_nifti(source)
% Supply SPM with an uncompressed file; clean up only our temporary directory.
filename = source; cleanup = [];
if numel(source) < 7 || ~strcmp(source(end-6:end),'.nii.gz'), return; end
directory = tempname(tempdir); mkdir(directory);
cleanup = onCleanup(@() removeTemporary(directory));
result = gunzip(source,directory);
if numel(result) ~= 1 || ~exist(result{1},'file')
    error('MIKey:NIfTI','Could not decompress NIfTI input: %s',source);
end
filename = result{1};
end

function removeTemporary(directory)
% Verify the resolved deletion target remains directly within MATLAB tempdir.
target = char(java.io.File(directory).getCanonicalPath());
parent = char(java.io.File(tempdir).getCanonicalPath());
if ~strcmpi(fileparts(target),parent)
    error('MIKey:TemporaryPath','Unexpected temporary cleanup path: %s',target);
end
if exist(target,'dir'), rmdir(target,'s'); end
end

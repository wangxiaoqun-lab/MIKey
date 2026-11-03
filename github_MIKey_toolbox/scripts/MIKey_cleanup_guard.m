function [directory, filename] = MIKey_cleanup_guard(bidsPath, relative)
% Confine cleanup to the literal derivatives/MIKey tree; reject redirected paths.
if nargin<2, relative=''; end
if isstring(bidsPath), bidsPath=char(bidsPath); end
if isstring(relative), relative=char(relative); end
base=java.io.File(bidsPath); base=char(base.getCanonicalPath());
directory=fullfile(base,'derivatives','MIKey');
verify(fullfile(base,'derivatives')); verify(directory);
if ~isfolder(directory), error('MIKey:CleanupPath','No MIKey derivatives directory: %s',directory); end
filename=directory;
if isempty(relative), return; end
relative=strrep(relative,'\','/'); parts=strsplit(relative,'/');
if any(cellfun(@isempty,parts)) || any(ismember(parts,{'.','..'})) || ...
        ~isempty(regexp(relative,'[:*?]','once'))
    error('MIKey:CleanupPath','Invalid relative cleanup path: %s',relative);
end
for i=1:numel(parts)
    filename=fullfile(filename,parts{i}); verify(filename);
end
end

function verify(filename)
file=java.io.File(filename);
absolute=char(file.getAbsolutePath()); canonical=char(file.getCanonicalPath());
if ispc, matches=strcmpi(absolute,canonical); else, matches=strcmp(absolute,canonical); end
if ~matches || java.nio.file.Files.isSymbolicLink(file.toPath())
    error('MIKey:CleanupPath','Cleanup refuses symbolic links, junctions or redirected paths: %s',filename);
end
end

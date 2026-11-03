function path = MIKey_prefixed_file(prefix, input)
% Native SPM outputs retain the exact basename of the chosen input, old or new.
input=regexprep(input,',\d+$','');
[directory,name,extension]=fileparts(input);
path=fullfile(directory,[prefix name extension]);
end

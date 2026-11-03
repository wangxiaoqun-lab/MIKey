function scans = MIKey_scans(path)
% Expand the chosen 4D file directly, rather than guessing its filename by regex.
scans=cellstr(spm_select('expand',path));
end

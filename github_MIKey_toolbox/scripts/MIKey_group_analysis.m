function directory = MIKey_group_analysis(cfg)
directory = fullfile(cfg.bidsPath,'derivatives','MIKey','group_analysis');
key = MIKey_selection_key(cfg);
if ~isempty(key), directory = fullfile(directory,key); end
end

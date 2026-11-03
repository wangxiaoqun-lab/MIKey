function controls = MIKey_batch_controls(input)
% Safe nonvisual control values for the selected stages only.
% Defaults are placeholders for unused controls, not changes to user config.
[cfg,active]=MIKey_config(input);defaults=MIKey_defaults();
controls=struct('bidsPath',cfg.bidsPath);map=MIKey_parameter_map();
for i=1:size(map,1)
    name=map{i,1};
    if active.(name),value=cfg.(name);else,value=defaults.(name);end
    if any(strcmp(name,{'customPCCounts','steps'}))
        value=strtrim(sprintf('%g ',value));
    end
    controls.(map{i,2})=struct('Value',value);
end
end

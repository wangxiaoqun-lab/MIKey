function key = MIKey_selection_key(cfg)
% Group and concatenated outputs must not reuse a different scan selection.
values = {cfg.sessionFilter,cfg.taskFilter,cfg.runFilter};
if isfield(cfg,'minTimepoints') && cfg.minTimepoints>0
    values{end+1}=sprintf('minTimepoints=%d',cfg.minTimepoints);
end
if all(strcmp(values,'*')), key = ''; return; end
digest = java.security.MessageDigest.getInstance('SHA-256');
digest.update(uint8(strjoin(values,'|')));
checksum = lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
key = ['selection-' checksum(1:16)];
end

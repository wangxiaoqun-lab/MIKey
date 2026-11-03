function matched = MIKey_match_entity(value, filter, prefix)
% Match exact BIDS entity values, wildcard patterns or comma-separated OR.
matched = false;
tokens = strsplit(strrep(filter,' ',''),',');
for i = 1:numel(tokens)
    token = tokens{i};
    entityPrefix = [prefix '-'];
    if strncmp(token,entityPrefix,numel(entityPrefix)), token = token(numel(entityPrefix)+1:end); end
    if strcmp(token,'*')
        matched = true;
    elseif strcmp(token,'none')
        matched = matched || isempty(value);
    else
        matched = matched || ~isempty(regexp(value,['^' regexptranslate('wildcard',token) '$'],'once'));
    end
end
end

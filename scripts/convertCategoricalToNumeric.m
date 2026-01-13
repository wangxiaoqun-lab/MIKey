function [Groupsubinfo, mappingDict] = convertCategoricalToNumeric(Groupsubinfo)
% Convert categorical columns in a table to numeric mappings
% Input: Groupsubinfo - N*s table with mixed data types
% Outputs:
%   Groupsubinfo - Modified table with categorical columns replaced by numeric mappings
%   mappingDict  - Structure containing mapping dictionaries for each converted column

% Initialize mapping dictionary structure
mappingDict = struct();

% Get all variable names
varNames = Groupsubinfo.Properties.VariableNames;

% Iterate through each column
for i = 2:length(varNames)
    currentVar = varNames{i};
    currentData = Groupsubinfo.(currentVar);
    
    % Check if column contains categorical data
    if iscategorical(currentData) || iscellstr(currentData) || ...
       isstring(currentData) || ischar(currentData)
        
        % Convert to categorical for unified processing
        if ~iscategorical(currentData)
            currentData = categorical(currentData);
        end
        
        % Get unique categories and mapping indices
        [uniqueCats, ~, idx] = unique(currentData, 'stable');
        
        % Create mapping container
        numMapping = (1:numel(uniqueCats))';
        strMapping = cellstr(uniqueCats);
        
        % Store mapping in dictionary structure
        mappingDict.(currentVar) = containers.Map(strMapping, numMapping);
        
        % Replace original column with numeric mapping
        Groupsubinfo.(currentVar) = idx;
        
        % Display mapping info
        fprintf('Mapped column: %s\n', currentVar);
        fprintf('Unique values: %d\n', numel(uniqueCats));
        for j = 1:min(5, numel(uniqueCats))  % Show first 5 mappings
            fprintf('  "%s" : %d\n', strMapping{j}, numMapping(j));
        end
        if numel(uniqueCats) > 5
            fprintf('  ... and %d more\n', numel(uniqueCats)-5);
        end
        fprintf('\n');
    end
end
end
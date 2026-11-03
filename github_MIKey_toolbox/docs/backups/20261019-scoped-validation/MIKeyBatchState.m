classdef MIKeyBatchState < handle
    % Shared processing functions read Value fields without any UI objects.
    properties
        UserData
        Config
        LogFile = -1
        Activity = 0
        Warnings = {}
    end
    methods
        function obj = MIKeyBatchState(cfg, fid)
            obj.Config = cfg;
            obj.LogFile = fid;
            map = MIKey_parameter_map();
            obj.UserData.bidsPath = cfg.bidsPath;
            for i = 1:size(map, 1)
                value = cfg.(map{i, 1});
                if any(strcmp(map{i, 1}, {'customPCCounts', 'steps'}))
                    value = strtrim(sprintf('%g ', value));
                end
                obj.UserData.(map{i, 2}) = struct('Value', value);
            end
        end
        function log(obj, message)
            line = sprintf('%s: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), message);
            fprintf('%s', line);
            if obj.LogFile >= 0
                fprintf(obj.LogFile, '%s', line);
            end
            % Both new output and existing output are useful activity.
            if ~isempty(regexp(message, '^(Completed |Skipping - |Saved |Group level noise estimation completed)', 'once'))
                obj.Activity = obj.Activity + 1;
            end
            if ~isempty(regexpi(message, '(^Error| error:)', 'once'))
                error('MIKey:ProcessingError', '%s', message);
            end
            if ~isempty(regexpi(message, '^Warning', 'once'))
                obj.Warnings{end+1} = message;
                if obj.Config.strictWarnings
                    error('MIKey:Prerequisite', '%s', message);
                end
            end
        end
    end
end

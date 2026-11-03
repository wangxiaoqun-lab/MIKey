function report = MIKey_check_runtime(control)
% Detect incomplete installs and mixed paths before a GUI job starts.
root=fileparts(mfilename('fullpath'));
names={'MIKey','MIKeyRunControl','MIKey_write_derivative_metadata','MIKey_check_runtime'};
files=struct();
for i=1:numel(names)
    resolved=which(names{i});expected=fullfile(root,[names{i} '.m']);
    a=strrep(resolved,'\','/');b=strrep(expected,'\','/');
    if ispc,match=strcmpi(a,b);else,match=strcmp(a,b);end
    if ~match
        error('MIKey:RuntimePath', ...
            'Incomplete or mixed MIKey installation. Expected %s; resolved %s. Add the MIKey root to the MATLAB path, remove older copies, and restart MATLAB after updating class files.',expected,resolved);
    end
    files.(names{i})=resolved;
end
if nargin<1,control=MIKeyRunControl();end
required={'start','checkpoint','finish','requestPause','requestStop','resume'};
for i=1:numel(required)
    if ~ismethod(control,required{i})
        error('MIKey:RuntimeClass', ...
            'Loaded MIKeyRunControl lacks method %s. Restart MATLAB after updating the complete toolbox; an old GUI/class instance cannot be refreshed safely during processing.',required{i});
    end
end
report=struct('status','passed','root',root,'files',files,'controlMethods',{methods(control)},'matlab',version);
end

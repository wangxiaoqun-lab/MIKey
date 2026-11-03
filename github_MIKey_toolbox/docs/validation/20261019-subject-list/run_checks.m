root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));addpath(fullfile(root,'scripts'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-tests.log'));
try
    fprintf('MATLAB %s\n',version);
    for file={'MIKey_config.m','MIKey_subjects.m','tests/test_mikey_subject_selection.m','tests/test_mikey_gui_filters.m'}
        diagnostics=checkcode(fullfile(root,file{1}),'-id');
        for k=1:numel(diagnostics)
            assert(~ismember(diagnostics(k).id,{'PARSE','SYNER','EOLPAR'}),diagnostics(k).message);
        end
        fprintf('SYNTAX_PASS %s\n',file{1});
    end
    test_mikey_subject_selection;
    test_mikey_config_flow;
    test_mikey_config_scopes;
    test_mikey_gui_filters;
    disp('MIKEY_SUBJECT_LIST_ALL_PASS');diary off;exit(0);
catch ME
    fprintf('%s\n',getReport(ME,'extended','hyperlinks','off'));diary off;exit(1);
end

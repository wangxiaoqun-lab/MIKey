root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));addpath(fullfile(root,'scripts'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-tests.log'));
try
    fprintf('MATLAB %s\n',version);
    files={'MIKey.m','MIKey_framewise_displacement.m','MIKey_check_fd_scale.m', ...
        'MIKey_noise_result.m','MIKey_parameter_scope.m','MIKey_write_derivative_metadata.m', ...
        'tests/test_mikey_fd_scaling.m','tests/test_mikey_pc_strategies.m', ...
        'tests/test_mikey_config_flow.m','tests/test_mikey_config_scopes.m'};
    for k=1:numel(files)
        messages=checkcode(fullfile(root,files{k}),'-id');
        for j=1:numel(messages)
            assert(~ismember(messages(j).id,{'PARSE','SYNER','EOLPAR'}),messages(j).message);
        end
        fprintf('SYNTAX_PASS %s\n',files{k});
    end
    test_mikey_fd;
    test_mikey_fd_scaling;
    test_mikey_config_flow;
    test_mikey_config_scopes;
    test_mikey_subject_selection;
    test_mikey_pc_strategies('D:/Program Files/MATLAB/mytoolbox/spm12');
    test_mikey_fd_gui;
    disp('MIKEY_FD_PHYSICAL_UNITS_ALL_PASS');diary off;exit(0);
catch ME
    fprintf('%s\n',getReport(ME,'extended','hyperlinks','off'));diary off;exit(1);
end

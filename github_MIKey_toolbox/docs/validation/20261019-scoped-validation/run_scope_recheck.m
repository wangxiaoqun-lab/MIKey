% Rerun the completed scope audit and the user's unchanged generic config.
root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));addpath(fullfile(root,'examples'));
logRoot=fileparts(mfilename('fullpath'));
diary(fullfile(logRoot,'matlab-scope-recheck.log'));
try
    result=test_mikey_config_scopes;
    input=mikey_config_example();
    for phases={1,2:10}
        input.steps=phases{1};cfg=MIKey_config(input);
        MIKey_batch_controls(cfg);
        assert(strcmp(cfg.fcLabel,'296') && strcmp(cfg.parcNetwork,'296rois'));
        fprintf('USER_CONFIG_PASS steps=%s fcLabel=%s parcNetwork=%s\n', ...
            mat2str(cfg.steps),cfg.fcLabel,cfg.parcNetwork);
    end
    test_mikey_pc_strategies('D:\Program Files\MATLAB\mytoolbox\spm12');
    save(fullfile(logRoot,'scope-results.mat'),'result');
    disp('MIKEY_SCOPE_RECHECK_ALL_PASS');diary off;exit(0);
catch ME
    fprintf('%s\n',getReport(ME,'extended','hyperlinks','off'));
    disp('MIKEY_SCOPE_RECHECK_FAILED');diary off;exit(1);
end

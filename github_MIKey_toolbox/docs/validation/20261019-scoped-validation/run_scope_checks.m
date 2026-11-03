% Pure configuration and empty-dataset integration checks, no SPM processing.
root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));addpath(fullfile(root,'scripts'));
logRoot=fullfile(root,'docs','validation','20261019-scoped-validation');
diary(fullfile(logRoot,'matlab-final-tests.log'));
fprintf('MIKEY_SCOPE_CHECKS_STARTED %s\nMATLAB %s\n',datestr(now,31),version);
tests={'test_mikey_config_scopes','test_mikey_pc_config', ...
    'test_mikey_config_choices','test_mikey_config_flow', ...
    'test_mikey_batch','test_mikey_pc_strategies'};
failed=false;
for k=1:numel(tests)
    fprintf('RUN %s\n',tests{k});
    try
        if any(strcmp(tests{k},{'test_mikey_batch','test_mikey_pc_strategies'}))
            feval(tests{k},'D:\Program Files\MATLAB\mytoolbox\spm12');
        else
            feval(tests{k});
        end
        fprintf('PASS %s\n',tests{k});
    catch ME
        failed=true;
        fprintf('FAIL %s\n%s\n',tests{k},getReport(ME,'extended','hyperlinks','off'));
    end
end
if failed,disp('MIKEY_SCOPE_CHECKS_FAILED');else,disp('MIKEY_SCOPE_CHECKS_ALL_PASS');end
diary off;
if failed,exit(1);else,exit(0);end

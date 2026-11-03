root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));addpath(fullfile(root,'scripts'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-tests.log'));
fprintf('MATLAB %s\n',version);failed=false;
for test={'test_mikey_fd','test_mikey_config_scopes','test_mikey_config_flow','test_mikey_pc_strategies'}
    fprintf('RUN %s\n',test{1});
    try
        if strcmp(test{1},'test_mikey_pc_strategies')
            test_mikey_pc_strategies('D:/Program Files/MATLAB/mytoolbox/spm12');
        else,feval(test{1});end
        fprintf('PASS %s\n',test{1});
    catch ME
        failed=true;fprintf('FAIL %s\n%s\n',test{1},getReport(ME,'extended','hyperlinks','off'));
    end
end
if failed,disp('MIKEY_FD_CHECKS_FAILED');else,disp('MIKEY_FD_CHECKS_ALL_PASS');end
diary off;if failed,exit(1);else,exit(0);end

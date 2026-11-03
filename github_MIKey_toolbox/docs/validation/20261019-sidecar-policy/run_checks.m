root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));addpath(fullfile(root,'scripts'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-tests.log'));
fprintf('MATLAB %s\n',version);failed=false;
for name={'test_mikey_sidecars','test_mikey_config_flow','test_mikey_batch'}
    fprintf('RUN %s\n',name{1});
    try
        if strcmp(name{1},'test_mikey_config_flow'),feval(name{1});
        else,feval(name{1},'D:/Program Files/MATLAB/mytoolbox/spm12');end
        fprintf('PASS %s\n',name{1});
    catch ME
        failed=true;fprintf('FAIL %s\n%s\n',name{1},getReport(ME,'extended','hyperlinks','off'));
    end
end
if failed,disp('MIKEY_SIDECAR_CHECKS_FAILED');else,disp('MIKEY_SIDECAR_CHECKS_ALL_PASS');end
diary off;if failed,exit(1);else,exit(0);end

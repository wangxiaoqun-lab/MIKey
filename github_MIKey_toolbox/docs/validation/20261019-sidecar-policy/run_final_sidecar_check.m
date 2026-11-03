root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-final-sidecar.log'));
try
    test_mikey_sidecars('D:/Program Files/MATLAB/mytoolbox/spm12');
    disp('MIKEY_FINAL_SIDECAR_PASS');diary off;exit(0);
catch ME
    fprintf('%s\n',getReport(ME,'extended','hyperlinks','off'));diary off;exit(1);
end

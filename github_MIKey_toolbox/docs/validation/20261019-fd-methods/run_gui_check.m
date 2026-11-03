root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-gui.log'));
try
    test_mikey_fd_gui;diary off;exit(0);
catch ME
    fprintf('%s\n',getReport(ME,'extended','hyperlinks','off'));disp('MIKEY_FD_GUI_FAILED');diary off;exit(1);
end

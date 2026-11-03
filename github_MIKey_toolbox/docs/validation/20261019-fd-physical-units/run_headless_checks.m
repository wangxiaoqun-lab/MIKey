root=fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(root);addpath(fullfile(root,'tests'));
diary(fullfile(fileparts(mfilename('fullpath')),'matlab-headless-final.log'));
try
    test_mikey_fd;
    test_mikey_fd_scaling;
    work='C:/MIKeyTest/tp89ccc28f_4a69_4a81_a15a_5ce155855578';
    directory=fullfile(work,'derivatives','MIKey','sub-01','func');
    for run=1:2
        file=fullfile(directory,sprintf('sub-01_task-rest_run-%02d_bold_desc-regressionResults.mat',run));
        saved=load(file);[~,~,info]=MIKey_noise_result(file);
        assert(info.version==2 && strcmp(info.spatialUnits,'mm') && info.voxelScaleFactor==20);
        expected=MIKey_framewise_displacement(saved.rp_original,info.method,info.rotationRadius,20);
        assert(isequal(expected,saved.FD));
    end
    group=load(fullfile(work,'derivatives','MIKey','group_analysis','group_level_noise_estimation.mat'));
    assert(isequal(size(group.all_corr_data),[2 3]) && strcmp(group.group_fd_info.spatialUnits,'mm'));
    best=load(fullfile(work,'derivatives','MIKey','group_analysis','best_regression_strategy.mat'));
    [~,index]=min(mean(abs(group.all_corr_data),1));
    assert(best.best_strategy_info.best_idx==index);
    disp('MIKEY_FD_HEADLESS_FINAL_PASS');diary off;exit(0);
catch ME
    fprintf('%s\n',getReport(ME,'extended','hyperlinks','off'));diary off;exit(1);
end

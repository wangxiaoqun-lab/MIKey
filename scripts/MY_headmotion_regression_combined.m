function MY_headmotion_regression_combined(RegBasFunc, data_ready_regress, Gmask, runpath, head, fname, detrend_flag, filter_flag, EPI_TR, High_f, Low_f)
    % Combined head motion regression, detrending and filtering function
    % Input parameters:
    %   RegBasFunc: time*noise - regression basis functions
    %   data_ready_regress: voxel*time - data to be processed
    %   Gmask: mask
    %   runpath: output path
    %   head: header information
    %   fname: output filename
    %   detrend_flag: logical flag for detrending
    %   filter_flag: logical flag for filtering
    %   EPI_TR: TR time (required if filter_flag is true)
    %   High_f: high-pass filter frequency (required if filter_flag is true)
    %   Low_f: low-pass filter frequency (required if filter_flag is true)

    % Head motion regression
    Beta = (RegBasFunc' * RegBasFunc) \ (RegBasFunc' * data_ready_regress');
    Residual = data_ready_regress - (RegBasFunc * Beta)';
    
    % Initialize processed data
    processed_data = Residual; % voxel*time
    
    % Apply detrending if requested
    if detrend_flag
        % detrend operates on columns, transpose to time*voxel, then back to voxel*time
        processed_data = detrend(processed_data', 1)';
    end
    
    % Apply filtering if requested
    if filter_flag
        if nargin < 9 || isempty(EPI_TR) || isempty(High_f) || isempty(Low_f)
            error('Filtering requires EPI_TR, High_f and Low_f parameters');
        end
        % Matrix_Filter expects time*voxel, transpose to time*voxel
        processed_data = Matrix_Filter(processed_data', EPI_TR, High_f, Low_f);
        % Matrix_Filter returns time*voxel, keep it as time*voxel
    else
        % If no filtering, ensure data is time*voxel for consistent output
        processed_data = processed_data'; % transpose to time*voxel
    end
    
    % Apply mask and save data
    % If filtered: processed_data is time*voxel, need to transpose to voxel*time for funmask
    % If not filtered: processed_data is time*voxel, need to transpose to voxel*time for funmask
    fMRI_data = funmask(processed_data', Gmask);
    
    cd(runpath);
    for k = 1:size(head,1)
        head(k).fname = fname;
    end
    spm_write_vol_4D(head, fMRI_data);
end
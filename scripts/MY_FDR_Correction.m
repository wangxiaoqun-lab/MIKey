function [intensity] = MY_FDR_Correction(statistic_file, q)
    % MY_FDR_CORRECTION Performs FDR correction on the statistic map
    %   [intensity] = MY_FDR_CORRECTION(statistic_file, q)
    %   Inputs:
    %       statistic_file: Absolute path to the statistic file (e.g., spmT_000X.nii)
    %       q: Corrected p-value (False discovery rate)
    %   Outputs:
    %       intensity: Intensity thresholds for positive and negative values

    % Read statistic file
    VspmSv = spm_vol(statistic_file);
    VspmData = spm_read_vols(VspmSv);

    % Extract degrees of freedom and test type (T or F)
    global TF df
    df_str = regexp(VspmSv.descrip, '\d*\.?\d*', 'match');
    df = str2double(df_str{1});
    tf_str = regexp(VspmSv.descrip, '{[TFp]+_', 'match');
 TF = cell2mat(regexp(cell2mat(tf_str), '[TFp]', 'match' ));

    % Process data for both positive and negative cases
    for pos_neg_ind = 1:2
        positive = -pos_neg_ind*2 + 3; % 1 for positive, -1 for negative

        % Extract and process the data
        Ts = VspmData;
        Ts(Ts == 0) = []; % Remove zero values
        Ts(isnan(Ts)) = []; % Remove NaN values
        Ts = positive * Ts; % Flip signs for negative case
        Ts = sort(Ts(:), 'descend'); % Sort in descending order

        if TF == 'T'
            ps = t2p(Ts, df, TF); % Calculate p-values
        elseif TF == 'F'
            ps = t2p(Ts, [df(1), df(2)], TF); % Calculate p-values for F-test
        end

        % Compute intensity threshold using FDR correction
        intensity(pos_neg_ind) = spm_uc_FDR(q, [1 df], TF, 1, ps, 0) * positive;
    end
end

function p = t2p(t, df, TF)
if ~iscell(t)
    if or( upper(TF)=='T' , upper(TF)=='S' )
        p = 1-spm_Tcdf(t,df);
    elseif upper(TF) == 'F'
        p = 1-spm_Fcdf(t,df);
    end
else
    for ii=1:length(t)
        p{ii} = t2p(t{ii},df{ii},TF{ii});
    end
end
end

function MY_task_state_statistics(animal_root_path,path_sub,func_ids,frames,Reg_choices,defined_1st,result_1st)

group_scan = defined_1st.Nscans;

switch group_scan
    case 'individual'
        individual_task_activation(animal_root_path,path_sub,func_ids,frames,Reg_choices,defined_1st,result_1st)
    case 'Allscans'
        allscans_task_activation(animal_root_path,path_sub,func_ids,frames,Reg_choices,defined_1st,result_1st)
end
end



function individual_task_activation(animal_root_path,path_sub,func_ids,frames,Reg_choices,defined_1st,result_1st)
file_name  = defined_1st.filename;
duration   = defined_1st.duration;
onset      = defined_1st.onset;

weights    = result_1st.weights;
slice      = result_1st.slice;
template   = result_1st.template;
FDR_pvalue = result_1st.FDR_pvalue;
colorbar   = result_1st.colorbar;

func_folder = func_ids{:};
for kk = 1:numel(func_folder)
    dest = [animal_root_path 'Functions\tsfMRI\' num2str(func_folder(kk))];
    mkdir(dest);
    design_unit = 'secs';
    Segments = MY_search_bruker_method('Segments',func_folder(kk),animal_root_path);
    EPI_TR = MY_search_bruker_method('EPI_TR',func_folder(kk),animal_root_path)/1000*Segments;
    %% regressors
    varargin = {1;{'rp_m2dseq.txt';'2dseq.nii';[file_name,'.nii']};...
        {'Mus_mask.nii';'WM_mask.nii';'CSF_mask.nii';'GS_mask.nii'}};
    RegBasFuc = MY_find_regressors_in_all_scans(animal_root_path,path_sub,{func_folder(kk)},frames,Reg_choices,varargin);
    all_epi = MY_find_images_in_all_scans(animal_root_path,path_sub,{func_folder(kk)},file_name,'.nii',frames,'separate_cells');
    
    sess(1) = struct('scans',all_epi,'multi_reg',{{RegBasFuc}},...
        'cond',struct('name',['tsfMRI_',num2str(func_folder(kk))],'onset',onset,...
        'duration',duration,'tmod',0,'orth',1,...
        'pmod',struct('name', {}, 'param', {}, 'poly', {})),...
        'regress',struct('name', {}, 'val', {}),...
        'multi',{{''}},'hpf',128);
    %% 1st level analysis
    first_level_analysis_mlb = MY_1st_level_analysis_1rodentNscan_get_default_batch_struct({dest},design_unit,EPI_TR,sess);
    F = spm_figure('GetWin');
    cd(dest);
%     spm_jobman('run',first_level_analysis_mlb);
%     hgexport(figure(F), fullfile(dest, strcat('1st_level_analysis')), hgexport('factorystyle'), 'Format', 'tiff');
%     %% estimate
%     estimate_mlb = MY_1st_level_analysis_estimate_batch_struct([dest '\SPM.mat']);
%     spm_jobman('run',estimate_mlb);
%     %% results
%     results_mlb = MY_1st_level_analysis_results_batch_struct([dest '\SPM.mat'],'tsfMRI',weights,'none');
%     spm_jobman('run',results_mlb);
    %% display
    spmT_file = [dest '\spmT_0001.nii'];
    Colormap(   'statfile',spmT_file,...
                'bgmfile',template,...
                'slice',slice,...
                'bar_value',colorbar,...
                'dest',dest,...
                'mapname','tmap');%,...
%                 'cluster',10,...
%                 'adjust_method','FDR',...
%                 'corrected_p',FDR_pvalue)
    %
    epi_Tem_name = [animal_root_path,'\',path_sub, '\' num2str(func_folder(kk)) '\' file_name '.nii,1'];
    spmT_file = [dest '\spmT_0001.nii'];
    Colormap(   'statfile',spmT_file,...
                'bgmfile',epi_Tem_name,...
                'slice',slice,...
                'bar_value',colorbar,...
                'dest',dest,...
                'mapname','tmap_epi');%,...
%                 'cluster',10,...
%                 'adjust_method','FDR',...
%                 'corrected_p',FDR_pvalue)
    %}
    fclose('all');
end
end





function allscans_task_activation(animal_root_path,path_sub,func_ids,frames,Reg_choices,defined_1st,result_1st)
file_name  = defined_1st.filename;
duration   = defined_1st.duration;
onset      = defined_1st.onset;

weights    = result_1st.weights;
slice      = result_1st.slice;
template   = result_1st.template;
FDR_pvalue = result_1st.FDR_pvalue;
colorbar   = result_1st.colorbar;

func_folder = func_ids{:};
dest = [animal_root_path 'Functions\tsfMRI\Allscans'];
mkdir(dest);
design_unit = 'secs';

for kk = 1:numel(func_folder)
    Segments = MY_search_bruker_method('Segments',func_folder(kk),animal_root_path);
    EPI_TR = MY_search_bruker_method('EPI_TR',func_folder(kk),animal_root_path)/1000*Segments;
    %% regressors
    varargin = {1;{'rp_m2dseq.txt';'2dseq.nii';[file_name,'.nii']};...
        {'Mus_mask.nii';'WM_mask.nii';'CSF_mask.nii';'GS_mask.nii'}};
    RegBasFuc = MY_find_regressors_in_all_scans(animal_root_path,path_sub,{func_folder(kk)},frames,Reg_choices,varargin);
    all_epi = MY_find_images_in_all_scans(animal_root_path,path_sub,{func_folder(kk)},file_name,'.nii',frames,'separate_cells');
    
    sess(kk) = struct('scans',all_epi,'multi_reg',{{RegBasFuc}},...
        'cond',struct('name',['tsfMRI_',num2str(func_folder(kk))],'onset',onset,...
        'duration',duration,'tmod',0,'orth',1,...
        'pmod',struct('name', {}, 'param', {}, 'poly', {})),...
        'regress',struct('name', {}, 'val', {}),...
        'multi',{{''}},'hpf',128);
end
%% 1st level analysis
first_level_analysis_mlb = MY_1st_level_analysis_1rodentNscan_get_default_batch_struct({dest},design_unit,EPI_TR,sess);
F = spm_figure('GetWin');
cd(dest);
spm_jobman('run',first_level_analysis_mlb);
hgexport(figure(F), fullfile(dest, strcat('1st_level_analysis')), hgexport('factorystyle'), 'Format', 'tiff');
%% estimate
estimate_mlb = MY_1st_level_analysis_estimate_batch_struct([dest '\SPM.mat']);
spm_jobman('run',estimate_mlb);
%% results
results_mlb = MY_1st_level_analysis_results_batch_struct([dest '\SPM.mat'],'tsfMRI',weights,'replsc');
spm_jobman('run',results_mlb);
%% display
spmT_file = [dest '\spmT_0001.nii'];
Colormap(   'statfile',spmT_file,...
            'bgmfile',template,...
            'slice',slice,...
            'bar_value',colorbar,...
            'dest',dest,...
                'mapname','tmap');%,...
%                 'cluster',10,...
%                 'adjust_method','FDR',...
%                 'corrected_p',FDR_pvalue)

% epi_Tem_name = [animal_root_path,'\',path_sub, '\' num2str(func_folder(kk)) '\' file_name '.nii,1'];
% Colormap(   'statfile',spmT_file,...
%             'bgmfile',epi_Tem_name,...
%             'slice',slice,...
%             'bar_value',colorbar,...
%             'dest',dest,...
%             'mapname','tmap',...
%             'cluster',10,...
%             'adjust_method','FDR',...
%             'corrected_p',FDR_pvalue)

fclose('all');
end

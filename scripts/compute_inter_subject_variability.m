function inter_var_map = compute_inter_subject_variability(WholePath, sub_paths, group_net, mask, group_head, img_type, num_sessions)

% Get unique networks
net_labels = unique(group_net(mask));
net_labels = net_labels(net_labels > 0); % Exclude background
n_nets = numel(net_labels);

% Initialize storage
n_subs = numel(sub_paths);
all_sub_corr = zeros([size(mask), n_subs]); % 4D matrix: x,y,z,sub

fprintf('Processing %d subjects...\n', n_subs);

% Process each subject
parfor sub_idx = 1:n_subs
    fprintf('  Subject %d/%d: %s\n', sub_idx, n_subs, sub_paths{sub_idx});
    
    % Initialize subject correlation map
    sub_corr_map = zeros(size(mask));
    
    % Try to find BOLD data for any session
    found_data = false;
    for s = 1:num_sessions
        run_dir = fullfile(WholePath, sub_paths{sub_idx}, 'BOLD', ['*run', num2str(s)]);
        bold_dir = dir(run_dir);
        if isempty(bold_dir), continue; end
        
        bold_file = fullfile(bold_dir(1).folder, bold_dir(1).name, img_type);
        if exist(bold_file, 'file')
            % Load BOLD data
            bold_head = spm_vol(bold_file);
            bold_data = spm_read_vols(bold_head);
            found_data = true;
            break;
        end
    end
    
    if ~found_data
        fprintf('    No BOLD data found for subject %s\n', sub_paths{sub_idx});
        continue;
    end
    
    % For each network, compute voxel-network correlations
    for net_idx = 1:n_nets
        net_label = net_labels(net_idx);
        net_mask = (group_net == net_label) & mask;
        
        if nnz(net_mask) < 10 % Skip small networks
            continue;
        end
        
        % Extract network time series (mean of all voxels in network)
        net_ts = mean(reshape(bold_data(repmat(net_mask, [1,1,1,size(bold_data,4)])), ...
            nnz(net_mask), size(bold_data,4)), 1);
        
        % Compute correlation for each voxel in the brain
        corr_vals = zeros(size(mask));
        for z = 1:size(bold_data,3)
            for y = 1:size(bold_data,2)
                for x = 1:size(bold_data,1)
                    if mask(x,y,z)
                        voxel_ts = squeeze(bold_data(x,y,z,:));
                        corr_val = corr(voxel_ts, net_ts');
                        if isnan(corr_val), corr_val = 0; end
                        corr_vals(x,y,z) = corr_val;
                    end
                end
            end
        end
        
        % Add to subject's correlation map (only for voxels in this network)
        sub_corr_map(net_mask) = corr_vals(net_mask);
    end
    
    % Store subject's correlation map
    all_sub_corr(:,:,:,sub_idx) = sub_corr_map;
end

% Calculate inter-subject variability (standard deviation across subjects)
inter_var_map = std(all_sub_corr, 0, 4);

% Smooth the variability map for better visualization
inter_var_map = smooth3(inter_var_map, 'gaussian', [3,3,3], 1);

% Mask out non-brain areas
inter_var_map(~mask) = 0;

fprintf('Completed variability calculation for %d subjects\n', n_subs);
end
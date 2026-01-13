function subject_networks = rebuild_individual_networks(final_networks, num_roi)
    n_subs = size(final_networks, 1);
    subject_networks = zeros(num_roi, num_roi, n_subs);
    
    for i = 1:n_subs
        net = zeros(num_roi);
        for r = 1:num_roi
            other_rois = setdiff(1:num_roi, r);
            net(other_rois, r) = final_networks{i, r};
        end
        sym_net = (abs(net) + abs(net')) / 2;
        subject_networks(:, :, i) = sym_net;
    end
end
function save_network_map(net_map, vol_header, dest_path, filename)
    vol_out = vol_header;
    vol_out.fname = fullfile(dest_path, filename);
    vol_out.dt = [16 0];
    spm_write_vol(vol_out, net_map);
end
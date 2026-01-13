function tsnr = compute_tsnr(data_4d)
    % Calculate temporal signal-to-noise ratio
    tmean = mean(data_4d, 4);
    tstd = std(data_4d, 0, 4);
    tsnr = tmean ./ tstd;
    tsnr(isinf(tsnr)) = 0;
end

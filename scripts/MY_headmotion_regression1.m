function [DVARS,  correlation]=MY_headmotion_regression1(RegBasFunc,data_ready_regress,FD,Gmask,runpath,head,fname)
Beta = (RegBasFunc' * RegBasFunc) \ (RegBasFunc' * data_ready_regress');
Residual = data_ready_regress - (RegBasFunc * Beta)';
data_ready_regress1 = Residual + Beta(1, :)';

dd = data_ready_regress1 - [data_ready_regress1(:,1),data_ready_regress1(:,1:end-1)];
DVARS = rms(dd);
DVARS(1)=median(DVARS);
correlation = corr(FD,DVARS');

data_ready_regress1


fMRI_data = funmask(data_ready_regress1,Gmask);
cd(runpath);
for k = 1:size(head,1)
    head(k).fname=fname;
end
spm_write_vol_4D(head,fMRI_data);

end
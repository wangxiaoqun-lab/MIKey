function [p,stats] = MY_Generate_T_contrast_from_multiCC(CC4D,lmask)
% CC4D : dim 1~3 spatial; dim 4 multi scan

Vc = fmask(CC4D,lmask);
Vc(isnan(Vc))=0;

% fisher z
Vz = atanh(Vc);

% ttest
[~,p,~,stats] = ttest(Vz');

end
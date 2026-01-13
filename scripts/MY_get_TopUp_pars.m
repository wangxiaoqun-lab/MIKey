function pars = MY_get_TopUp_pars(Animal_root_path,EPI_folder,prefix)

% prefix : to discriminate the SEEPI and GEEPI

pars = [];
for kk = EPI_folder
    fid = fopen(fullfile(Animal_root_path,num2str(kk),'method'),'r');
    while feof(fid) == 0
        line    =   fgetl(fid);
        tag     =   strread(line,'%s','delimiter','=');
        switch tag{1}
            case {'##$ViewMode';'##$ReverseView'}
                type   = tag{2};
            case {'##$PVM_EpiNEchoes'}
                EpiNEchoes     = eval(tag{2});
            case {'##$PVM_EpiEchoSpacing'}
                EpiEchoSpacing = eval(tag{2});
            case {'##$PVM_NRepetitions'}
                Volumes = eval(tag{2});
        end
    end

    % phase-encoding direction
    if strcmp(type,'Positive') || strcmp(type,'Yes');PEdirec = 1;else;PEdirec = -1;end
    
    % C4 = 10^-3 * EPIfactor (NEchoes) * Echo Spacing
    % https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq
    % https://wenku.baidu.com/view/a198b2c686c24028915f804d2b160b4e777f814b.html
    C4 = EpiNEchoes*EpiEchoSpacing/1000;
    
    % generate pars.txt
    acqpars = repmat([0 PEdirec 0 1],Volumes,1);
    pars = [pars; acqpars];
end

end
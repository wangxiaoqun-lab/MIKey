function [FD_GS_r,F] = MY_get_figure_rp_Reg_GSintensity(filepath,NIIfile,rpfile,Reg_choices,lmask)
%%
% rp : head motion parameters (6) (relative URL)
% G_Signal: the whole brain signal name (relative URL) {cell}
% F: Figure
cd(filepath);
head = spm_vol(NIIfile);
fMRI_data = spm_read_vols(head);
data_ready_regress = fmask(fMRI_data,lmask);
clear fMRI_data
rp = load(rpfile);
drp = rp - [zeros(1,6);rp(1:end-1,:)];
PCs = load('PCs.txt');
GS_SD_DVARS_Excel = fullfile(filepath,'GS_SD_DVARS.xlsx');

color = {[138 043 226];[112 173 071];[138 043 226];[068 114 196];[237 125 049];[248 192 000];};
F = figure;
set(F,'position',[0 0 1900 960]);
axis normal;
a=0;

for jj = 1:size(Reg_choices,1)
x_l = (0.05+(jj-1))*1/3;
x_r = 1/3*0.85;
%% rp
positionVector=[x_l 1-1/(2+3*size(Reg_choices,2)) x_r 0.75/(2+3*size(Reg_choices,2))];
subplot('Position',positionVector);
cd(filepath)
rp_6 = load(rpfile);
rp_6(:,4:6) = rp_6(:,4:6)*15;
rp_6(:,1:3) = rp_6(:,1:3)/6;
plot(rp_6)
set(gca,'LooseInset',get(gca,'TightInset'))
xlim([1 length(rp_6)]);
ylim([min(rp_6(:))*1.1 max(rp_6(:))*1.1]);
axis off;box off
ylabel('rp','FontSize',8,'FontWeight','bold','color','k');
xloc = length(rp_6)*1.005;
yloc = min(rp_6(:))*1.1*0.15+max(rp_6(:))*1.1*0.85;
text(xloc,yloc,'Max/Min','HorizontalAlignment','left','fontsize',7,'color',color{1}/255);
yloc = min(rp_6(:))*1.1*0.35+max(rp_6(:))*1.1*0.65;
text(xloc,yloc,[num2str(max(max(rp_6(:,1:3))),'%0.2f'),'/',num2str(min(min(rp_6(:,1:3))),'%0.2f')],...
    'HorizontalAlignment','left','fontsize',7,'color',color{1}/255);
yloc = min(rp_6(:))*1.1*0.55+max(rp_6(:))*1.1*0.45;
text(xloc,yloc,[num2str(max(max(rp_6(:,4:6))),'%0.2f'),'/',num2str(min(min(rp_6(:,4:6))),'%0.2f')],...
    'HorizontalAlignment','left','fontsize',7,'color',color{1}/255);

%% FD
positionVector=[x_l 1-2/(2+3*size(Reg_choices,2)) x_r 1/(2+3*size(Reg_choices,2))];
subplot('Position',positionVector);
cd(filepath)

rp_6 = load(rpfile);
[~,rp_6] = gradient(rp_6);
rp_6(:,4:6) = rp_6(:,4:6).*15; %% mm
rp_6(:,1:3) = rp_6(:,1:3)/6;
rp_displace = sqrt(rp_6(:,1).^2+rp_6(:,2).^2+rp_6(:,3).^2+rp_6(:,4).^2+rp_6(:,5).^2+rp_6(:,6).^2);

plot(rp_displace,'color',color{5}/255)
set(gca,'LooseInset',get(gca,'TightInset'))
xlim([1 length(rp_6)]);
ylim([0 max(rp_displace(:))*1.1]);
axis off;box off
ylabel({'FD'},'FontSize',8,'FontWeight','bold','color','k');
xloc = length(rp_6)*1.005;
yloc = min(rp_displace(:))*1.1*0.00+max(rp_displace(:))*1.1*1.00;
text(xloc,yloc,'FD','HorizontalAlignment','left','fontsize',7,'color',color{5}/255);
yloc = min(rp_displace(:))*1.1*0.15+max(rp_displace(:))*1.1*0.85;
text(xloc,yloc,[num2str(max(rp_displace(:)*1000),'%0.2f'),'/',num2str(min(rp_displace(:)*1000),'%0.2f')],...
    'HorizontalAlignment','left','fontsize',7,'color',color{1}/255);

for kk = 1:size(Reg_choices,2)
    
    a=a+1;   blank = data_ready_regress;
    Reg = Reg_choices(jj,kk);
    if isnan(Reg); continue;end
    switch Reg
        case 0
            RegBasFunc = ones([length(rp_6),1]);label_txt='no regression';
        case 6
            RegBasFunc = [ones([length(rp_6),1]) rp];label_txt='6 rp';
        case 12
            RegBasFunc = [ones([length(rp_6),1]) rp drp];label_txt='12 rp';
        case 24
            RegBasFunc = [ones([length(rp_6),1]) rp drp rp.^2 drp.^2];label_txt='24 rp';
        case 120
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1)];label_txt='12 rp + 1 PC';
        case 121
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:2)];label_txt='12 rp + 2 PCs';
        case 122
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:3)];label_txt='12 rp + 3 PCs';
        case 123
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:4)];label_txt='12 rp + 4 PCs';
        case 124
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:5)];label_txt='12 rp + 5 PCs';
        case 125
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:6)];label_txt='12 rp + 6 PCs';
        case 126
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:7)];label_txt='12 rp + 7 PCs';
        case 127
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:8)];label_txt='12 rp + 8 PCs';
        case 128
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:9)];label_txt='12 rp + 9 PCs';
        case 129
            RegBasFunc = [ones([length(rp_6),1]) rp drp PCs(:,1:10)];label_txt='12 rp + 10 PCs';
    end
    
    for iii = 1:size(blank,1)
        [Beta,~,Residual] = regress(squeeze(blank(iii,:))',RegBasFunc);
        blank(iii,:) = Residual + Beta(1);
    end
    
    %% DVARS and SD
    G_S = mean(blank,1);
    SD = std(blank,0,1);
    ram = gradient(blank,1);
    ram = ram.^2;
    DVARS = sqrt(sum(ram,1))/size(ram,1);
    pars = [G_S(:),DVARS(:),SD(:)]';

    A = {['GS_',num2str(Reg,'%03d')];...
        ['DVARS_',num2str(Reg,'%03d')];...
        ['SD_',num2str(Reg,'%03d')]};
    xlswrite(GS_SD_DVARS_Excel,A,'Sheet1',['A',num2str(1+(a-1)*3)]);
    xlswrite(GS_SD_DVARS_Excel,pars,'Sheet1',['B',num2str(1+(a-1)*3)]);

    
    GS = blank; clear blank;
    mask_RAM = mean(GS,2);
    GS(mask_RAM<=0,:) = [];
    GS = double(GS)-mean(GS,2);
    GS(isnan(GS)) = 0;
    
    positionVector=[x_l 1-(3*kk-0.25)/(2+3*size(Reg_choices,2)) x_r 0.75/(2+3*size(Reg_choices,2))];
    subplot('Position',positionVector);
    plot(mapminmax(G_S,0,1),'k');hold on;
    DVARS = [DVARS(2) DVARS(2:end-1) DVARS(end-1)];
    plot(mapminmax(DVARS,0,1),'r');
    xlim([1 numel(mean(GS,1))]);
    ylim([-0.1,1.1]);
    axis off;box off
    ylabel({'GS';'A.U.'},'FontSize',8,'FontWeight','bold','color','k');
    set(gca,'LooseInset',get(gca,'TightInset'))
    yloc = 1.1*0.75;
    text(xloc,yloc,[num2str(max(mean(GS,1)),'%0.2f'),'/',num2str(min(mean(GS,1)),'%0.2f')],...
        'HorizontalAlignment','left','fontsize',7,'color',color{1}/255);
    yloc = 1.1*0.45;
    text(xloc,yloc,'FD&GS','HorizontalAlignment','left','fontsize',7);
    yloc = 1.1*0.15;
    x = rp_displace(:);
    y = mean(GS,1);
    FD_GS_r(kk) = corr(x(5:end),y(5:end)');
    text(xloc,yloc,['r=',num2str(FD_GS_r(kk),'%0.4f')],'HorizontalAlignment','left','fontsize',7);
    yloc = -1.1*0.25;
    text(xloc,yloc,[num2str(max(DVARS),'%0.2f'),'/',num2str(min(DVARS),'%0.2f')],...
        'HorizontalAlignment','left','fontsize',7,'color',color{1}/255);
    yloc = -1.1*0.55;
    text(xloc,yloc,'FD&DVARS','HorizontalAlignment','left','fontsize',7);
    yloc = -1.1*0.85;
    x = rp_displace(:);
    y = DVARS;
    FD_DVARS_r(kk) = corr(x(2:end-1),y(2:end-1)');
    text(xloc,yloc,['r=',num2str(FD_DVARS_r(kk),'%0.4f')],'HorizontalAlignment','left','fontsize',7);
    
    positionVector=[x_l 1-(3*kk+2)/(2+3*size(Reg_choices,2)) x_r 2.25/(2+3*size(Reg_choices,2))];
    subplot('Position',positionVector);
    imagesc(GS);box off;
    set(gca,'ytick',[],'xtick',[],'xcolor','w','ycolor','w')
    ylabel(label_txt,'FontSize',8,'FontWeight','bold','Interpreter','none','color','k');
    caxis([mean(GS(:))-2*std(GS(:)) mean(GS(:))+2*std(GS(:))]);
    x = [size(GS,2)*0.05 size(GS,2)*0.05 size(GS,2)*0.05+20 size(GS,2)*0.05+20];
    y = [size(GS,1)*0.1 size(GS,1)*0.1*2 size(GS,1)*0.1*2 size(GS,1)*0.1];
    patch(x,y,'k','FaceAlpha',.75,'EdgeColor','none')
    text(size(GS,2)*0.05+23,size(GS,1)*0.1+size(GS,1)*0.1/2,'20 TR','HorizontalAlignment','left','Fontweight','bold','color','k');
    clear GS;
end

end
end

function out=fmask(fdata,mask)
temp=squeeze(fdata(:,:,:,1));
if ~isequal(size(temp), size(mask))
    error('mask size is not equal to data size');
end
idx=find(mask>0);
fdata_reshape=reshape(fdata,[],size(fdata,4));
out=fdata_reshape(idx,:);
end

clc;clear
codepath = 'D:\HUASHAN\fMRI_code_Trange\';
cd(codepath);
addpath(genpath(codepath));

% Animal_path{1} = 'D:\HUASHAN\data_from_(-)cp\20191023_104054_20191023_tcj_czy_elec_forepaw_mouse00_1_1\'; % wild type
Animal_path{2} = 'D:\HUASHAN\data_from_(-)cp\20191030_094200_20191030_tcj_czy_elec_forepaw_mouse03_1_1\'; % wild type
Animal_path{3} = 'D:\HUASHAN\data_from_(-)cp\20191030_120435_20191030_tcj_czy_elec_forepaw_mouse04_1_1\'; % wild type

% Animal_path{4} = 'D:\HUASHAN\20191204_212536_20191204_tcj_czy_elec_forepaw_CP_WT_M06_1_1\';
Animal_path{5} = 'D:\HUASHAN\20191208_173453_20191208_tcj_czy_elec_forepaw_CP_WT_M07_1_1\';
Animal_path{6} = 'D:\HUASHAN\20191208_200353_20191208_tcj_czy_elec_forepaw_CP_WT_M08_1_1\';

Animal_EPI_type       = {'Left_forepaw';};
Animal_EPI_folder{1} = {[14 15 18]};
Animal_EPI_folder{2} = {[10 11 12]};
Animal_EPI_folder{3} = {[16 17 18]};
Animal_EPI_folder{4} = {[09 11 14]};
Animal_EPI_folder{5} = {[08 09 15]};
Animal_EPI_folder{6} = {[12 13 14]};


for flag_stage = 1
    if flag_stage == 1
        %% Refigure
        for Idx = 1:numel(Animal_path)
            folder = Animal_EPI_folder{Idx}{1};
            FilePath = strcat(Animal_path{Idx},filesep,'Functions',filesep,'tsfMRI');
            % individual result
            for Idx_per = 1:numel(folder)
                dest = fullfile(FilePath,num2str(folder(Idx_per)));
                spmT_file = [dest '\spmT_0001.nii'];
                template = fullfile(Animal_path{Idx},'Results',num2str(folder(Idx_per)),'nbmrs2dseq.nii,1');
                Img_RGBL = Colormap('statfile',spmT_file,...
                    'bgmfile',template,...
                    'slice',11:17,...
                    'bar_value',[-5 -2 2 5],...
                    'dest',dest,...
                    'mapname','tmap_NoFDR',...
                    'cluster',10);%,...
                    % 'adjust_method','FDR',...
                    % 'corrected_p',0.05);
                TextBox = zeros([size(Img_RGBL,1)/2,size(Img_RGBL,2),size(Img_RGBL,3)]);
                TextL = insertText(TextBox,[0,0],['Left forepaw  0.5mA      Scan ' num2str(Idx_per) ,'        (no FDR corrected) arbitrary threshold'],'FontSize', 20,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0);

                BarBox = zeros([size(Img_RGBL,1)/2,size(Img_RGBL,2),size(Img_RGBL,3)]);
                % positive bar
                left = round(size(BarBox,2)*0.65);        right = round(size(BarBox,2)*0.9);
                upper_bound = round(size(BarBox,1)*0.3);  lower_bound = round(size(BarBox,1)*0.7);
                BarBox(upper_bound:lower_bound,left:right,1) = 1*255;
                BarBox(upper_bound:lower_bound,left:right,2) = repmat(((left:right)-left)/(right-left)*255,[numel(upper_bound:lower_bound),1]);
                BarBox(upper_bound:lower_bound,left:right,3) = 0;
                % negtive bar
                left = round(size(BarBox,2)*0.3);        right = round(size(BarBox,2)*0.55);
                upper_bound = round(size(BarBox,1)*0.3);  lower_bound = round(size(BarBox,1)*0.7);
                BarBox(upper_bound:lower_bound,right:-1:left,1) = 0;
                BarBox(upper_bound:lower_bound,right:-1:left,2) = repmat(((left:right)-left)/(right-left)*255,[numel(upper_bound:lower_bound),1]);
                BarBox(upper_bound:lower_bound,right:-1:left,3) = 255-repmat(((left:right)-left)/(right-left)*255,[numel(upper_bound:lower_bound),1]);

                loc = [round(size(BarBox,2)*0.6),round(size(BarBox,1)*0.5)];
                BarBox = insertText(BarBox,loc,['-2 +2'],'FontSize', 17,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','Center');
                loc = [round(size(BarBox,2)*0.3),round(size(BarBox,1)*0.5)];
                BarBox = insertText(BarBox,loc,['T -5'],'FontSize', 17,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','RightCenter');
                loc = [round(size(BarBox,2)*0.9),round(size(BarBox,1)*0.5)];
                BarBox = insertText(BarBox,loc,['+5'],'FontSize', 17,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','LeftCenter');

                Img_RGBLR = cat(1,[TextL;Img_RGBL;BarBox]);
                imwrite(uint8(Img_RGBLR), strcat(dest,filesep,'Forepaw.tiff'), 'tiff');
            end
            % group results
            template = strcat(Animal_path{Idx},filesep,'Results',filesep,num2str(folder(1)),filesep,'nbmrs2dseq.nii,1');
            dest = [FilePath filesep 'Allscans_Left_forepaw'];
            spmT_file = [dest '\spmT_0001.nii'];
            Img_RGBL = Colormap('statfile',spmT_file,...
                'bgmfile',template,...
                'slice',11:17,...
                'bar_value',[-5 -2 2 5],...
                'dest',dest,...
                'mapname','tmap_NoFDR',...
                'cluster',10);%,...
                % 'adjust_method','FDR',...
                % 'corrected_p',0.05);
                
                TextBox = zeros([size(Img_RGBL,1)/2,size(Img_RGBL,2),size(Img_RGBL,3)]);
                TextL = insertText(TextBox,[0,0],['Left forepaw  0.5mA     Mouse ' num2str(Idx) ,'        (no FDR corrected) arbitrary threshold'],'FontSize', 20,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0);

                BarBox = zeros([size(Img_RGBL,1)/2,size(Img_RGBL,2),size(Img_RGBL,3)]);
                % positive bar
                left = round(size(BarBox,2)*0.65);        right = round(size(BarBox,2)*0.9);
                upper_bound = round(size(BarBox,1)*0.3);  lower_bound = round(size(BarBox,1)*0.7);
                BarBox(upper_bound:lower_bound,left:right,1) = 1*255;
                BarBox(upper_bound:lower_bound,left:right,2) = repmat(((left:right)-left)/(right-left)*255,[numel(upper_bound:lower_bound),1]);
                BarBox(upper_bound:lower_bound,left:right,3) = 0;
                % negtive bar
                left = round(size(BarBox,2)*0.3);        right = round(size(BarBox,2)*0.55);
                upper_bound = round(size(BarBox,1)*0.3);  lower_bound = round(size(BarBox,1)*0.7);
                BarBox(upper_bound:lower_bound,right:-1:left,1) = 0;
                BarBox(upper_bound:lower_bound,right:-1:left,2) = repmat(((left:right)-left)/(right-left)*255,[numel(upper_bound:lower_bound),1]);
                BarBox(upper_bound:lower_bound,right:-1:left,3) = 255-repmat(((left:right)-left)/(right-left)*255,[numel(upper_bound:lower_bound),1]);

                loc = [round(size(BarBox,2)*0.6),round(size(BarBox,1)*0.5)];
                BarBox = insertText(BarBox,loc,['-2 +2'],'FontSize', 17,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','Center');
                loc = [round(size(BarBox,2)*0.3),round(size(BarBox,1)*0.5)];
                BarBox = insertText(BarBox,loc,['T -5'],'FontSize', 17,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','RightCenter');
                loc = [round(size(BarBox,2)*0.9),round(size(BarBox,1)*0.5)];
                BarBox = insertText(BarBox,loc,['+5'],'FontSize', 17,'TextColor',[255 255 255],'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','LeftCenter');

                Img_RGBLR = cat(1,[TextL;Img_RGBL;BarBox]);
                imwrite(uint8(Img_RGBLR), strcat(dest,filesep,'Forepaw.tiff'), 'tiff');                
        end
    end
    
end
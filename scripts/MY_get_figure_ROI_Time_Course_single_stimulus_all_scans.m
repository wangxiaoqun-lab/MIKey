function F = MY_get_figure_ROI_Time_Course_single_stimulus_all_scans(Time_course,title_txt)
%% Time_course : cell{Time_course} ; Multiple Time_course datasets
% F: Figure

F = figure;
set(F,'position',[100 100 300 300]);

color = {[138 043 226];[002 152 182];[135 199 000];[248 199 000];[005 139 085];[000 000 255]};
%% rp
for count = 1:numel(Time_course)
    TimeCourse_mean = Time_course(count).data;
    stimulus_T = Time_course(count).stimulus;
    legend_txt = Time_course(count).name;
    
    number = size(TimeCourse_mean,2);
    Time_series = mean(TimeCourse_mean,2);
    RAM = TimeCourse_mean(1:9,:);
    Time_series = Time_series-mean(RAM(:));     
    upper = Time_series+std(TimeCourse_mean,0,2)/sqrt(number);
    lower = flipud(Time_series-std(TimeCourse_mean,0,2)/sqrt(number));
    
    axis_index = 1:numel(Time_series);
    f = plot(axis_index,Time_series,'color',color{count}/255,'LineWidth',1);
    hold on;
    plot(axis_index,axis_index*0,'k--','LineWidth',0.5);
    x = [1:numel(Time_series),fliplr(1:numel(Time_series))]';
    y = [upper;lower];
    patch(x,y,color{count}/255,'FaceAlpha',0.4,'EdgeColor','none');
    hold on;
    
    
    ylabel('BOLD response (%)');
    xlabel('Time (s)');
    set(gca,'FontSize',8,'FontWeight','bold');
    set(gca, 'LineWidth',1.5);
    
%     y_min =-1.0;
%     y_max = 3.0;

    y_min = floor(min(lower(:)));
    y_max = ceil(max(upper(:)));

    %% stimulus
    
    stimulus_deT = stimulus_T - [stimulus_T(2:end) stimulus_T(1)];
    patch_x = [find(stimulus_deT==-1);find(stimulus_deT==1);find(stimulus_deT==1);find(stimulus_deT==-1)];
    patch_y = [y_min y_min y_max y_max]';
    patch(patch_x,patch_y,'r','FaceAlpha',.2,'EdgeColor','none');

    axis([0 numel(Time_series) y_min y_max])
    h = legend(f,legend_txt,'position','northeast');
    set(h,'Box','off');
    box off;
end
hold off;
title([title_txt ' (Mean¡ÀSEM)'],'Interpreter','none');
set(gca,'FontWeight','bold');
end
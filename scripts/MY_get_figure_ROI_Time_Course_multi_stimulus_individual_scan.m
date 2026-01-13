function F = MY_get_figure_ROI_Time_Course_multi_stimulus_individual_scan(Time_course,title_txt)
%% Time_course : cell{Time_course} ; Multiple Time_course datasets
% F: Figure

F = figure;
set(F,'position',[100 100 300*3 300]);

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
    
    axis_index = 1:numel(Time_series);
    f = plot(axis_index,Time_series,'color',color{count}/255,'LineWidth',1);
    hold on;
    plot(axis_index,axis_index*0,'k--','LineWidth',1);
    hold on;
    
    
    ylabel('BOLD response (%)');
    xlabel('Time (s)');
    set(gca,'FontSize',16,'FontWeight','bold');
    set(gca, 'LineWidth',3);
    
    
    y_min = floor(min(Time_series(:)));
    y_max = ceil(max(Time_series(:)));
    %% stimulus
    
    stimulus = stimulus_T(:);
    stimulus(stimulus~=0) = 1;
    stimulus_dev = stimulus - [stimulus(2:end);stimulus(1)];
    stimulus_up = find(stimulus_dev==1);
    stimulus_down = find(stimulus_dev==-1);
    patch_x = [stimulus_down stimulus_down stimulus_up stimulus_up]';
    patch_y = [repmat(y_min,1,numel(stimulus_down));repmat(y_max,1,numel(stimulus_up));
               repmat(y_max,1,numel(stimulus_up));repmat(y_min,1,numel(stimulus_down));];
    patch(patch_x,patch_y,'r','FaceAlpha',.2,'EdgeColor','none');  

    axis([0 numel(Time_series) y_min y_max])
%     h = legend(f,legend_txt,'position','best');
%     set(h,'Box','off');
    box off;
end
hold off;
title([title_txt],'Interpreter','none');
set(gca,'FontWeight','bold');
end
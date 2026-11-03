function test_mikey_fd_gui
% Actual FD button callback with scripted dialog answers, no processing data.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;
oldVisible=get(groot,'DefaultFigureVisible');before=findall(groot,'Type','figure');
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldVisible,before,work));
write(fullfile(work,'questdlg.m'),sprintf('function value=questdlg(varargin)\nglobal MIKEY_FD_METHOD;value=MIKEY_FD_METHOD;\nend\n'));
write(fullfile(work,'inputdlg.m'),sprintf('function value=inputdlg(varargin)\nglobal MIKEY_FD_RADIUS;value=MIKEY_FD_RADIUS;\nend\n'));
write(fullfile(work,'errordlg.m'),sprintf('function errordlg(varargin)\nglobal MIKEY_FD_ERROR;MIKEY_FD_ERROR=varargin{1};\nend\n'));
addpath(root);addpath(work,'-begin');set(groot,'DefaultFigureVisible','off');
global MIKEY_FD_METHOD MIKEY_FD_RADIUS MIKEY_FD_ERROR;
MIKey;figures=findall(groot,'Type','figure');figures=figures(~ismember(figures,before));
assert(numel(figures)==1);fig=figures(1);fig.Visible='off';ui=fig.UserData;
assert(strcmp(ui.fdMethodSetting.Value,'euclidean'));
for trial=1:2
    if trial==1,MIKEY_FD_METHOD='Power (L1)';method='power';else,MIKEY_FD_METHOD='Euclidean (L2)';method='euclidean';end
    MIKEY_FD_RADIUS={'75'};ui.fdSettingsButton.ButtonPushedFcn([],[]);
    assert(strcmp(fig.UserData.fdMethodSetting.Value,method) && fig.UserData.fdRadiusSetting.Value==75);
    cfg=MIKey_defaults();map=MIKey_parameter_map();
    for i=1:size(map,1),cfg.(map{i,1})=fig.UserData.(map{i,2}).Value;end
    cfg.steps=10;cfg=MIKey_config(cfg);assert(strcmp(cfg.fdMethod,method) && cfg.fdRadius==75);
end
MIKEY_FD_RADIUS={'invalid'};MIKEY_FD_ERROR='';ui.fdSettingsButton.ButtonPushedFcn([],[]);
assert(~isempty(MIKEY_FD_ERROR) && fig.UserData.fdRadiusSetting.Value==75);
MIKEY_FD_METHOD='Cancel';ui.fdSettingsButton.ButtonPushedFcn([],[]);
assert(strcmp(fig.UserData.fdMethodSetting.Value,'euclidean'));
rectangles=[];
for child=reshape(fig.Children,1,[])
    if ~isprop(child,'Visible') || strcmp(child.Visible,'off'),continue;end
    a=child.Position;assert(a(1)>=0 && a(2)>=0 && a(1)+a(3)<=fig.Position(3) && a(2)+a(4)<=fig.Position(4));
    rectangles(end+1,:)=a;
end
for i=1:size(rectangles,1)
    for j=i+1:size(rectangles,1)
        a=rectangles(i,:);b=rectangles(j,:);
        assert(min(a(1)+a(3),b(1)+b(3))<=max(a(1),b(1)) || min(a(2)+a(4),b(2)+b(4))<=max(a(2),b(2)));
    end
end
disp('MIKEY_FD_GUI_PASS');
end
function write(name,body)
fid=fopen(name,'w');assert(fid>=0);fprintf(fid,'%s',body);fclose(fid);
end
function restore(oldPath,oldVisible,before,work)
figures=findall(groot,'Type','figure');delete(figures(~ismember(figures,before)));
path(oldPath);set(groot,'DefaultFigureVisible',oldVisible);
target=char(java.io.File(work).getCanonicalPath());parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
clear global MIKEY_FD_METHOD MIKEY_FD_RADIUS MIKEY_FD_ERROR;
end

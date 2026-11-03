function test_mikey_gui_filters()
% Create the actual GUI invisibly, inspect fields and exercise batch-state parity.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);
old=get(groot,'DefaultFigureVisible');
cleanup=onCleanup(@() set(groot,'DefaultFigureVisible',old)); %#ok<NASGU>
set(groot,'DefaultFigureVisible','off');
before=findall(groot,'Type','figure');
MIKey;
figures=findall(groot,'Type','figure'); figures=figures(~ismember(figures,before));
assert(numel(figures)==1); fig=figures(1);
figCleanup=onCleanup(@() delete(fig)); %#ok<NASGU>
assert(strcmp(fig.UserData.sessionEdit.Value,'*'));
assert(strcmp(fig.UserData.taskEdit.Value,'*'));
assert(strcmp(fig.UserData.runEdit.Value,'*'));
assert(isempty(fig.UserData.groupNetworkEdit.Value));
fig.UserData.subjectsEdit.Value='sub-001,sub-002';
fig.UserData.sessionEdit.Value='01,02';
fig.UserData.taskEdit.Value='rest';
fig.UserData.runEdit.Value='01';
fig.UserData.groupNetworkEdit.Value=fullfile(root,'share_temp','AMCP_temp','AMCP_428prior_17net.nii');
cfg=MIKey_defaults(); map=MIKey_parameter_map();
for i=1:size(map,1), cfg.(map{i,1})=fig.UserData.(map{i,2}).Value; end
cfg.steps=15; % Explicit group network is used by clustering.
cfg=MIKey_config(cfg);
assert(strcmp(cfg.sessionFilter,'01,02') && strcmp(cfg.taskFilter,'rest') && strcmp(cfg.runFilter,'01'));
assert(strcmp(cfg.subjectFilter,'sub-001,sub-002'));
state=MIKeyBatchState(cfg,-1);
assert(strcmp(state.UserData.subjectsEdit.Value,fig.UserData.subjectsEdit.Value));
assert(strcmp(state.UserData.sessionEdit.Value,fig.UserData.sessionEdit.Value));
assert(strcmp(state.UserData.groupNetworkEdit.Value,fig.UserData.groupNetworkEdit.Value));
assert(~isempty(fig.UserData.groupNetworkButton.ButtonPushedFcn));
disp('MIKEY_GUI_FILTERS_PASS');
end

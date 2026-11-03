function test_mikey_ui_layout()
% Real controls: names, fields, callback routing, bounds, and pairwise overlap.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root);addpath(fullfile(root,'scripts'));
old=get(groot,'DefaultFigureVisible'); cleanup=onCleanup(@() set(groot,'DefaultFigureVisible',old)); %#ok<NASGU>
set(groot,'DefaultFigureVisible','off'); before=findall(groot,'Type','figure');
MIKey;
all=findall(groot,'Type','figure'); created=all(~ismember(all,before));
assert(numel(created)==1); fig=created(1); closer=onCleanup(@() delete(fig)); %#ok<NASGU>
ui=fig.UserData;
assert(strcmp(ui.segSmoothFWHM.Value,'6 6 6'));
ui.segSmoothFWHM.Value='2 3 4';
seg=MIKey_config(struct('steps',17,'segSmoothFWHM',ui.segSmoothFWHM.Value));
assert(isequal(seg.segSmoothFWHM,[2 3 4]));
assert(isa(ui.clustROIEdit,'matlab.ui.control.NumericEditField') && ui.clustROIEdit.Value==100);
assert(strcmp(ui.customPCCountsEdit.Enable,'off'));
ui.defaultPCStrategyCheckbox.Value=false;
ui.defaultPCStrategyCheckbox.ValueChangedFcn(ui.defaultPCStrategyCheckbox,[]);
assert(strcmp(ui.customPCCountsEdit.Enable,'on'));
ui.customPCCountsEdit.Value='0 3 7';
cfg=MIKey_defaults(); map=MIKey_parameter_map();
for i=1:size(map,1),cfg.(map{i,1})=ui.(map{i,2}).Value;end
cfg.steps=[10 15]; % Validate the PC/ROI controls under their selected stages.
cfg=MIKey_config(cfg);assert(~cfg.useDefaultPCStrategy && isequal(cfg.customPCCounts,[0 3 7]));
state=MIKeyBatchState(cfg,-1);assert(isnumeric(state.UserData.clustROIEdit.Value));
assert(isequal(MIKey_pc_counts(state.UserData.defaultPCStrategyCheckbox.Value,state.UserData.customPCCountsEdit.Value,40,10),[0 3 7]));
for controls={ui.coregInterpHelp,ui.normInterpHelp}
    text=controls{1}.Text;assert(numel(text)==3 && ~isempty(strfind(text{3},'7th degree B-spline')));
end
ui.useCustomParcCheckbox.Value=true;ui.useCustomParcCheckbox.ValueChangedFcn(ui.useCustomParcCheckbox,[]);
assert(strcmp(ui.networkCustomLabel.Text,'Network Prior:') && strcmp(ui.networkCustomLabel.Visible,'on'));
assert(strcmp(ui.labelCustomLabel.Text,'ROI Label Atlas:') && strcmp(ui.labelCustomLabel.Visible,'on'));
assert(ui.percentTopEdit.Position(2)>ui.tissueSegButton.Position(2));
assert(ui.groupNetworkEdit.Position(2)>ui.tissueSegButton.Position(2));
for button={ui.configButton,ui.saveConfigButton,ui.exportConfigButton}
    rectangle=button{1}.Position;assert(rectangle(2)+rectangle(4)<ui.statusText.Position(2));
    color=button{1}.BackgroundColor;assert(color(2)>color(1) && color(2)>color(3));
end
assert(~isempty(ui.exportConfigButton.ButtonPushedFcn));
ui.useDefaultTemplateCheckbox.Value=false;ui.useDefaultTemplateCheckbox.ValueChangedFcn(ui.useDefaultTemplateCheckbox,[]);
ui.fcLabelDropdown.Value='Custom...';ui.fcLabelDropdown.ValueChangedFcn(ui.fcLabelDropdown,[]);
children=fig.Children;
rectangles=[];
for i=1:numel(children)
    child=children(i);
    if ~isprop(child,'Visible') || strcmp(child.Visible,'off'),continue;end
    position=child.Position;
    assert(position(1)>=0 && position(2)>=0 && position(1)+position(3)<=fig.Position(3) && position(2)+position(4)<=fig.Position(4));
    rectangles(end+1,:)=position; %#ok<AGROW>
end
for i=1:size(rectangles,1)
    for j=i+1:size(rectangles,1)
        a=rectangles(i,:);b=rectangles(j,:);
        overlapX=min(a(1)+a(3),b(1)+b(3))-max(a(1),b(1));
        overlapY=min(a(2)+a(4),b(2)+b(4))-max(a(2),b(2));
        assert(overlapX<=0 || overlapY<=0,'Visible controls overlap.');
    end
end
disp('MIKEY_UI_LAYOUT_PASS');
end

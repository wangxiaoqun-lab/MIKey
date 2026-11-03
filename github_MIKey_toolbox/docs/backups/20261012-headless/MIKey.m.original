function MIKey
clc;close all;clear all;
fig = uifigure('Name', 'MIKey - Mouse Image Key Toolbox', 'Position', [100 100 1400 900]);
createGUIComponents(fig);
end

function createGUIComponents(fig)

window_width = 1400;
col_width = floor(window_width / 3);
col1_x = 20;
col2_x = col1_x + col_width;
col3_x = col2_x + col_width;

uilabel(fig, 'Position', [col1_x 870 300 20], 'Text', 'Select BIDS Root Folder', 'FontSize', 11, 'FontWeight', 'bold','FontColor', 'red');
bidsButton = uibutton(fig, 'Position', [col1_x 840 150 25], 'Text', 'Select BIDS Folder','BackgroundColor', [1 0.8 0.8]);

uilabel(fig, 'Position', [col2_x-50 845 80 20], 'Text', 'Template:', 'FontSize', 10);
templateEdit = uieditfield(fig, 'text', 'Position', [col2_x+40 845 200 20], 'Value', fullfile('.', 'share_temp'));

uilabel(fig, 'Position', [col3_x-50 845 70 20], 'Text', 'Code Path:', 'FontSize', 10);
codeEdit = uieditfield(fig, 'text', 'Position', [col3_x+30 845 200 20], 'Value', fullfile('.', 'scripts'));

uilabel(fig, 'Position', [col1_x 800 90 20], 'Text', 'Subj Filter:', 'FontSize', 10);
subjectsEdit = uieditfield(fig, 'text', 'Position', [col1_x+100 800 120 20], 'Value', 'sub-*');

uilabel(fig, 'Position', [col2_x 800 80 20], 'Text', 'Steps:', 'FontSize', 10);
stagesEdit = uieditfield(fig, 'text', 'Position', [col2_x+90 800 80 20], 'Value', '1:17');

runStepsButton = uibutton(fig, 'Position', [col3_x 800 250 30], 'Text', 'Run Selected Steps','BackgroundColor', [0.8 0.8 1]);

separator_y = 770;
uipanel(fig, 'Position', [20 separator_y window_width-40 2], ...
    'BackgroundColor', [0.7 0.7 0.7], 'BorderType', 'none');


y_start = 720;

% Step 1: Voxel Scaling
uilabel(fig, 'Position', [col1_x y_start 200 20], 'Text', '1. Voxel Scaling', 'FontSize', 12, 'FontWeight', 'bold');
scalingButton = uibutton(fig, 'Position', [col1_x y_start-25 120 22], 'Text', 'Execute');
uilabel(fig, 'Position', [col1_x+130 y_start-25 60 20], 'Text', 'Scale:', 'FontSize', 9);
voxelScaleEdit = uieditfield(fig, 'numeric', 'Position', [col1_x+190 y_start-25 50 20], 'Value', 20);

uilabel(fig, 'Position', [col1_x y_start-55 400 20], 'Text', 'Please generate brain-mask with scaled images<sub*-brainmask.nii>', 'FontSize', 10, 'FontWeight', 'bold','FontColor', [0.5 0.5 0.5]);

% Step 2: Mask Data
uilabel(fig, 'Position', [col1_x y_start-85 200 20], 'Text', '2. Mask Data', 'FontSize', 12, 'FontWeight', 'bold');
maskButton = uibutton(fig, 'Position', [col1_x y_start-110 120 22], 'Text', 'Whole-brain Mask');

% Step 3: Fieldmap Correction
uilabel(fig, 'Position', [col1_x y_start-140 250 20], 'Text', '3. Fieldmap Correction (Opt)', 'FontSize', 12, 'FontWeight', 'bold');
fieldmapButton = uibutton(fig, 'Position', [col1_x y_start-165 120 22], 'Text', 'Fieldmap Corr');

% Step 4: Slice Timing
uilabel(fig, 'Position', [col1_x y_start-195 200 20], 'Text', '4. Slice Timing (Opt)', 'FontSize', 12, 'FontWeight', 'bold');
slicetimeButton = uibutton(fig, 'Position', [col1_x y_start-220 120 22], 'Text', 'Slice Timing');
uilabel(fig, 'Position', [col1_x+130 y_start-220 30 20], 'Text', 'TR:', 'FontSize', 9);
sliceTimingTR = uieditfield(fig, 'numeric', 'Position', [col1_x+160 y_start-220 40 20], 'Value', 2.0);
uilabel(fig, 'Position', [col1_x+210 y_start-220 40 20], 'Text', 'Slices:', 'FontSize', 9);
sliceTimingNSlices = uieditfield(fig, 'numeric', 'Position', [col1_x+250 y_start-220 40 20], 'Value', 30);

uilabel(fig, 'Position', [col1_x y_start-245 60 20], 'Text', 'Slice Order:', 'FontSize', 9);
sliceTimingOrder = uidropdown(fig, 'Position', [col1_x+65 y_start-245 180 20], ...
    'Items', {'Auto-detect', 'ascending', 'descending', 'interleaved'}, 'Value', 'Auto-detect');

% Step 5: Realignment
uilabel(fig, 'Position', [col1_x y_start-275 200 20], 'Text', '5. Realignment', 'FontSize', 12, 'FontWeight', 'bold');
realignButton = uibutton(fig, 'Position', [col1_x y_start-300 120 22], 'Text', 'Realignment');

% Step 6: Coregistration
uilabel(fig, 'Position', [col1_x y_start-330 200 20], 'Text', '6. Coregistration', 'FontSize', 12, 'FontWeight', 'bold');
coregButton = uibutton(fig, 'Position', [col1_x y_start-355 120 22], 'Text', 'Coregistration');
uilabel(fig, 'Position', [col1_x+130 y_start-355 60 20], 'Text', 'Interp:', 'FontSize', 9);
coregInterpEdit = uieditfield(fig, 'numeric', 'Position', [col1_x+190 y_start-355 40 20], 'Value', 2);

% Step 7: Normalization
uilabel(fig, 'Position', [col1_x y_start-385 200 20], 'Text', '7. Normalization', 'FontSize', 12, 'FontWeight', 'bold');
normButton = uibutton(fig, 'Position', [col1_x y_start-410 120 22], 'Text', 'Normalization');
uilabel(fig, 'Position', [col1_x+130 y_start-410 60 20], 'Text', 'Interp:', 'FontSize', 9);
normInterpEdit = uieditfield(fig, 'numeric', 'Position', [col1_x+190 y_start-410 40 20], 'Value', 2);

uilabel(fig, 'Position', [col1_x y_start-435 100 20], 'Text', 'Use Def Template:', 'FontSize', 9);
useDefaultTemplateCheckbox = uicheckbox(fig, 'Position', [col1_x+100 y_start-435 20 20], 'Value', true);
uilabel(fig, 'Position', [col1_x+130 y_start-435 80 20], 'Text', 'Custom:', 'FontSize', 9);
templateCustomEdit = uieditfield(fig, 'text', 'Position', [col1_x+190 y_start-435 120 20], 'Visible', 'off');
templateCustomButton = uibutton(fig, 'Position', [col1_x+310 y_start-435 40 20], 'Text', '...', 'Visible', 'off');

% Step 8: Smoothing
uilabel(fig, 'Position', [col1_x y_start-465 200 20], 'Text', '8. Smoothing', 'FontSize', 12, 'FontWeight', 'bold');
smoothButton = uibutton(fig, 'Position', [col1_x y_start-490 120 22], 'Text', 'Smoothing');
uilabel(fig, 'Position', [col1_x+130 y_start-490 50 20], 'Text', 'FWHM:', 'FontSize', 9);
smoothFWHM = uieditfield(fig, 'text', 'Position', [col1_x+180 y_start-490 80 20], 'Value', '6 6 6');

% Step 9: Noise PC Estimation
uilabel(fig, 'Position', [col2_x y_start 200 20], 'Text', '9. Noise PC Estimation', 'FontSize', 12, 'FontWeight', 'bold');
noiseButton = uibutton(fig, 'Position', [col2_x y_start-25 120 22], 'Text', 'Estimate PCs');

% Step 10: Single Run Noise Regression
uilabel(fig, 'Position', [col2_x y_start-55 250 20], 'Text', '10. Single Run Noise Regression', 'FontSize', 12, 'FontWeight', 'bold');
regressionButton = uibutton(fig, 'Position', [col2_x y_start-80 120 22], 'Text', 'Single Run Est');

% Step 11: Optimal Noise Regression Strategy
uilabel(fig, 'Position', [col2_x y_start-110 250 20], 'Text', '11. Optimal Noise Strategy', 'FontSize', 12, 'FontWeight', 'bold');
groupNoiseButton = uibutton(fig, 'Position', [col2_x y_start-135 120 22], 'Text', 'Cross Run Est');

% Step 12: Advanced Regression
uilabel(fig, 'Position', [col2_x y_start-165 200 20], 'Text', '12. Advanced Regression', 'FontSize', 12, 'FontWeight', 'bold');
advRegressionButton = uibutton(fig, 'Position', [col2_x y_start-190 120 22], 'Text', 'Adv Regression');

% Head Motion Regression parameters
uilabel(fig, 'Position', [col2_x+130 y_start-190 80 20], 'Text', 'Detrend:', 'FontSize', 9);
detrendCheckbox = uicheckbox(fig, 'Position', [col2_x+180 y_start-190 20 20], 'Value', true);
uilabel(fig, 'Position', [col2_x+210 y_start-190 50 20], 'Text', 'Filter:', 'FontSize', 9);
filterCheckbox = uicheckbox(fig, 'Position', [col2_x+250 y_start-190 20 20], 'Value', true);

uilabel(fig, 'Position', [col2_x y_start-215 70 20], 'Text', 'High Freq:', 'FontSize', 9);
highFreqEdit = uieditfield(fig, 'numeric', 'Position', [col2_x+70 y_start-215 40 20], 'Value', 0.1);
uilabel(fig, 'Position', [col2_x+120 y_start-215 70 20], 'Text', 'Low Freq:', 'FontSize', 9);
lowFreqEdit = uieditfield(fig, 'numeric', 'Position', [col2_x+190 y_start-215 40 20], 'Value', 0.01);

% Advanced regression strategies
uilabel(fig, 'Position', [col2_x y_start-240 120 20], 'Text', 'Strategies:', 'FontSize', 9, 'FontWeight', 'bold');
advRegressionPCOnlyCheckbox = uicheckbox(fig, 'Position', [col2_x y_start-265 70 20], 'Text', 'PC only', 'Value', true);
advRegressionPCCSFCheckbox = uicheckbox(fig, 'Position', [col2_x+80 y_start-265 70 20], 'Text', 'PC+CSF', 'Value', true);
advRegressionPCGSCheckbox = uicheckbox(fig, 'Position', [col2_x+160 y_start-265 70 20], 'Text', 'PC+GS', 'Value', true);
advRegressionPCCSFGSCheckbox = uicheckbox(fig, 'Position', [col2_x+240 y_start-265 90 20], 'Text', 'PC+CSF+GS', 'Value', true);

% Step 13: Region FC
uilabel(fig, 'Position', [col2_x y_start-295 200 20], 'Text', '13. Region/Network FC', 'FontSize', 12, 'FontWeight', 'bold');
fcButton = uibutton(fig, 'Position', [col2_x y_start-320 120 22], 'Text', 'FC Analysis');
uilabel(fig, 'Position', [col2_x+130 y_start-320 60 20], 'Text', 'Label:', 'FontSize', 9);
fcLabelDropdown = uidropdown(fig, 'Position', [col2_x+190 y_start-320 100 20], ...
    'Items', {'214', '428', '604', '1184', 'Custom...'}, 'Value', '428');
fcCustomEdit = uieditfield(fig, 'text', 'Position', [col2_x y_start-345 220 20], 'Visible', 'off');
fcCustomButton = uibutton(fig, 'Position', [col2_x+230 y_start-345 40 20], 'Text', '...', 'Visible', 'off');

% Step 14: Individual Parcellation - Prior Label (Moved to middle column)
uilabel(fig, 'Position', [col2_x y_start-370 300 20], 'Text', '14. Parcellation - Prior Label', 'FontSize', 12, 'FontWeight', 'bold');
parcellationButton = uibutton(fig, 'Position', [col2_x y_start-395 120 22], 'Text', 'Network Parc');
uilabel(fig, 'Position', [col2_x+130 y_start-395 80 20], 'Text', 'Network:', 'FontSize', 9);
parcNetworkDropdown = uidropdown(fig, 'Position', [col2_x+210 y_start-395 180 20], ...
    'Items', {'214rois', '428rois', '604rois', '1184rois'}, 'Value', '428rois');

useCustomParcCheckbox = uicheckbox(fig, 'Position', [col2_x y_start-420 150 20], 'Text', 'Use Custom', 'Value', false);
networkCustomEdit = uieditfield(fig, 'text', 'Position', [col2_x y_start-445 180 20], 'Visible', 'off');
networkCustomButton = uibutton(fig, 'Position', [col2_x+190 y_start-445 40 20], 'Text', '...', 'Visible', 'off');
labelCustomEdit = uieditfield(fig, 'text', 'Position', [col2_x y_start-470 180 20], 'Visible', 'off');
labelCustomButton = uibutton(fig, 'Position', [col2_x+190 y_start-470 40 20], 'Text', '...', 'Visible', 'off');


% Step 15: Individual Parcellation - Clustering
uilabel(fig, 'Position', [col3_x y_start 300 20], 'Text', '15. Parcellation - Clustering', 'FontSize', 12, 'FontWeight', 'bold');
parcellationClustButton = uibutton(fig, 'Position', [col3_x y_start-25 120 22], 'Text', 'Clustering Parc');
uilabel(fig, 'Position', [col3_x+130 y_start-25 70 20], 'Text', 'ROI Num:', 'FontSize', 9);
clustROIEdit = uieditfield(fig, 'text', 'Position', [col3_x+200 y_start-25 100 20], 'Value', '100 200 400 800');

% Step 16: Individual Parcellation - Voxel Mode
uilabel(fig, 'Position', [col3_x y_start-55 300 20], 'Text', '16. Parcellation - Voxel Mode', 'FontSize', 12, 'FontWeight', 'bold');
parcellationVoxelButton = uibutton(fig, 'Position', [col3_x y_start-80 120 22], 'Text', 'Voxel Parc');
uilabel(fig, 'Position', [col3_x+130 y_start-80 90 20], 'Text', 'Downsample:', 'FontSize', 9);
voxelDownsampleEdit = uieditfield(fig, 'numeric', 'Position', [col3_x+220 y_start-80 50 20], 'Value', 2);

% Step 17: Tissue Segmentation
uilabel(fig, 'Position', [col3_x y_start-110 250 20], 'Text', '17. Tissue Segmentation', 'FontSize', 12, 'FontWeight', 'bold');
tissueSegButton = uibutton(fig, 'Position', [col3_x y_start-135 120 22], 'Text', 'Tissue Seg');

% Shared Parcellation Parameters
uilabel(fig, 'Position', [col3_x y_start-185 200 20], 'Text', 'Parcellation Parameters', 'FontSize', 11, 'FontWeight', 'bold');

uilabel(fig, 'Position', [col3_x y_start-210 70 20], 'Text', 'Percent Top:', 'FontSize', 9);
percentTopEdit = uieditfield(fig, 'numeric', 'Position', [col3_x+70 y_start-210 50 20], 'Value', 0.8);

uilabel(fig, 'Position', [col3_x+130 y_start-210 60 20], 'Text', 'Max Iter:', 'FontSize', 9);
maxIterEdit = uieditfield(fig, 'numeric', 'Position', [col3_x+190 y_start-210 50 20], 'Value', 30);

uilabel(fig, 'Position', [col3_x y_start-235 80 20], 'Text', 'Change Thr:', 'FontSize', 9);
changeThrEdit = uieditfield(fig, 'numeric', 'Position', [col3_x+80 y_start-235 50 20], 'Value', 0.001);

uilabel(fig, 'Position', [col3_x+140 y_start-235 70 20], 'Text', 'Conf Thr:', 'FontSize', 9);
confThrEdit = uieditfield(fig, 'numeric', 'Position', [col3_x+210 y_start-235 50 20], 'Value', 2.5);

% Parcellation corrections
useTSNRCheckbox = uicheckbox(fig, 'Position', [col3_x y_start-265 80 20], 'Text', 'Use tSNR', 'Value', false);
useInterSubjectVarCheckbox = uicheckbox(fig, 'Position', [col3_x+90 y_start-265 120 20], 'Text', 'Use Inter-Subj Var', 'Value', false);

configButton = uibutton(fig, 'Position', [col3_x y_start-310 120 25], 'Text', 'Load Config');
saveConfigButton = uibutton(fig, 'Position', [col3_x+130 y_start-310 120 25], 'Text', 'Save Config');


uilabel(fig, 'Position', [50 160 1300 20], 'Text', 'Status Display:', 'FontSize', 11, 'FontWeight', 'bold');
statusText = uitextarea(fig, 'Position', [50 10 1300 150], 'Editable', false);

fig.UserData.bidsButton = bidsButton;
fig.UserData.runStepsButton = runStepsButton;
fig.UserData.scalingButton = scalingButton;
fig.UserData.maskButton = maskButton;
fig.UserData.fieldmapButton = fieldmapButton;
fig.UserData.slicetimeButton = slicetimeButton;
fig.UserData.realignButton = realignButton;
fig.UserData.coregButton = coregButton;
fig.UserData.normButton = normButton;
fig.UserData.smoothButton = smoothButton;
fig.UserData.noiseButton = noiseButton;
fig.UserData.regressionButton = regressionButton;
fig.UserData.groupNoiseButton = groupNoiseButton;
fig.UserData.advRegressionButton = advRegressionButton;
fig.UserData.fcButton = fcButton;
fig.UserData.parcellationButton = parcellationButton;
fig.UserData.parcellationClustButton = parcellationClustButton;
fig.UserData.parcellationVoxelButton = parcellationVoxelButton;
fig.UserData.tissueSegButton = tissueSegButton;
fig.UserData.statusText = statusText;
fig.UserData.templateEdit = templateEdit;
fig.UserData.codeEdit = codeEdit;
fig.UserData.subjectsEdit = subjectsEdit;
fig.UserData.stagesEdit = stagesEdit;
fig.UserData.voxelScaleEdit = voxelScaleEdit;
fig.UserData.sliceTimingTR = sliceTimingTR;
fig.UserData.sliceTimingNSlices = sliceTimingNSlices;
fig.UserData.sliceTimingOrder = sliceTimingOrder;
fig.UserData.smoothFWHM = smoothFWHM;
fig.UserData.coregInterpEdit = coregInterpEdit;
fig.UserData.normInterpEdit = normInterpEdit;
fig.UserData.fcLabelDropdown = fcLabelDropdown;
fig.UserData.parcNetworkDropdown = parcNetworkDropdown;
fig.UserData.fcCustomEdit = fcCustomEdit;
fig.UserData.networkCustomEdit = networkCustomEdit;
fig.UserData.labelCustomEdit = labelCustomEdit;
fig.UserData.useCustomParcCheckbox = useCustomParcCheckbox;
fig.UserData.clustROIEdit = clustROIEdit;
fig.UserData.voxelDownsampleEdit = voxelDownsampleEdit;
fig.UserData.useTSNRCheckbox = useTSNRCheckbox;
fig.UserData.useInterSubjectVarCheckbox = useInterSubjectVarCheckbox;
fig.UserData.advRegressionPCOnlyCheckbox = advRegressionPCOnlyCheckbox;
fig.UserData.advRegressionPCCSFCheckbox = advRegressionPCCSFCheckbox;
fig.UserData.advRegressionPCGSCheckbox = advRegressionPCGSCheckbox;
fig.UserData.advRegressionPCCSFGSCheckbox = advRegressionPCCSFGSCheckbox;
fig.UserData.percentTopEdit = percentTopEdit;
fig.UserData.maxIterEdit = maxIterEdit;
fig.UserData.changeThrEdit = changeThrEdit;
fig.UserData.confThrEdit = confThrEdit;
fig.UserData.detrendCheckbox = detrendCheckbox;
fig.UserData.filterCheckbox = filterCheckbox;
fig.UserData.highFreqEdit = highFreqEdit;
fig.UserData.lowFreqEdit = lowFreqEdit;
fig.UserData.useDefaultTemplateCheckbox = useDefaultTemplateCheckbox;
fig.UserData.templateCustomEdit = templateCustomEdit;
fig.UserData.templateCustomButton = templateCustomButton;
fig.UserData.fcCustomButton = fcCustomButton;
fig.UserData.networkCustomButton = networkCustomButton;
fig.UserData.labelCustomButton = labelCustomButton;


bidsButton.ButtonPushedFcn = @(btn,event) selectBIDSFolder(fig);
runStepsButton.ButtonPushedFcn = @(btn,event) runSelectedSteps(fig);
scalingButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 1);
maskButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 2);
fieldmapButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 3);
slicetimeButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 4);
realignButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 5);
coregButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 6);
normButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 7);
smoothButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 8);
noiseButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 9);
regressionButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 10);
groupNoiseButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 11);
advRegressionButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 12);
fcButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 13);
parcellationButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 14);
parcellationClustButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 15);
parcellationVoxelButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 16);
tissueSegButton.ButtonPushedFcn = @(btn,event) executeStage(fig, 17);
configButton.ButtonPushedFcn = @(btn,event) loadConfiguration(fig);
saveConfigButton.ButtonPushedFcn = @(btn,event) saveConfiguration(fig);


fcLabelDropdown.ValueChangedFcn = @(dd,event) handleDropdownChange(fig, 'fc');
useCustomParcCheckbox.ValueChangedFcn = @(cb,event) handleCustomParcCheckbox(fig);
useDefaultTemplateCheckbox.ValueChangedFcn = @(cb,event) handleTemplateCheckbox(fig);
templateCustomButton.ButtonPushedFcn = @(btn,event) selectCustomTemplate(fig);
fcCustomButton.ButtonPushedFcn = @(btn,event) selectCustomFile(fig, 'fc');
networkCustomButton.ButtonPushedFcn = @(btn,event) selectCustomFile(fig, 'network');
labelCustomButton.ButtonPushedFcn = @(btn,event) selectCustomFile(fig, 'label');

handleCustomParcCheckbox(fig);
handleTemplateCheckbox(fig);
handleDropdownChange(fig, 'fc');
end


function handleDropdownChange(fig, dropdownType)
switch dropdownType
    case 'fc'
        if strcmp(fig.UserData.fcLabelDropdown.Value, 'Custom...')
            fig.UserData.fcCustomEdit.Visible = 'on';
            fig.UserData.fcCustomButton.Visible = 'on';
        else
            fig.UserData.fcCustomEdit.Visible = 'off';
            fig.UserData.fcCustomButton.Visible = 'off';
        end
end
end

function handleCustomParcCheckbox(fig)
if fig.UserData.useCustomParcCheckbox.Value
    fig.UserData.parcNetworkDropdown.Visible = 'off';
    fig.UserData.networkCustomEdit.Visible = 'on';
    fig.UserData.labelCustomEdit.Visible = 'on';
    fig.UserData.networkCustomButton.Visible = 'on';
    fig.UserData.labelCustomButton.Visible = 'on';
else
    fig.UserData.parcNetworkDropdown.Visible = 'on';
    fig.UserData.networkCustomEdit.Visible = 'off';
    fig.UserData.labelCustomEdit.Visible = 'off';
    fig.UserData.networkCustomButton.Visible = 'off';
    fig.UserData.labelCustomButton.Visible = 'off';
end
end

function handleTemplateCheckbox(fig)
if fig.UserData.useDefaultTemplateCheckbox.Value
    fig.UserData.templateCustomEdit.Visible = 'off';
    fig.UserData.templateCustomButton.Visible = 'off';
else
    fig.UserData.templateCustomEdit.Visible = 'on';
    fig.UserData.templateCustomButton.Visible = 'on';
end
end

function selectCustomTemplate(fig)
[file, path] = uigetfile('*.nii', 'Select Custom Template File');
if file ~= 0
    filePath = fullfile(path, file);
    fig.UserData.templateCustomEdit.Value = filePath;
    updateStatus(fig, ['Selected custom template: ' filePath]);
end
end

function selectCustomFile(fig, fileType)
[file, path] = uigetfile('*.nii', ['Select ' fileType ' file']);
if file ~= 0
    filePath = fullfile(path, file);
    
    if validateNiftiDimensions(fig, filePath)
        switch fileType
            case 'fc'
                fig.UserData.fcCustomEdit.Value = filePath;
            case 'network'
                fig.UserData.networkCustomEdit.Value = filePath;
            case 'label'
                fig.UserData.labelCustomEdit.Value = filePath;
        end
        updateStatus(fig, ['Selected ' fileType ' file: ' filePath]);
    else
        errordlg(['The selected ' fileType ' file has incorrect dimensions or data type. Please select a file matching Template_Mouse_v38.nii dimensions with integer values 1:n.'], 'File Validation Error');
    end
end
end

function isValid = validateNiftiDimensions(fig, filePath)
isValid = false;
try
    templatePath = fig.UserData.templateEdit.Value;
    templateFile = fullfile(templatePath, 'Template_Mouse_v38.nii');
    
    if ~exist(templateFile, 'file')
        updateStatus(fig, 'Warning: Template file not found, skipping dimension validation');
        isValid = true;
        return;
    end
    
    templateHeader = spm_vol(templateFile);
    customHeader = spm_vol(filePath);
    
    if ~isequal(templateHeader.dim, customHeader.dim)
        updateStatus(fig, ['Dimension mismatch: Template=' mat2str(templateHeader.dim) ', Custom=' mat2str(customHeader.dim)]);
        return;
    end
    
    customData = spm_read_vols(customHeader);
    uniqueVals = unique(customData(:));
    uniqueVals = uniqueVals(~isnan(uniqueVals) & uniqueVals ~= 0);
    
    if any(uniqueVals ~= round(uniqueVals)) || ~isequal(uniqueVals', 1:length(uniqueVals))
        updateStatus(fig, 'Data validation failed: Values should be integers from 1 to n');
        return;
    end
    
    isValid = true;
    updateStatus(fig, 'Custom file validation passed');
    
catch ME
    updateStatus(fig, ['File validation error: ' ME.message]);
end
end

function runSelectedSteps(fig)
if ~isfield(fig.UserData, 'bidsPath')
    errordlg('Please select BIDS folder first', 'Error');
    return;
end

stepsStr = fig.UserData.stagesEdit.Value;
steps = parseStepsString(stepsStr);

if isempty(steps)
    errordlg('Invalid steps format. Please use format like "1:17" or "1,2,3,5:8"', 'Error');
    return;
end

updateStatus(fig, ['Running steps: ' stepsStr]);

for i = 1:length(steps)
    step = steps(i);
    if step >= 1 && step <= 17
        updateStatus(fig, ['=== Starting Step ' num2str(step) ' ===']);
        executeStage(fig, step);
        updateStatus(fig, ['=== Completed Step ' num2str(step) ' ===']);
    else
        updateStatus(fig, ['Warning: Invalid step number ' num2str(step) ', skipping']);
    end
end

updateStatus(fig, 'All selected steps completed!');
end

function steps = parseStepsString(stepsStr)
steps = [];
try
    stepsStr = strrep(stepsStr, ' ', '');
    parts = strsplit(stepsStr, ',');
    
    for i = 1:length(parts)
        part = parts{i};
        if contains(part, ':')
            rangeParts = strsplit(part, ':');
            if length(rangeParts) == 2
                startStep = str2double(rangeParts{1});
                endStep = str2double(rangeParts{2});
                if ~isnan(startStep) && ~isnan(endStep)
                    steps = [steps, startStep:endStep];
                end
            end
        else
            step = str2double(part);
            if ~isnan(step)
                steps = [steps, step];
            end
        end
    end
    
    steps = unique(steps);
    
catch
    steps = [];
end
end

function updateStatus(fig, message)
currentText = fig.UserData.statusText.Value;
timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
formattedMessage = [timestamp, ': ', message];

if isempty(currentText)
    newText = {formattedMessage};
else
    newText = [currentText; {formattedMessage}];
end
fig.UserData.statusText.Value = newText;
drawnow;
end

function selectBIDSFolder(fig)
bidsPath = uigetdir('', 'Select BIDS Root Folder');
if bidsPath == 0
    return;
end
fig.UserData.bidsPath = bidsPath;
updateStatus(fig, ['Selected BIDS folder: ' bidsPath]);
toolboxRoot = fileparts(mfilename('fullpath'));
fig.UserData.templateEdit.Value = fullfile(toolboxRoot, 'share_temp');
fig.UserData.codeEdit.Value = fullfile(toolboxRoot, 'scripts');
checkBIDSStructure(fig, bidsPath);
end

function checkBIDSStructure(fig, bidsPath)
subDirs = dir(fullfile(bidsPath, 'sub-*'));
if isempty(subDirs)
    updateStatus(fig, 'Warning: No subject directories found (sub-*)');
    return;
end

updateStatus(fig, ['Found ' num2str(length(subDirs)) ' subject directories']);

for i = 1:length(subDirs)
    subPath = fullfile(subDirs(i).folder, subDirs(i).name);
    
    anatPath = fullfile(subPath, 'anat');
    if exist(anatPath, 'dir')
        t2Files = dir(fullfile(anatPath, '*_T2w.nii'));
        updateStatus(fig, ['Subject ' subDirs(i).name ': Found ' num2str(length(t2Files)) ' T2w files']);
    end
    fmapPath = fullfile(subPath, 'fmap');
    if exist(fmapPath, 'dir')
        fmapFiles = dir(fullfile(fmapPath, '*.nii'));
        updateStatus(fig, ['Subject ' subDirs(i).name ': Found ' num2str(length(fmapFiles)) ' fmap files']);
    end
    funcPath = fullfile(subPath, 'func');
    if exist(funcPath, 'dir')
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        updateStatus(fig, ['Subject ' subDirs(i).name ': Found ' num2str(length(boldFiles)) ' BOLD files']);
    end
end
end

function loadConfiguration(fig)
[file, path] = uigetfile('*.mat', 'Select Configuration File');
if file == 0
    return;
end

config = load(fullfile(path, file));
if isfield(config, 'bidsPath')
    fig.UserData.bidsPath = config.bidsPath;
end
if isfield(config, 'templatePath')
    fig.UserData.templateEdit.Value = config.templatePath;
end
if isfield(config, 'codePath')
    fig.UserData.codeEdit.Value = config.codePath;
end
if isfield(config, 'voxelScaleFactor')
    fig.UserData.voxelScaleEdit.Value = config.voxelScaleFactor;
end
if isfield(config, 'sliceTimingTR')
    fig.UserData.sliceTimingTR.Value = config.sliceTimingTR;
end
if isfield(config, 'sliceTimingNSlices')
    fig.UserData.sliceTimingNSlices.Value = config.sliceTimingNSlices;
end
if isfield(config, 'sliceTimingOrder')
    fig.UserData.sliceTimingOrder.Value = config.sliceTimingOrder;
end
if isfield(config, 'smoothFWHM')
    fig.UserData.smoothFWHM.Value = config.smoothFWHM;
end
if isfield(config, 'bandpassLow')
    fig.UserData.bandpassLowEdit.Value = config.bandpassLow;
end
if isfield(config, 'bandpassHigh')
    fig.UserData.bandpassHighEdit.Value = config.bandpassHigh;
end
if isfield(config, 'coregInterp')
    fig.UserData.coregInterpEdit.Value = config.coregInterp;
end
if isfield(config, 'normInterp')
    fig.UserData.normInterpEdit.Value = config.normInterp;
end
if isfield(config, 'percentTop')
    fig.UserData.percentTopEdit.Value = config.percentTop;
end
if isfield(config, 'maxIter')
    fig.UserData.maxIterEdit.Value = config.maxIter;
end
if isfield(config, 'changeThr')
    fig.UserData.changeThrEdit.Value = config.changeThr;
end
if isfield(config, 'confThr')
    fig.UserData.confThrEdit.Value = config.confThr;
end
if isfield(config, 'voxelDownsampleFactor')
    fig.UserData.voxelDownsampleEdit.Value = config.voxelDownsampleFactor;
end
if isfield(config, 'useTSNR')
    fig.UserData.useTSNRCheckbox.Value = config.useTSNR;
end
if isfield(config, 'useInterSubjectVar')
    fig.UserData.useInterSubjectVarCheckbox.Value = config.useInterSubjectVar;
end

if isfield(config, 'detrendFlag')
    fig.UserData.detrendCheckbox.Value = config.detrendFlag;
end
if isfield(config, 'filterFlag')
    fig.UserData.filterCheckbox.Value = config.filterFlag;
end
if isfield(config, 'highFreq')
    fig.UserData.highFreqEdit.Value = config.highFreq;
end
if isfield(config, 'lowFreq')
    fig.UserData.lowFreqEdit.Value = config.lowFreq;
end
if isfield(config, 'useDefaultTemplate')
    fig.UserData.useDefaultTemplateCheckbox.Value = config.useDefaultTemplate;
end
if isfield(config, 'customTemplatePath')
    fig.UserData.templateCustomEdit.Value = config.customTemplatePath;
end

handleTemplateCheckbox(fig);

updateStatus(fig, ['Loaded configuration: ' file]);
end

function saveConfiguration(fig)
[file, path] = uiputfile('MIKey_BIDS_config.mat', 'Save Configuration As');
if file == 0
    return;
end

config.bidsPath = fig.UserData.bidsPath;
config.templatePath = fig.UserData.templateEdit.Value;
config.codePath = fig.UserData.codeEdit.Value;
config.voxelScaleFactor = fig.UserData.voxelScaleEdit.Value;
config.sliceTimingTR = fig.UserData.sliceTimingTR.Value;
config.sliceTimingNSlices = fig.UserData.sliceTimingNSlices.Value;
config.sliceTimingOrder = fig.UserData.sliceTimingOrder.Value;
config.smoothFWHM = fig.UserData.smoothFWHM.Value;
config.bandpassLow = fig.UserData.bandpassLowEdit.Value;
config.bandpassHigh = fig.UserData.bandpassHighEdit.Value;
config.coregInterp = fig.UserData.coregInterpEdit.Value;
config.normInterp = fig.UserData.normInterpEdit.Value;
config.percentTop = fig.UserData.percentTopEdit.Value;
config.maxIter = fig.UserData.maxIterEdit.Value;
config.changeThr = fig.UserData.changeThrEdit.Value;
config.confThr = fig.UserData.confThrEdit.Value;
config.voxelDownsampleFactor = fig.UserData.voxelDownsampleEdit.Value;
config.useTSNR = fig.UserData.useTSNRCheckbox.Value;
config.useInterSubjectVar = fig.UserData.useInterSubjectVarCheckbox.Value;

config.detrendFlag = fig.UserData.detrendCheckbox.Value;
config.filterFlag = fig.UserData.filterCheckbox.Value;
config.highFreq = fig.UserData.highFreqEdit.Value;
config.lowFreq = fig.UserData.lowFreqEdit.Value;
config.useDefaultTemplate = fig.UserData.useDefaultTemplateCheckbox.Value;
config.customTemplatePath = fig.UserData.templateCustomEdit.Value;

save(fullfile(path, file), 'config');
updateStatus(fig, ['Saved configuration: ' file]);
end

function executeStage(fig, stage)
if ~isfield(fig.UserData, 'bidsPath')
    errordlg('Please select BIDS folder first', 'Error');
    return;
end

codePath = fig.UserData.codeEdit.Value;
if exist(codePath, 'dir')
    addpath(genpath(codePath));
    updateStatus(fig, ['Added code path: ' codePath]);
else
    errordlg('Code path not found', 'Error');
    return;
end

templatePath = fig.UserData.templateEdit.Value;
if ~exist(templatePath, 'dir')
    errordlg('Template path not found', 'Error');
    return;
end

subjectFilter = fig.UserData.subjectsEdit.Value;

switch stage
    case 1
        updateStatus(fig, 'Starting Voxel Scaling');
        processVoxelScaling_BIDS(fig, subjectFilter, templatePath);
    case 2
        updateStatus(fig, 'Starting Mask Generation');
        processMaskedData_BIDS(fig, subjectFilter);
    case 3
        updateStatus(fig, 'Starting Fieldmap Correction');
        processFieldmapCorrection_BIDS(fig, subjectFilter, templatePath);
    case 4
        updateStatus(fig, 'Starting Slice Timing');
        processSliceTiming_BIDS(fig, subjectFilter);
    case 5
        updateStatus(fig, 'Starting Realignment');
        processRealignment_BIDS(fig, subjectFilter);
    case 6
        updateStatus(fig, 'Starting Coregistration');
        processCoregistration_BIDS(fig, subjectFilter);
    case 7
        updateStatus(fig, 'Starting Normalization');
        processNormalization_BIDS(fig, subjectFilter, templatePath);
    case 8
        updateStatus(fig, 'Starting Smoothing');
        processSmoothing_BIDS(fig, subjectFilter);
    case 9
        updateStatus(fig, 'Starting Noise PC Estimation');
        processNoisePCEstimation_BIDS(fig, subjectFilter);
    case 10
        updateStatus(fig, 'Starting Head Motion Regression');
        processMotionRegression_BIDS(fig, subjectFilter);
    case 11
        updateStatus(fig, 'Starting Group Level Noise Estimation');
        processGroupLevelNoiseEstimation_BIDS(fig, subjectFilter);
    case 12
        updateStatus(fig, 'Starting Advanced Regression');
        processAdvancedRegression_BIDS(fig, subjectFilter);
    case 13
        updateStatus(fig, 'Starting Functional Connectivity');
        processFunctionalConnectivity_BIDS(fig, subjectFilter, templatePath);
    case 14
        updateStatus(fig, 'Starting Individual Parcellation - Prior Label');
        processIndividualParcellationPrior_BIDS(fig, subjectFilter, templatePath);
    case 15
        updateStatus(fig, 'Starting Individual Parcellation - Clustering');
        processIndividualParcellationClust_BIDS(fig, subjectFilter, templatePath);
    case 16
        updateStatus(fig, 'Starting Individual Parcellation - Voxel Mode');
        processIndividualParcellationVoxel_BIDS(fig, subjectFilter, templatePath);
    case 17
        updateStatus(fig, 'Starting Tissue Segmentation');
        processTissueSegmentation_BIDS(fig, subjectFilter);
end
end

%% BIDS-Compatible Processing Functions with file existence checks

function processVoxelScaling_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

if isfield(fig.UserData, 'voxelScaleEdit')
    voxelScaleFactor = fig.UserData.voxelScaleEdit.Value;
else
    voxelScaleFactor = 20;
end

if isempty(voxelScaleFactor) || voxelScaleFactor <= 0
    updateStatus(fig, 'Warning: Invalid voxel scaling factor, using default value of 20');
    voxelScaleFactor = 20;
end

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Processing subject: ' subDirs(i).name]);
        updateStatus(fig, ['Using voxel scaling factor: ' num2str(voxelScaleFactor)]);
        
        funcPath = fullfile(subPath, 'func');
        if exist(funcPath, 'dir')
            boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
            
            for j = 1:length(boldFiles)
                boldFile = boldFiles(j).name;
                [~, baseName, ext] = fileparts(boldFile);
                
                derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
                if ~exist(derivPath, 'dir')
                    mkdir(derivPath);
                end
                
                scaledBoldPath = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                if exist(scaledBoldPath, 'file')
                    updateStatus(fig, ['Skipping - voxel scaled BOLD already exists: ' boldFile]);
                    skippedCount = skippedCount + 1;
                    continue;
                end
                
                origBoldPath = fullfile(funcPath, boldFile);
                derivBoldPath = fullfile(derivPath, [baseName '_desc-orig' ext]);
                copyfile(origBoldPath, derivBoldPath);
                
                imginfo = spm_vol(derivBoldPath);
                imgdata = spm_read_vols(imginfo);
                for k = 1:length(imginfo)
                    mat = imginfo(k).mat;
                    mat = mat * voxelScaleFactor;
                    mat(4,4) = 1;
                    imginfo(k).mat = mat;
                    imginfo(k).fname = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                end
                spm_write_vol_4D(imginfo, imgdata);
                
                updateStatus(fig, ['Completed voxel scaling for: ' boldFile]);
                processedCount = processedCount + 1;
            end
        end
        
        anatPath = fullfile(subPath, 'anat');
        if exist(anatPath, 'dir')
            t2Files = dir(fullfile(anatPath, '*_T2w.nii'));
            
            for j = 1:length(t2Files)
                t2File = t2Files(j).name;
                [~, baseName, ext] = fileparts(t2File);
                
                derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'anat');
                if ~exist(derivPath, 'dir')
                    mkdir(derivPath);
                end
                
                scaledT2Path = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                if exist(scaledT2Path, 'file')
                    updateStatus(fig, ['Skipping - voxel scaled T2w already exists: ' t2File]);
                    skippedCount = skippedCount + 1;
                    continue;
                end
                
                origT2Path = fullfile(anatPath, t2File);
                derivT2Path = fullfile(derivPath, [baseName '_desc-orig' ext]);
                copyfile(origT2Path, derivT2Path);
                
                data_head = spm_vol(derivT2Path);
                data = spm_read_vols(data_head);
                data_head.mat = data_head.mat * voxelScaleFactor;
                data_head.mat(4,4) = 1;
                data_head.fname = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                spm_write_vol(data_head, data);
                
                updateStatus(fig, ['Completed voxel scaling for: ' t2File]);
                processedCount = processedCount + 1;
            end
        end
        
        fmapPath = fullfile(subPath, 'fmap');
        if exist(fmapPath, 'dir')
            fmapFiles = dir(fullfile(fmapPath, '*.nii'));
            
            for j = 1:length(fmapFiles)
                fmapFile = fmapFiles(j).name;
                [~, baseName, ext] = fileparts(fmapFile);
                
                derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'fmap');
                if ~exist(derivPath, 'dir')
                    mkdir(derivPath);
                end
                
                scaledfmapPath = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                if exist(scaledfmapPath, 'file')
                    updateStatus(fig, ['Skipping - voxel scaled fmap already exists: ' fmapFile]);
                    skippedCount = skippedCount + 1;
                    continue;
                end
                
                origfmapPath = fullfile(fmapPath, fmapFile);
                derivfmapPath = fullfile(derivPath, [baseName '_desc-orig' ext]);
                copyfile(origfmapPath, derivfmapPath);
                
                data_head = spm_vol(derivfmapPath);
                data = spm_read_vols(data_head);
                data_head.mat = data_head.mat * voxelScaleFactor;
                data_head.mat(4,4) = 1;
                data_head.fname = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                spm_write_vol(data_head, data);
                
                updateStatus(fig, ['Completed voxel scaling for: ' fmapFile]);
                processedCount = processedCount + 1;
            end
        end
        
    catch ME
        updateStatus(fig, ['Error processing subject ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Voxel scaling completed: %d files processed, %d files skipped', processedCount, skippedCount));
updateStatus(fig, 'Please generate brain mask with scaled images [sub*bold-brainmask.nii] before next step');
end

function processMaskedData_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Generating whole-brain masked data for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        if exist(funcPath, 'dir')
            boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
            if ~isempty(boldFiles)
                for j = 1:length(boldFiles)
                    boldFile = boldFiles(j).name;
                    [~, baseName, ext] = fileparts(boldFile);
                    
                    derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
                    
                    maskedboldPath = fullfile(derivPath, [baseName '_desc-masked' ext]);
                    if exist(maskedboldPath, 'file')
                        updateStatus(fig, ['Skipping - masked BOLD already exists for: ' boldFile]);
                        skippedCount = skippedCount + 1;
                        continue;
                    end
                    
                    boldMaskFiles = dir(fullfile(derivPath, '*brainmask.nii'));
                    if isempty(boldMaskFiles)
                        updateStatus(fig, ['Warning - BOLD brain mask not found for: ' subDirs(i).name '. Please generate brain mask first.']);
                        continue;
                    else
                        boldMaskPath = fullfile(boldMaskFiles(1).folder, boldMaskFiles(1).name);
                        boldmask = spm_read_vols(spm_vol(boldMaskPath));
                    end
                    
                    scaledBoldPath = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                    if exist(scaledBoldPath, 'file')
                        boldHead = spm_vol(scaledBoldPath);
                        boldData = spm_read_vols(boldHead);
                        
                        maskedData = boldData .* repmat(boldmask, [1, 1, 1, size(boldData, 4)]);
                        
                        for k = 1:numel(boldHead)
                            boldHead(k).fname = maskedboldPath;
                        end
                        spm_write_vol_4D(boldHead, maskedData);
                        
                        updateStatus(fig, ['Completed BOLD masking for: ' boldFile]);
                        processedCount = processedCount + 1;
                    else
                        updateStatus(fig, ['Warning - scaled BOLD data not found for: ' boldFile]);
                    end
                end
            end
        end
        
        anatPath = fullfile(subPath, 'anat');
        if exist(anatPath, 'dir')
            t2Files = dir(fullfile(anatPath, '*_T2w.nii'));
            if ~isempty(t2Files)
                for j = 1:length(t2Files)
                    t2File = t2Files(j).name;
                    [~, baseName, ext] = fileparts(t2File);
                    
                    derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'anat');
                    
                    maskedT2Path = fullfile(derivPath, [baseName '_desc-masked' ext]);
                    if exist(maskedT2Path, 'file')
                        updateStatus(fig, ['Skipping - masked T2w already exists for: ' t2File]);
                        skippedCount = skippedCount + 1;
                        continue;
                    end
                    
                    t2MaskFiles = dir(fullfile(derivPath, '*brainmask.nii'));
                    if isempty(t2MaskFiles)
                        updateStatus(fig, ['Warning - T2w brain mask not found for: ' subDirs(i).name '. Please generate brain mask first.']);
                        continue;
                    else
                        t2MaskPath = fullfile(t2MaskFiles(1).folder, t2MaskFiles(1).name);
                        t2mask = spm_read_vols(spm_vol(t2MaskPath));
                    end
                    
                    scaledT2Path = fullfile(derivPath, [baseName '_desc-scaled' ext]);
                    if exist(scaledT2Path, 'file')
                        t2Head = spm_vol(scaledT2Path);
                        t2Data = spm_read_vols(t2Head);
                        
                        maskedT2Data = t2Data .* t2mask;
                        
                        t2Head.fname = maskedT2Path;
                        spm_write_vol(t2Head, maskedT2Data);
                        
                        updateStatus(fig, ['Completed T2w masking for: ' t2File]);
                        processedCount = processedCount + 1;
                    else
                        updateStatus(fig, ['Warning - scaled T2w data not found for: ' t2File]);
                    end
                end
            end
        end
        
    catch ME
        updateStatus(fig, ['Error processing masked data for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Mask application completed: %d files processed, %d files skipped', processedCount, skippedCount));
updateStatus(fig, ['Please proceed to the next step']);
end

function processFieldmapCorrection_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;
template = fullfile(templatePath, 'Template_Mouse_v38.nii,1');
subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        fmapPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'fmap');
        if ~exist(fmapPath, 'dir')
            updateStatus(fig, ['No fieldmap directory for: ' subDirs(i).name]);
            continue;
        end
        
        updateStatus(fig, ['Fieldmap correction for: ' subDirs(i).name]);
        
        echo1_M = dir(fullfile(fmapPath, 'sub*magnitude1_desc-scaled.nii'));
        echo1_P = dir(fullfile(fmapPath, 'sub*phase1_desc-scaled.nii'));
        echo2_M = dir(fullfile(fmapPath, 'sub*magnitude2_desc-scaled.nii'));
        echo2_P = dir(fullfile(fmapPath, 'sub*phase2_desc-scaled.nii'));
        
        if isempty(echo1_M) || isempty(echo1_P) || isempty(echo2_M) || isempty(echo2_P)
            updateStatus(fig, ['Incomplete fieldmap data for: ' subDirs(i).name]);
            continue;
        end
        
        echo1_M_path{1,1} = fullfile(echo1_M(1).folder, [echo1_M(1).name ',1']);
        echo1_P_path{1,1} = fullfile(echo1_P(1).folder, [echo1_P(1).name ',1']);
        echo2_M_path{1,1} = fullfile(echo2_M(1).folder, [echo2_M(1).name ',1']);
        echo2_P_path{1,1} = fullfile(echo2_P(1).folder, [echo2_P(1).name ',1']);
        ref{1,1} = template;
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, baseName, ext] = fileparts(boldFile);
            
            derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            fieldmapCorrectedPath = fullfile(derivPath, [baseName '_desc-fieldmap' ext]);
            if exist(fieldmapCorrectedPath, 'file')
                updateStatus(fig, ['Skipping - fieldmap corrected file already exists: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            scaledBoldPath = fullfile(derivPath, [baseName '_desc-masked' ext]);
            
            if exist(scaledBoldPath, 'file')
                epi_first_frame{1,1} = [scaledBoldPath ',1'];
                all_func = UN_find_images_in_all_scans(derivPath, ['^' baseName '_desc-masked'], '.nii', [1 Inf], 'all_mixed');
                
                fieldmap_mlb = UN_fieldmap_batch_struct(echo1_P_path, echo1_M_path, echo2_P_path, echo2_M_path, epi_first_frame, ref, all_func);
                spm_jobman('run', fieldmap_mlb);
                
                tempFieldmapPath = fullfile(derivPath, ['fieldmap' baseName '_desc-masked' ext]);
                if exist(tempFieldmapPath, 'file')
                    movefile(tempFieldmapPath, fieldmapCorrectedPath);
                    cd(derivPath);
                    delete('mean*.nii');delete('u*.nii');delete('wf*nii');
                    updateStatus(fig, ['Completed fieldmap correction for: ' boldFile]);
                    processedCount = processedCount + 1;
                end
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in fieldmap correction for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Fieldmap correction completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function processSliceTiming_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

if isfield(fig.UserData, 'sliceTimingTR')
    user_TR = fig.UserData.sliceTimingTR.Value;
    if user_TR == 2.0
        user_TR = [];
    end
else
    user_TR = [];
end

if isfield(fig.UserData, 'sliceTimingNSlices')
    user_NSlices = fig.UserData.sliceTimingNSlices.Value;
    if user_NSlices == 30
        user_NSlices = [];
    end
else
    user_NSlices = [];
end

if isfield(fig.UserData, 'sliceTimingOrder')
    user_SliceOrder = fig.UserData.sliceTimingOrder.Value;
    if strcmp(user_SliceOrder, 'Auto-detect from JSON')
        user_SliceOrder = [];
    end
else
    user_SliceOrder = [];
end

processedCount = 0;
skippedCount = 0;
errorCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Slice timing for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, baseName, ext] = fileparts(boldFile);
            
            derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            sliceTimedPath = fullfile(derivPath, [baseName '_desc-slicetimed' ext]);
            if exist(sliceTimedPath, 'file')
                updateStatus(fig, ['Skipping - slice timed file already exists: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            inputPath1 = fullfile(derivPath, [baseName '_desc-fieldmap' ext]);
            inputPath2 = fullfile(derivPath, [baseName '_desc-masked' ext]);
            if exist(inputPath1, 'file')
                inputPath = inputPath1;
                inputname=[baseName '_desc-fieldmap' ext];
                
            else
                inputPath = inputPath2;
                inputname= [baseName '_desc-masked' ext];
            end
            
            if exist(inputPath, 'file')
                cd(derivPath);
                
                EPI_TR = [];
                Nslice = [];
                slice_order = [];
                
                jsonFile = dir(fullfile(funcPath, [baseName '.json']));
                if ~isempty(jsonFile)
                    try
                        info = jsondecode(fileread(fullfile(jsonFile(1).folder, jsonFile(1).name)));
                        
                        if isfield(info, 'RepetitionTime')
                            EPI_TR = info.RepetitionTime;
                        elseif isfield(info, 'repetitiontime')
                            EPI_TR = info.repetitiontime;
                        elseif isfield(info, 'TR')
                            EPI_TR = info.TR;
                        elseif isfield(info, 'tr')
                            EPI_TR = info.tr;
                        end
                        
                        slice_timing = [];
                        if isfield(info, 'SliceTiming')
                            slice_timing = info.SliceTiming;
                        elseif isfield(info, 'slicetiming')
                            slice_timing = info.slicetiming;
                        elseif isfield(info, 'SliceTimingSec')
                            slice_timing = info.SliceTimingSec;
                        end
                        
                        if ~isempty(slice_timing)
                            Nslice = length(slice_timing);
                            slice_order = inferSliceOrder(slice_timing);
                            updateStatus(fig, ['Inferred slice order from JSON: ' slice_order]);
                        end
                        
                    catch ME
                        updateStatus(fig, ['Error reading JSON file for ' boldFile ': ' ME.message]);
                    end
                end
                
                if isempty(EPI_TR) && ~isempty(user_TR)
                    EPI_TR = user_TR;
                    updateStatus(fig, ['Using user-defined TR: ' num2str(EPI_TR)]);
                end
                
                if isempty(Nslice) && ~isempty(user_NSlices)
                    Nslice = user_NSlices;
                    updateStatus(fig, ['Using user-defined number of slices: ' num2str(Nslice)]);
                end
                
                if isempty(slice_order) && ~isempty(user_SliceOrder)
                    slice_order = user_SliceOrder;
                    updateStatus(fig, ['Using user-defined slice order: ' slice_order]);
                end
                
                if isempty(EPI_TR) || isempty(Nslice) || isempty(slice_order)
                    errorMsg = 'Missing slice timing parameters: ';
                    missingParams = {};
                    if isempty(EPI_TR)
                        missingParams{end+1} = 'TR';
                    end
                    if isempty(Nslice)
                        missingParams{end+1} = 'number of slices';
                    end
                    if isempty(slice_order)
                        missingParams{end+1} = 'slice order';
                    end
                    errorMsg = [errorMsg strjoin(missingParams, ', ')];
                    errorMsg = [errorMsg '. Please check JSON file or set user parameters.'];
                    
                    updateStatus(fig, ['Error: ' errorMsg]);
                    errorCount = errorCount + 1;
                    continue;
                end
                
                all_func = UN_find_images_in_all_scans(derivPath, inputname(1:end-4), '.nii', [1 Inf], 'separate_cells');
                slicetiming_mlb = UN_get_default_slicetiming_batch_struct(all_func, Nslice, EPI_TR, slice_order);
                spm_jobman('run', slicetiming_mlb);
                
                sliceFiles = dir(fullfile(derivPath, ['slicetime' baseName '_desc-*' ext]));
                if ~isempty(sliceFiles)
                    movefile(fullfile(sliceFiles(1).folder, sliceFiles(1).name), sliceTimedPath);
                    updateStatus(fig, ['Completed slice timing for: ' boldFile]);
                    updateStatus(fig, ['Parameters - TR: ' num2str(EPI_TR) ', Slices: ' num2str(Nslice) ', Order: ' slice_order]);
                    processedCount = processedCount + 1;
                end
            else
                updateStatus(fig, ['Warning: No input file found for slice timing: ' boldFile]);
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in slice timing for ' subDirs(i).name ': ' ME.message]);
        errorCount = errorCount + 1;
    end
end
updateStatus(fig, sprintf('Slice timing completed: %d files processed, %d files skipped, %d errors', processedCount, skippedCount, errorCount));
updateStatus(fig, ['Please proceed to the next step']);
end

function slice_order = inferSliceOrder(slice_timing)
n_slices = length(slice_timing);
[~, acq_order] = sort(slice_timing);

if isequal(acq_order, 1:n_slices)
    slice_order = 'ascending';
    return;
end

if isequal(acq_order, n_slices:-1:1)
    slice_order = 'descending';
    return;
end

odd_first = [1:2:n_slices, 2:2:n_slices];
if isequal(acq_order, odd_first)
    slice_order = 'interleaved ascending (odd first)';
    return;
end

even_first = [2:2:n_slices, 1:2:n_slices];
if isequal(acq_order, even_first)
    slice_order = 'interleaved ascending (even first)';
    return;
end

odd_first_desc = [n_slices:-2:1, n_slices-1:-2:1];
if isequal(acq_order, odd_first_desc)
    slice_order = 'interleaved descending (odd first)';
    return;
end

even_first_desc = [n_slices-1:-2:1, n_slices:-2:1];
if isequal(acq_order, even_first_desc)
    slice_order = 'interleaved descending (even first)';
    return;
end

if n_slices >= 4
    diffs = diff(acq_order);
    
    if all(abs(diffs(1:2:end-1)) > 1) && all(abs(diffs(2:2:end)) > 1)
        if acq_order(1) < acq_order(2)
            slice_order = 'interleaved ascending';
        else
            slice_order = 'interleaved descending';
        end
        return;
    end
end

slice_order = 'interleaved ascending';
end

function processRealignment_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Realignment for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, baseName, ext] = fileparts(boldFile);
            
            derivPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            realignedPath = fullfile(derivPath, [baseName '_desc-realign' ext]);
            if exist(realignedPath, 'file')
                updateStatus(fig, ['Skipping - realigned file already exists: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            inputPath1 = fullfile(derivPath, [baseName '_desc-slicetimed' ext]);
            inputPath2 = fullfile(derivPath, [baseName '_desc-fieldmap' ext]);
            inputPath3 = fullfile(derivPath, [baseName '_desc-masked' ext]);
            if exist(inputPath1, 'file')
                inputPath = inputPath1;
                inputname = [baseName '_desc-slicetimed' ext];
            elseif exist(inputPath2, 'file')
                inputPath = inputPath2;
                inputname = [baseName '_desc-fieldmap' ext];
            elseif exist(inputPath3, 'file')
                inputPath = inputPath3;
                inputname = [baseName '_desc-masked' ext];
            else
                error('No suitable functional file found for baseName: %s', baseName);
            end
            
            if exist(inputPath, 'file')
                cd(derivPath);
                all_func = UN_find_images_in_all_scans(derivPath, inputname(1:end-4), '.nii', [1 Inf], 'separate_cells');
                realign_mlb = MY_get_default_realign_batch_struct(all_func);
                F = spm_figure('GetWin');
                spm_jobman('run', realign_mlb);
                
                tempRealignedPath = dir(fullfile(derivPath, ['realign' baseName '*' ext]));
                meanrealignedPath = dir(fullfile(derivPath, ['mean' baseName '*' ext]));
                if ~isempty(tempRealignedPath)
                    movefile(fullfile(tempRealignedPath(1).folder,tempRealignedPath(1).name), realignedPath);
                    delete(fullfile(meanrealignedPath(1).folder,meanrealignedPath(1).name));
                    updateStatus(fig, ['Completed realignment for: ' boldFile]);
                    processedCount = processedCount + 1;
                end
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in realignment for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Realignment completed: %d files processed, %d files skipped', processedCount, skippedCount));
updateStatus(fig, ['Please proceed to the next step']);
end

function processCoregistration_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

if isfield(fig.UserData, 'coregInterpEdit')
    interp = fig.UserData.coregInterpEdit.Value;
else
    interp = 2;
end

updateStatus(fig, ['Using coregistration interpolation method: ' num2str(interp) ' (0-Nearest neighbour; 1-Trilinear; 2-2nd Degree B-Spline; 3-3rd Degree B-Spline; 4-4th Degree B-Spline; 5-5th Degree B-Spline; 6-6th Degree B-Spline; 7-7th Degree B-Spline)']);

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Coregistration for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        anatPath = fullfile(subPath, 'anat');
        
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        t2Files = dir(fullfile(anatPath, '*_T2w.nii'));
        
        if isempty(boldFiles) || isempty(t2Files)
            continue;
        end
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            derivAnatPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'anat');
            
            coregT2Path = fullfile(derivFuncPath, [boldBaseName '_desc-T2coreg' ext]);
            
            if exist(coregT2Path, 'file')
                updateStatus(fig, ['Skipping - coregistration already completed for: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            realignedBoldPath = fullfile(derivFuncPath, [boldBaseName '_desc-realign' ext]);
            scaledT2Path = fullfile(derivAnatPath, [t2Files(1).name(1:end-4) '_desc-masked' ext]);
            
            if exist(realignedBoldPath, 'file') && exist(scaledT2Path, 'file')
                copyfile(scaledT2Path,derivFuncPath);
                scaledT2Pathnew = fullfile(derivFuncPath, [t2Files(1).name(1:end-4) '_desc-masked' ext]);
                cd(derivFuncPath);
                meanBoldPath = fullfile(derivFuncPath, [boldBaseName '_desc-mean' ext]);
                if ~exist(meanBoldPath, 'file')
                    head = spm_vol(realignedBoldPath);
                    fMRI_data = spm_read_vols(head);
                    fMRI_data1 = mean(fMRI_data, 4);
                    head1 = head(1);
                    head1.fname = meanBoldPath;
                    spm_write_vol_4D(head1, fMRI_data1);
                end
                
                ref{1,1} = [meanBoldPath ',1'];
                source{1,1} = [scaledT2Pathnew ',1'];
                coreg_mlb = MY_get_default_coreg_batch_struct(ref, source, {''}, interp);
                spm_jobman('run', coreg_mlb);
                
                tempCoregT2Path = fullfile(derivFuncPath, ['coreg' t2Files(1).name(1:end-4) '_desc-masked' ext]);
                if exist(tempCoregT2Path, 'file')
                    movefile(tempCoregT2Path, coregT2Path);
                    updateStatus(fig, ['Completed coregistration for: ' boldFile]);
                    processedCount = processedCount + 1;
                end
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in coregistration for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Coregistration completed: %d files processed, %d files skipped', processedCount, skippedCount));
updateStatus(fig, ['Please proceed to the next step']);
end

function processNormalization_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;

if fig.UserData.useDefaultTemplateCheckbox.Value
    template = fullfile(templatePath, 'Template_Mouse_v38.nii,1');
    updateStatus(fig, 'Using default template: Template_Mouse_v38.nii');
else
    customTemplatePath = fig.UserData.templateCustomEdit.Value;
    if isempty(customTemplatePath) || ~exist(customTemplatePath, 'file')
        updateStatus(fig, 'Warning: Custom template not specified or not found. Using default template.');
        template = fullfile(templatePath, 'Template_Mouse_v38.nii,1');
    else
        template = [customTemplatePath ',1'];
        updateStatus(fig, ['Using custom template: ' customTemplatePath]);
    end
end

ref{1,1} = template;

if isfield(fig.UserData, 'normInterpEdit')
    interp = fig.UserData.normInterpEdit.Value;
else
    interp = 2;
end

updateStatus(fig, ['Using normalization interpolation method: ' num2str(interp) ' (0-Nearest neighbour; 1-Trilinear; 2-2nd Degree B-Spline; 3-3rd Degree B-Spline; 4-4th Degree B-Spline; 5-5th Degree B-Spline; 6-6th Degree B-Spline; 7-7th Degree B-Spline)']);

subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Normalization for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            normalizedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-normalized' ext]);
            normalizedT2Path = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-T2normalized' ext]);
            
            if exist(normalizedBoldPath, 'file') && exist(normalizedT2Path, 'file')
                updateStatus(fig, ['Skipping - normalization already completed for: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            realignedBoldPath = fullfile(derivFuncPath, [boldBaseName '_desc-realign' ext]);
            coregT2Path = fullfile(derivFuncPath, [boldBaseName '_desc-T2coreg' ext]);
            
            if exist(realignedBoldPath, 'file') && exist(coregT2Path, 'file')
                source{1,1} = [coregT2Path ',1'];
                all_func = UN_find_images_in_all_scans(derivFuncPath, ['^' boldBaseName '_desc-realign'], '.nii', [1 Inf], 'all_mixed');
                all_func = [all_func; [coregT2Path ',1']];
                OldNormalize_mlb = UN_get_default_oldnormalize_batch_struct(ref, source, all_func, interp);
                spm_jobman('run', OldNormalize_mlb);
                
                normBoldPath = fullfile(derivFuncPath, ['norm' boldBaseName '_desc-realign' ext]);
                normT2Path = fullfile(derivFuncPath, ['norm' boldBaseName '_desc-T2coreg' ext]);
                
                if exist(normBoldPath, 'file')
                    movefile(normBoldPath, normalizedBoldPath);
                end
                if exist(normT2Path, 'file')
                    movefile(normT2Path, normalizedT2Path);
                end
                
                updateStatus(fig, ['Completed normalization for: ' boldFile]);
                processedCount = processedCount + 1;
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in normalization for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Normalization completed: %d files processed, %d files skipped', processedCount, skippedCount));
updateStatus(fig, ['Please proceed to the next step']);
end

function processSmoothing_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;

if isfield(fig.UserData, 'smoothFWHM')
    user_smooth = fig.UserData.smoothFWHM.Value;
    if ~isempty(user_smooth) && isnumeric(user_smooth) && length(user_smooth) == 3 && all(user_smooth >= 0)
        smooth_para = user_smooth;
        updateStatus(fig, ['Using user-defined smoothing FWHM: [' num2str(smooth_para) '] mm']);
    else
        smooth_para = [6, 6, 6];
        updateStatus(fig, 'Invalid smoothing parameters, using default [6, 6, 6] mm');
    end
else
    smooth_para = [6, 6, 6];
    updateStatus(fig, 'Using default smoothing FWHM: [6, 6, 6] mm');
end

subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Smoothing for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            smoothedPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-smoothed' ext]);
            if exist(smoothedPath, 'file')
                updateStatus(fig, ['Skipping - smoothed file already exists: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            normalizedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-normalized' ext]);
            
            if exist(normalizedBoldPath, 'file')
                cd(derivFuncPath);
                
                all_func = UN_find_images_in_all_scans(derivFuncPath, ['^' boldBaseName '_space-template_desc-normalized'], '.nii', [1 Inf], 'all_mixed');
                Smooth_mlb = MY_get_default_smooth_batch_struct(all_func, smooth_para);
                spm_jobman('run', Smooth_mlb);
                
                tempSmoothedPath = fullfile(derivFuncPath, ['s' boldBaseName '_space-template_desc-normalized' ext]);
                if exist(tempSmoothedPath, 'file')
                    movefile(tempSmoothedPath, smoothedPath);
                    updateStatus(fig, ['Completed smoothing for: ' boldFile ' with FWHM=[' num2str(smooth_para) '] mm']);
                    processedCount = processedCount + 1;
                end
            else
                updateStatus(fig, ['Warning: Normalized BOLD file not found for: ' boldFile]);
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in smoothing for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Smoothing completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function smooth_para = parseSmoothingParameters(user_input)
if ischar(user_input) || isstring(user_input)
    user_input = strrep(user_input, ',', ' ');
    smooth_para = str2num(user_input);
elseif isnumeric(user_input)
    smooth_para = user_input;
else
    smooth_para = [6, 6, 6];
end

if length(smooth_para) ~= 3
    smooth_para = [6, 6, 6];
end
end

function processNoisePCEstimation_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Noise PC estimation for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            pcPath = fullfile(derivFuncPath, [boldBaseName '_desc-NBPCs.mat']);
            if exist(pcPath, 'file')
                updateStatus(fig, ['Skipping - noise PCs already exist for: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            scaledBoldPath = fullfile(derivFuncPath, [boldBaseName '_desc-scaled' ext]);
            boldMaskFiles = dir(fullfile(derivFuncPath, '*brainmask.nii'));
            boldMaskPath = fullfile(boldMaskFiles.folder,boldMaskFiles.name);
            
            if exist(scaledBoldPath, 'file')==2 && exist(boldMaskPath, 'file')==2
                bold_mask = spm_read_vols(spm_vol(boldMaskPath));
                fMRI_data = spm_read_vols(spm_vol(scaledBoldPath));
                timepoint=size(fMRI_data,4);
                PC = MY_get_principle_component_out_of_brian(fMRI_data, bold_mask, timepoint-1);
                
                save(pcPath, 'PC');
                
                updateStatus(fig, ['Completed noise PC estimation for: ' boldFile]);
                processedCount = processedCount + 1;
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in noise PC estimation for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Noise PC estimation completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function processMotionRegression_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
templatePath = fig.UserData.templateEdit.Value;
Gmask_head = spm_vol(fullfile(templatePath, 'brainmask_Mouse_v38.nii'));
Gmask = spm_read_vols(Gmask_head);
subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Motion regression for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            resultsPath = fullfile(derivFuncPath, [boldBaseName '_desc-regressionResults.mat']);
            if exist(resultsPath, 'file')
                updateStatus(fig, ['Skipping - motion regression already completed for: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            smoothedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-smoothed' ext]);
            pcPath = fullfile(derivFuncPath, [boldBaseName '_desc-NBPCs.mat']);
            
            if exist(smoothedBoldPath, 'file') && exist(pcPath, 'file')
                cd(derivFuncPath);
                
                head = spm_vol(smoothedBoldPath);
                fMRI_data = spm_read_vols(head);
                timepoint=size(fMRI_data,4);
                data_ready_regress = fmask(fMRI_data, Gmask);
                clear fMRI_data;
                
                dd = data_ready_regress - [data_ready_regress(:,1), data_ready_regress(:,1:end-1)];
                DVARS0 = rms(dd);
                DVARS0(1) = median(DVARS0);
                
                rpFile = dir(fullfile(derivFuncPath, ['rp_' boldBaseName '*']));
                if ~isempty(rpFile)
                    rp = load(fullfile(rpFile(1).folder, rpFile(1).name));
                    [~, rp] = gradient(rp);
                    magnification = 1;
                    radius = 100;
                    rp(:,1:3) = rp(:,1:3) / magnification;
                    rp(:,4:6) = rp(:,4:6) .* radius;
                    drp = rp - [zeros(1,6); rp(1:end-1,:)];
                    FD = sqrt(rp(:,1).^2 + rp(:,2).^2 + rp(:,3).^2 + rp(:,4).^2 + rp(:,5).^2 + rp(:,6).^2);
                    corr0 = corr(FD, DVARS0');
                else
                    FD = [];
                    corr0 = 0;
                end
                
                load(pcPath);
                
                pc_configs = 0:20:floor((timepoint-1)/20)*20;
                
                for k = 1:length(pc_configs)
                    pc_num = pc_configs(k);
                    if pc_num == 0
                        RegBasFunc = [ones([size(rp,1),1]) rp drp];
                    else
                        RegBasFunc = [ones([size(rp,1),1]) rp drp PC(:,1:pc_num)];
                    end
                    
                    output_name = [boldBaseName '_desc-regressed' num2str(pc_num) 'pc' ext];
                    [DVARS, corr_val] = MY_headmotion_regression_estimate(RegBasFunc, data_ready_regress, FD, Gmask, derivFuncPath, head, output_name);
                    
                    results.(['DVARS' num2str(k)]) = DVARS;
                    results.(['corr' num2str(k)]) = corr_val;
                end
                
                results.FD = FD;
                results.DVARS0 = DVARS0;
                results.corr0 = corr0;
                
                save(resultsPath, '-struct', 'results');
                updateStatus(fig, ['Completed motion regression for: ' boldFile]);
                processedCount = processedCount + 1;
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in motion regression for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Motion regression completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function processGroupLevelNoiseEstimation_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
subDirs = dir(fullfile(bidsPath, subjectFilter));

updateStatus(fig, 'Starting group level noise estimation...');

groupAnalysisPath = fullfile(bidsPath, 'derivatives', 'MIKey', 'group_analysis');
if ~exist(groupAnalysisPath, 'dir')
    mkdir(groupAnalysisPath);
end

all_corr_data = [];
config_labels = {};

for i = 1:length(subDirs)
    subPath = fullfile(subDirs(i).folder, subDirs(i).name);
    derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
    
    if ~exist(derivFuncPath, 'dir')
        continue;
    end
    
    resultFiles = dir(fullfile(derivFuncPath, '*_desc-regressionResults.mat'));
    
    for j = 1:length(resultFiles)
        resultsPath = fullfile(resultFiles(j).folder, resultFiles(j).name);
        try
            results = load(resultsPath);
            
            pc_configs = 0:20:floor((length(fieldnames(results))-5)/2)*20;
            
            if isempty(all_corr_data)
                config_labels = cell(1, length(pc_configs) + 1);
                config_labels{1} = 'No regress';
                for k = 1:length(pc_configs)
                    if pc_configs(k) == 0
                        config_labels{k+1} = '12rp';
                    else
                        config_labels{k+1} = ['12rp+', num2str(pc_configs(k))];
                    end
                end
                all_corr_data = zeros(0, length(pc_configs) + 1);
            end
            
            corr_values = zeros(1, length(pc_configs) + 1);
            corr_values(1) = results.corr0;
            
            for k = 1:length(pc_configs)
                corr_values(k+1) = results.(['corr' num2str(k)]);
            end
            
            all_corr_data = [all_corr_data; corr_values];
            
        catch ME
            updateStatus(fig, ['Error loading results file: ' resultsPath ': ' ME.message]);
        end
    end
end

if isempty(all_corr_data)
    updateStatus(fig, 'No regression results found for group level analysis');
    return;
end

abs_corr_data = abs(all_corr_data);
mean_abs_corrs = mean(abs_corr_data, 1);
mean_orig_corrs = mean(all_corr_data, 1);

best_idx = findOptimalStrategyFromAbsoluteTrend(mean_abs_corrs);

if isempty(best_idx)
    [~, best_idx] = min(mean_abs_corrs);
    updateStatus(fig, 'No clear decreasing trend found in absolute values, using global minimum');
else
    updateStatus(fig, 'Found optimal strategy at the minimum point of absolute value decreasing trend');
end

best_strategy = config_labels{best_idx};

updateStatus(fig, ['Group level analysis completed. Total runs: ' num2str(size(all_corr_data, 1))]);
updateStatus(fig, ['Best regression strategy: ' best_strategy]);
updateStatus(fig, ['Original mean correlation: ' num2str(mean_orig_corrs(best_idx))]);
updateStatus(fig, ['Absolute mean correlation: ' num2str(mean_abs_corrs(best_idx))]);

figure('Position', [100, 100, 1200, 800]);

errorbar(1:length(config_labels), mean_abs_corrs, std(abs_corr_data, 0, 1), 'o-', 'LineWidth', 2, 'MarkerSize', 8);
set(gca, 'XTick', 1:length(config_labels), 'XTickLabel', config_labels);
title('Mean Absolute FD-DVARS Correlation ¡À SD');
ylabel('Absolute Correlation Value');
xlabel('Regression Strategy');
grid on;
ax = gca;
hold on;
plot(best_idx, mean_abs_corrs(best_idx), 'ro', 'MarkerSize', 12, 'LineWidth', 3);
text(best_idx, mean_abs_corrs(best_idx), ' Optimal', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'red');
ax.XTickLabelRotation = 45;

groupResultsPath = fullfile(groupAnalysisPath, 'group_level_noise_estimation.mat');
save(groupResultsPath, 'all_corr_data', 'abs_corr_data', 'config_labels', 'mean_abs_corrs', 'best_strategy', 'best_idx');

saveas(gcf, fullfile(groupAnalysisPath, 'group_level_noise_estimation_boxplot.png'));
saveas(gcf, fullfile(groupAnalysisPath, 'group_level_noise_estimation_boxplot.fig'));

best_strategy_info.best_strategy = best_strategy;
best_strategy_info.best_idx = best_idx;
best_strategy_info.mean_orig_corrs = mean_orig_corrs;
best_strategy_info.mean_abs_corrs = mean_abs_corrs;
best_strategy_info.config_labels = config_labels;
best_strategy_info.trend_analysis = 'Selected at minimum point of absolute value decreasing trend before increase';

save(fullfile(groupAnalysisPath, 'best_regression_strategy.mat'), 'best_strategy_info');

updateStatus(fig, ['Group level noise estimation completed. Results saved to: ' groupAnalysisPath]);
updateStatus(fig, ['Best strategy saved for advanced regression: ' best_strategy]);
end

function optimal_idx = findOptimalStrategyFromAbsoluteTrend(mean_abs_corrs)
n = length(mean_abs_corrs);

if n < 3
    [~, optimal_idx] = min(mean_abs_corrs);
    return;
end

diffs = diff(mean_abs_corrs);

for i = 2:(n-1)
    if mean_abs_corrs(i) < mean_abs_corrs(i-1) && mean_abs_corrs(i) < mean_abs_corrs(i+1)
        optimal_idx = i;
        return;
    end
end

for i = 2:(n-1)
    if diffs(i-1) < 0 && diffs(i) > 0
        optimal_idx = i;
        return;
    end
end

max_neg_diff = 0;
candidate_idx = 1;

for i = 1:(n-1)
    if diffs(i) < max_neg_diff
        max_neg_diff = diffs(i);
        candidate_idx = i + 1;
    end
end

if max_neg_diff < -0.01
    optimal_idx = candidate_idx;
    return;
end

[~, optimal_idx] = min(mean_abs_corrs);
end

function processAdvancedRegression_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
templatePath = fig.UserData.templateEdit.Value;
Gmask_head = spm_vol(fullfile(templatePath, 'brainmask_Mouse_v38.nii'));
Gmask = spm_read_vols(Gmask_head);
ventricle_mask = spm_read_vols(spm_vol(fullfile(templatePath, 'AMCP_temp', 'AMCP_ventricle_mask.nii')));

groupAnalysisPath = fullfile(bidsPath, 'derivatives', 'MIKey', 'group_analysis');
bestStrategyPath = fullfile(groupAnalysisPath, 'best_regression_strategy.mat');

if ~exist(bestStrategyPath, 'file')
    updateStatus(fig, 'Error: Best regression strategy not found. Please run group level noise estimation first.');
    return;
end

load(bestStrategyPath, 'best_strategy_info');
updateStatus(fig, ['Using best regression strategy: ' best_strategy_info.best_strategy]);

selected_strategies = {};
if fig.UserData.advRegressionPCOnlyCheckbox.Value
    selected_strategies{end+1} = 'pc';
end
if fig.UserData.advRegressionPCCSFCheckbox.Value
    selected_strategies{end+1} = 'pcCSF';
end
if fig.UserData.advRegressionPCGSCheckbox.Value
    selected_strategies{end+1} = 'pcGS';
end
if fig.UserData.advRegressionPCCSFGSCheckbox.Value
    selected_strategies{end+1} = 'pcCSFGS';
end

if isempty(selected_strategies)
    updateStatus(fig, 'Warning: No regression strategies selected. Using default PC only.');
    selected_strategies = {'pc'};
end

updateStatus(fig, ['Selected regression strategies: ' strjoin(selected_strategies, ', ')]);

detrend_flag = fig.UserData.detrendCheckbox.Value;
filter_flag = fig.UserData.filterCheckbox.Value;
High_f = fig.UserData.highFreqEdit.Value;
Low_f = fig.UserData.lowFreqEdit.Value;

updateStatus(fig, ['Head Motion Regression Parameters - Detrend: ' num2str(detrend_flag) ...
    ', Filter: ' num2str(filter_flag) ', High Freq: ' num2str(High_f) ...
    ', Low Freq: ' num2str(Low_f)]);

subDirs = dir(fullfile(bidsPath, subjectFilter));

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Advanced regression for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            resultsPath = fullfile(derivFuncPath, [boldBaseName '_desc-advancedRegressionResults.mat']);
            if exist(resultsPath, 'file')
                updateStatus(fig, ['Skipping - advanced regression already completed for: ' boldFile]);
                skippedCount = skippedCount + 1;
                continue;
            end
            
            smoothedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-smoothed' ext]);
            pcPath = fullfile(derivFuncPath, [boldBaseName '_desc-NBPCs.mat']);
            
            if exist(smoothedBoldPath, 'file') && exist(pcPath, 'file')
                cd(derivFuncPath);
                
                head = spm_vol(smoothedBoldPath);
                fMRI_data = spm_read_vols(head);
                
                jsonFile = dir(fullfile(funcPath, [boldBaseName '.json']));
                if ~isempty(jsonFile)
                    info = jsondecode(fileread(fullfile(jsonFile(1).folder, jsonFile(1).name)));
                    EPI_TR = info.RepetitionTime;
                else
                    EPI_TR = 2.0;
                end
                
                data_ready_regress = fmask(fMRI_data, Gmask);
                csf = fmask(fMRI_data, ventricle_mask);
                csf = mean(csf, 1)';
                GS = fmask(fMRI_data, Gmask);
                GS = mean(GS, 1)';
                clear fMRI_data;
                
                rpFile = dir(fullfile(derivFuncPath, ['rp_' boldBaseName '*']));
                if ~isempty(rpFile)
                    rp = load(fullfile(rpFile(1).folder, rpFile(1).name));
                    [~, rp] = gradient(rp);
                    radius = 100;
                    rp(:,1:3) = rp(:,1:3);
                    rp(:,4:6) = rp(:,4:6) .* radius;
                    drp = rp - [zeros(1,6); rp(1:end-1,:)];
                end
                
                load(pcPath);
                
                pc_num = extractPCNumber(best_strategy_info.best_strategy);
                if pc_num == 0
                    optimal_RegBasFunc = [ones([size(rp,1),1]) rp drp];
                else
                    optimal_RegBasFunc = [ones([size(rp,1),1]) rp drp PC(:,1:pc_num)];
                end
                
                for k = 1:length(selected_strategies)
                    strategy = selected_strategies{k};
                    
                    switch strategy
                        case 'pc'
                            RegBasFunc = optimal_RegBasFunc;
                            output_name = [boldBaseName '_space-template_desc-Regressedpc' ext];
                            MY_headmotion_regression_combined(RegBasFunc, data_ready_regress, Gmask, derivFuncPath, head, output_name, detrend_flag, filter_flag, EPI_TR, High_f, Low_f);
                        case 'pcCSF'
                            RegBasFunc = [optimal_RegBasFunc csf];
                            output_name = [boldBaseName '_space-template_desc-RegressedpcCSF' ext];
                            MY_headmotion_regression_combined(RegBasFunc, data_ready_regress, Gmask, derivFuncPath, head, output_name, detrend_flag, filter_flag, EPI_TR, High_f, Low_f);
                        case 'pcGS'
                            RegBasFunc = [optimal_RegBasFunc GS];
                            output_name = [boldBaseName '_space-template_desc-RegressedpcGS' ext];
                            MY_headmotion_regression_combined(RegBasFunc, data_ready_regress, Gmask, derivFuncPath, head, output_name, detrend_flag, filter_flag, EPI_TR, High_f, Low_f);
                        case 'pcCSFGS'
                            RegBasFunc = [optimal_RegBasFunc csf GS];
                            output_name = [boldBaseName '_space-template_desc-RegressedpcCSFGS' ext];
                            MY_headmotion_regression_combined(RegBasFunc, data_ready_regress, Gmask, derivFuncPath, head, output_name, detrend_flag, filter_flag, EPI_TR, High_f, Low_f);
                    end
                    
                end
                
                updateStatus(fig, ['Completed noise regression for: ' boldFile]);
                processedCount = processedCount + 1;
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in regression for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Advanced regression completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function pc_num = extractPCNumber(strategy_str)
if strcmp(strategy_str, 'No regress')
    pc_num = 0;
elseif strcmp(strategy_str, '12rp')
    pc_num = 0;
else
    tokens = regexp(strategy_str, '12rp\+(\d+)', 'tokens');
    if ~isempty(tokens)
        pc_num = str2double(tokens{1}{1});
    else
        pc_num = 0;
    end
end
end

function processFunctionalConnectivity_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;

selected_label = fig.UserData.fcLabelDropdown.Value;
if strcmp(selected_label, 'Custom...')
    customLabelPath = fig.UserData.fcCustomEdit.Value;
    if isempty(customLabelPath) || ~exist(customLabelPath, 'file')
        updateStatus(fig, 'Error: Custom FC label file not specified or not found');
        return;
    end
    label_file = customLabelPath;
    label_name = 'Custom';
else
    switch selected_label
        case '214'
            label_file = 'Label_Mouse_214_v38.nii';
        case '428'
            label_file = 'Label_Mouse_428_v38.nii';
        case '604'
            label_file = 'Label_Mouse_604_v38.nii';
        case '1184'
            label_file = 'Label_Mouse_1184_v38.nii';
    end
    label_file = fullfile(templatePath, label_file);
    label_name = selected_label;
end

if ~exist(label_file, 'file')
    updateStatus(fig, ['Error: Label file not found: ' label_file]);
    return;
end

try
    label_head = spm_vol(label_file);
    label = spm_read_vols(label_head);
    updateStatus(fig, ['Using label file: ' label_file ' with ' num2str(length(unique(label))) ' regions']);
catch ME
    updateStatus(fig, ['Error loading label file: ' ME.message]);
    return;
end

Gmask_head = spm_vol(fullfile(templatePath, 'brainmask_Mouse_v38.nii'));
Gmask = spm_read_vols(Gmask_head);
subDirs = dir(fullfile(bidsPath, subjectFilter));

selected_strategies = {};
if fig.UserData.advRegressionPCOnlyCheckbox.Value
    selected_strategies{end+1} = 'Regressedpc';
end
if fig.UserData.advRegressionPCCSFCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSF';
end
if fig.UserData.advRegressionPCGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcGS';
end
if fig.UserData.advRegressionPCCSFGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSFGS';
end

if isempty(selected_strategies)
    updateStatus(fig, 'Warning: No regression strategies selected for FC. Using default PC only.');
    selected_strategies = {'Regressedpc'};
end

updateStatus(fig, ['FC will be computed for strategies: ' strjoin(selected_strategies, ', ')]);

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Functional connectivity for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'func');
            
            for strategy_idx = 1:length(selected_strategies)
                strategy_suffix = selected_strategies{strategy_idx};
                strategy_name = strrep(strategy_suffix, 'Regressed', '');
                
                regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
                
                if ~exist(regressedBoldPath, 'file')
                    updateStatus(fig, ['Warning: Regression output not found for strategy ' strategy_name ': ' regressedBoldPath]);
                    continue;
                end
                
                fcPath = fullfile(derivFuncPath, [boldBaseName '_desc-' label_name 'regionFC_' strategy_suffix '.mat']);
                if exist(fcPath, 'file')
                    updateStatus(fig, ['Skipping - FC already computed for: ' boldFile ' with ' strategy_name]);
                    skippedCount = skippedCount + 1;
                    continue;
                end
                
                if exist(regressedBoldPath, 'file')
                    cd(derivFuncPath);
                    
                    all_img_head = spm_vol(regressedBoldPath);
                    all_img= spm_read_vols(all_img_head);
                    all_img_reshape = reshape(all_img, [], size(all_img,4));
                    clear all_img;
                    all_roi = [];
                    roi_num = unique(label);
                    
                    for k = 1:max(roi_num)
                        idx_roi = find(label == k);
                        if ~isempty(idx_roi)
                            all_roi(k,:) = mean(all_img_reshape(idx_roi,:), 1);
                        else
                            all_roi(k,:) = zeros(1, size(all_img_reshape, 2));
                        end
                    end
                    
                    all_roi_zscore = (all_roi - mean(all_roi, 2)) ./ std(all_roi, 0, 2);
                    all_roi_zscore(isnan(all_roi_zscore)) = 0;
                    
                    pearson_corr = corr(all_roi_zscore');
                    pearson_corr(logical(eye(size(pearson_corr)))) = 0;
                    pearson_corr_z = atanh(pearson_corr);
                    
                    save(fcPath, 'pearson_corr_z');
                    updateStatus(fig, ['Completed FC calculation for: ' boldFile ' with ' strategy_name ' using ' label_name ' labels']);
                    processedCount = processedCount + 1;
                end
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in FC calculation for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Functional connectivity completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function processIndividualParcellationPrior_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;
GMWM_head = spm_vol(fullfile(templatePath, 'AMCP_temp', 'AMCP_GMWM_mask.nii'));
GMWM_mask = spm_read_vols(GMWM_head);
subDirs = dir(fullfile(bidsPath, subjectFilter));

selected_networks = {fig.UserData.parcNetworkDropdown.Value};
use_custom = fig.UserData.useCustomParcCheckbox.Value;

network_configs = {
    struct('network_file', 'AMCP_214prior_11net.nii', 'label_file', 'Label_Mouse_214_v38.nii', 'folder_suffix', 'prior_mode_214', 'dice_file', 'dice_cross_runs_based_214roi.mat'),
    struct('network_file', 'AMCP_428prior_11net.nii', 'label_file', 'Label_Mouse_428_v38.nii', 'folder_suffix', 'prior_mode_428', 'dice_file', 'dice_cross_runs_based_428roi.mat'),
    struct('network_file', 'AMCP_604prior_12net.nii', 'label_file', 'Label_Mouse_604_v38.nii', 'folder_suffix', 'prior_mode_604', 'dice_file', 'dice_cross_runs_based_604roi.mat'),
    struct('network_file', 'AMCP_1184prior_13net.nii', 'label_file', 'Label_Mouse_1184_v38.nii', 'folder_suffix', 'prior_mode_1184', 'dice_file', 'dice_cross_runs_based_1184roi.mat'),
    struct('network_file', 'AMCP_428prior_17net.nii', 'label_file', 'Label_Mouse_428_v38.nii', 'folder_suffix', 'prior_mode_428', 'dice_file', 'dice_cross_runs_based_428roi.mat')
    };

selected_strategies = {};
if fig.UserData.advRegressionPCOnlyCheckbox.Value
    selected_strategies{end+1} = 'Regressedpc';
end
if fig.UserData.advRegressionPCCSFCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSF';
end
if fig.UserData.advRegressionPCGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcGS';
end
if fig.UserData.advRegressionPCCSFGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSFGS';
end

if isempty(selected_strategies)
    updateStatus(fig, 'Warning: No regression strategies selected for parcellation. Using default PC only.');
    selected_strategies = {'Regressedpc'};
end

updateStatus(fig, ['Parcellation will use strategies: ' strjoin(selected_strategies, ', ')]);

selected_configs = {};

if use_custom
    custom_network_path = fig.UserData.networkCustomEdit.Value;
    custom_label_path = fig.UserData.labelCustomEdit.Value;
    
    if isempty(custom_network_path) || ~exist(custom_network_path, 'file')
        updateStatus(fig, 'Error: Custom network file not specified or not found');
        return;
    end
    if isempty(custom_label_path) || ~exist(custom_label_path, 'file')
        updateStatus(fig, 'Error: Custom label file not specified or not found');
        return;
    end
    
    custom_config = struct();
    custom_config.network_file = custom_network_path;
    custom_config.label_file = custom_label_path;
    [~, network_name, ~] = fileparts(custom_network_path);
    [~, label_name, ~] = fileparts(custom_label_path);
    custom_config.folder_suffix = ['prior_mode_' label_name ''];
    custom_config.dice_file = ['dice_cross_runs_' label_name '.mat'];
    selected_configs{1} = custom_config;
    
    updateStatus(fig, ['Using custom configuration: Network=' network_name ', Label=' label_name]);
else
    for config_idx = 1:length(network_configs)
        config = network_configs{config_idx};
        if any(strcmp(config.network_file, selected_networks))
            selected_configs{end+1} = config;
            selected_configs{end}.network_file = fullfile(templatePath, 'AMCP_temp', selected_configs{end}.network_file);
            selected_configs{end}.label_file = fullfile(templatePath, selected_configs{end}.label_file);
        end
    end
end

if isempty(selected_configs)
    selected_configs{1} = network_configs{2};
    selected_configs{1}.network_file = fullfile(templatePath, 'AMCP_temp', selected_configs{1}.network_file);
    selected_configs{1}.label_file = fullfile(templatePath, selected_configs{1}.label_file);
    updateStatus(fig, 'No network selected, using default configuration: 428');
end

updateStatus(fig, ['Using ' num2str(length(selected_configs)) ' configuration(s) for parcellation']);

percent_top = fig.UserData.percentTopEdit.Value;
max_iter = fig.UserData.maxIterEdit.Value;
change_thr = fig.UserData.changeThrEdit.Value;
conf_thr = fig.UserData.confThrEdit.Value;

updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);

use_tSNR = fig.UserData.useTSNRCheckbox.Value;
use_inter_subject_var = fig.UserData.useInterSubjectVarCheckbox.Value;

updateStatus(fig, ['Correction parameters - Use tSNR: ' num2str(use_tSNR) ', Use Inter-Subject Var: ' num2str(use_inter_subject_var)]);

InterSubjectVar_heads = struct();
if use_inter_subject_var
    updateStatus(fig, 'Calculating Inter-Subject Variability maps for all selected strategies...');
    for strategy_idx = 1:length(selected_strategies)
        strategy_suffix = selected_strategies{strategy_idx};
        InterSubjectVar_head = computeInterSubjectVariabilityBIDS(fig, bidsPath, subjectFilter, strategy_suffix, templatePath);
        if ~isempty(InterSubjectVar_head)
            InterSubjectVar_heads.(strategy_suffix) = InterSubjectVar_head;
            updateStatus(fig, ['Inter-Subject Variability map computed for strategy: ' strategy_suffix]);
        else
            updateStatus(fig, ['Warning: Failed to compute Inter-Subject Variability map for strategy ' strategy_suffix '. Continuing without it.']);
        end
    end
end

parcellation_mode = questdlg('Select parcellation mode:', 'Parcellation Mode', ...
    'Individual Runs (separate folders)', 'Concatenated Runs (single folder)', ...
    'Individual Runs (separate folders)');

if isempty(parcellation_mode)
    updateStatus(fig, 'Parcellation cancelled by user');
    return;
end

updateStatus(fig, ['Selected parcellation mode: ' parcellation_mode]);

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Individual parcellation for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        if isempty(boldFiles)
            updateStatus(fig, ['No BOLD files found for subject: ' subDirs(i).name]);
            continue;
        end
        
        switch parcellation_mode
            case 'Individual Runs (separate folders)'
                [processed, skipped] = processIndividualRuns_Prior(fig, bidsPath, subDirs(i).name, boldFiles, ...
                    selected_configs, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
                    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads);
                processedCount = processedCount + processed;
                skippedCount = skippedCount + skipped;
                
            case 'Concatenated Runs (single folder)'
                [processed, skipped] = processConcatenatedRuns_Prior(fig, bidsPath, subDirs(i).name, boldFiles, ...
                    selected_configs, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
                    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads);
                processedCount = processedCount + processed;
                skippedCount = skippedCount + skipped;
        end
        
    catch ME
        updateStatus(fig, ['Error in parcellation for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Individual parcellation completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function [processedCount, skippedCount] = processIndividualRuns_Prior(fig, bidsPath, subjectName, boldFiles, ...
    selected_configs, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads)

processedCount = 0;
skippedCount = 0;
derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subjectName, 'func');

for config_idx = 1:length(selected_configs)
    config = selected_configs{config_idx};
    
    if ~exist(config.network_file, 'file')
        updateStatus(fig, ['Warning: Network file not found: ' config.network_file]);
        continue;
    end
    if ~exist(config.label_file, 'file')
        updateStatus(fig, ['Warning: Label file not found: ' config.label_file]);
        continue;
    end
    
    group_net = spm_read_vols(spm_vol(config.network_file));
    
    for strategy_idx = 1:length(selected_strategies)
        strategy_suffix = selected_strategies{strategy_idx};
        strategy_name = strrep(strategy_suffix, 'Regressed', '');
        
        strategy_net_maps = [];
        strategy_run_names = {};
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            output_dir = fullfile(derivFuncPath, [boldBaseName '_parcellation_' config.folder_suffix '_' strategy_suffix]);
            parcellationPath = fullfile(output_dir, [boldBaseName '_space-template_desc-individualParcellation' ext]);
            
            if exist(parcellationPath, 'file')
                updateStatus(fig, ['Skipping - individual parcellation already exists for: ' boldFile ' with ' strategy_name]);
                skippedCount = skippedCount + 1;
                
                existing_net_map = spm_read_vols(spm_vol(parcellationPath));
                strategy_net_maps(:, :, :, end+1) = existing_net_map;
                strategy_run_names{end+1} = boldBaseName;
                continue;
            end
            
            regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
            if ~exist(regressedBoldPath, 'file')
                updateStatus(fig, ['Warning: Regression output not found for ' strategy_name ': ' regressedBoldPath]);
                continue;
            end
            
            tSNR_path = '';
            if use_tSNR
                tSNR_path = calculateTSNR(fig, derivFuncPath, boldBaseName, strategy_suffix);
                if isempty(tSNR_path)
                    updateStatus(fig, ['Warning: Failed to calculate tSNR for ' boldFile '. Continuing without tSNR correction.']);
                else
                    updateStatus(fig, ['tSNR calculated for: ' boldFile]);
                end
            end
            
            InterSubjectVar_head = [];
            if isfield(InterSubjectVar_heads, strategy_suffix)
                InterSubjectVar_head = InterSubjectVar_heads.(strategy_suffix);
            end
            
            if exist(regressedBoldPath, 'file')
                cd(derivFuncPath);
                
                fMRI_4D = spm_read_vols(spm_vol(regressedBoldPath));
                
                optional_params = {};
                if use_tSNR && ~isempty(tSNR_path)
                    optional_params{end+1} = 'tSNR';
                    optional_params{end+1} = true;
                    optional_params{end+1} = 'tSNRfile';
                    optional_params{end+1} = tSNR_path;
                end
                
                if ~isempty(InterSubjectVar_head)
                    optional_params{end+1} = 'InterSubjectVar';
                    optional_params{end+1} = InterSubjectVar_head;
                end
                
                [net_map, corr_map, iter] = individualized_parcellation_rsfMRI_v3(fMRI_4D, group_net, GMWM_head, 'prior', config.label_file, percent_top, output_dir, max_iter, change_thr, conf_thr, optional_params{:});
                
                net_head = GMWM_head;
                net_head.fname = parcellationPath;
                net_head.dt = [16 0];
                spm_write_vol(net_head, net_map);
                
                strategy_net_maps(:, :, :, end+1) = net_map;
                strategy_run_names{end+1} = boldBaseName;
                
                updateStatus(fig, ['Completed individual parcellation for: ' boldFile ' with config ' config.folder_suffix ' and ' strategy_name]);
                updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);
                processedCount = processedCount + 1;
            end
        end
        
        if size(strategy_net_maps, 4) > 1
            M = size(strategy_net_maps, 4);
            dice_strategy = zeros(M, M);
            for k = 1:M
                for m = 1:M
                    dice_strategy(k, m) = dice_coefficient(strategy_net_maps(:, :, :, k), strategy_net_maps(:, :, :, m), GMWM_mask);
                end
            end
            
            strategy_dice_file = fullfile(derivFuncPath, [config.dice_file(1:end-4) '_' strategy_suffix '.mat']);
            save(strategy_dice_file, 'dice_strategy', 'strategy_run_names');
            
            mean_dice = mean(dice_strategy(dice_strategy > 0 & ~eye(M)));
            updateStatus(fig, ['Configuration ' config.folder_suffix ' strategy ' strategy_name ' average Dice (across runs): ' num2str(mean_dice)]);
        end
    end
end

end

function [processedCount, skippedCount] = processConcatenatedRuns_Prior(fig, bidsPath, subjectName, boldFiles, ...
    selected_configs, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads)

processedCount = 0;
skippedCount = 0;
derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subjectName, 'func');

concatenated_dir = fullfile(derivFuncPath, 'parcellation_concatenated');
if ~exist(concatenated_dir, 'dir')
    mkdir(concatenated_dir);
end

for config_idx = 1:length(selected_configs)
    config = selected_configs{config_idx};
    
    if ~exist(config.network_file, 'file')
        updateStatus(fig, ['Warning: Network file not found: ' config.network_file]);
        continue;
    end
    if ~exist(config.label_file, 'file')
        updateStatus(fig, ['Warning: Label file not found: ' config.label_file]);
        continue;
    end
    
    group_net = spm_read_vols(spm_vol(config.network_file));
    
    for strategy_idx = 1:length(selected_strategies)
        strategy_suffix = selected_strategies{strategy_idx};
        strategy_name = strrep(strategy_suffix, 'Regressed', '');
        
        config_output_dir = fullfile(concatenated_dir, [config.folder_suffix '_' strategy_suffix]);
        concatenated_parcellationPath = fullfile(config_output_dir, [subjectName '_space-template_desc-concatenatedParcellation.nii']);
        
        if exist(concatenated_parcellationPath, 'file')
            updateStatus(fig, ['Skipping - concatenated parcellation already exists for config ' config.folder_suffix ' and ' strategy_name]);
            skippedCount = skippedCount + 1;
            continue;
        end
        
        all_fMRI_data = [];
        valid_runs = {};
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
            
            if exist(regressedBoldPath, 'file')
                fMRI_data = spm_read_vols(spm_vol(regressedBoldPath));
                
                if isempty(all_fMRI_data)
                    all_fMRI_data = fMRI_data;
                else
                    all_fMRI_data = cat(4, all_fMRI_data, fMRI_data);
                end
                
                valid_runs{end+1} = boldBaseName;
                updateStatus(fig, ['Added run ' boldBaseName ' to concatenated data for ' strategy_name]);
            else
                updateStatus(fig, ['Skipping run ' boldBaseName ' - missing regression output for ' strategy_name]);
            end
        end
        
        if isempty(all_fMRI_data)
            updateStatus(fig, ['No valid runs found for concatenation with strategy ' strategy_name]);
            continue;
        end
        
        updateStatus(fig, ['Concatenated ' num2str(length(valid_runs)) ' runs for strategy ' strategy_name]);
        updateStatus(fig, ['Final data dimensions: ' mat2str(size(all_fMRI_data))]);
        
        if ~exist(config_output_dir, 'dir')
            mkdir(config_output_dir);
        end
        
        tSNR_path = '';
        if use_tSNR
            tSNR_path = calculateTSNRFromData(fig, config_output_dir, all_fMRI_data, GMWM_head, [subjectName '_concatenated_tSNR.nii']);
            if isempty(tSNR_path)
                updateStatus(fig, ['Warning: Failed to calculate tSNR for concatenated data. Continuing without tSNR correction.']);
            else
                updateStatus(fig, 'tSNR calculated for concatenated data');
            end
        end
        
        InterSubjectVar_head = [];
        if isfield(InterSubjectVar_heads, strategy_suffix)
            InterSubjectVar_head = InterSubjectVar_heads.(strategy_suffix);
        end
        
        optional_params = {};
        if use_tSNR && ~isempty(tSNR_path)
            optional_params{end+1} = 'tSNR';
            optional_params{end+1} = true;
            optional_params{end+1} = 'tSNRfile';
            optional_params{end+1} = tSNR_path;
        end
        
        if ~isempty(InterSubjectVar_head)
            optional_params{end+1} = 'InterSubjectVar';
            optional_params{end+1} = InterSubjectVar_head;
        end
        
        cd(derivFuncPath);
        [net_map, corr_map, iter] = individualized_parcellation_rsfMRI_v3(all_fMRI_data, group_net, GMWM_head, 'prior', config.label_file, percent_top, config_output_dir, max_iter, change_thr, conf_thr, optional_params{:});
        
        net_head = GMWM_head;
        net_head.fname = concatenated_parcellationPath;
        net_head.dt = [16 0];
        spm_write_vol(net_head, net_map);
        
        concat_info.valid_runs = valid_runs;
        concat_info.strategy = strategy_name;
        concat_info.config = config;
        concat_info.use_tSNR = use_tSNR;
        concat_info.use_inter_subject_var = ~isempty(InterSubjectVar_head);
        concat_info.data_dimensions = size(all_fMRI_data);
        concat_info.parcellation_params = struct('percent_top', percent_top, 'max_iter', max_iter, 'change_thr', change_thr, 'conf_thr', conf_thr);
        save(fullfile(config_output_dir, 'concatenation_info.mat'), 'concat_info');
        
        updateStatus(fig, ['Completed concatenated parcellation for ' subjectName ' with config ' config.folder_suffix ' and ' strategy_name]);
        updateStatus(fig, ['Used ' num2str(length(valid_runs)) ' runs: ' strjoin(valid_runs, ', ')]);
        updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);
        processedCount = processedCount + 1;
        
        clear all_fMRI_data net_map corr_map;
    end
end
end


function processIndividualParcellationClust_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;
GMWM_head = spm_vol(fullfile(templatePath, 'AMCP_temp', 'AMCP_GMWM_mask.nii'));
GMWM_mask = spm_read_vols(GMWM_head);
subDirs = dir(fullfile(bidsPath, subjectFilter));

roi_nums = str2num(fig.UserData.clustROIEdit.Value);
if isempty(roi_nums)
    roi_nums = [100, 200, 400, 800];
    updateStatus(fig, 'Using default ROI numbers: 100, 200, 400, 800');
end

updateStatus(fig, ['Using ROI numbers: ' num2str(roi_nums)]);

selected_strategies = {};
if fig.UserData.advRegressionPCOnlyCheckbox.Value
    selected_strategies{end+1} = 'Regressedpc';
end
if fig.UserData.advRegressionPCCSFCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSF';
end
if fig.UserData.advRegressionPCGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcGS';
end
if fig.UserData.advRegressionPCCSFGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSFGS';
end

if isempty(selected_strategies)
    updateStatus(fig, 'Warning: No regression strategies selected for clustering parcellation. Using default PC only.');
    selected_strategies = {'Regressedpc'};
end

updateStatus(fig, ['Clustering parcellation will use strategies: ' strjoin(selected_strategies, ', ')]);

percent_top = fig.UserData.percentTopEdit.Value;
max_iter = fig.UserData.maxIterEdit.Value;
change_thr = fig.UserData.changeThrEdit.Value;
conf_thr = fig.UserData.confThrEdit.Value;

updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);

use_tSNR = fig.UserData.useTSNRCheckbox.Value;
use_inter_subject_var = fig.UserData.useInterSubjectVarCheckbox.Value;

updateStatus(fig, ['Correction parameters - Use tSNR: ' num2str(use_tSNR) ', Use Inter-Subject Var: ' num2str(use_inter_subject_var)]);

InterSubjectVar_heads = struct();
if use_inter_subject_var
    updateStatus(fig, 'Calculating Inter-Subject Variability maps for all selected strategies...');
    for strategy_idx = 1:length(selected_strategies)
        strategy_suffix = selected_strategies{strategy_idx};
        InterSubjectVar_head = computeInterSubjectVariabilityBIDS(fig, bidsPath, subjectFilter, strategy_suffix, templatePath);
        if ~isempty(InterSubjectVar_head)
            InterSubjectVar_heads.(strategy_suffix) = InterSubjectVar_head;
            updateStatus(fig, ['Inter-Subject Variability map computed for strategy: ' strategy_suffix]);
        else
            updateStatus(fig, ['Warning: Failed to compute Inter-Subject Variability map for strategy ' strategy_suffix '. Continuing without it.']);
        end
    end
end

parcellation_mode = questdlg('Select parcellation mode:', 'Parcellation Mode', ...
    'Individual Runs (separate folders)', 'Concatenated Runs (single folder)', ...
    'Individual Runs (separate folders)');

if isempty(parcellation_mode)
    updateStatus(fig, 'Parcellation cancelled by user');
    return;
end

updateStatus(fig, ['Selected parcellation mode: ' parcellation_mode]);

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Individual parcellation (clustering) for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        if isempty(boldFiles)
            updateStatus(fig, ['No BOLD files found for subject: ' subDirs(i).name]);
            continue;
        end
        
        switch parcellation_mode
            case 'Individual Runs (separate folders)'
                [processed, skipped] = processIndividualRuns_Clust(fig, bidsPath, subDirs(i).name, boldFiles, ...
                    roi_nums, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
                    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads);
                processedCount = processedCount + processed;
                skippedCount = skippedCount + skipped;
                
            case 'Concatenated Runs (single folder)'
                [processed, skipped] = processConcatenatedRuns_Clust(fig, bidsPath, subDirs(i).name, boldFiles, ...
                    roi_nums, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
                    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads);
                processedCount = processedCount + processed;
                skippedCount = skippedCount + skipped;
        end
        
    catch ME
        updateStatus(fig, ['Error in clustering parcellation for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Individual parcellation (clustering) completed: %d files processed, %d files skipped', processedCount, skippedCount));
end


function [processedCount, skippedCount] = processIndividualRuns_Clust(fig, bidsPath, subjectName, boldFiles, ...
    roi_nums, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads)

processedCount = 0;
skippedCount = 0;
derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subjectName, 'func');

for roi_idx = 1:length(roi_nums)
    roi_num = roi_nums(roi_idx);
    
    for strategy_idx = 1:length(selected_strategies)
        strategy_suffix = selected_strategies{strategy_idx};
        strategy_name = strrep(strategy_suffix, 'Regressed', '');
        
        strategy_net_maps = [];
        strategy_run_names = {};
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            output_dir = fullfile(derivFuncPath, [boldBaseName '_parcellation_clust_' num2str(roi_num) '_' strategy_suffix]);
            strategy_parcellationPath = fullfile(output_dir, [boldBaseName '_space-template_desc-individualParcellation' ext]);
            
            if exist(strategy_parcellationPath, 'file')
                updateStatus(fig, ['Skipping - individual parcellation already exists for: ' boldFile ' with ROI ' num2str(roi_num) ' and ' strategy_name]);
                skippedCount = skippedCount + 1;
                
                existing_net_map = spm_read_vols(spm_vol(strategy_parcellationPath));
                strategy_net_maps(:, :, :, end+1) = existing_net_map;
                strategy_run_names{end+1} = boldBaseName;
                continue;
            end
            
            regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
            if ~exist(regressedBoldPath, 'file')
                updateStatus(fig, ['Warning: Regression output not found for ' strategy_name ': ' regressedBoldPath]);
                continue;
            end
            
            group_net_file = fullfile(templatePath, 'AMCP_temp', 'final_network_428rois_12clusters.nii');
            group_net = spm_read_vols(spm_vol(group_net_file));
            
            tSNR_path = '';
            if use_tSNR
                tSNR_path = calculateTSNR(fig, derivFuncPath, boldBaseName, strategy_suffix);
                if isempty(tSNR_path)
                    updateStatus(fig, ['Warning: Failed to calculate tSNR for ' boldFile '. Continuing without tSNR correction.']);
                else
                    updateStatus(fig, ['tSNR calculated for: ' boldFile]);
                end
            end
            
            InterSubjectVar_head = [];
            if isfield(InterSubjectVar_heads, strategy_suffix)
                InterSubjectVar_head = InterSubjectVar_heads.(strategy_suffix);
            end
            
            if exist(regressedBoldPath, 'file')
                cd(derivFuncPath);
                
                fMRI_4D = spm_read_vols(spm_vol(regressedBoldPath));
                
                optional_params = {};
                if use_tSNR && ~isempty(tSNR_path)
                    optional_params{end+1} = 'tSNR';
                    optional_params{end+1} = true;
                    optional_params{end+1} = 'tSNRfile';
                    optional_params{end+1} = tSNR_path;
                end
                
                if ~isempty(InterSubjectVar_head)
                    optional_params{end+1} = 'InterSubjectVar';
                    optional_params{end+1} = InterSubjectVar_head;
                end
                
                [net_map, corr_map, iter] = individualized_parcellation_rsfMRI_v3(fMRI_4D, group_net, GMWM_head, 'kmeans', roi_num, percent_top, output_dir, max_iter, change_thr, conf_thr, optional_params{:});
                
                strategy_net_maps(:, :, :, end+1) = net_map;
                strategy_run_names{end+1} = boldBaseName;
                
                net_head = GMWM_head;
                net_head.fname = strategy_parcellationPath;
                net_head.dt = [16 0];
                spm_write_vol(net_head, net_map);
                
                updateStatus(fig, ['Completed individual parcellation for: ' boldFile ' with ROI ' num2str(roi_num) ' and ' strategy_name]);
                updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);
                processedCount = processedCount + 1;
            end
        end
        
        if size(strategy_net_maps, 4) > 1
            M = size(strategy_net_maps, 4);
            dice_strategy = zeros(M, M);
            for k = 1:M
                for m = 1:M
                    dice_strategy(k, m) = dice_coefficient(strategy_net_maps(:, :, :, k), strategy_net_maps(:, :, :, m), GMWM_mask);
                end
            end
            
            strategy_dice_file = fullfile(derivFuncPath, ['dice_cross_runs_clust_' num2str(roi_num) '_' strategy_suffix '.mat']);
            save(strategy_dice_file, 'dice_strategy', 'strategy_run_names');
            
            mean_dice = mean(dice_strategy(dice_strategy > 0 & ~eye(M)));
            updateStatus(fig, ['ROI ' num2str(roi_num) ' strategy ' strategy_name ' average Dice (across runs): ' num2str(mean_dice)]);
        end
    end
end

end


function [processedCount, skippedCount] = processConcatenatedRuns_Clust(fig, bidsPath, subjectName, boldFiles, ...
    roi_nums, selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
    percent_top, max_iter, change_thr, conf_thr, use_tSNR, InterSubjectVar_heads)

processedCount = 0;
skippedCount = 0;
derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subjectName, 'func');

concatenated_dir = fullfile(derivFuncPath, 'parcellation_concatenated_clust');
if ~exist(concatenated_dir, 'dir')
    mkdir(concatenated_dir);
end

for roi_idx = 1:length(roi_nums)
    roi_num = roi_nums(roi_idx);
    
    for strategy_idx = 1:length(selected_strategies)
        strategy_suffix = selected_strategies{strategy_idx};
        strategy_name = strrep(strategy_suffix, 'Regressed', '');
        
        config_output_dir = fullfile(concatenated_dir, ['clust_' num2str(roi_num) '_' strategy_suffix]);
        concatenated_parcellationPath = fullfile(config_output_dir, [subjectName '_space-template_desc-concatenatedParcellation.nii']);
        
        if exist(concatenated_parcellationPath, 'file')
            updateStatus(fig, ['Skipping - concatenated parcellation already exists for ROI ' num2str(roi_num) ' and ' strategy_name]);
            skippedCount = skippedCount + 1;
            continue;
        end
        
        all_fMRI_data = [];
        valid_runs = {};
        
        for j = 1:length(boldFiles)
            boldFile = boldFiles(j).name;
            [~, boldBaseName, ext] = fileparts(boldFile);
            
            regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
            
            if exist(regressedBoldPath, 'file')
                fMRI_data = spm_read_vols(spm_vol(regressedBoldPath));
                
                if isempty(all_fMRI_data)
                    all_fMRI_data = fMRI_data;
                else
                    all_fMRI_data = cat(4, all_fMRI_data, fMRI_data);
                end
                
                valid_runs{end+1} = boldBaseName;
                updateStatus(fig, ['Added run ' boldBaseName ' to concatenated data for ROI ' num2str(roi_num) ' and ' strategy_name]);
            else
                updateStatus(fig, ['Skipping run ' boldBaseName ' - missing regression output for ROI ' num2str(roi_num) ' and ' strategy_name]);
            end
        end
        
        if isempty(all_fMRI_data)
            updateStatus(fig, ['No valid runs found for concatenation with ROI ' num2str(roi_num) ' and strategy ' strategy_name]);
            continue;
        end
        
        updateStatus(fig, ['Concatenated ' num2str(length(valid_runs)) ' runs for ROI ' num2str(roi_num) ' and strategy ' strategy_name]);
        updateStatus(fig, ['Final data dimensions: ' mat2str(size(all_fMRI_data))]);
        
        if ~exist(config_output_dir, 'dir')
            mkdir(config_output_dir);
        end
        
        group_net_file = fullfile(templatePath, 'AMCP_temp', 'final_network_428rois_12clusters.nii');
        group_net = spm_read_vols(spm_vol(group_net_file));
        
        tSNR_path = '';
        if use_tSNR
            tSNR_path = calculateTSNRFromData(fig, config_output_dir, all_fMRI_data, GMWM_head, [subjectName '_concatenated_tSNR.nii']);
            if isempty(tSNR_path)
                updateStatus(fig, ['Warning: Failed to calculate tSNR for concatenated data. Continuing without tSNR correction.']);
            else
                updateStatus(fig, 'tSNR calculated for concatenated data');
            end
        end
        
        InterSubjectVar_head = [];
        if isfield(InterSubjectVar_heads, strategy_suffix)
            InterSubjectVar_head = InterSubjectVar_heads.(strategy_suffix);
        end
        
        optional_params = {};
        if use_tSNR && ~isempty(tSNR_path)
            optional_params{end+1} = 'tSNR';
            optional_params{end+1} = true;
            optional_params{end+1} = 'tSNRfile';
            optional_params{end+1} = tSNR_path;
        end
        
        if ~isempty(InterSubjectVar_head)
            optional_params{end+1} = 'InterSubjectVar';
            optional_params{end+1} = InterSubjectVar_head;
        end
        
        cd(derivFuncPath);
        [net_map, corr_map, iter] = individualized_parcellation_rsfMRI_v3(all_fMRI_data, group_net, GMWM_head, 'kmeans', roi_num, percent_top, config_output_dir, max_iter, change_thr, conf_thr, optional_params{:});
        
        net_head = GMWM_head;
        net_head.fname = concatenated_parcellationPath;
        net_head.dt = [16 0];
        spm_write_vol(net_head, net_map);
        
        concat_info.valid_runs = valid_runs;
        concat_info.strategy = strategy_name;
        concat_info.roi_num = roi_num;
        concat_info.use_tSNR = use_tSNR;
        concat_info.use_inter_subject_var = ~isempty(InterSubjectVar_head);
        concat_info.data_dimensions = size(all_fMRI_data);
        concat_info.parcellation_params = struct('percent_top', percent_top, 'max_iter', max_iter, 'change_thr', change_thr, 'conf_thr', conf_thr);
        save(fullfile(config_output_dir, 'concatenation_info.mat'), 'concat_info');
        
        updateStatus(fig, ['Completed concatenated parcellation for ' subjectName ' with ROI ' num2str(roi_num) ' and ' strategy_name]);
        updateStatus(fig, ['Used ' num2str(length(valid_runs)) ' runs: ' strjoin(valid_runs, ', ')]);
        updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);
        processedCount = processedCount + 1;
        
        clear all_fMRI_data net_map corr_map;
    end
end
end


function processIndividualParcellationVoxel_BIDS(fig, subjectFilter, templatePath)
bidsPath = fig.UserData.bidsPath;
GMWM_head = spm_vol(fullfile(templatePath, 'AMCP_temp', 'AMCP_GMWM_mask.nii'));
GMWM_mask = spm_read_vols(GMWM_head);
subDirs = dir(fullfile(bidsPath, subjectFilter));

downsample_factor = fig.UserData.voxelDownsampleEdit.Value;
use_tSNR = fig.UserData.useTSNRCheckbox.Value;
use_inter_subject_var = fig.UserData.useInterSubjectVarCheckbox.Value;

updateStatus(fig, ['Using voxel mode parameters - Downsample Factor: ' num2str(downsample_factor) ...
    ', Use tSNR: ' num2str(use_tSNR) ', Use Inter-Subject Var: ' num2str(use_inter_subject_var)]);

selected_strategies = {};
if fig.UserData.advRegressionPCOnlyCheckbox.Value
    selected_strategies{end+1} = 'Regressedpc';
end
if fig.UserData.advRegressionPCCSFCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSF';
end
if fig.UserData.advRegressionPCGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcGS';
end
if fig.UserData.advRegressionPCCSFGSCheckbox.Value
    selected_strategies{end+1} = 'RegressedpcCSFGS';
end

if isempty(selected_strategies)
    updateStatus(fig, 'Warning: No regression strategies selected for voxel parcellation. Using default PC only.');
    selected_strategies = {'Regressedpc'};
end

updateStatus(fig, ['Voxel parcellation will use strategies: ' strjoin(selected_strategies, ', ')]);

percent_top = fig.UserData.percentTopEdit.Value;
max_iter = fig.UserData.maxIterEdit.Value;
change_thr = fig.UserData.changeThrEdit.Value;
conf_thr = fig.UserData.confThrEdit.Value;

updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);

InterSubjectVar_head = [];
if use_inter_subject_var
    updateStatus(fig, 'Calculating Inter-Subject Variability map...');
    InterSubjectVar_head = computeInterSubjectVariabilityBIDS(fig, bidsPath, subjectFilter, selected_strategies, templatePath);
    if isempty(InterSubjectVar_head)
        updateStatus(fig, 'Warning: Failed to compute Inter-Subject Variability map. Continuing without it.');
        use_inter_subject_var = false;
    else
        updateStatus(fig, 'Inter-Subject Variability map computed successfully.');
    end
end

parcellation_mode = questdlg('Select parcellation mode:', 'Parcellation Mode', ...
    'Individual Runs (separate folders)', 'Concatenated Runs (single folder)', ...
    'Individual Runs (separate folders)');

if isempty(parcellation_mode)
    updateStatus(fig, 'Parcellation cancelled by user');
    return;
end

updateStatus(fig, ['Selected parcellation mode: ' parcellation_mode]);

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Individual parcellation (voxel mode) for: ' subDirs(i).name]);
        
        funcPath = fullfile(subPath, 'func');
        boldFiles = dir(fullfile(funcPath, '*_bold.nii'));
        
        if isempty(boldFiles)
            updateStatus(fig, ['No BOLD files found for subject: ' subDirs(i).name]);
            continue;
        end
        
        switch parcellation_mode
            case 'Individual Runs (separate folders)'
                [processed, skipped] = processIndividualRuns_Voxel(fig, bidsPath, subDirs(i).name, boldFiles, ...
                    selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
                    downsample_factor, use_tSNR, InterSubjectVar_head, ...
                    percent_top, max_iter, change_thr, conf_thr);
                processedCount = processedCount + processed;
                skippedCount = skippedCount + skipped;
                
            case 'Concatenated Runs (single folder)'
                [processed, skipped] = processConcatenatedRuns_Voxel(fig, bidsPath, subDirs(i).name, boldFiles, ...
                    selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
                    downsample_factor, use_tSNR, InterSubjectVar_head, ...
                    percent_top, max_iter, change_thr, conf_thr);
                processedCount = processedCount + processed;
                skippedCount = skippedCount + skipped;
        end
        
    catch ME
        updateStatus(fig, ['Error in voxel parcellation for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Individual parcellation (voxel mode) completed: %d files processed, %d files skipped', processedCount, skippedCount));
end

function [processedCount, skippedCount] = processIndividualRuns_Voxel(fig, bidsPath, subjectName, boldFiles, ...
    selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
    downsample_factor, use_tSNR, InterSubjectVar_head, ...
    percent_top, max_iter, change_thr, conf_thr)

processedCount = 0;
skippedCount = 0;
derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subjectName, 'func');

group_net_file = fullfile(templatePath, 'AMCP_temp', 'final_network_428rois_12clusters.nii');
group_net = spm_read_vols(spm_vol(group_net_file));

for strategy_idx = 1:length(selected_strategies)
    strategy_suffix = selected_strategies{strategy_idx};
    strategy_name = strrep(strategy_suffix, 'Regressed', '');
    
    strategy_net_maps = [];
    strategy_run_names = {};
    
    for j = 1:length(boldFiles)
        boldFile = boldFiles(j).name;
        [~, boldBaseName, ext] = fileparts(boldFile);
        
        output_dir = fullfile(derivFuncPath, [boldBaseName '_parcellation_voxel_' num2str(downsample_factor) '_' strategy_suffix]);
        parcellationPath = fullfile(output_dir, [boldBaseName '_space-template_desc-individualParcellation' ext]);
        
        if exist(parcellationPath, 'file')
            updateStatus(fig, ['Skipping - voxel parcellation already exists for: ' boldFile ' with ' strategy_name]);
            skippedCount = skippedCount + 1;
            
            existing_net_map = spm_read_vols(spm_vol(parcellationPath));
            strategy_net_maps(:, :, :, end+1) = existing_net_map;
            strategy_run_names{end+1} = boldBaseName;
            continue;
        end
        
        regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
        if ~exist(regressedBoldPath, 'file')
            updateStatus(fig, ['Warning: Regression output not found for ' strategy_name ': ' regressedBoldPath]);
            continue;
        end
        
        tSNR_path = '';
        if use_tSNR
            tSNR_path = calculateTSNR(fig, derivFuncPath, boldBaseName, strategy_suffix);
            if isempty(tSNR_path)
                updateStatus(fig, ['Warning: Failed to calculate tSNR for ' boldFile '. Continuing without tSNR correction.']);
            else
                updateStatus(fig, ['tSNR calculated for: ' boldFile]);
            end
        end
        
        if exist(regressedBoldPath, 'file')
            cd(derivFuncPath);
            
            fMRI_4D = spm_read_vols(spm_vol(regressedBoldPath));
            
            optional_params = {'DownsampleMethod', 'nearest'};
            
            if use_tSNR && ~isempty(tSNR_path)
                optional_params{end+1} = 'tSNR';
                optional_params{end+1} = true;
                optional_params{end+1} = 'tSNRfile';
                optional_params{end+1} = tSNR_path;
            end
            
            if ~isempty(InterSubjectVar_head)
                optional_params{end+1} = 'InterSubjectVar';
                optional_params{end+1} = InterSubjectVar_head;
            end
            
            [net_map, corr_map, iter] = individualized_parcellation_rsfMRI_v3(fMRI_4D, group_net, GMWM_head, ...
                'voxel', downsample_factor, percent_top, output_dir, max_iter, change_thr, conf_thr, optional_params{:});
            
            net_head = GMWM_head;
            net_head.fname = parcellationPath;
            net_head.dt = [16 0];
            spm_write_vol(net_head, net_map);
            
            strategy_net_maps(:, :, :, end+1) = net_map;
            strategy_run_names{end+1} = boldBaseName;
            
            updateStatus(fig, ['Completed voxel parcellation for: ' boldFile ' with downsample factor ' num2str(downsample_factor) ' and ' strategy_name]);
            updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);
            processedCount = processedCount + 1;
        end
    end
    
    if size(strategy_net_maps, 4) > 1
        M = size(strategy_net_maps, 4);
        dice_strategy = zeros(M, M);
        for k = 1:M
            for m = 1:M
                dice_strategy(k, m) = dice_coefficient(strategy_net_maps(:, :, :, k), strategy_net_maps(:, :, :, m), GMWM_mask);
            end
        end
        
        strategy_dice_file = fullfile(derivFuncPath, ['dice_cross_runs_voxel_' num2str(downsample_factor) '_' strategy_suffix '.mat']);
        save(strategy_dice_file, 'dice_strategy', 'strategy_run_names');
        
        mean_dice = mean(dice_strategy(dice_strategy > 0 & ~eye(M)));
        updateStatus(fig, ['Voxel mode strategy ' strategy_name ' average Dice (across runs): ' num2str(mean_dice)]);
    end
end

end

function [processedCount, skippedCount] = processConcatenatedRuns_Voxel(fig, bidsPath, subjectName, boldFiles, ...
    selected_strategies, GMWM_head, GMWM_mask, templatePath, ...
    downsample_factor, use_tSNR, InterSubjectVar_head, ...
    percent_top, max_iter, change_thr, conf_thr)

processedCount = 0;
skippedCount = 0;
derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subjectName, 'func');

concatenated_dir = fullfile(derivFuncPath, 'parcellation_concatenated_voxel');
if ~exist(concatenated_dir, 'dir')
    mkdir(concatenated_dir);
end

group_net_file = fullfile(templatePath, 'AMCP_temp', 'final_network_428rois_12clusters.nii');
group_net = spm_read_vols(spm_vol(group_net_file));

for strategy_idx = 1:length(selected_strategies)
    strategy_suffix = selected_strategies{strategy_idx};
    strategy_name = strrep(strategy_suffix, 'Regressed', '');
    
    config_output_dir = fullfile(concatenated_dir, ['voxel_' num2str(downsample_factor) '_' strategy_suffix]);
    concatenated_parcellationPath = fullfile(config_output_dir, [subjectName '_space-template_desc-concatenatedParcellation.nii']);
    
    if exist(concatenated_parcellationPath, 'file')
        updateStatus(fig, ['Skipping - concatenated voxel parcellation already exists for ' strategy_name]);
        skippedCount = skippedCount + 1;
        continue;
    end
    
    all_fMRI_data = [];
    valid_runs = {};
    
    for j = 1:length(boldFiles)
        boldFile = boldFiles(j).name;
        [~, boldBaseName, ext] = fileparts(boldFile);
        
        regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix ext]);
        
        if exist(regressedBoldPath, 'file')
            fMRI_data = spm_read_vols(spm_vol(regressedBoldPath));
            
            if isempty(all_fMRI_data)
                all_fMRI_data = fMRI_data;
            else
                all_fMRI_data = cat(4, all_fMRI_data, fMRI_data);
            end
            
            valid_runs{end+1} = boldBaseName;
            updateStatus(fig, ['Added run ' boldBaseName ' to concatenated data for ' strategy_name]);
        else
            updateStatus(fig, ['Skipping run ' boldBaseName ' - missing regression output for ' strategy_name]);
        end
    end
    
    if isempty(all_fMRI_data)
        updateStatus(fig, ['No valid runs found for concatenation with strategy ' strategy_name]);
        continue;
    end
    
    updateStatus(fig, ['Concatenated ' num2str(length(valid_runs)) ' runs for strategy ' strategy_name]);
    updateStatus(fig, ['Final data dimensions: ' mat2str(size(all_fMRI_data))]);
    
    if ~exist(config_output_dir, 'dir')
        mkdir(config_output_dir);
    end
    
    tSNR_path = '';
    if use_tSNR
        tSNR_path = calculateTSNRFromData(fig, config_output_dir, all_fMRI_data, GMWM_head, [subjectName '_concatenated_tSNR.nii']);
        if isempty(tSNR_path)
            updateStatus(fig, ['Warning: Failed to calculate tSNR for concatenated data. Continuing without tSNR correction.']);
        else
            updateStatus(fig, 'tSNR calculated for concatenated data');
        end
    end
    
    optional_params = {'DownsampleMethod', 'nearest'};
    
    if use_tSNR && ~isempty(tSNR_path)
        optional_params{end+1} = 'tSNR';
        optional_params{end+1} = true;
        optional_params{end+1} = 'tSNRfile';
        optional_params{end+1} = tSNR_path;
    end
    
    if ~isempty(InterSubjectVar_head)
        optional_params{end+1} = 'InterSubjectVar';
        optional_params{end+1} = InterSubjectVar_head;
    end
    
    cd(derivFuncPath);
    [net_map, corr_map, iter] = individualized_parcellation_rsfMRI_v3(all_fMRI_data, group_net, GMWM_head, ...
        'voxel', downsample_factor, percent_top, config_output_dir, max_iter, change_thr, conf_thr, optional_params{:});
    
    net_head = GMWM_head;
    net_head.fname = concatenated_parcellationPath;
    net_head.dt = [16 0];
    spm_write_vol(net_head, net_map);
    
    concat_info.valid_runs = valid_runs;
    concat_info.strategy = strategy_name;
    concat_info.downsample_factor = downsample_factor;
    concat_info.use_tSNR = use_tSNR;
    concat_info.use_inter_subject_var = ~isempty(InterSubjectVar_head);
    concat_info.data_dimensions = size(all_fMRI_data);
    concat_info.parcellation_params = struct('percent_top', percent_top, 'max_iter', max_iter, 'change_thr', change_thr, 'conf_thr', conf_thr);
    save(fullfile(config_output_dir, 'concatenation_info.mat'), 'concat_info');
    
    updateStatus(fig, ['Completed concatenated voxel parcellation for ' subjectName ' with downsample factor ' num2str(downsample_factor) ' and ' strategy_name]);
    updateStatus(fig, ['Used ' num2str(length(valid_runs)) ' runs: ' strjoin(valid_runs, ', ')]);
    updateStatus(fig, ['Parcellation parameters - Percent Top: ' num2str(percent_top) ', Max Iter: ' num2str(max_iter) ', Change Thr: ' num2str(change_thr) ', Conf Thr: ' num2str(conf_thr)]);
    processedCount = processedCount + 1;
    
    clear all_fMRI_data net_map corr_map;
end
end

function tSNR_path = calculateTSNR(fig, derivFuncPath, boldBaseName, strategy_suffix)
try
    regressedBoldPath = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-' strategy_suffix '.nii']);
    
    if ~exist(regressedBoldPath, 'file')
        updateStatus(fig, ['Warning: Regression output not found for tSNR calculation: ' regressedBoldPath]);
        tSNR_path = '';
        return;
    end
    
    bold_head = spm_vol(regressedBoldPath);
    bold_data = spm_read_vols(bold_head);
    
    tSNR_data = mean(bold_data, 4) ./ std(bold_data, 0, 4);
    tSNR_data(isnan(tSNR_data) | isinf(tSNR_data)) = 0;
    
    tSNR_path = fullfile(derivFuncPath, [boldBaseName '_space-template_desc-tSNR_' strategy_suffix '.nii']);
    tSNR_head = bold_head(1);
    tSNR_head.fname = tSNR_path;
    tSNR_head.dt = [16 0];
    spm_write_vol(tSNR_head, tSNR_data);
    
    updateStatus(fig, ['tSNR map saved: ' tSNR_path]);
    
catch ME
    updateStatus(fig, ['Error calculating tSNR: ' ME.message]);
    tSNR_path = '';
end
end

function tSNR_path = calculateTSNRFromData(fig, output_dir, bold_data, template_head, output_filename)
try
    tSNR_data = mean(bold_data, 4) ./ std(bold_data, 0, 4);
    tSNR_data(isnan(tSNR_data) | isinf(tSNR_data)) = 0;
    
    tSNR_path = fullfile(output_dir, output_filename);
    tSNR_head = template_head;
    tSNR_head.fname = tSNR_path;
    tSNR_head.dt = [16 0];
    spm_write_vol(tSNR_head, tSNR_data);
    
    updateStatus(fig, ['tSNR map saved: ' tSNR_path]);
    
catch ME
    updateStatus(fig, ['Error calculating tSNR from data: ' ME.message]);
    tSNR_path = '';
end
end

function InterSubjectVar_head = computeInterSubjectVariabilityBIDS(fig, bidsPath, subjectFilter, strategy_suffix, templatePath)
try
    updateStatus(fig, ['Starting inter-subject variability calculation for strategy: ' strategy_suffix]);
    
    template_head = spm_vol(fullfile(templatePath, 'Template_Mouse_v38.nii'));
    Gmask_head = spm_vol(fullfile(templatePath, 'brainmask_Mouse_v38.nii'));
    Gmask = spm_read_vols(Gmask_head);
    
    group_net_file = fullfile(templatePath, 'AMCP_temp', 'final_network_428rois_12clusters.nii');
    group_net = spm_read_vols(spm_vol(group_net_file));
    
    net_labels = unique(group_net(Gmask > 0));
    net_labels = net_labels(net_labels > 0);
    n_nets = numel(net_labels);
    
    subDirs = dir(fullfile(bidsPath, subjectFilter));
    n_subs = numel(subDirs);
    
    all_sub_corr = [];
    valid_subjects = {};
    
    updateStatus(fig, ['Processing ' num2str(n_subs) ' subjects for variability calculation...']);
    
    for sub_idx = 1:n_subs
        subPath = fullfile(subDirs(sub_idx).folder, subDirs(sub_idx).name);
        derivFuncPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(sub_idx).name, 'func');
        
        if ~exist(derivFuncPath, 'dir')
            continue;
        end
        
        boldFiles = dir(fullfile(derivFuncPath, ['*_space-template_desc-' strategy_suffix '.nii']));
        if isempty(boldFiles)
            continue;
        end
        
        boldFile = boldFiles(1).name;
        boldPath = fullfile(boldFiles(1).folder, boldFile);
        
        try
            bold_head = spm_vol(boldPath);
            bold_data = spm_read_vols(bold_head);
            
            sub_corr_map = zeros(size(Gmask));
            
            for net_idx = 1:n_nets
                net_label = net_labels(net_idx);
                net_mask = (group_net == net_label) & (Gmask > 0);
                
                if nnz(net_mask) < 10
                    continue;
                end
                
                net_ts = mean(reshape(bold_data(repmat(net_mask, [1,1,1,size(bold_data,4)])), ...
                    nnz(net_mask), size(bold_data,4)), 1);
                
                corr_vals = zeros(size(Gmask));
                for z = 1:size(bold_data,3)
                    for y = 1:size(bold_data,2)
                        for x = 1:size(bold_data,1)
                            if Gmask(x,y,z) > 0
                                voxel_ts = squeeze(bold_data(x,y,z,:));
                                corr_val = corr(voxel_ts, net_ts');
                                if isnan(corr_val), corr_val = 0; end
                                corr_vals(x,y,z) = corr_val;
                            end
                        end
                    end
                end
                
                sub_corr_map(net_mask) = corr_vals(net_mask);
            end
            
            if isempty(all_sub_corr)
                all_sub_corr = zeros([size(Gmask), n_subs]);
            end
            all_sub_corr(:, :, :, sub_idx) = sub_corr_map;
            valid_subjects{end+1} = subDirs(sub_idx).name;
            
            updateStatus(fig, ['Processed subject ' num2str(sub_idx) ': ' subDirs(sub_idx).name]);
            
        catch ME
            updateStatus(fig, ['Error processing subject ' subDirs(sub_idx).name ': ' ME.message]);
            continue;
        end
    end
    
    valid_indices = ~all(reshape(all_sub_corr, [], size(all_sub_corr,4)) == 0, 1);
    all_sub_corr = all_sub_corr(:, :, :, valid_indices);
    valid_subjects = valid_subjects(valid_indices);
    
    if isempty(all_sub_corr) || size(all_sub_corr,4) < 2
        updateStatus(fig, 'Warning: Not enough subjects with valid data for variability calculation.');
        InterSubjectVar_head = [];
        return;
    end
    
    updateStatus(fig, ['Calculating variability across ' num2str(size(all_sub_corr,4)) ' valid subjects...']);
    
    inter_var_map = std(all_sub_corr, 0, 4);
    inter_var_map = smooth3(inter_var_map, 'gaussian', [3,3,3], 1);
    inter_var_map(~Gmask) = 0;
    
    groupAnalysisPath = fullfile(bidsPath, 'derivatives', 'MIKey', 'group_analysis');
    if ~exist(groupAnalysisPath, 'dir')
        mkdir(groupAnalysisPath);
    end
    
    inter_var_path = fullfile(groupAnalysisPath, ['InterSubjectVariability_' strategy_suffix '.nii']);
    inter_var_head = template_head;
    inter_var_head.fname = inter_var_path;
    inter_var_head.dt = [16 0];
    spm_write_vol(inter_var_head, inter_var_map);
    
    var_info.valid_subjects = valid_subjects;
    var_info.strategy_used = strategy_suffix;
    var_info.n_subjects = length(valid_subjects);
    save(fullfile(groupAnalysisPath, ['InterSubjectVariability_info_' strategy_suffix '.mat']), 'var_info');
    
    updateStatus(fig, ['Inter-subject variability map saved: ' inter_var_path]);
    updateStatus(fig, ['Based on ' num2str(length(valid_subjects)) ' subjects']);
    
    InterSubjectVar_head = inter_var_head;
    
catch ME
    updateStatus(fig, ['Error in inter-subject variability calculation: ' ME.message]);
    InterSubjectVar_head = [];
end
end

function dice_val = dice_coefficient(img1, img2, mask)
img1_mask = img1(mask > 0);
img2_mask = img2(mask > 0);

intersection = sum(img1_mask & img2_mask);
sum_img1 = sum(img1_mask);
sum_img2 = sum(img2_mask);

if (sum_img1 + sum_img2) == 0
    dice_val = 0;
else
    dice_val = 2 * intersection / (sum_img1 + sum_img2);
end
end

function processTissueSegmentation_BIDS(fig, subjectFilter)
bidsPath = fig.UserData.bidsPath;
templatePath = fig.UserData.templateEdit.Value;
subDirs = dir(fullfile(bidsPath, subjectFilter));

ref_prob = {
    fullfile(templatePath,'AMCP_temp','AMCP_TPM.nii,1');
    fullfile(templatePath,'AMCP_temp','AMCP_TPM.nii,2');
    fullfile(templatePath,'AMCP_temp','AMCP_TPM.nii,3');
    fullfile(templatePath,'AMCP_temp','AMCP_TPM.nii,4');
    fullfile(templatePath,'AMCP_temp','AMCP_TPM.nii,5')
    };

processedCount = 0;
skippedCount = 0;

for i = 1:length(subDirs)
    try
        subPath = fullfile(subDirs(i).folder, subDirs(i).name);
        updateStatus(fig, ['Tissue segmentation: ' subDirs(i).name]);
        
        anatPath = fullfile(subPath, 'anat');
        t2Files = dir(fullfile(anatPath, '*_T2w.nii'));
        if isempty(t2Files)
            continue;
        end
        for j = 1:length(t2Files)
            t2File = t2Files(j).name;
            [~, baseName, ext] = fileparts(t2File);
            derivAnatPath = fullfile(bidsPath, 'derivatives', 'MIKey', subDirs(i).name, 'anat');
            
            oldsegGMPath = fullfile(derivAnatPath, [baseName '_desc-gmvol' ext]);
            if exist(oldsegGMPath, 'file')
                updateStatus(fig, ['Skipping - Tissue segmentation already completed for: ' t2File]);
                skippedCount = skippedCount + 1;
                continue;
            end
            maskedT2Path = fullfile(derivAnatPath, [t2Files(j).name(1:end-4) '_desc-masked' ext]);
            scaledT2Path = fullfile(derivAnatPath, [t2Files(j).name(1:end-4) '_desc-scaled' ext]);
            
            if exist(scaledT2Path, 'file')
                ref{1,1} = fullfile(templatePath, 'Template_Mouse_v38.nii');
                source{1,1} = [ maskedT2Path ',1'];
                all_func = [source; [scaledT2Path ',1']];
                OldNormalize_mlb = UN_get_default_oldnormalize_batch_struct(ref, source, all_func,2);
                spm_jobman('run',OldNormalize_mlb);
                movefile(fullfile(derivAnatPath, ['norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]), fullfile(derivAnatPath, [t2Files(j).name(1:end-4) '_space-template' ext]));
                movefile(fullfile(derivAnatPath, ['norm' t2Files(j).name(1:end-4) '_desc-masked' ext]),fullfile(derivAnatPath, [t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]));
                clear OldNormalize_mlb;
                
                % seg
                %                 tempCoregT2Path = fullfile(derivAnatPath, ['norm' t2Files(j).name(1:end-4) '_desc-scaled' ext ',1']);
                %                 segment_mlb = UN_get_segment_batch_struct(tempCoregT2Path, ref_prob);
                %                 spm_jobman('run',segment_mlb);
                %                 clear segment_mlb;
                %
                %                 smooth_para = [6,6,6];
                %                 all_func = {
                %                     fullfile(derivAnatPath, ['c1norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                     fullfile(derivAnatPath, ['c2norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                     fullfile(derivAnatPath, ['c3norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                     fullfile(derivAnatPath, ['c4norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                     fullfile(derivAnatPath, ['c5norm' t2Files(j).name(1:end-4) '_desc-scaled' ext])
                %                     };
                %                 Smooth_mlb = MY_get_default_smooth_batch_struct(all_func, smooth_para);
                %                 updateStatus(fig, 'Start to process Smooth!');
                %                 spm_jobman('run',Smooth_mlb);
                %                 clear Smooth_mlb;
                %                  segGMPath = fullfile(derivAnatPath, [baseName '_desc-gmprob' ext]);
                %                 segWMPath = fullfile(derivAnatPath, [baseName '_desc-wmprob' ext]);
                %                 segCSFPath = fullfile(derivAnatPath, [baseName '_desc-csfprob' ext]);
                %                 segOTPath = fullfile(derivAnatPath, [baseName '_desc-otprob' ext]);
                %                 segAIRPath = fullfile(derivAnatPath, [baseName '_desc-airprob' ext]);
                %
                %                 tempSegGMPath =  fullfile(derivAnatPath, ['sc1norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                 tempSegWMPath =  fullfile(derivAnatPath, ['sc2norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                 tempSegCSFPath = fullfile(derivAnatPath, ['sc3norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                 tempSegOTPath =  fullfile(derivAnatPath, ['sc4norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                 tempSegAIRPath =  fullfile(derivAnatPath, ['sc5norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %                 tempT2path = fullfile(derivAnatPath, ['norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]);
                %
                %                 movefile(tempSegGMPath, segGMPath);
                %                 movefile(tempSegWMPath, segWMPath);
                %                 movefile(tempSegCSFPath, segCSFPath);
                %                 movefile(tempSegOTPath, segOTPath);
                %                 movefile(tempSegAIRPath, segAIRPath);
                
                %                 updateStatus(fig, ['Completed tissue segmentation for: ' t2File]);
                %                 processedCount = processedCount + 1;
                %
                %                 delete( fullfile(derivAnatPath, ['c1norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]));
                %                 delete( fullfile(derivAnatPath, ['c2norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]));
                %                 delete( fullfile(derivAnatPath, ['c3norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]));
                %                 delete( fullfile(derivAnatPath, ['c4norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]));
                %                 delete( fullfile(derivAnatPath, ['c5norm' t2Files(j).name(1:end-4) '_desc-scaled' ext]));
                
                %oldseg
                source = {fullfile(derivAnatPath, [t2Files(j).name(1:end-4) '_space-template_desc-masked' ext])};
                ref_prob_old = {
                    fullfile(templatePath(1:end-10), 'scripts','AMCP_GM.nii,1');
                    fullfile(templatePath(1:end-10), 'scripts','AMCP_WM.nii,1');
                    fullfile(templatePath(1:end-10), 'scripts','AMCP_CSF.nii,1')};
                segment_mlb = UN_get_old_segment_batch_struct(source, ref_prob_old);
                spm_jobman('run',segment_mlb);
                clear segment_mlb;
                
                smooth_para = [6,6,6];
                all_func_old = {
                    fullfile(derivAnatPath, ['mwc1' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]);
                    fullfile(derivAnatPath, ['mwc2' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]);
                    fullfile(derivAnatPath, ['mwc3' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext])
                    };
                Smooth_mlb = MY_get_default_smooth_batch_struct(all_func_old, smooth_para);
                spm_jobman('run',Smooth_mlb);
                clear Smooth_mlb;
                oldsegWMPath = fullfile(derivAnatPath, [baseName '_desc-gmvol' ext]);
                oldsegWMPath = fullfile(derivAnatPath, [baseName '_desc-wmvol' ext]);
                oldsegCSFPath = fullfile(derivAnatPath, [baseName '_desc-csfvol' ext]);
                
                oldtempSegGMPath =  fullfile(derivAnatPath, ['smwc1' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]);
                oldtempSegWMPath =  fullfile(derivAnatPath, ['smwc2' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]);
                oldtempSegCSFPath = fullfile(derivAnatPath, ['smwc3' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]);
                movefile(oldtempSegGMPath, oldsegGMPath);
                movefile(oldtempSegWMPath, oldsegWMPath);
                movefile(oldtempSegCSFPath, oldsegCSFPath);
                delete(fullfile(derivAnatPath, ['mwc1' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]));
                delete(fullfile(derivAnatPath, ['mwc2' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]));
                delete( fullfile(derivAnatPath, ['mwc3' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]));
                delete( fullfile(derivAnatPath, ['m' t2Files(j).name(1:end-4) '_space-template_desc-masked' ext]));
                delete(fullfile(derivAnatPath,'*.mat'));
            end
        end
        
    catch ME
        updateStatus(fig, ['Error in tissue segmentation for ' subDirs(i).name ': ' ME.message]);
    end
end
updateStatus(fig, sprintf('Tissue segmentation completed: %d files processed, %d files skipped', processedCount, skippedCount));
updateStatus(fig, ['Please proceed to the next step']);
end
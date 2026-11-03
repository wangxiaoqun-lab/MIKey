function test_mikey_config_choices
% Pure stage-choice validation; does not run SPM or touch subject images.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;
cleanup=onCleanup(@()path(oldPath));addpath(root);addpath(fullfile(root,'scripts'));
input=struct('steps',1,'fcLabel','unused','parcNetwork','unused', ...
    'parcellationMode','unused','sliceTimingOrder','unused');
cfg=MIKey_config(input);
assert(strcmp(cfg.fcLabel,'unused') && strcmp(cfg.parcNetwork,'unused'));
assert(strcmp(cfg.parcellationMode,'unused') && strcmp(cfg.sliceTimingOrder,'unused'));
state=MIKeyBatchState(cfg,-1);assert(strcmp(state.UserData.fcLabelDropdown.Value,'428'));
% Preprocessing 2:10 uses slice order, but not FC/parcellation choices.
input.steps=2:10;input.sliceTimingOrder='Auto-detect';
MIKey_config(input);
% Selecting an additional stage must revalidate its preserved value.
cfg.steps=13;expectError(cfg,'fcLabel');
for steps={4,[1 4],2:10}
    expectError(struct('steps',steps{1},'sliceTimingOrder','unused'),'sliceTimingOrder');
end
for steps={13,[10 13]}
    expectError(struct('steps',steps{1},'fcLabel','unused'),'fcLabel');
end
for stage=14:16
    expectError(struct('steps',stage,'parcNetwork','unused'),'parcNetwork');
    expectError(struct('steps',stage,'parcellationMode','unused'),'parcellationMode');
end
for label={'214','296','428','592','604','1184','Custom...'}
    cfg=MIKey_config(struct('steps',13,'fcLabel',label{1}));assert(strcmp(cfg.fcLabel,label{1}));
end
for network={'214rois','296rois','428rois','592rois','604rois','1184rois'}
    MIKey_config(struct('steps',14,'parcNetwork',network{1}));
end
for mode={'individual','concatenated'}
    MIKey_config(struct('steps',16,'parcellationMode',mode{1}));
end
% Inactive types are preserved; selected-stage types and typos are strict.
MIKey_config(struct('steps',1,'fcLabel',false));
expectError(struct('steps',13,'fcLabel',false),'fcLabel must be a character vector');
expectError(struct('steps',1,'unknownLabel','428'),'Unknown parameter','MIKey:UnknownParameter');
disp('MIKEY_CONFIG_CHOICES_PASS');
end

function expectError(input,message,id)
if nargin<3,id='MIKey:Parameter';end
try
    MIKey_config(input);
catch ME
    assert(strcmp(ME.identifier,id),ME.message);
    assert(contains(ME.message,message),ME.message);
    return;
end
error('MIKey:Test','Expected invalid selected-stage choice to be rejected.');
end

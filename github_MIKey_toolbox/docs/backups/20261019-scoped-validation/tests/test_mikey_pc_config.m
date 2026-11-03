function test_mikey_pc_config
% Pure configuration/count selection checks; no SPM, GUI or image processing.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;
cleanup=onCleanup(@()path(oldPath));addpath(root);
blank={[], '', '   ', string('')};
for k=1:numel(blank)
    input=struct('useDefaultPCStrategy',true);input.customPCCounts=blank{k};
    cfg=MIKey_config(input);assert(isnumeric(cfg.customPCCounts) && isempty(cfg.customPCCounts));
    state=MIKeyBatchState(cfg,-1);assert(isempty(state.UserData.customPCCountsEdit.Value));
    assert(isequal(MIKey_pc_counts(true,cfg.customPCCounts,101,85),[0 20 40 60 80]));
    input.useDefaultPCStrategy=false;expectError(input);
end
% Numeric zero is a valid PC count; logical false is not a PC-count list.
for default=[true false]
    input=struct('useDefaultPCStrategy',default,'customPCCounts',0);
    cfg=MIKey_config(input);assert(isequal(cfg.customPCCounts,0));
    input.customPCCounts=false;expectError(input,'not a true/false switch');
    input.customPCCounts=true;expectError(input,'not a true/false switch');
end
cfg=MIKey_config(struct('useDefaultPCStrategy',false,'customPCCounts',[20 0 5]));
assert(isequal(cfg.customPCCounts,[0 5 20]));
cfg=MIKey_config(struct('useDefaultPCStrategy',false,'customPCCounts','0,5,20'));
assert(isequal(cfg.customPCCounts,[0 5 20]));
invalid={[0 2 2],[-1 5],[0 .5],[0 NaN],[0 Inf],1+1i,{0 5},'false','0;disp(1)'};
for default=[true false]
    for k=1:numel(invalid)
        input=struct('useDefaultPCStrategy',default);input.customPCCounts=invalid{k};
        expectError(input);
    end
end
expectError(struct('useDefaultPCStrategy',2,'customPCCounts',[]));
disp('MIKEY_PC_CONFIG_PASS');
end

function expectError(input,message)
if nargin<2,message='';end
try
    MIKey_config(input);
catch ME
    assert(strcmp(ME.identifier,'MIKey:Parameter'),ME.message);
    if ~isempty(message),assert(~isempty(strfind(ME.message,message)));end %#ok<STREMP>
    return;
end
error('MIKey:Test','Expected invalid PC configuration to be rejected.');
end

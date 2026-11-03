function result = test_mikey_config_scopes
% Exhaustive inactive-field/type sweep and active-field rejection, no SPM.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;
cleanup=onCleanup(@()path(oldPath));addpath(root);
d=MIKey_defaults();names=fieldnames(d);checks=0;
common={'bidsPath','spmPath','codePath','subjectFilter','sessionFilter', ...
    'taskFilter','runFilter','minTimepoints','steps','dryRun','failFast', ...
    'strictWarnings','logDir'};
phaseFields={ [common {'voxelScaleFactor'}], ...
    [common {'templatePath','sliceTimingTR','sliceTimingNSlices','sliceTimingOrder', ...
    'coregInterp','normInterp','useDefaultTemplate','smoothFWHM','useDefaultPCStrategy','fdMethod','fdRadius'}] };
phases={1,2:10};poison={false,[],NaN,Inf,'disabled',struct('unused',1),{false,'unused'}};
for phase=1:2
    input=d;input.steps=phases{phase};[cfg,active]=MIKey_config(input);
    actual=names(cellfun(@(n)active.(n),names));
    assert(isequal(sort(actual(:)),sort(phaseFields{phase}(:))));
    % Every unused field is tested alone against multiple wrong types, then
    % all unused fields are poisoned together through serialization/preflight.
    inactive=setdiff(names,phaseFields{phase});
    for i=1:numel(inactive)
        for k=1:numel(poison)
            changed=input;changed.(inactive{i})=poison{k};
            out=MIKey_config(changed);assert(isequaln(out.(inactive{i}),poison{k}));
            controls=MIKey_batch_controls(out);assert(isstruct(controls));
            checks=checks+1;
        end
        input.(inactive{i})=poison{mod(i-1,numel(poison))+1};
    end
    cfg=MIKey_config(input);state=MIKeyBatchState(cfg,-1);assert(isstruct(state.UserData));
    MIKey_check_stage(cfg,phases{phase}(1));
    % Preflight may report absent data/SPM, but no unused-field type, atlas,
    % group-network lookup or template-directory exception may escape it.
    report=MIKey_preflight(cfg);assert(isstruct(report) && isfield(report,'parameterScope'));
    if phase==1
        assert(isempty(report.requiredImages));
        assert(~any(contains(report.issues,'share_temp')));
    end
end
% Audit all 17 single-stage routes with every inactive field invalid at once.
% No images or GUI are created by these dependency/control checks.
for stage=1:17
    input=d;input.steps=stage;[~,scope]=MIKey_config(input);
    inactive=names(~cellfun(@(n)scope.(n),names));
    for i=1:numel(inactive)
        input.(inactive{i})=poison{mod(i-1,numel(poison))+1};
    end
    cfg=MIKey_config(input);MIKey_batch_controls(cfg);
    try
        MIKey_check_stage(cfg,stage);
    catch ME
        % Empty data intentionally lack Step 12's group strategy result.
        assert(strcmp(ME.identifier,'MIKey:Prerequisite'),ME.message);
    end
    MIKey_preflight(cfg);checks=checks+1;
end
% Every parameter has an active scenario and rejects an invalid type there.
% Conditional custom paths need separate scenarios from built-in selections.
scenarios={d};scenarios{1}.steps=1:17;
c=d;c.steps=7;c.useDefaultTemplate=false;scenarios{end+1}=c;
c=d;c.steps=10;c.useDefaultPCStrategy=false;scenarios{end+1}=c;
c=d;c.steps=13;c.fcLabel='Custom...';scenarios{end+1}=c;
c=d;c.steps=14;c.useCustomParc=true;scenarios{end+1}=c;
covered=struct();
for k=1:numel(scenarios)
    input=scenarios{k};[~,scope]=MIKey_config(input);
    for i=1:numel(names)
        name=names{i};if ~scope.(name) || isfield(covered,name),continue;end
        changed=input;changed.(name)=struct('invalid',1);
        if strcmp(name,'steps')
            expectError(changed,{'steps'});
        else
            expectError(changed,{name});
        end
        covered.(name)=true;checks=checks+1;
    end
end
assert(isequal(sort(fieldnames(covered)),sort(names)));
% Active input validation remains strict and reports multiple bad fields at once.
bad=struct('steps',2:10,'sliceTimingTR',0,'sliceTimingNSlices',2.5, ...
    'sliceTimingOrder','bad','coregInterp',9,'normInterp',-1, ...
    'smoothFWHM',[-1 2],'useDefaultPCStrategy','bad');
expectError(bad,{'sliceTimingTR','sliceTimingNSlices','sliceTimingOrder', ...
    'coregInterp','normInterp','smoothFWHM','useDefaultPCStrategy'});checks=checks+7;
expectError(struct('steps',1,'voxelScaleFactor',0),{'voxelScaleFactor'});
expectError(struct('steps',1,'minTimepoints',-1),{'minTimepoints'});
expectError(struct('steps',1,'subjectFilter','../sub-01'),{'subjectFilter'});
% Conditional dependencies, including those not used by Steps 1 / 2:10.
cfg=d;cfg.steps=10;cfg.customPCCounts=false;out=MIKey_config(cfg);
assert(isequal(out.customPCCounts,false));
cfg.useDefaultPCStrategy=false;expectError(cfg,{'customPCCounts'});
cfg.customPCCounts=[20 0 5];out=MIKey_config(cfg);assert(isequal(out.customPCCounts,[0 5 20]));
cfg=d;cfg.steps=12;cfg.filterFlag=false;cfg.lowFreq=struct('unused',1);
cfg.highFreq=false;cfg.sliceTimingTR=NaN;MIKey_config(cfg);
cfg.filterFlag=true;expectError(cfg,{'lowFreq','sliceTimingTR'});
cfg=d;cfg.steps=13;cfg.fcLabel=false;expectError(cfg,{'fcLabel'});
cfg=d;cfg.steps=15;cfg.clustROINums=[];cfg.maxIter=0;cfg.percentTop=2;
expectError(cfg,{'clustROINums','maxIter','percentTop'});
cfg=d;cfg.steps=16;cfg.voxelDownsampleFactor=0;expectError(cfg,{'voxelDownsampleFactor'});
cfg=d;cfg.steps=7;cfg.useDefaultTemplate=false;cfg.customTemplatePath='custom.nii';
cfg.templatePath=struct('unused',1);[cfg,active]=MIKey_config(cfg);assert(~active.templatePath);
cfg=d;cfg.steps=14;cfg.useCustomParc=true;cfg.parcNetwork=false;
cfg.networkCustomPath='network.nii';cfg.labelCustomPath='labels.nii';MIKey_config(cfg);
cfg=d;cfg.steps=15;cfg.groupNetworkPath='group.nii';cfg.useCustomParc=struct('unused',1);
cfg.parcNetwork=struct('unused',1);MIKey_config(cfg);
cfg=d;cfg.steps=13;cfg.fcLabel='Custom...';cfg.fcCustomPath=false;expectError(cfg,{'fcCustomPath'});
cfg=d;cfg.steps=1;cfg.fcLabel='296';cfg.parcNetwork='296rois';cfg=MIKey_config(cfg);
assert(strcmp(cfg.fcLabel,'296') && strcmp(cfg.parcNetwork,'296rois'));
cfg.steps=13;expectError(cfg,{'fcLabel'});
% The public parameter schema has no unaccounted fields and catches typos.
active=MIKey_parameter_scope(d);assert(isequal(sort(fieldnames(active)),sort(names)));
expectError(struct('steps',1,'misspelledParameter',1),{'Unknown parameter'},'MIKey:UnknownParameter');
result=struct('status','passed','inactiveTypeChecks',checks,'phases',{{'1','2:10'}});
disp(result);disp('MIKEY_CONFIG_SCOPES_PASS');
end

function expectError(input,messages,id)
if nargin<3,id='MIKey:Parameter';end
try
    MIKey_config(input);
catch ME
    assert(strcmp(ME.identifier,id),ME.message);
    for i=1:numel(messages),assert(contains(ME.message,messages{i}),ME.message);end
    return;
end
error('MIKey:Test','Expected selected-stage parameters to be rejected.');
end

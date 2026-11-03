function active = MIKey_parameter_scope(cfg)
% Single usage map for validation, preflight and batch control adaptation.
% cfg.steps must already be parsed. Invalid active switches are rejected by
% MIKey_config; predicates here never evaluate arbitrary inactive values.
names=fieldnames(MIKey_defaults());active=struct();
for i=1:numel(names),active.(names{i})=false;end
s=cfg.steps;
active=mark(active,{'bidsPath','spmPath','codePath','subjectFilter', ...
    'sessionFilter','taskFilter','runFilter','minTimepoints','steps', ...
    'dryRun','failFast','strictWarnings','logDir'},true);
active=mark(active,{'voxelScaleFactor'},any(ismember(s,[1 10])));
active=mark(active,{'sliceTimingTR'},ismember(4,s) || (ismember(12,s) && on(cfg.filterFlag)));
active=mark(active,{'sliceTimingNSlices','sliceTimingOrder'},ismember(4,s));
active=mark(active,{'coregInterp'},ismember(6,s));
active=mark(active,{'normInterp','useDefaultTemplate'},ismember(7,s));
active=mark(active,{'customTemplatePath'},ismember(7,s) && ~on(cfg.useDefaultTemplate));
active=mark(active,{'smoothFWHM'},ismember(8,s));
active=mark(active,{'useDefaultPCStrategy','fdMethod','fdRadius'},ismember(10,s));
active=mark(active,{'customPCCounts'},ismember(10,s) && ~on(cfg.useDefaultPCStrategy));
active=mark(active,{'detrendFlag','filterFlag'},ismember(12,s));
active=mark(active,{'lowFreq','highFreq'},ismember(12,s) && on(cfg.filterFlag));
active=mark(active,{'advRegressionPCOnly','advRegressionPCCSF', ...
    'advRegressionPCGS','advRegressionPCCSFGS'},any(ismember(s,12:16)));
active=mark(active,{'fcLabel'},ismember(13,s));
active=mark(active,{'fcCustomPath'},ismember(13,s) && textIs(cfg.fcLabel,'Custom...'));
parc=any(ismember(s,14:16));
active=mark(active,{'percentTop','maxIter','changeThr','confThr','useTSNR', ...
    'useInterSubjectVar','parcellationUseParallel','parcellationMode'},parc);
active=mark(active,{'clustROINums'},ismember(15,s));
active=mark(active,{'voxelDownsampleFactor'},ismember(16,s));
group=any(ismember(s,[15 16])) || (ismember(14,s) && on(cfg.useInterSubjectVar));
active=mark(active,{'groupNetworkPath'},group);
groupFallback=group && ~hasText(cfg.groupNetworkPath);
active=mark(active,{'useCustomParc'},ismember(14,s) || groupFallback);
active=mark(active,{'parcNetwork'}, ...
    (ismember(14,s) || groupFallback) && ~on(cfg.useCustomParc));
active=mark(active,{'networkCustomPath'}, ...
    (ismember(14,s) || groupFallback) && on(cfg.useCustomParc));
active=mark(active,{'labelCustomPath'},ismember(14,s) && on(cfg.useCustomParc));
active=mark(active,{'templatePath'},any(ismember(s,[3 10 12 13 14 15 16 17])) || ...
    (ismember(7,s) && on(cfg.useDefaultTemplate)));
end

function active=mark(active,names,used)
if used
    for i=1:numel(names),active.(names{i})=true;end
end
end

function value=on(value)
value=(islogical(value) || isnumeric(value)) && isreal(value) && ...
    isscalar(value) && isfinite(value) && value==1;
end

function value=textIs(value,expected)
value=(ischar(value) && size(value,1)<=1 || isstring(value) && isscalar(value)) && ...
    strcmp(value,expected);
end

function value=hasText(value)
value=(ischar(value) && size(value,1)<=1 || isstring(value) && isscalar(value)) && ...
    ~isempty(strtrim(char(value)));
end

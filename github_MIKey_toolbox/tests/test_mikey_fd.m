function test_mikey_fd
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));
% Known motion: offsets disappear, backward differences have known lengths.
rp=[10 20 30 .4 .5 .6;13 24 30 .4 .5 .6;13 24 42 .4 .5 .6;13 24 42 .4 .55 .6];
[power,p]=MIKey_framewise_displacement(rp,'power',100);
[euclidean,e]=MIKey_framewise_displacement(rp,'euclidean',100);
assert(max(abs(power-[0;7;12;5]))<1e-12);
assert(max(abs(euclidean-[0;5;12;5]))<1e-12);
[small,~]=MIKey_framewise_displacement(rp,'euclidean',20);
assert(max(abs(small-[0;5;12;1]))<1e-12);
assert(strcmp(p.method,'power') && strcmp(e.method,'euclidean') && e.correlationStartFrame==2);
shift=rp+repmat([100 -50 20 .2 -.3 .1],4,1);
assert(max(abs(MIKey_framewise_displacement(shift,'power',100)-power))<1e-11);
% Central gradients differ from this backward-difference result.
[~,central]=gradient(rp);central(:,4:6)=central(:,4:6)*100;
assert(norm(sqrt(sum(central.^2,2))-euclidean)>1);
fd=[0;1;3;2;5];dv=[1e6;3;2;7;4];
expected=corr(fd(2:end),dv(2:end));
assert(abs(MIKey_fd_dvars_correlation(fd,dv)-expected)<1e-12);
expect(@()MIKey_fd_dvars_correlation(zeros(5,1),dv),'MIKey:FDCorrelation');
expect(@()MIKey_framewise_displacement(rp(:,1:5),'power',100),'MIKey:MotionParameters');
expect(@()MIKey_framewise_displacement(rp,'power',0),'MIKey:FDRadius');
expect(@()MIKey_framewise_displacement(rp,'squared',100),'MIKey:FDMethod');
% A later global minimum must beat an earlier local minimum.
CC=[.8 -.2 .4 -.05 .3;-.8 .2 -.4 .05 -.3];
[best,meanAbs,meanSigned]=MIKey_select_noise_strategy(CC);
assert(best==4 && max(abs(meanAbs-[.8 .2 .4 .05 .3]))<1e-12);
assert(all(meanSigned==0));
assert(MIKey_select_noise_strategy([.2 -.2 .3])==1); % Deterministic tie.
expect(@()MIKey_select_noise_strategy([1 NaN]),'MIKey:StrategyResults');
for method={'power','euclidean'}
 c=MIKey_config(struct('steps',10,'fdMethod',method{1},'fdRadius',80));
 state=MIKeyBatchState(c,-1);assert(strcmp(state.UserData.fdMethodSetting.Value,method{1}));
 assert(state.UserData.fdRadiusSetting.Value==80);
end
MIKey_config(struct('steps',1,'fdMethod',struct(),'fdRadius',NaN));
MIKey_config(struct('steps',11,'fdMethod',struct(),'fdRadius',NaN));
expect(@()MIKey_config(struct('steps',10,'fdMethod','bad','fdRadius',0)),'MIKey:Parameter');
disp('MIKEY_FD_PASS');
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end

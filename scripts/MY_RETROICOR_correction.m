function MY_RETROICOR_correction(NIIfilename,Phyfilename,BW,TR)

% Matlab implementation of RETROICOR correction algorithm

% Function inputs:
% NIIfilename: pointer to file containing 4D functional MRI data
% Phyfilename: pointer to file containing recorded physiological data
% BW: 3D binary number matrix (ROI for Analysis)

% Function outputs:
% s_bold_t_series_phys: corrected BOLD series data
% s_noise_phys: voxel-wise physiological noise components
% adjRsq: matrix containing adjusted R squared values

% -------------------------------------------------------------------------
% Modified by Trange (Chuanjun Tong) 2019Oct.18 Shanghai
% -------------------------------------------------------------------------

% Script to perform modified RETROICOR correction on BOLD image data
% Compiled by Tess Wallace (Department of Radiology, University of Cambridge)

% -------------------------------------------------------------------------
% Load nii images
% -------------------------------------------------------------------------
info = spm_vol(NIIfilename);

vox = sqrt(sum(info(1).mat(1:3,1:3).^2));

dicom_header.xdim = info(1).dim(1);
dicom_header.ydim = info(1).dim(2);
dicom_header.zdim = info(1).dim(3);
dicom_header.tdim = numel(info);
dicom_header.PixelSpacing = vox(1:2);
dicom_header.SliceThickness = vox(3);
dicom_header.TR = TR;

% -------------------------------------------------------------------------
% Perform RETROICOR
% -------------------------------------------------------------------------
% Define start of scan relative to physiological data acquisition
start_time = 0; % ms

% Fifth order Fourier series calculated to model cardiac (C) and
% respiratory (R) phases
% Four multiplicative (X) terms calculated
[design_matrix, TR_phs, H] = mod_retroicor(Phyfilename, start_time, dicom_header);
stage = strsplit(info(1).fname,'\');
imwrite(H, fullfile(stage{1:end-1},'RETROICOR.tif'));
% -------------------------------------------------------------------------
% Perform Linear Regression using GLM
% -------------------------------------------------------------------------
HW_flag = 1; % 1: linear, 2: quadratic polynomial to correct for drift
retroicor_flag = 1; % 0: off, 1: on

% Specify order of RETROICOR correction e.g. 2R2C1X
order.C = 2; % nth order cardiac (C=0-5)
order.R = 2; % nth order respiratory (R=0-5)
order.X = 1; % n multiplicative terms (X=0-4)

s_bold_t_series = spm_read_vols_4D(info);
[s_bold_t_series_phys, s_noise_phys, adjRsq] = glm_regression(s_bold_t_series, design_matrix, order, dicom_header, BW, HW_flag, retroicor_flag);
clear s_bold_t_series


for i = 1:numel(info)
    stage = strsplit(info(i).fname,'\');
    stage{end} = strcat('G',stage{end});
    info(i).fname = fullfile(stage{:});
end
spm_write_vol_4D(info,s_bold_t_series_phys);

for i = 1:numel(info)
    stage = strsplit(info(i).fname,'\');
    info(i).fname = fullfile(stage{1:end-1},'RETROICOR_noise.nii');
end
spm_write_vol_4D(info,s_noise_phys);

Info = info(1);
stage = strsplit(Info.fname,'\');
Info.fname = fullfile(stage{1:end-1},'RETROICOR_R2.nii');
Info.dt = [16 0];
spm_write_vol(Info,adjRsq);

end

function [design_matrix, TR_phs, H] = mod_retroicor(Phyfilename,  start_time, dicom_header)

% Matlab implementation of RETROICOR correction algorithm
% Adapted from http://cbi.nyu.edu/software/

% Function inputs:
% Phyfilename: pointer to file containing recorded physiological data
% start_time: start time of scan relative to beginning of physiological
% data recording
% dicom_header: struct containing relevant DICOM header information

% Function outputs:
% design_matrix: matrix of cardiac (C), respiratory (R) and
% multiplicative (X) sine and cosine terms, based on the C and R phases
% at each image time point
% TR_phs: C and R phases at each image time point

order = 5; % nth order correction

% -------------------------------------------------------------------------
% Read in physiological data
% -------------------------------------------------------------------------

R = lvm_import(Phyfilename,0);

% Define sample rate
PPGsr = R.Segment1.num_samples(1); %sample rate in ms
RESPsr = R.Segment1.num_samples(3); %sample rate in ms

% find trigger
trigger = R.Trig;
trigger_norm = imbinarize(trigger,(max(trigger)+min(trigger))/2);
RAM = find(diff(trigger_norm)<0);

RESPData = R.Resp(RAM(end):end);
PPGData = R.ECG(RAM(end):end);

[b,a]=butter(8,0.1);
RESPData = filtfilt(b,a,RESPData);
[b,a]=butter(8,0.25);
PPGData = filtfilt(b,a,PPGData);


if strcmp(R.ECGTXT,'ECGwave OFF');PPGData=ones(size(PPGData));end

fclose('all');


tPPG = PPGsr*(1:1:length(PPGData));
tRESP = RESPsr*(1:1:length(RESPData));

h1=figure;
subplot(2,1,1);
plot(tPPG(1:1000), PPGData(1:1000));

title('PPG Trace');
xlabel('Time (ms)');
subplot(2,1,2);
plot(tRESP(1:1000), RESPData(1:1000));
title('RESP Trace');
xlabel('Time (ms)');

dt = 1/PPGsr;

%Find TR times
TR_len = dicom_header.TR/1000*PPGsr; % ms
numTR = dicom_header.tdim;
TR_start = start_time/PPGsr + (0:TR_len:((numTR-1)*TR_len)); %in samples

%% ------------------------------------------------------------------------
% Compute Cardiac Phase
% -------------------------------------------------------------------------

h2=figure;
subplot(2,1,1);
plot(1:1:length(PPGData), PPGData);
hold;
pulse_axis = axis;
for i=1:numTR
    plot([TR_start(i) TR_start(i)],pulse_axis(3:4),'g');
end

% smp = 1:1:length(PPGData);

% Find peaks in pulse
% lm = local_max(PPGData);
[~,c_peaks] = findpeaks(PPGData,'MinPeakHeight',mean(PPGData)+std(PPGData),'MinPeakDistance',10);

% c_peaks = smp(lm);
plot(c_peaks,PPGData(c_peaks),'r.');

% const=input('Enter threshold for peak detection: ','s');
% const = str2double(const);
const = -1;

pulse_mean = mean(PPGData);
plot([0 length(PPGData)],[const+pulse_mean const+pulse_mean],'y');
rmpk1 = find(PPGData(c_peaks) < pulse_mean+const);
plot(c_peaks(rmpk1),PPGData(c_peaks(rmpk1)),'k.');

%manual peak editing
% medit=input('Manual Edit (y/n)? ','s');
medit= 'n';

if medit == 'y'
    dch=datacursormode;
    set(dch,'DisplayStyle','datatip','SnapToDataVertex','on');
    mp_count=0; getpoints=1;
    while getpoints
        cont=1;
        cont=input('Click on a datapoint to remove, then hit enter. Type 0 when done:');
        if ~cont
            disp('Done!');
            getpoints = 0;
        else
            mp_count=mp_count+1;
            dcinfo = getCursorInfo(dch);
            man_points(mp_count) = dcinfo.DataIndex;
            delete(findall(gca,'Type','hggroup','HandleVisibility','off'));
            plot(c_peaks(man_points(mp_count)),PPGData(c_peaks(man_points(mp_count))),'c.');
        end
    end
    delete(findall(gca,'Type','hggroup','HandleVisibility','off'));
    plot(c_peaks(man_points),PPGData(c_peaks(man_points)),'k.');
    rmpk = union(rmpk1,man_points);
else
    rmpk = rmpk1;
end

c_peaks = setdiff(c_peaks,c_peaks(rmpk));
if strcmp(R.ECGTXT,'ECGwave ON')
    for i=1:length(PPGData)
        if i < c_peaks(1)
            c_phs(i) = NaN;
        elseif i >= c_peaks(end)
            c_phs(i) = NaN;
        else
            prev_peak = max(find(c_peaks <=i));
            t1 = c_peaks(prev_peak);
            t2 = c_peaks(prev_peak+1);
            c_phs(i) = 2*pi*(i - t1)/(t2-t1); %find cardiac phase for each acquisition
        end
    end
else
    c_phs = zeros(size(PPGData));
end
plot(c_phs,'m');
xlabel('Samples');
title('Computing Cardiac Phase');
ylabel('mV');
axis([3000 4000 -Inf Inf]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(c_phs)-1<max(TR_start)
    c_phs(end+1:max(TR_start)+1)=c_phs(end);
end
if numel(PPGData)-1<max(TR_start)
    PPGData(end+1:max(TR_start)+1)=PPGData(end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TR_phs(:,1) = c_phs(TR_start+1);
subplot(2,1,2);
scatter(TR_phs(:,1),PPGData(TR_start+1));
xlabel('Phase in Cardiac Cycle (Radians)');
ylabel('mV');
axis([0 2*pi -Inf Inf]);

% Fit nth order fourier series to estimate phase
for i = 1:order
    dm_c_phs(:,(i*2)-1) = cos(i*TR_phs(:,1));
    dm_c_phs(:,i*2) = sin(i*TR_phs(:,1));
end

h3=figure;
imagesc(dm_c_phs);
colormap(gray);
title({'Design Matrix (C)';'Cardiac'});

%% ------------------------------------------------------------------------
% Compute Respiratory Phase
% -------------------------------------------------------------------------

% Normalize to range of 0 to 1
resp_range = range(RESPData);
resp_norm = (RESPData - min(RESPData) ) / resp_range;

h4=figure;
subplot(3,1,1);
plot(resp_norm);
hold;

% Histogram-equalized transfer function between respiratory amplitude and
%resp phase
nbins = 100;
[resp_hist,bins] = hist(resp_norm,nbins);
resp_transfer_func = [0 (cumsum(resp_hist) / sum(resp_hist))];
kern_size = 1/dt - 1;
resp_smooth = conv(resp_norm,ones(kern_size,1),'same'); %smoothed version for taking derivative
resp_diff = [diff(resp_smooth);0]; %derivative dR/dt
r_phs = pi*resp_transfer_func(round(resp_norm * nbins)+1)' .* sign(resp_diff);

plot(resp_smooth / max(resp_smooth),'g'); %plot smoothed version
% axis([0 length(resp_norm) 0 1]);
axis([3000 4000 0 1]);

subplot(3,1,2);
plot(r_phs,'m');
hold;
for i=1:numTR
    plot([TR_start(i) TR_start(i)],[-pi pi],'g');
end
% axis([0 length(r_phs) -pi pi]);
axis([0 1000  -pi pi]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(r_phs)-1<max(TR_start)
    r_phs(end+1:max(TR_start)+1)=r_phs(end);
end
if numel(resp_norm)-1<max(TR_start)
    resp_norm(end+1:max(TR_start)+1)=resp_norm(end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get TR phase
TR_phs(:,2) = r_phs(round(TR_start+1));
subplot(3,1,3);
scatter(TR_phs(:,2),resp_norm(round(TR_start+1)));
axis([-pi pi 0 1]);
xlabel('Phase in Respiratory Cycle (Radians)');
ylabel({'Normalized Respiration';'Belt (norm V) '});

% Fit nth order fourier series to estimate phase
for i = 1:order
    dm_r_phs(:,(i*2)-1) = cos(i*TR_phs(:,2));
    dm_r_phs(:,i*2) = sin(i*TR_phs(:,2));
end

h5=figure;
imagesc(dm_r_phs);
colormap(gray);
title({'Design Matrix (R)';'Respiratory'});

%% ------------------------------------------------------------------------
% Compute Multiplicative Terms
% -------------------------------------------------------------------------

i=1;
for C = 1:2
    for D = 1:2
        dm_cr_phs(:,(i*4)-3) = sin(C*TR_phs(:,1)+D*TR_phs(:,2));
        dm_cr_phs(:,(i*4)-2) = cos(C*TR_phs(:,1)+D*TR_phs(:,2));
        dm_cr_phs(:,(i*4)-1) = sin(C*TR_phs(:,1)-D*TR_phs(:,2));
        dm_cr_phs(:,(i*4)) = cos(C*TR_phs(:,1)-D*TR_phs(:,2));
        i=i+1;
    end
end

h6=figure;
imagesc(dm_cr_phs);
colormap(gray);
title({'Design Matrix (X)';'multiplicative - sine and cosine terms'});

%% ------------------------------------------------------------------------
% Assign output design matrix
% -------------------------------------------------------------------------

design_matrix = [dm_c_phs dm_r_phs dm_cr_phs];

% fin=input('Hit Enter to close plots and exit');

print(h1,'-dtiff','h1');H1 = imread('h1.tif');
print(h2,'-dtiff','h2');H2 = imread('h2.tif');
print(h3,'-dtiff','h3');H3 = imread('h3.tif');
print(h4,'-dtiff','h4');H4 = imread('h4.tif');
print(h5,'-dtiff','h5');H5 = imread('h5.tif');
print(h6,'-dtiff','h6');H6 = imread('h6.tif');

H = [H1 H2 H3;H4 H5 H6];

close([h1 h2 h3 h4 h5 h6]);
delete('h*.tif');
end


function [s_bold_t_series_phys, yDelta, adjRsq ] = glm_regression(s_bold_t_series, design_matrix, order, dicom_header, BW, HW_flag, retroicor_flag)

% GLM regression to perform RETROICOR correction

% Function inputs:
% s_bold_t_series: 3D matrix containing dynamic BOLD series data
% design_matrix: matrix containing sine and cosine terms calcualted
% from mod_retroicor
% order: struct containing order of C, R and X terms to include in
% regression analysis
% dicom_header: struct containing key dicom info
% BW: mask of region to include in analysis
% HW_flag: specifies linear (1) or quadratic (2) HW regressor
% retroicor_flag: RETROICOR correction on (1) or off (0)

% Function outputs:
% s_bold_t_series_phys: corrected BOLD series data
% yDelta: voxel-wise physiological noise components
% adjRsq: matrix containing adjusted R squared values

% YDelta = zeros(dicom_header.ydim*dicom_header.xdim*dicom_header.zdim, dicom_header.tdim);
%
% S_bold_t_series_phys = zeros(size(YDelta));
%
% adjRsq = zeros(dicom_header.ydim, dicom_header.xdim);

design_matrix(isnan(design_matrix)) = 0;

t_i=(1:1:dicom_header.tdim)';

T_design_matrix = array2table(design_matrix,'VariableNames',{'ac1', 'bc1', 'ac2', 'bc2', 'ac3', 'bc3', 'ac4','bc4','ac5','bc5', 'ar1', 'br1', 'ar2', 'br2', 'ar3', 'br3','ar4','br4','ar5','br5', 'x111','x112','x113','x114','x211','x212','x213','x214','x121','x122','x123','x124','x221','x222','x223','x224'});

if retroicor_flag == 1
    % Modify design_matrix and T_design_matrix based on specified order
    if order.X == 0
        if order.C == 0
            T_design_matrix_mod = T_design_matrix(:,[11:(10+2*order.R)]); % just R terms
        elseif order.R == 0
            T_design_matrix_mod = T_design_matrix(:,[1:(2*order.C)]); % just C terms
        else
            T_design_matrix_mod = T_design_matrix(:,[1:(2*order.C),11:(10+2*order.R)]); % just CR terms
        end
    else
        if order.C == 0
            T_design_matrix_mod = T_design_matrix(:,[11:(10+2*order.R),21:(20+4*order.X)]); % just RX terms
        elseif order.R == 0
            T_design_matrix_mod = T_design_matrix(:,[1:(2*order.C),21:(20+4*order.X)]); % just CX terms
        else
            T_design_matrix_mod = T_design_matrix(:,[1:(2*order.C),11:(10+2*order.R),21:(20+4*order.X)]); % CRX terms
        end
    end
    
    design_matrix_mod = table2array(T_design_matrix_mod);
end

%{
y = fmask(s_bold_t_series,BW);

y(isnan(y))=0;

c = cell(size(y,1),1);
for i = 1:size(y,1);   c{i}=y(i,:); end

l = dicom_header.tdim;

bold = cellfun(@(x) polyfit(t_i',x,1), c, 'UniformOutput',false);

HW = cellfun(@(x) x(2)+x(1)*t_i, bold, 'UniformOutput',false);

ext_m = cellfun(@(x) [ones(l,1),x,design_matrix_mod], HW, 'UniformOutput',false); clear HW

Tglm = cellfun(@(x,y) [x,y'], ext_m,c, 'UniformOutput',false); clear c

[Beta,~,Residual,~,STATS] = cellfun(@(x) regress(x(:,end),x(:,1:end-1)), Tglm, 'UniformOutput',false);
     
b=zeros(size(y,1),size(T_design_matrix_mod,2)+2);
for i=1:size(b,1);b(i,:)=Beta{i}';end

re=zeros(size(y));
for i=1:size(re,1);re(i,:)=Residual{i};end

R2=zeros(size(y,1),1);
for i=1:size(R2,1);R2(i,:)=STATS{i}(1);end


w = cellfun(@(x,y) sum(repmat(x', l ,1).*y,2), Beta,ext_m, 'UniformOutput',false);

Y = zeros(size(y));
for i=1:size(Y,1);Y(i,:)=w{i};end


s_bold_t_series_phys = funmask(y-Y, BW);
adjRsq = funmask(R2,BW);
yDelta = funmask(Y, BW);
%}




%
s_reshape = fmask(s_bold_t_series,BW);

YDelta = zeros(size(s_reshape));
S_bold_t_series_phys = zeros(size(YDelta));
AdjRsq = zeros(numel(find(BW==1)),1);

for i = 1:size(s_reshape,1)
    
    y=squeeze(s_reshape(i,:));
    
    y(isnan(y))=0;
    test_signal = y(:) - mean(y);
    
    
    if ~isempty(find(test_signal)~=0)
        
        T_sig = table(test_signal,'VariableNames',{'BOLD_Signal'});
        
        if HW_flag == 1
            
            p1 = polyfit(t_i,test_signal,1);
            
            HW = p1(2) + p1(1)*t_i;
            
        elseif HW_flag == 2
            
            p2 = polyfit(t_i,test_signal,2);
            
            HW = p2(3) + p2(2)*t_i + p2(1)*t_i.^2;
            
        end
        
        T_HW = array2table(HW, 'VariableNames', {'HW2'});
        
        if retroicor_flag == 1
            
            T_regressors = [T_HW T_design_matrix_mod];
            
            ext_design_matrix = [ones(dicom_header.tdim,1) HW design_matrix_mod];
            
        else
            
            T_regressors = T_HW;
            
            ext_design_matrix = [ones(dicom_header.tdim,1) HW];
            
        end
        
        
        
        T_glm = [T_regressors T_sig];
        
        mdl = fitlm(T_glm,'linear');
        
        coef_tbl = mdl.Coefficients(:,1);
        
        coefvals = table2array(coef_tbl)';
        
        coefvals = repmat(coefvals, dicom_header.tdim ,1);
        
        YDelta(i,:) = sum(coefvals.*ext_design_matrix,2);
        
        AdjRsq(i,:) = mdl.Rsquared.Adjusted;
        
        S_bold_t_series_phys(i,:) = y - squeeze(YDelta(i,:));
    end
end

yDelta = funmask(YDelta,BW);
adjRsq = funmask(AdjRsq,BW);
s_bold_t_series_phys = funmask(S_bold_t_series_phys,BW);

%}
end

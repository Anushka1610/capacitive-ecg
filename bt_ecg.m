clear all;
close all;
clc;

%CHANGES
% fscanf (%f) vs fread
% initialize array size beforehand (no dynamic sizing)
% moved from softwareserial to actual serial for BT
%Name of device and number of data that will be sent
b = Bluetooth('H-C-2010-06-01',1);

%Opening communication port for Bluetooth
fopen(b);

%%
% close all;
clear V;
clear T;

EKG=zeros(1,2000);
a=zeros(1,1000);
p=0;
for i=1:2000
    EKG(i)=fscanf(b,'%f',1);
end

% This section of code is used to read the data in real time, like a serial
% monitor. To use this comment out the above while loop and the below time
% loop.
% i=1;
% close all;
% figure(1);
% hold on;
%
% while(1)
%     i=i+1;
%         EKG=fscanf(b,'%f',1);
%         %plot(i,EKG/1000.0);
%         plot(i,EKG/1000.0,'o','markersize',3);
%         drawnow;
% end


%fclose(b);       %With this command we close Bluetooth communication port

% we now have our ECG signal in V

 %Now we mostly use code from ECG

EKG = EKG(5:end);       % remove transient (incorrect) serial output

while EKG(1) > 10000
    EKG = EKG(2:end)    % remove unmatched timestamp from start
end

while EKG(end) < 10000
    EKG = EKG(1:end-1)  % remove unmatched voltage from end
end

% split mixed array into voltage and time arrays
V = EKG(1:2:end);
T = EKG(2:2:end);

V = V(125:end);
T = T(125:end);

T = T - T(1);
k=T;
% chop off first 8th of signal (remove transient discontinuities)

% subtract t0 from every element in T

V = V./1000.0;


% convert time array to seconds (from microseconds)
k = k./1000000.0;

% V = EKG()./1000.0; % convert values to V
% k=a;
% % to chop off the abrupt peak in 1st second
% V = V(125:end);
% k = k(125:end);

figure
plot(k,V)
title('ECG Signal')
xlabel('Time [second]');
ylabel('Voltage [V]')
grid on

%%
% Step 2: Detrend the ECG Signal

% [p,S,mu] = polyfit(x,y,n) returns the coefficients for a polynomial p(x)
%of degree n that is a best fit for the data in y.
%Structure S is used as an input to polyval to obtain error estimates.
%mu is a two-element vector with centering and scaling values.
%mu(1) is mean(x), and mu(2) is std(x)using which,
%polyfit centers x at zero and scales it to have unit
%standard deviation.
[p,s,mu] = polyfit((1:numel(V)),V,6);
f_y = polyval(p,(1:numel(V)),[],mu);
ECG_detrended = V - f_y;        % Detrend data
figure
plot(k,ECG_detrended)
title('Detrended ECG Signal')
xlabel('Time [second]');
ylabel('Voltage [V]')
grid on

%%
% Step 3: Apply low pass filtering to the ECG Signal

% Designs an IIR LPF of order 2, passband frequency 20 Hz at a sample rate
%of 150 Hz and passband ripple of 0.2 dB. We should have a normalized
%frequency between 0-1.0 for MATLAB.
lpFilt = designfilt('lowpassiir','FilterOrder',2, ...
         'PassbandFrequency',20,'PassbandRipple',0.2, ...
         'SampleRate',150);
ECG_data_LP = filtfilt(lpFilt,ECG_detrended);
figure
plot(k,ECG_data_LP)
title('ECG Signal: Detrended, LP Filtering')
xlabel('Time [second]');
ylabel('Voltage [V]')
grid on
fvtool(lpFilt) %frequency response of filter
%%
% Step 4: Apply high pass filtering to the ECG Signal

% % Designs an IIR HPF of order 2, passband frequency 0.5 Hz passband ripple
%of 0.2 dB and sample rate of 20 Hz.
hpFilt = designfilt('highpassiir','FilterOrder',2, ...
         'PassbandFrequency',0.5,'PassbandRipple',0.2, ...
         'SampleRate',20);
ECG_data_HP = filtfilt(hpFilt ,ECG_data_LP);
figure
plot(k,ECG_data_HP)
title('ECG Signal: Detrended, LP & HP Filtering')
xlabel('Time [second]');
ylabel('Voltage [V]')
grid on
fvtool(hpFilt) %frequency response of filter

%%
% Step 5: Apply notch filtering to the ECG Signal (Notch frequency = 60 Hz)

% Designs a bandstop Butterworth IIR filter of order 2,
%passband frequencies 59 Hz and 61 Hz, sample rate of 1000 Hz.
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',1000);
ECG_data_notched = filtfilt(d,ECG_data_HP);
figure
plot(k,ECG_data_notched)
title('ECG Signal: Detrended, LP/HP/Notch Filtering')
xlabel('Time [second]');
ylabel('Voltage [V]')
grid on
fvtool(d)  %frequency response of filter
%%
% Step 6: Identify the R peaks of the ECG waveforms
% [pk,locs]=findpeaks(ECG_data_notched,k,'MinPeakHeight',0.15,'MinPeakDistance',0.65);
%  figure
%  findpeaks(ECG_data_notched,k,'MinPeakHeight',0.15,'MinPeakDistance',0.65);
%  R_count=length(pk);

% Step 6 Alt: alternative, slightly safer method of R-peak detection
%             (doesn't yet implement minimum-distance removal; that's why
               it's not the default method)
% rpk_thresh = 0.15;
% % find highest value in signal (an R-peak)
% highest_peak = max(ECG_data_notched);
% % all indices with a value within a certain threshold of the max R-value
% pk = ECG_data_notched(highest_peak - ECG_data_notched < rpk_thresh)
% locs_Rwave = find(highest_peak - ECG_data_notched < rpk_thresh)
% r_count=numel(locs_Rwave);
% get time vals by accessing time array for locs_Rwave indices
% (IE locs_Rwave are the same for the time array)

% loop through peak list and remove any below minimum distance
%for i=[locs_Rwave';locs_Rwave(2:end)']


%%


% Step 7: Calculate the heart rate variability of the patient.
% HRV: Total time passed on the x axis. Time between last R peak detection
% on the y axis.

differences = diff(locs); % Find the time differences between the R waves.
t_diff = locs(2:end); % linspace(0,65775,R_count-1)
% Plot the HRV based upon the ECG signal.
figure
plot(t_diff,differences)
title('HRV')
xlabel('Time [second]');
ylabel('Time Difference [second]')
grid on

% Step 8: Calculate the heart beat rate for the ECG signal.
diff=locs(8)-locs(1);
bpm = (R_count/diff)*60;  % counts per second, * 60

% Step 9:
% run the sgolay filter upon the ECG signal.
% Savitzy-Golay filter is used as it smoothens the signal and preserves the
% shape of the signal which is vital for an ECG signal.

smoothECG = sgolayfilt(ECG_data_notched,4,21);

figure
plot(k,ECG_data_notched,'b',k,smoothECG,'r')
grid on
axis([2.5 8.5 -1 0.7])
xlabel('Time[s]')
ylabel('Voltage(V)')
legend('Pre-SG ECG Signal','SG-Filtered Signal')
title('SG Filtering Noisy ECG Signal')

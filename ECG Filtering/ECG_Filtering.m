clear all; close all; clc;

% Load ecg data
ecg = importdata('ecg_sample.txt');
fs = 500;           % sampling frequency [Hz]
N = length(ecg);    % number of samples
n = 0:N-1;          % sample array
t = n/fs;           % time axis [s]


%% Plot ecg in time domain
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
plot(t, ecg)
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;


%% spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nfft = 2^12;
Sa = 20*log10(abs(fft(ecg,nfft)));
farr = (0:nfft-1)*fs/nfft;

figure(2)
plot(farr,Sa);
xlabel('Frequency (Hz)');ylabel('Amplitude (dB)')
grid on;
ylim([-20 55])
xlim([0 250]);


%% notch filter: fs 500Hz, notch 50Hz, Q 1.5, A 0.5dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('notch_filter.mat');

ecg_filt1 = filtfilt(b,a,ecg);
Sa2 = 20*log10(abs(fft(ecg_filt1,nfft)));

figure(3)
plot(farr,Sa,farr,Sa2);
xlabel('Frequency (Hz)');ylabel('Amplitude (dB)')
grid on;
ylim([-20 55])
xlim([0 250]);

figure(4)
plot(t,ecg,t,ecg_filt1);
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;


%% low pass filter: fs 500Hz, Fpas 100Hz, Fstop 150Hz, Apass 0.5dB, Astop 70dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('lowpass_filter.mat');

ecg_filt2 = filtfilt(b,a,ecg_filt1);
Sa3 = 20*log10(abs(fft(ecg_filt2,nfft)));

figure(4)
plot(t,ecg_filt1,t,ecg_filt2);
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;

figure(5)
plot(farr,Sa,farr,Sa3);
xlabel('Frequency (Hz)');ylabel('Amplitude (dB)')
grid on;
ylim([-40 55])
xlim([0 250]);


%% high pass filter: fs 500Hz, Fpas 3Hz, Fstop 1Hz, Apass 0.5dB, Astop 60dB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('highpass_filter.mat');

ecg_filt3 = filtfilt(b,a,ecg_filt2);
Sa4 = 20*log10(abs(fft(ecg_filt3,nfft)));

figure(7)
plot(t,ecg,t,ecg_filt3);
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;

figure(8)
plot(farr,Sa,farr,Sa4);
xlabel('Frequency (Hz)');ylabel('Amplitude (dB)')
grid on;
ylim([-40 55])
xlim([0 250]);



%% Heart Beat Rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(8)
plot(t,ecg_filt3);
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;

% use threshold
tr = 0.6;
trLine = ones(1,N)*tr;

figure(9)
plot(t,ecg_filt3,t,trLine);
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;

squares = [];
for j=1:N
   if ecg_filt3(j)>tr
       squares(j)=1;
   else
       squares(j)=0;
   end
end

figure(9)
plot(t,ecg_filt3,t,squares,t,trLine);
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;

% use peaks
[pks,locs] = findpeaks(ecg_filt3,'MinPeakHeight',tr);

figure(10)
plot(t,ecg_filt3,t(locs),pks,'o');
xlabel('Time (s)');ylabel('Amplitude (V)')
grid on;

hb = 60./diff(t(locs));
vid = mean(hb)

figure(11)
plot(hb);
xlabel('Beats (A.U.)');ylabel('Heart Beat (bpm)')
grid on;


%% langai
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pries = 60;
po = 100;
arr=[];
[~,locs] = findpeaks(ecg_filt3,'MinPeakHeight',0.6);
for j=1:length(locs)
    index = locs(j);
    arr(j,:) = ecg_filt3(index-pries:index+po);
end

figure(100)
mesh(arr)
colormap(cool)
xlabel('Time (s)');
ylabel('ECG No')
zlabel('Amplitude (V)')



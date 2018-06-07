% wav white noise script
Fs = 88200; % Sampling frequency
FilterFreq=[ 1000 40000 ]; % Range of frequencies for the noise
Time = 110; % time in seconds;
Noise = rand(length(0:1/Fs:Time),1)-.5;
[b a] = butter(4,FilterFreq/Fs);
FiltNoise=filtfilt(b,a,Noise);
%%
% Ramping Sound
RampTime = 2; % ramping time in seconds
RampUp = (0:1/Fs:RampTime)/RampTime;
RampDown = (RampTime:-1/Fs:0)/RampTime;

FiltNoise(1:length(RampUp))=FiltNoise(1:length(RampUp)).*RampUp';
FiltNoise(length(FiltNoise)-length(RampDown)+1:length(FiltNoise))=FiltNoise(length(FiltNoise)-length(RampDown)+1:length(FiltNoise)).*RampDown';
%%
% save wav file
NormFiltNoise=FiltNoise*max(abs(FiltNoise));

audiowrite('default.wav',NormFiltNoise,Fs)
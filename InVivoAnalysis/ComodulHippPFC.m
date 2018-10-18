%ChannelsReg = [PFC_ch VH_ch DH_ch];

figure(101)

GTitle = ['vHipp - dHipp'];
PlotNo = 4;

lfpPhase = data1000(:,10)';
lfpAmp = data1000(:,9)';

% xlim([0 1000])
% set(gca,'fontsize',14)
% xlabel('time (ms)')
% ylabel('mV')

data_length=length(lfpAmp);
srate=1000;

% Define the Amplitude- and Phase- Frequencies

PhaseFreqVector=0:1:20;
AmpFreqVector=10:5:200;

PhaseFreq_BandWidth=4;
AmpFreq_BandWidth=10;

% For comodulation calculation (only has to be calculated once)

nbin = 18;
position=zeros(1,nbin); % this variable will get the beginning (not the center) of each phase bin (in rads)
winsize = 2*pi/nbin;
for j=1:nbin 
    position(j) = -pi+(j-1)*winsize; 
end

% Do filtering and Hilbert transform on CPU

'CPU filtering'
tic
Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);

for ii=1:length(AmpFreqVector)
    Af1 = AmpFreqVector(ii);
    Af2=Af1+AmpFreq_BandWidth;
    AmpFreq=eegfilt(lfpAmp,srate,Af1,Af2); % just filtering
    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
end

for jj=1:length(PhaseFreqVector)
    Pf1 = PhaseFreqVector(jj);
    Pf2 = Pf1 + PhaseFreq_BandWidth;
    PhaseFreq=eegfilt(lfpPhase,srate,Pf1,Pf2); % this is just filtering 
    PhaseFreqTransformed(jj, :) = angle(hilbert(PhaseFreq)); % this is getting the phase time series
end
toc

'Comodulation loop'

counter1=0;
for ii=1:length(PhaseFreqVector)
counter1=counter1+1;

    Pf1 = PhaseFreqVector(ii);
    Pf2 = Pf1+PhaseFreq_BandWidth;
    
    counter2=0;
    for jj=1:length(AmpFreqVector)
    counter2=counter2+1;
    
        Af1 = AmpFreqVector(jj);
        Af2 = Af1+AmpFreq_BandWidth;
        [MI,MeanAmp]=ModIndex_v2(PhaseFreqTransformed(ii, :), AmpFreqTransformed(jj, :), position);
        Comodulogram(counter1,counter2)=MI;
    end
end
toc

% Graph comodulogram

%clf
subplot(2,2,PlotNo),
contourf(PhaseFreqVector+PhaseFreq_BandWidth/2,AmpFreqVector+AmpFreq_BandWidth/2,Comodulogram',30,'lines','none')
set(gca,'fontsize',14)
title(GTitle)
ylabel('Amplitude Frequency (Hz)')
xlabel('Phase Frequency (Hz)')
colorbar


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Use the routine below to look at specific pairs of frequency range:
% 
% Pf1 = 4
% Pf2 = 12
% Af1 = 30
% Af2 = 60
% 
% hh=figure;
% subplot(2,1,1)
% [MI_LG,MeanAmp] = ModIndex_v1(lfp,srate,Pf1,Pf2,Af1,Af2)
% 
% Pf1 = 4
% Pf2 = 12
% Af1 = 60
% Af2 = 100
% 
% subplot(2,1,2)
% [MI_HG,MeanAmp] = ModIndex_v1(lfp,srate,Pf1,Pf2,Af1,Af2)
% 
% 
%%
figure (103)
for ii=1:16
    subplot(4,4,ii)
    contourf(Channel(ii).PhaseFreqVector+Channel(ii).PhaseFreq_BandWidth/2,Channel(ii).AmpFreqVector+Channel(ii).AmpFreq_BandWidth/2,Channel(ii).Comodulogram',30,'lines','none')
    title(int2str(ii));
end
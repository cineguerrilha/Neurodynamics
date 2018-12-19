%%
%---------------------Kwik
data = load_open_ephys_kwik('experiment1_100.raw.kwd');

data1000=data{1,3}(1:16,1:30:end);
data1000=data1000';
t1000=[0:size(data1000,2)-1]/1000;
h1=figure(1);
thr=1000;


%%
for ii=1:8
aux1000=(data{1,3}(16+ii,1:30:end));
plot(aux1000)
ii
pause
end
%%
aux1000=(data{1,3}(24,1:30:end));
aux1000(aux1000<thr)=0;
aux1000(aux1000>thr)=1;
[pks,locs]=findpeaks(aux1000);



%%
srate=1000;

for ii=1:16
fc = 1.3;
   [b,a]=butter(1,.2*fc/srate,'high');
   data1000=filtfilt(b,a,data1000);
    
    ii
end
%%

for ii=1:16
    [P(:,ii) f]=pwelch(detrend(data1000(locs(1):locs(end)+30,ii)),2000,1500,2^17,1000);
    subplot(4,4,ii)
    plot(f,P(:,ii))
    title(int2str(ii))
    xlim([1.5 20])
    ii
end


%savefig(h1,'PSD.fig')
save PSD data1000 P f t1000 aux1000

%%
%savefig(h1,'PSD.fig')
%%
% Run comodulation (adriano's) of all channels - takes a loooooong time -
% only 1st half
figure(2)
for kk=1:16
%lfp=detrend(data1000(Locs(1):Locs(round(length(Locs)/2)),kk))';

lfp=detrend(data1000(:,kk))';
kk
subplot(4,4,kk)
CallerRoutine16

Channel(kk).PhaseFreqVector = PhaseFreqVector;
Channel(kk).PhaseFreq_BandWidth = PhaseFreq_BandWidth;
Channel(kk).AmpFreqVector = AmpFreqVector;
Channel(kk).AmpFreq_BandWidth = AmpFreq_BandWidth;
Channel(kk).Comodulogram = Comodulogram;

end

save Comodul Channel
% Load intan files in a single big file 
a=dir('*.int');

[t,amps,data2,aux] = read_intan_data_leao(a(1).name);
data1000=double(data2(:,1:25:end)');
aux1000=double(aux(1:25:end,:));
for jj=2:length(a)
[t,amps,data2,aux] = read_intan_data_leao(a(jj).name);
data1000=[data1000;double(data2(:,1:25:end)')];
aux1000=[aux1000;double(aux(1:25:end,:))];
disp([int2str(jj),' of ',int2str(length(a))])
end;
t1000=[0:size(data1000,1)-1]/1000;
clear data2 aux
%%
% Find Intan aux channel with video
MA=mean(aux1000);
VideoCh=find(MA>0);
[pks,locs]=findpeaks(aux1000);

%%
% Calculate PSD of all channels (during the video)
h1=figure(1);
for ii=1:16
    [P(:,ii) f]=pwelch(detrend(data1000(locs(1):locs(end)+50,ii)),2000,1500,2^17,1000);
    subplot(4,4,ii)
    plot(f,P(:,ii))
    title(int2str(ii))
    xlim([0 20])
    ii
end

%%

savefig(h1,'PSD.fig')
save PSD data1000 P f t1000 aux1000

%%
% Run comodulation (adriano's) of all channels - takes a loooooong time -
% only 1st half
h2=figure(2);
for kk=1:16
lfp=detrend(data1000(locs(1):locs(round(length(locs)/2))+50,kk))';
kk
subplot(4,4,kk)
CallerRoutine16

Channel(kk).PhaseFreqVector = PhaseFreqVector;
Channel(kk).PhaseFreq_BandWidth = PhaseFreq_BandWidth;
Channel(kk).AmpFreqVector = AmpFreqVector;
Channel(kk).AmpFreq_BandWidth = AmpFreq_BandWidth;
Channel(kk).Comodulogram = Comodulogram;

end

savefig(h2,'Comodul.fig')
save Comodul Channel
%%
%----------------------------------------------------------------
% Ploting PSDs
% Separate all channels in the SR
for ii=1:5
    PSD_c(:,ii)=animal(ii).saline.P(:,Ch(ii));
    PSD_l(:,ii)=animal(ii).lithium.P(:,Ch(ii));
end;
f=animal(1).saline.f;
%%
% Plot with shadows
F=f;
f=F(find(F<50));


P= mean(PSD_c');
Ds = std(PSD_c')/sqrt(5);

U=[P(find(F<50))+Ds(find(F<50))];
L=[P(find(F<50))-Ds(find(F<50))];

X=[f;flipud(f)];
Y=[U';flipud(L')];

h=fill(X,Y,[.5 .5 .5]);                
set(h,'EdgeColor','none')

hold on

plot(f,P(find(F<50)),'k','LineWidth',2)

P= mean(PSD_l');
Ds = std(PSD_l')/sqrt(5);

U=[P(find(F<50))+Ds(find(F<50))];
L=[P(find(F<50))-Ds(find(F<50))];
X=[f;flipud(f)];
Y=[U';flipud(L')];


h=fill(X,Y,[1 .5 .5]);                
set(h,'EdgeColor','none')
set(h,'facealpha',.8)
plot(f,P(find(F<50)),'r','LineWidth',2)

hold off

xlim([0 20])
set(gca,'FontSize',16)
set(gca,'FontName','arial')
ylabel('Power')
xlabel('Frequency (Hz)')
box off

f=F;

%%
% Normalise Lithium
for ii=1:5
    PSDN_c(:,ii)=PSD_c(:,ii)/sum(PSD_c(:,ii));
    PSDN_l(:,ii)=PSD_l(:,ii)/sum(PSD_l(:,ii));
end

%f=animal(1).saline.f;

F=f;
f=F(find(F<50));

P= mean(PSDN_c');
Ds = std(PSDN_c')/sqrt(5);

U=[P(find(F<50))+Ds(find(F<50))];
L=[P(find(F<50))-Ds(find(F<50))];

X=[f;flipud(f)];
Y=[U';flipud(L')];

h=fill(X,Y,[.5 .5 .5]);                
set(h,'EdgeColor','none')

hold on

plot(f,P(find(F<50)),'k','LineWidth',2)

P= mean(PSDN_l');
Ds = std(PSDN_l')/sqrt(5);

U=[P(find(F<50))+Ds(find(F<50))];
L=[P(find(F<50))-Ds(find(F<50))];
X=[f;flipud(f)];
Y=[U';flipud(L')];


h=fill(X,Y,[1 .5 .5]);                
set(h,'EdgeColor','none')
set(h,'facealpha',.4)

plot(f,P(find(F<50)),'r','LineWidth',2)

hold off

xlim([0 20])
set(gca,'FontSize',16)
set(gca,'FontName','arial')
ylabel('Power')
xlabel('Frequency (Hz)')
box off

f=F;

%%
for ii=1:5
    T2C(ii,1)=mean(PSD_c(f>4 & f<6,ii));
    T2S(ii,1)=mean(PSD_l(f>4 & f<6,ii));
   % T2A(ii,1)=mean(PSDM_a(f>4 & f<6,ii));
    
    T1C(ii,1)=mean(PSD_c(f>7 & f<10,ii));
    T1S(ii,1)=mean(PSD_l(f>7 & f<10,ii));
   % T1A(ii,1)=mean(PSDM_a(f>7 & f<10,ii));
end
%%
 boxplot([T2C T2S]); box off
 set(gca,'FontSize',16)
 ylabel('Mean Power')
 xlabel('4-6 Hz')
 set(gca,'FontName','arial')
ylim([0 6000])
box off

%%
 boxplot([T1C T1S]); box off
 set(gca,'FontSize',16)
 ylabel('Mean Power')
 xlabel('7-10 Hz')
 set(gca,'FontName','arial')
ylim([0 4000])

%%

for jj=1:5

for ii=1:16
    p=animal(jj).saline.P(:,ii);
    f=animal(jj).saline.f;
    subplot(4,4,ii)
    plot(f,p,'k')
    hold on
    p=animal(jj).lithium.P(:,ii);
    f=animal(jj).lithium.f;
    plot(f,p,'r')
    hold off
    title(int2str(ii))
    xlim([0 20])

end

pause
end

%%
for ii=1:5
    PSD_c(:,ii)=animal(ii).saline.P(:,Channels(ii))/Fc(ii);
    PSD_l(:,ii)=animal(ii).lithium.P(:,Channels(ii))/Fc(ii);
end
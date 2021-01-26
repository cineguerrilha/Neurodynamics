%%
% This script extracts the ttl (aux) information from 
FN='animal2_210116';
files=dir([FN,'*.int'])
OutDir=['stim/',FN];
mkdir(OutDir);
%%
FNo=numel(files);
AuxCh = 3;
for jj=1:FNo 
    [t,amps,y,aux] = read_intan_data_leao(files(jj).name);
    files(1).name
    [amps locs]=findpeaks(double(aux(:,AuxCh)));
    StimTimes(jj).locs=t(locs);
    disp(['File No: ',int2str(jj),'  Number of peaks: ',int2str(length(locs))]);
end

save StimTimes StimTimes

%%
% Synthetise PV stim (Sanja's computer)
% Signal Frequencies and duty cycle
sr=1000;
t=0:1/sr:12;
ff=[2 4 8 16 32 40];
DC=[.04 0.08 0.16 0.32 0.64 0.5];

for jj=1:FNo 
    if length(StimTimes(jj).locs)>5
        for ii=1:6
            StimTimes(jj).locs(ii)
            TStart=StimTimes(jj).locs(ii);
            ThetaSig = square(ff(ii)*2*pi*t,100*DC(ii))+1;
            [amps locs]=findpeaks(ThetaSig);
            StimTimes(ii).SynthSig = ((locs-1)/1000)+TStart;
        end
        eval(['save ',OutDir,'/StimTime_',FN,'_',int2str(jj), ' StimTimes']);
    end
end
%%
% PSTH
% FN='20210116_210116';
StimDir=['stim/',FN];
SpikeDir=['spk/',FN];

FNo=4;
StimFiles = [2 3 4 7 8 9 10]; 
for RunAllFiles=1:length(StimFiles)
    FNo = StimFiles(RunAllFiles)
SpkFileTime = dir([SpikeDir,'/times_',FN,'_',int2str(FNo),'*.mat']);
StimFile = [StimDir,'/StimTime_',FN,'_',int2str(FNo),'.mat'];
load(StimFile)
PSTH_Min = -250;
PSTH_Max = 1000;
NumberOfStimPulses = 6;
edges = PSTH_Min:25:PSTH_Max;
UnitCount=1;
for ii=1:length(SpkFileTime)
    load([SpkFileTime(ii).folder,'\',SpkFileTime(ii).name])
    for jj=1:max(cluster_class(:,1))
        UnitTimes = cluster_class(cluster_class(:,1)==jj,2);
        UnitNo = UnitCount;
        UnitCount = UnitCount+1;
        for kk=1:NumberOfStimPulses
            disp(['Number of Pulses: ',int2str(length(StimTimes(kk).SynthSig))])
            PSTH=zeros(length(edges),1);
            for ll=1:length(StimTimes(kk).SynthSig)
                PulseTime = StimTimes(kk).SynthSig(ll)*1000;
                N = histc(UnitTimes-PulseTime,edges);
                PSTH=PSTH+N;
            end
            bar(edges,PSTH,'histc')
            PSTHCell(UnitCount).PSTH(:,kk) = PSTH; 
            pause
        end
        PSTHCell(UnitCount).TimesUnitNo=jj;
        PSTHCell(UnitCount).FileName = SpkFileTime(ii).name;
    end
end

save([StimDir,'/PSTH_',FN,'_',int2str(FNo),'.mat'],'PSTHCell');
end
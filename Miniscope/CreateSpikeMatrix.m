
fileID = fopen('timestamp.dat','r');
dataArray = textscan(fileID, '%f%f%f%f%[^\n\r]', 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
camNum = dataArray{:, 1};
frameNum = dataArray{:, 2};
sysClock = dataArray{:, 3};
buffer1 = dataArray{:, 4};
clearvars dataArray;
fclose(fileID);
%%
load temporal
%%
miniscopeCam=0;
TimeMiniscope = sysClock(camNum==miniscopeCam);
TimeMiniscope(1)=0;

%%
clear SpkArray
BinSize=100; % time bin size
TMax=600000; % Max time
TVec = 0:BinSize:TMax;

Spk=S_temporal;
for jj=1:size(Spk,1)
for ii=1:length(TVec)-1
    Sig=Spk(jj,:);
    SpkArray(jj,ii)=round(sum(Sig(TimeMiniscope>=TVec(ii) & TimeMiniscope<TVec(ii+1))));
end
jj
end
ms.numNeurons=size(C_spatial,1);
ms.FiltTraces=C_spatial';
ms.numFrames=size(C_spatial,2);

%%
% For S and C from minian
ms.numNeurons=size(C,1);
ms.FiltTraces=C';
ms.numFrames=size(C,2);
ms.firing=S';
%%
% Read the timestamp miniscope time
fileID = fopen('timestamp.dat','r');
dataArray = textscan(fileID, '%f%f%f%f%[^\n\r]', 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
camNum = dataArray{:, 1};
frameNum = dataArray{:, 2};
sysClock = dataArray{:, 3};
buffer1 = dataArray{:, 4};
clearvars dataArray;
fclose(fileID);

miniscopeCam=1;
TimeMiniscope = sysClock(camNum==miniscopeCam);
TimeMiniscope(1)=0;

%disp(['Number of time points in the NI file: ',int2str(NofF)])
disp(['Number of time points from miniscope timestamp: ',int2str(length(TimeMiniscope))])

ms.time=TimeMiniscope;
%%
ms = msFiringRL(ms);
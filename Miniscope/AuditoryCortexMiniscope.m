%Analysis miniscope cortex auditivo
clear
load ms
%%
for ii=1:size(ms.FiltTraces,2)
    plot(ms.FiltTraces(:,ii))
    [ii size(ms.FiltTraces,2)]
    GoodTraces(ii)=input('good (0/1)?');
end
save GoodTraces GoodTraces

%%
hold on
traces=ms.FiltTraces(:,GoodTraces==1);
for ii=1:size(traces,2)
    plot(traces(:,ii)+ii*2,'k')
end
hold off

%%
%Baseline> O play foi dado no frame: 1179

%
% Pós estimulação> o play foi dado no frame: 194
%
% CentreFrequencies = [2 4 6 8;10 12 14 16;17 18 19 20]*1000;
% 30s

for ii=1:size(ms.firing,2)
    subplot(2,1,1),  imagesc(ms.SFPs(:,:,ii))
    subplot(2,1,2),  plot(ms.firing(:,ii))
    title(int2str(ii))
    pause
end

%%
% miniscope time
% Read the timestamp miniscope time
%
fileID = fopen('timestamp.dat','r');
dataArray = textscan(fileID, '%f%f%f%f%[^\n\r]', 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
camNum = dataArray{:, 1};
frameNum = dataArray{:, 2};
sysClock = dataArray{:, 3};
buffer1 = dataArray{:, 4};
clearvars dataArray;
fclose(fileID);

miniscopeCam=0;
TimeMiniscope = sysClock(camNum==miniscopeCam);
TimeMiniscope(1)=0;

behavCam=1;
TimeBehav = sysClock(camNum==miniscopeCam);
%TimeMiniscope(1)=0;

%disp(['Number of time points in the NI file: ',int2str(NofF)])
disp(['Number of time points from miniscope timestamp: ',int2str(length(TimeMiniscope))])
%%
% ctr - FrameStart = 1179
% stm = 194
FrameStart = 194
MinTime = TimeBehav(FrameStart);
MaxFrame = size(ms.firing,1);
TimeStim=30000;
tmin=MinTime;
cnt=0;
for ii=1:MaxFrame
    if TimeMiniscope(ii)>tmin
        cnt=cnt+1;
        tmin=tmin+TimeStim;
    end
    FrameStimIndex(ii)=cnt;
end

%%
cc=1;
for ii=1:size(ms.firing,2)
    for jj=1:11
        if jj==11
            cc=1.1;
        else
            cc=1;
        end
        SpkArray (ii,jj) = sum(ms.firing(FrameStimIndex==jj,ii))*cc;
    end
end

save SpkArray SpkArray
   
%%
% Plot firing according to the sound stim protocolç

for ii=1:size(ms.firing,2)
    subplot(2,1,1),  imagesc(ms.SFPs(:,:,ii))
    subplot(2,1,2),  plot(SpkArray(ii,:))
    title(int2str(ii))
    FiringType=input('Firing tipe (0 constant, 1 peak, 2 long peaks)')
end

%%
%%
% Plot firing according to the sound stim protocolç

for ii=1:size(ms.firing,2)
    subplot(2,1,1),  imagesc(ms.SFPs(:,:,ii))
    subplot(2,1,2),  plot(ms.FiltTraces(1:10000,ii))
    title(int2str(ii))
    pause
end

%%
% cell reg, change order of footprints
for ii=1:size(ms.firing,2)
    allFiltersMat(ii,:,:)=double(ms.SFPs(:,:,ii));
end
%%
% Defining the results_directory and creating the figures_directory:
results_directory='C:\Users\richardson\Desktop\MiniscopeSom\AC\a2\cellReg';
figures_directory=fullfile(results_directory,'Figures');
if exist(figures_directory,'dir')~=7
    mkdir(figures_directory);
end
figures_visibility='on'; % either 'on' or 'off' (in any case figures are saved)
    
file_names={'C:\Users\richardson\Desktop\MiniscopeSom\AC\a2\cellReg\ctrSFP.mat' ,...
            'C:\Users\richardson\Desktop\MiniscopeSom\AC\a2\cellReg\stmSFP.mat'};
        
%%
Im1=(ms.SFPs(:,:,1));
for ii=2:ms.numNeurons
    Im1=Im1+ms.SFPs(:,:,ii);
end
imagesc(Im1)

%%
Traces=ms.FiltTraces(:,GoodTraces==1);
hold on
for ii=1:size(Traces,2)
    plot(ms.time/1000,Traces(:,ii)+ii*2,'k');
end
hold off
axis tight

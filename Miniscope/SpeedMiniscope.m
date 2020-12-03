%%
% this part is for files without the speed file
SpeedVecUppsala;
FirstFrame=300;
AngSpeedResampled=V;
CCount=0:length(AngSpeedResampled)-FirstFrame;
TVec=[-ones(FirstFrame-1,1);CCount'];
CCount=0:length(AngSpeedResampled)-FirstFrame;
TVec=[-ones(FirstFrame-1,1);CCount'];

%%
clear
fname=dir('*.csv');
fid = fopen(fname.name);
tline = fgetl(fid);
Head=strsplit(tline,'\t')
tline = fgetl(fid);
NoEl=num2str(tline);
ii=1;
NoColumns=4;
while ~feof(fid)
    tline = fgetl(fid);
    tline = strrep(tline,',','.');
    TCell=strsplit(tline,'\t');
    for jj=1:NoColumns
        Data(ii,jj)=str2num(cell2mat(TCell(jj)));
    end
    ii=ii+1;
end
fclose(fid);
SR=100; % Sampling rate
%%
InvertSpeed=-1;
Speed=smooth(InvertSpeed*Data(:,2));
plot(Speed)
disp('Threshold')
thr=ginput(1);

% Calculate treadmill speed
MarkerAngle=30;
SpeedVec=zeros(length(Speed),1);
SpeedVec(Speed>thr(2))=1;
clear speed
[pks, locs]=findpeaks(SpeedVec);
plot(SpeedVec)
hold on
plot(locs,pks,'ro')
hold off
%%
AngSpeed=zeros(length(SpeedVec),1);
cnt=1;
InterLocs=diff(locs/SR);
AngSpeedInst=0;
for ii=1:length(SpeedVec)
    if ii>locs(cnt)
        if cnt<length(locs)
            AngSpeedInst=MarkerAngle/InterLocs(cnt);
            cnt=cnt+1;
        end
        
    end
    AngSpeed(ii)=AngSpeedInst;
end
AngSpeed(locs(length(locs)):end)=0
plot(AngSpeed)
%%
InvertSpeed=1;
if mean(Data(1:10,1))>0
    InvertSpeed=-1;
end
Frames=Data(:,1)*InvertSpeed;
FrameVec=zeros(length(Frames),1);
FrameVec(Frames>1)=1;
plot(FrameVec)
[pks locs]=findpeaks(FrameVec);
clear Frames
hold on
plot(locs,pks,'ro')
hold off
NofF=length(locs);

% Resample velocity vector and do correlation
AngSpeedResampled=smooth(resample(AngSpeed,1000,SR),100);
plot(AngSpeedResampled)
FirstFrame=round((locs(1)*1000)/SR);
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

miniscopeCam=0;
TimeMiniscope = sysClock(camNum==miniscopeCam);
TimeMiniscope(1)=0;

%disp(['Number of time points in the NI file: ',int2str(NofF)])
disp(['Number of time points from miniscope timestamp: ',int2str(length(TimeMiniscope))])



%%
CCount=0:length(AngSpeedResampled)-FirstFrame;
TVec=[-ones(FirstFrame-1,1);CCount'];
%load S
S=ms.firing';
MinCaVal=0.1;


maxTime=max(TVec);
% crop S if necessary
if maxTime<max(TimeMiniscope)
    Crop=find(TimeMiniscope>maxTime)
    Crop=Crop(1);
    S=S(:,1:Crop(1));
    disp('Miniscope data croped')
end

%%
for ii=1:size(S,1)
    SCa=S(ii,:);
    SCa(SCa<0.1)=0;
    [pks locs]=findpeaks(SCa);
    VVec=0;
    
    for jj=1:length(locs)

            VVec(jj)=AngSpeedResampled(round(TimeMiniscope(locs(jj)))==TVec);
    end
    if length(pks)>1
    CVv=corrcoef(VVec,pks);
    end

    if length(VVec)>3
        VCa(ii)=CVv(1,2);
    else
        VCa(ii)=NaN;
        disp(['NaN value in ' int2str(ii) ' with only ' int2str(length(pks)) ' spikes'])
    end
end

save SpeedCorrelation VCa
hist(VCa)

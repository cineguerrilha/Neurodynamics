clc
disp('iniciando o progrmaa')
cd('F:\helton\dropBox\Dropbox\projects\proj_optoTheta')
clear all;  close all force hidden;

delete(daqfind)
delete(imaqfind)

trial_period = 20;     % seconds
wait_period  = 5;      % seconds
cam_period   = 1;      % frames
srate        = 250000; % samples per second 250000=max ni 6215,
FPS          = 30;     % frames per second

aviname      = 'testando';
disp('variabveis prontas')
%% ====== configure ==========
disp('configurando a ni anal[ogica')
load squareLaserStimulo.mat


ao = analogoutput('nidaq','Dev2');
addchannel(ao, 1);
% addchannel(ao, 0:1);
ao.SampleRate = srate;
pause(5);
disp('configurando a ni digital')
global digital_io
digital_io  = digitalio('nidaq','Dev2');
digital_out = addline(digital_io,4,'Out');
putvalue(digital_io,0)

disp('configure camera')
filenum               = num2str(length(dir(fullfile(cd,[aviname '*.avi'])))+1);
filename              = [aviname filenum];

disp('criando objetos')
infoWin               = imaqhwinfo('winvideo');
camUSB                = infoWin.DeviceInfo(1);
camOBJ                = eval(camUSB.VideoInputConstructor);
disp('objetos criados')
set(camOBJ,'FramesPerTrigger'      ,Inf);
set(camOBJ,'FramesAcquiredFcnCount',cam_period);
set(camOBJ,'FramesAcquiredFcn'     ,'cam_clock');
set(camOBJ,'LoggingMode'           ,'disk');
set(camOBJ,'ReturnedColorSpace','grayscale');
triggerconfig(camOBJ, 'manual')
disp('objeto setado')

global cam_timestamp
cam_timestamp = [];
disp('preparando pra come;arc')

% %pipe to intan
a=[];
while (isempty(a))
    a=pipeTest;
end;

for i=randsample(1:8,8)    
    disp(['iniciando a estimulacao ' num2str(i*2) ' hz'])
    
    camAVI                = avifile([filename '_' num2str(i*2) 'hz' '.avi'],'compression','none') ;
    camAVI.Fps            = FPS;
    camAVI.Quality        = 50;
    camAVI.KeyFramePerSec = FPS;
    camAVI.Colormap       = gray(256);
    
    set(camOBJ,'DiskLogger'            ,camAVI)
    start(camOBJ);
    trigger(camOBJ);
    
    while strcmp(get(camOBJ,'Running'),'off')
    end
    pause(0.5);
    
    %send estimulus
    putdata(ao,h(:,i))
    set(ao,'RepeatOutput',trial_period); % repeat signal in sec
    ao.TriggerType = 'Immediate';
    ao.Timeout=10;
    start(ao);
    %tic
    wait(ao,trial_period+10);
    %toc
    stop(ao);
    
    %send "the same stimulus time (baseline)"
    putdata(ao,0*h(:,i))
    set(ao,'RepeatOutput',trial_period); % repeat signal in sec
    ao.TriggerType = 'Immediate';
    ao.Timeout=10;
    start(ao);
    wait(ao,trial_period+10);
    %toc
    stop(ao);
    %pause(wait_period);
    
    stop(camOBJ)
    camAVI = close(camAVI);
    clear camAVI
end
disp('end...')
%delete(ao);

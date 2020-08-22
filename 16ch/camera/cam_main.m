srate = 20000;

dt = 1/srate;

freqs = 2:2:16;
%%
close all force hidden

delete(imaqfind)


basename = 'opto_theta';
filenum  = num2str(length(dir(fullfile(cd,[basename '*.avi'])))+1);
filename = [basename filenum '.avi'];

FPS                   = 30;
camAVI                = avifile(filename,'compression','none') ;
camAVI.Fps            = FPS;
camAVI.Quality        = 100;
camAVI.KeyFramePerSec = FPS;

infoWin               = imaqhwinfo('winvideo');
camUSB                = infoWin.DeviceInfo(2);
camOBJ                = eval(camUSB.VideoInputConstructor);

T                     = 2;

set(camOBJ,'FramesPerTrigger'      ,T*FPS);
set(camOBJ,'FramesAcquiredFcnCount',1);
set(camOBJ,'FramesAcquiredFcn'     ,'cam_clock');
set(camOBJ,'LoggingMode'           ,'disk');
set(camOBJ,'DiskLogger'            ,camAVI)
set(camOBJ,'TriggerType','manual');
%%

tic
start(camOBJ)

%%
stop(camOBJ)

%%

camAVI = close(camAVI);

%%
figure(1)
for i = 1 : length(opto_theta3)
    imagesc(opto_theta3(i).cdata)
    title(i)
    pause(.1)
end
    


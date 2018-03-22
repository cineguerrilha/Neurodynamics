NoBehaveFiles=length(dir('behav*.avi'));
for ii=1:NoBehaveFiles
    Files{ii}=['behavCam',int2str(ii),'.avi'];
end

vid=VideoReader(Files{1});
vid.CurrentTime=0;
ImRed = readFrame(vid);
ImRed=squeeze(double(ImRed(:,:,1)));
imagesc(ImRed)
h=imrect;
Pos=round(wait(h));

%%

cnt=1;

for kk=1:NoBehaveFiles

vid=VideoReader(Files{kk});
Files{kk}
vid.CurrentTime=0;

while hasFrame(vid)
   % [size(ImRed) cnt]
            ImRed = readFrame(vid);
            ImRed=squeeze(double(ImRed(:,:,1)));
            
            meanLed(cnt) = max(max(ImRed(Pos(2):Pos(2)+Pos(4),Pos(1):Pos(1)+Pos(3))));   
            cnt=cnt+1;
end
delete(vid)
end

%%
vid=VideoReader(Files{1});
t=(1:length(meanLed))*(1/vid.FrameRate)-(1/vid.FrameRate);
delete vid

save Led meanLed t

clear all
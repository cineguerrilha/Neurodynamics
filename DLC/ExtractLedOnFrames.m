VidObj=VideoReader(VideoFile);
FirstFrame = 1000;
Img=read(VidObj,FirstFrame);
%%
imagesc(Img)
disp('Click at the upper-left corner of the led rectangle')
P1=round(ginput(1));
hold on
plot(P1(1),P1(2),'r+')
disp('Click at the lower-right corner of the led rectangle')
P2=round(ginput(1));
plot(P2(1),P2(2),'r+')
hold off
rect=[P1(1) P1(2) P2(1) P2(2)];
%%
TotalFrames = VidObj.Duration*VidObj.FrameRate;
for ii=1:TotalFrames
    Img=read(VidObj,ii);
    Led(ii)=max(mean(double(Img(rect(2):rect(4),rect(1):rect(3),1))));
end
%%
plot(Led)
disp('threshold')
P1=ginput(1);
FirstFrame=find(Led>P1(2));
FirstFrame=FirstFrame(1);
%%
TotalFrames = round(VidObj.Duration*VidObj.FrameRate);
BehaviourTime(1:FirstFrame-1)=-1;
BehaviourTime(FirstFrame:TotalFrames)=(0:TotalFrames-FirstFrame)*(1/VidObj.FrameRate);
save BehaviourTime TotalFrames FirstFrame BehaviourTime Led rect
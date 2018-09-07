% Image tracking
% Reads the first frame
clear all
AA=dir('behav*.avi');
FileNo=length(AA);
clear AA

for ii=1:FileNo
    FName{ii}=['behavCam',int2str(ii),'.avi'];
end
%%
%filename='chr_sess2.avi' %AA(1).name
FileStart = 1;
%FileNo = 27; % Use only specified files

filename=char(FName(FileStart))

obj=VideoReader(filename);

%%
Video=rgb2gray(read(obj,1));
imagesc(Video);
colorbar;
colormap('jet');
%%
%run this cell to crop
disp('select led')
[X,Y,I2,RECT]=imcrop(255-Video);

imagesc(I2)
colormap('jet');
RECT=round(RECT);

[m,n]=size(Video);

if RECT(2)+RECT(4)>m
    RECT(4)=RECT(4)-1;
end

if RECT(1)+RECT(3)>m
    RECT(3)=RECT(3)-1;
end


%%
cnt=1;
clear PixelValue

for kk=FileStart:FileNo
    kk
    filename=FName{kk}
    obj=VideoReader(filename);
for ii=1:obj.NumberOfFrames

    Video=rgb2gray(read(obj,ii));
    video=Video(RECT(2):RECT(2)+RECT(4),RECT(1):RECT(1)+RECT(3));

        imagesc(video);
        
        PixelValue(cnt)=mean(mean(video));
    cnt=cnt+1;
    %pause
end


end


BehaveCam=1;
A=importdata('timestamp.dat');
time=A.data(A.data(:,1)==BehaveCam,3);
if (FileNo*1000)<=length(PixelValue)
    time=time(((FileStart-1)*1000)+1:(FileNo*1000));
else
    time=time(((FileStart-1)*1000)+1:length(PixelValue));
end

if FileStart==1
    time(1)=0;
end
    
%     MiniscopeCam=0;
% timeMiniscope=A.data(A.data(:,1)==MiniscopeCam,3);
% timeMiniscope(1)=0;
% 
% TStart = find(timeMiniscope<time(1));
% TEnd = find(timeMiniscope<time(end));
% timeMiniscope=timeMiniscope(TStart(end):TEnd(end));

%timeSpaced=(TStart(end)):30:(TEnd(end));


save(['PixValue_File_',int2str(FileStart),'_to_',int2str(FileNo),'.mat'],'PixelValue','time');

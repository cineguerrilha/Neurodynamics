
% Image tracking
% Reads the first frame
AA=dir('*.mp4');
%filename=AA(1).name
%IntFName=AA(3).name

disp('Dates')

AA(1).date

%%
filename=AA(1).name
obj=VideoReader(filename);

%%
Video=rgb2gray(read(obj,1));
imagesc((255-Video));
colorbar;
colormap('jet');
%%
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

FirstFrame = 1;

Video=rgb2gray(read(obj,FirstFrame));
imagesc(Video);
%%
% here you can select the maze
video=Video(RECT(2):RECT(2)+RECT(4),RECT(1):RECT(1)+RECT(3));
imagesc(video);
BW=roipoly;
InvertedVideo=255-video;
EPM_video=InvertedVideo.*uint8(BW);
imagesc(EPM_video)
%%
%Here you set up the detection level

%level = 0.105;   %Change this to isolate the mouse
level = 0.9;   %Change this to isolate the mouse
NoPixel=150;  %here also

bw = (im2bw(EPM_video,level));
bw=  bwareaopen(bw,NoPixel);
STATS = regionprops(bw);

imagesc(bw);
Coord=STATS.Centroid;
hold on
plot(Coord(1),Coord(2),'go')
hold off

%%

DistThr=60;
jj=1;

for ii=FirstFrame:obj.NumberOfFrames

    Video=rgb2gray(read(obj,ii));
    video=Video(RECT(2):RECT(2)+RECT(4),RECT(1):RECT(1)+RECT(3));
    InvertedVideo=255-video;
    EPM_video=InvertedVideo.*uint8(BW);
    
    bw = (im2bw(EPM_video,level));
    bw=  bwareaopen(bw,NoPixel);
    STATS = regionprops(bw);

    imagesc(bw);
    if (mean(mean(bw))<0.001)
        imagesc(EPM_video);
        disp('find the animal');
        Coord(jj,:)=ginput(1);
    else
        Coord(jj,:)=STATS.Centroid;
    
%     if ii>1
%     D(ii-1)=pdist(Coord([ii,ii-1],:),'Euclidean');
%         if (DD(ii-1)>thr)
%     end
    
        H=text(40,200,['Frame no. ',int2str(ii)]);
        set(H,'FontSize',14);
        set(H,'Color','g');
        hold on
        plot(Coord(jj,1),Coord(jj,2),'go')
    
        if jj>1
        
            if (abs(Coord(jj,1)-xx)>DistThr | abs(Coord(jj,2)-yy)>DistThr)
                imagesc(video);
                plot(Coord(jj,1),Coord(jj,2),'y+')
                disp('abrupt change in position, find the animal');
                Coord(jj,:)=ginput(1);
            else
                Coord(jj,:)=STATS.Centroid;
            end
            D(jj-1)=sqrt((Coord(jj,1)-xx)^2+(Coord(jj,2)-yy)^2);
            H=text(40,250,['Distance ',num2str(D(jj-1))]);
            set(H,'FontSize',14);
            set(H,'Color','r');
        end
        
    end
    xx=Coord(jj,1);
    yy=Coord(jj,2);
    hold off
    drawnow
    %pause
    jj=jj+1;
end

plot(Coord(:,1),Coord(:,2))
save([filename(1:end-4),'_Coord'],'Coord','EPM_video');

%%
% Open and close time vec

imagesc(EPM_video)
hold on
plot(Coord(:,1),Coord(:,2),'r')
hold off
title('Click on the center of the arena')
aa=ginput(1);

[m,n]=size(EPM_video);

hold on
plot(aa(1),[1:m],'k+')
plot([1:n],aa(2),'k+')
hold off
text(aa(1)-100,aa(2)+100,'opened')
text(aa(1)-100,aa(2)-100,'closed')
text(aa(1)+70,aa(2)+100,'closed')
text(aa(1)+70,aa(2)-100,'opened')

Opened=zeros(length(Coord),1);
for ii=1:length(Coord)
    if (Coord(ii,1)<=aa(1) & Coord(ii,2)>=aa(2)) | (Coord(ii,1)>aa(1) & Coord(ii,2)<aa(2))
        Opened(ii)=1;
    end
end

hold on
plot(Coord(Opened==1,1),Coord(Opened==1,2),'r+')
plot(Coord(Opened==0,1),Coord(Opened==0,2),'k*')
hold off

%%

[pks,locs]=findpeaks(aux1000);
DataFilm=detrend(data1000(locs(1):locs(end)+50,:));

auxFilm=zeros(locs(end)+50-locs(1)+1,1);


tVideoKwik=locs(end)+50-locs(1);
disp('Inter frame interval');
FInt=1/(length(Opened)/(tVideoKwik))

FOn=1:FInt:tVideoKwik;

% for ii=1:length(FOn)
%     auxFilm(round(FOn(ii)),1)=1;
% end


DataClosed=zeros(length(DataFilm),16);
DataOpened=zeros(length(DataFilm),16);

cntClose=1;
cntOpen=1;

for ii=1:length(FOn)-1
    if (Opened(ii)==0)
        DataClosed(cntClose:cntClose+(round(FOn(ii+1))-round(FOn(ii))),:)=DataFilm(round(FOn(ii)):round(FOn(ii+1)),:);
        cntClose=(round(FOn(ii+1))-round(FOn(ii)))+cntClose;
    else
        DataOpened(cntOpen:cntOpen+(round(FOn(ii+1))-round(FOn(ii))),:)=DataFilm(round(FOn(ii)):round(FOn(ii+1)),:);
        cntOpen=(round(FOn(ii+1))-round(FOn(ii)))+cntOpen;
    end
    
end

DataOpened(cntOpen-1:end,:)=[];
DataClosed(cntClose-1:end,:)=[];

save DataOpenClose DataOpened DataClosed

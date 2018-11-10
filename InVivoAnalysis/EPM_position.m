
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
level = 0.97;   %Change this to isolate the mouse
NoPixel=200;  %here also

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

for ii=1:obj.NumberOfFrames

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
        Coord(ii,:)=ginput(1);
    else
        Coord(ii,:)=STATS.Centroid;
    
%     if ii>1
%     D(ii-1)=pdist(Coord([ii,ii-1],:),'Euclidean');
%         if (DD(ii-1)>thr)
%     end
    
        H=text(40,200,['Frame no. ',int2str(ii)]);
        set(H,'FontSize',14);
        set(H,'Color','g');
        hold on
        plot(Coord(ii,1),Coord(ii,2),'go')
    
        if ii>1
        
            if (abs(Coord(ii,1)-xx)>DistThr | abs(Coord(ii,2)-yy)>DistThr)
                imagesc(video);
                plot(Coord(ii,1),Coord(ii,2),'y+')
                disp('abrupt change in position, find the animal');
                Coord(ii,:)=ginput(1);
            else
                Coord(ii,:)=STATS.Centroid;
            end
            D(ii-1)=sqrt((Coord(ii,1)-xx)^2+(Coord(ii,2)-yy)^2);
            H=text(40,250,['Distance ',num2str(D(ii-1))]);
            set(H,'FontSize',14);
            set(H,'Color','r');
        end
        
    end
    xx=Coord(ii,1);
    yy=Coord(ii,2);
    hold off
    drawnow
    %pause
end

plot(Coord(:,1),Coord(:,2))
save([filename(1:end-4),'_Coord'],'Coord','EPM_video');
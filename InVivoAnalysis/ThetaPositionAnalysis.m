
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
Video=rgb2gray(read(obj,25));
imagesc((255-Video));
colorbar;
colormap('jet');
%%
%run this cell to crop

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
% if you do not want to crop, run this cell, otherwise SKIP it

[m,n]=size(Video);

RECT(1)=1;
RECT(2)=1;

RECT(3)=n-1;
RECT(4)=m-1;

%% Create polygon with pixels set to 0
imagesc((255-Video));
h=impoly;
mask=h.createMask();
mask=~mask;
%position = wait(h);

%poly2mask

%%
%video=rgb2gray(read(obj1));
FirstFrame = 1700;
%Here you set up the detection level
Video=rgb2gray(read(obj,FirstFrame));
imagesc(Video);
%%
%level = 0.105;   %Change this to isolate the mouse
level = 0.001;   %Change this to isolate the mouse
NoPixel=300;  %here also

video=Video(RECT(2):RECT(2)+RECT(4),RECT(1):RECT(1)+RECT(3));
bw = not(im2bw(video,level));
bw=  bwareaopen(bw,NoPixel);
STATS = regionprops(bw);

imagesc(bw);
Coord=STATS.Centroid;
hold on
plot(Coord(1),Coord(2),'go')
hold off

%%
FirstFrame = 1000;
%Coord=zeros(obj.NumberOfFrames,2);
Coord=zeros(length(FirstFrame:obj.NumberOfFrames),2);
DistThr=60;

jj=1;
for ii=FirstFrame:obj.NumberOfFrames
    %for ii=1:20000
    Video=rgb2gray(read(obj,ii));
    video=Video(RECT(2):RECT(2)+RECT(4),RECT(1):RECT(1)+RECT(3));
    % apply polygon
    if(exist('mask','var'))
        video(mask)=255;
        %imagesc(video)
    end
    
    bw = not(im2bw(video,level));
    bw=  bwareaopen(bw,NoPixel);
    STATS = regionprops(bw);
    imagesc(bw);
    if (mean(mean(bw))<0.001)
        imagesc(video);
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
                plot(Coord(jj,1),Coord(ii,2),'y+')
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
save([filename(1:end-4),'_Coord'],'Coord');
%%
% Calculates the velocity
% 
% for ii=1:length(Coord)-1
%     D(ii)=sqrt((Coord(ii,1)-xx)^2+(Coord(ii,2)-yy)^2);
% end


plot(D)

[b,a]=butter(4,1/5); %Filter cut off

Dfilt=filtfilt(b,a,D); %Filtered distance

hold on

h=plot(Dfilt,'r')
set(h,'LineWidth',1)
hold off

V=abs(diff(D)); %Velocity: use Dfilt for filtered distance and D for unfiltered

disp('Press a key for velocity')
pause

plot(V)

%%
[t,amps,y,aux] = read_intan_data_leao(IntFName);
%%
y=y(:,1:25:end);
t=t(1:25:end);

%%
Theta = eegfilt(double(y),1000,3,10);
Delta = eegfilt(double(y),1000,2,4);
%%
V=smooth(V);
%%

t2=(1:length(V))/(obj.FrameRate/2);
vv=V/max(V);c

%time fo analysis - if there is a lot of noise for example
tt1=[30,60];
tt2=[60,90];
tt3=[90,120];

offset=200;

for ii=1:16
    Xt=hilbert(Theta(ii,:));
    %Xd=hilbert(Delta(ii,:));
    t1=resample(smooth(abs(Xt),70),round(obj.FrameRate/2),1000);
    %d1=resample(smooth(abs(Xd),70),round(obj.FrameRate/2),1000);
    %theta1=t1./d1; %Theta/Delta
    theta1=t1;
    theta1=theta1(1:length(V));
    plot(t2,theta1+((ii-1)*offset));
    ii
    R=corrcoef(V(t2>tt1(1) & t2<tt1(2)),theta1(t2>tt1(1) & t2<tt1(2))');
    r1(ii)=R(2,1);
    R=corrcoef(V(t2>tt2(1) & t2<tt2(2)),theta1(t2>tt2(1) & t2<tt2(2))');
    r2(ii)=R(2,1);
    R=corrcoef(V(t2>tt3(1) & t2<tt3(2)),theta1(t2>tt3(1) & t2<tt3(2))');
    r3(ii)=R(2,1);
    hold on
end
ii=ii+1;
plot(t2,vv*max(max(theta1))+((ii-1)*offset),'r')
hold off
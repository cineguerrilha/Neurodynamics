% Image tracking
% Reads the first frame
AA=dir('behav*.avi');

FileNo=length(AA);
%%
%filename='chr_sess2.avi' %AA(1).name
filename=AA(1).name

obj=VideoReader(filename);

%%
Video=rgb2gray(read(obj,1));
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

% [m,n]=size(Video);
% 
% RECT(1)=1;
% RECT(2)=1;
% 
% RECT(3)=n-1;
% RECT(4)=m-1;


%%
Video=rgb2gray(read(obj,1));

%Here you set up the detection level

%level = 0.105;   %Change this to isolate the mouse
level = 0.34;   %Change this to isolate the mouse
NoPixel=1000;  %here also

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
%Coord=zeros(obj.NumberOfFrames,2);

DistThr=60;
cnt=1;
clear Coord

FileStart = 1;
FileNo = 13; % Use only specified files

for kk=FileStart:FileNo
    kk
    filename=['behavCam',int2str(kk),'.avi']
    obj=VideoReader(filename);
for ii=1:obj.NumberOfFrames

    Video=rgb2gray(read(obj,ii));
    video=Video(RECT(2):RECT(2)+RECT(4),RECT(1):RECT(1)+RECT(3));

    bw = not(im2bw(video,level));
    bw=  bwareaopen(bw,NoPixel);
    STATS = regionprops(bw);
    imagesc(bw);
    if (mean(mean(bw))<0.001)
        imagesc(video);
        disp('find the animal');
        Coord(cnt,:)=ginput(1);
    else
        Coord(cnt,:)=STATS.Centroid;
        H=text(250,200,['Frame no. ',int2str(cnt)]);
        set(H,'FontSize',14);
        set(H,'Color','y');
        hold on
        plot(Coord(cnt,1),Coord(cnt,2),'go')
    
        if cnt>1     
           if (abs(Coord(cnt,1)-xx)>DistThr | abs(Coord(cnt,2)-yy)>DistThr)
                imagesc(video);
                plot(Coord(cnt,1),Coord(cnt,2),'y+')
                disp('abrupt change in position, find the animal');
                Coord(cnt,:)=ginput(1);
            else
                Coord(cnt,:)=STATS.Centroid;
            end
            D(cnt-1)=sqrt((Coord(cnt,1)-xx)^2+(Coord(cnt,2)-yy)^2);
            H=text(250,250,['Distance ',num2str(D(cnt-1))]);
            set(H,'FontSize',14);
            set(H,'Color','y');
        end
        
    end
    xx=Coord(cnt,1);
    yy=Coord(cnt,2);
    hold off
    cnt=cnt+1;
    %pause
end

delete obj
end

%%
BehaveCam=1;
A=importdata('timestamp.dat');
time=A.data(A.data(:,1)==BehaveCam,3);
time=time(((FileStart-1)*1000)+1:(FileNo*1000));
%time(1)=0;

MiniscopeCam=0;
timeMiniscope=A.data(A.data(:,1)==MiniscopeCam,3);
timeMiniscope(1)=0;

TStart = find(timeMiniscope<time(1));
TEnd = find(timeMiniscope<time(end));
timeMiniscope=timeMiniscope(TStart(end):TEnd(end));

timeSpaced=(TStart(end)):30:(TEnd(end));


save Coord_File1_File7 Coord D time
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
vv=V/max(V);

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
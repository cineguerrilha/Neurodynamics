X=Coord(:,1);
Y=Coord(:,2);

Xmin=min(X);
Ymin=min(Y);

X=X-Xmin;
Y=Y-Ymin;

YMax=max(Y);
XMax=max(X);

% if YMax>XMax
%     Y(Y>XMax)=XMax;
% else
%     X(X>YMax)=YMax;
% end

plot(X,Y)
hold on
plot(XMax/2,YMax/2,'r+');
hold off
title('Click on the arena center')
axis('tight')
CenterPoint=ginput(1);

%%
% Here you write the percentage of the radius that is considered the center
% I am assuming 30%
% Change accordingly
% The radius is the center point to XMax distance
TotalRadius = XMax-CenterPoint(1);

InnerRadius=.7;
HairRadius=.15;  % Radius of the hair container - Measured in the fig

IRadius = TotalRadius*InnerRadius;
HRadius = TotalRadius*HairRadius;

t=0:.01:2*pi;

x1=cos(t)*TotalRadius+CenterPoint(1);
y1=sin(t)*TotalRadius+CenterPoint(2);

plot(x1,y1);
hold on
plot(X,Y,'k')
plot(CenterPoint(1),CenterPoint(2),'r*')

x1=cos(t)*IRadius+CenterPoint(1);
y1=sin(t)*IRadius+CenterPoint(2);
plot(x1,y1,'g');

x1=cos(t)*HRadius+CenterPoint(1);
y1=sin(t)*HRadius+CenterPoint(2);
plot(x1,y1,'r');
hold off

%%
% I will now create a vector with distances 'D' of each point from the center
% then, any operation can be done by checking whether D is smaller than
% whatever
% e.g. , is the point P(1) contained in the inner part of the arena:
% D(1)>IRadius
for ii=1:length(X)
    D(ii)=norm([CenterPoint(1) CenterPoint(2)]-[X(ii) Y(ii)]);
end

%%
% Example plot:
InnerPoints=zeros(length(D),1);
InnerPoints(D<IRadius)=1;
plot(X(InnerPoints==1),Y(InnerPoints==1),'ro')
hold on
plot(X(InnerPoints==0),Y(InnerPoints==0),'ko')
hold off

% then the time in the center is sum(InnerPoints)/fps


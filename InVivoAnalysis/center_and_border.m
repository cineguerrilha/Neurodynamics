% Plots center and border coordenates for the open field
% RL 2017
%Gray Coord
%clear
%close
load Coord

%Coord= ___;
%Coord=Coord(1:2:18010,:);
%Coord=Coord(1:9010,:);
% borders
% Max x = 650 max y=520

% Dimensao da caixa

XX=40;
YY=32;
fps=20;

XBound=max(Coord(:,1));
YBound=max(Coord(:,2));

CoordCM_X=(Coord(:,1)./XBound(1))*XX;
CoordCM_Y=(Coord(:,2)./YBound(1))*YY;

yT=[8]
yB=[YY-8];

xL=[8];
xR=[XX-7];
figure(101)
hold on

%plot(Coord(:,1),Coord(:,2),'ro')
LR=find(CoordCM_X<xL | CoordCM_X>xR);
plot(CoordCM_X(LR),CoordCM_Y(LR),'LineStyle','none','Marker','o','Color',[.5 .5 .5])
TB=find(CoordCM_Y(:)<yT | CoordCM_Y(:)>yB);
plot(CoordCM_X(TB),CoordCM_Y(TB),'LineStyle','none','Marker','o','Color',[.5 .5 .5])

LR=find((CoordCM_X(:)>=xL & CoordCM_X(:)<=xR) & (CoordCM_Y(:)>=yT & CoordCM_Y(:)<=yB));
plot(CoordCM_X(LR),CoordCM_Y(LR),'ko')


hold off

D(1)=0;
xx=CoordCM_X(1);
yy=CoordCM_Y(1);

for ii=2:length(CoordCM_X)
D(ii-1)=sqrt((CoordCM_X(ii)-xx)^2+(CoordCM_Y(ii)-yy)^2);
xx=CoordCM_X(ii);
yy=CoordCM_Y(ii);
end

TimeInMin=floor((length(D)/fps)/60);
Ind=1;
for ii=1:TimeInMin
    DInMin(ii)=sum(D(Ind:ii*fps*60))/100;
    Ind=ii*fps*60;
end

TotalDist=sum(D)/100;

TimeInCenter=length(LR)/fps;

timeCoord=((1:length(Coord))-1)/fps;

CenterBorder=zeros(length(Coord),1);
CenterBorder(LR)=1;

%%
% Plot with coherence
for ii=1:length(t)
    MeanCxyTheta(ii)=mean(cxx((f>6 & f<8),ii));
end
h2=figure(102);

plot(timeCoord,CenterBorder);
hold on
plot(t,smooth(MeanCxyTheta),'r')
hold off
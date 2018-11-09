clear 
close
load Coord
load PSD
XX=40;
YY=32;
plot(Coord(:,1),Coord(:,2),'.')

%%
% deu Errado, se nao deu pula
gg=ginput(2);
xMin=gg(1,1);
xMax=gg(2,1);

yMax=gg(1,2);
yMin=gg(2,2);

for ii=1:length(Coord)
    if Coord(ii,1)<xMin
        Coord(ii,1)=xMin;
    end
    if Coord(ii,1)>xMax
        Coord(ii,1)=xMax;
    end
    
    if Coord(ii,2)<yMin
        Coord(ii,2)=yMin;
    end
    if Coord(ii,2)>yMax
        Coord(ii,2)=yMax;
    end
end
plot(Coord(:,1),Coord(:,2),'.')
%%

% XNeg=find(Coord(:,1)<0);
% if not(isempty(XNeg))
% Coord(XNeg,:)=1;
% end
% 
% YNeg=find(Coord(:,2)<0);
% if not(isempty(YNeg))
% Coord(YNeg,:)=1;
% end

XBound=max(Coord(:,1));
YBound=max(Coord(:,2));

CoordCM_X=(Coord(:,1)./XBound(1))*XX;
CoordCM_Y=(Coord(:,2)./YBound(1))*YY;

yT=[8]
yB=[YY-8];

xL=[8];
xR=[XX-8];

Center=zeros(length(CoordCM_X),1);
InOut=zeros(length(CoordCM_X),1);

%plot(CoordCM_X,CoordCM_Y)
for ii=1:length(CoordCM_X)
    if (CoordCM_X(ii)>xL & CoordCM_X(ii)<xR) & (CoordCM_Y(ii)>yT & CoordCM_Y(ii)<yB)
        Center(ii)=1;
        if ii>1 & ii<(length(CoordCM_X)+2)
%             if Center(ii-1)==0 | Center(ii-2)==0
%                 InOut(ii,1)=1; % Animal is entering center
%             end
            
%             if not((CoordCM_X(ii+1)>xL & CoordCM_X(ii+1)<xR) & (CoordCM_Y(ii+1)>yT & CoordCM_Y(ii+1)<yB) | (CoordCM_X(ii+2)>xL & CoordCM_X(ii+2)<xR) & (CoordCM_Y(ii+2)>yT & CoordCM_Y(ii+2)<yB))
%                 InOut(ii,1)=2;
%             end
        end
    end
end

%%
plot(CoordCM_X(Center==1),CoordCM_Y(Center==1),'LineStyle','none','Marker','o','Color',[.5 .5 .5])
hold on
plot(CoordCM_X(InOut==1),CoordCM_Y(InOut==1),'LineStyle','none','Marker','o','Color',[.5 .5 .5],'MarkerFaceColor','r')
plot(CoordCM_X(InOut==2),CoordCM_Y(InOut==2),'LineStyle','none','Marker','o','Color',[.5 .5 .5],'MarkerFaceColor','b')
plot(CoordCM_X(Center==0),CoordCM_Y(Center==0),'LineStyle','none','Marker','o','Color',[0 0 0])

hold off

hold on
gg=find(Center==1);
for ii=1700:1850
    plot(CoordCM_X(gg(ii)),CoordCM_Y(gg(ii)),'m+')
end

%%
% Coherence border and center
[pks,locs]=findpeaks(aux1000);
DataFilm=detrend(data1000(locs(1):locs(end)+50,:));
DataBorder(1,1:16)=0;
DataCenter(1,1:16)=0;
tVideoKwik=locs(end)+50-locs(1);
disp('Inter frame interval');
1/(length(Center)/(tVideoKwik))

cntCenter=1;
cntBorder=1;
SamplesPerFrame=10;

DataBorder=zeros(length(find(Center==0)),16);
DataCenter=zeros(length(find(Center==1)),16);

for ii=1:round(length(DataFilm)/SamplesPerFrame)
    I1=(ii-1)*SamplesPerFrame+1;
    I2=ii*SamplesPerFrame;
    if (Center(ii)==0)
        if (cntBorder*SamplesPerFrame)<=length(DataBorder)
        DataBorder((cntBorder-1)*SamplesPerFrame+1:cntBorder*SamplesPerFrame,:)=DataFilm(I1:I2,:);
        cntBorder=cntBorder+1;
        end
    else
        if (cntCenter*SamplesPerFrame)<=length(DataCenter)
        DataCenter((cntCenter-1)*SamplesPerFrame+1:cntCenter*SamplesPerFrame,:)=DataFilm(I1:I2,:);
        cntCenter=cntCenter+1;
        end
    end
end
%%

PFC_ch = 4;
VH_ch = 12;
DH_ch = 16;

[CdfC,fc]=mscohere(detrend(DataCenter(:,DH_ch)),detrend(DataCenter(:,PFC_ch)),1000,800,2^18,1000);
[CdvC,fc]=mscohere(detrend(DataCenter(:,DH_ch)),detrend(DataCenter(:,VH_ch)),1000,800,2^18,1000);
[CvfC,fc]=mscohere(detrend(DataCenter(:,VH_ch)),detrend(DataCenter(:,PFC_ch)),1000,800,2^18,1000);

[CdfB,fb]=mscohere(detrend(DataBorder(:,DH_ch)),detrend(DataBorder(:,PFC_ch)),1000,800,2^18,1000);
[CdvB,fb]=mscohere(detrend(DataBorder(:,DH_ch)),detrend(DataBorder(:,VH_ch)),1000,800,2^18,1000);
[CvfB,fb]=mscohere(detrend(DataBorder(:,VH_ch)),detrend(DataBorder(:,PFC_ch)),1000,800,2^18,1000);

save CoherenceCenterBorder CdfC CdvC CvfC fc CdfB CdvB CvfB fb PFC_ch VH_ch DH_ch
%%
subplot(2,2,1),
plot(fc,CdfC,'r')
hold on
plot(fb,CdfB,'k')
hold off
xlim([0 20])
title('DH x PFC')

subplot(2,2,2),
plot(fc,CvfC,'r')
hold on
plot(fb,CvfB,'k')
hold off
xlim([0 20])
title('VH x PFC')

subplot(2,2,3),
plot(fc,CdvC,'r')
hold on
plot(fb,CdvB,'k')
hold off
xlim([0 20])
title('VH x DH')
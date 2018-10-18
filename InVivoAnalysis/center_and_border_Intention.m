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
xR=[XX-8];

Center=zeros(length(CoordCM_X),1);
InOut=zeros(length(CoordCM_X),1);

%plot(CoordCM_X,CoordCM_Y)
for ii=1:length(CoordCM_X)
    if (CoordCM_X(ii)>xL & CoordCM_X(ii)<xR) & (CoordCM_Y(ii)>yT & CoordCM_Y(ii)<yB)
        Center(ii)=1;
        if ii>1 & ii<length(CoordCM_X)
            if Center(ii-1)==0 | Center(ii-2)==0
                InOut(ii)=1; % Animal is entering center
            end
            
            if not((CoordCM_X(ii+1)>xL & CoordCM_X(ii+1)<xR) & (CoordCM_Y(ii+1)>yT & CoordCM_Y(ii+1)<yB) | (CoordCM_X(ii+2)>xL & CoordCM_X(ii+2)<xR) & (CoordCM_Y(ii+2)>yT & CoordCM_Y(ii+2)<yB))
                InOut(ii)=2;
            end
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

%%
% First points
hold on
gg=find(Center==1);
for ii=1700:1850
    plot(CoordCM_X(gg(ii)),CoordCM_Y(gg(ii)),'m+')
end
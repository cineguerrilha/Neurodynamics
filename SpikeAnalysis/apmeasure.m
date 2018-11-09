function [ap, apf]=apmeasure(d,t)

dd=find(d==max(d));
dd=dd(1);

ap=d(dd-150:dd+500)-d(dd-150);

%t=0:si/1000:(length(ap)-1)*si/1000;
dV=integrateAP(ap);

plot(ap,'b')
hold on

app=max(ap);

dd=find(ap==max(ap));
plot(dd(1),app(1)-1,'rd');
text(dd(1)+10,app(1),num2str(app));

hw=find(ap>=app/2);

line([hw(1) hw(length(hw))],[app/2 app/2])
hw=t(length(hw));
text(hw(length(hw)),app/2,num2str(hw));
ahp=min(ap);
hold off

apf=[app;hw;ahp]
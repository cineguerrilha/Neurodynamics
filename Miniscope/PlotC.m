function h=PlotC(time, C, Space)
NeuNo=size(C,1);
hold on
for ii=1:NeuNo
    plot(time,C(ii,:)+(ii*Space),'k')
end
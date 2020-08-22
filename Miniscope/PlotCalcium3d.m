function h=PlotCalcium3d(C,t,Index,Colour)

for ii=1:length(Index)
    TraceNo=C(Index(ii),:);
    h=plot3(t,ones(length(TraceNo),1)*Index(ii),TraceNo',Colour);
    hold on
end
hold off
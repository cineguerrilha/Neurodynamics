TraceNo=size(ms.trace,2);

hold on
for ii=1:TraceNo
    plot(ms.time,ms.firing(:,ii)+(ii*.3),'r')
    plot(ms.time,ms.trace(:,ii)+(ii*.3),'k')
end
hold off

axis tight
axis off
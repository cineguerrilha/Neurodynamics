TraceNo=size(ms.FiltTraces,2);

figure(1)
hold on
for ii=1:TraceNo
    %plot(ms.time,ms.firing(:,ii)+(ii*.3),'r')
    plot(ms.FiltTraces(:,ii)+(ii*.3),'k')
end
hold off

axis tight
axis off



TotNeurons = size(ms.firing,2);
figure(2)
hold on
for ii=1:TotNeurons;
    [pks locs] = findpeaks(ms.firing(:,ii),'MinPeakHeight',.5*std(ms.firing(:,ii)));
    Neuron(ii).locs=locs;
    plot(ms.time(locs),ii,'k.')
end
hold off

TotalTime=ms.time(end)
Edges=1:100:TotalTime;

figure(3);
hold on
for ii=1:TotNeurons
    HistCh(:,ii)=histc(ms.time(Neuron(ii).locs),Edges);
    plot(Edges,HistCh(:,ii)+ii)
end
hold  off

figure(4)
plot(sum(HistCh'))
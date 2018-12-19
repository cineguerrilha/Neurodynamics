OutDir=['spk'];
mkdir(OutDir)

datakwik = load_open_ephys_kwik('experiment1_100.raw.kwd');

%%
thr=4; % Number of standard deviations for threshold

for ii=1:16

dd=eegfilt(datakwik{1,3}(ii,:),30000,600,6000);
subplot(4,4,ii),
    plot(dd(12000:122000))
    hold on
    sdd=std(dd(12000:122000))*-thr*ones(length(dd(12000:122000)),1);
    plot(sdd,'r--')
    hold off
    ii
    
    if length(find(dd(12000:122000)<std(dd(12000:122000))*-thr))>30
        data=double(datakwik{1,3}(ii,:));
        eval(['save ',OutDir,'/ch_',int2str(ii),' data']);
        disp(['Spikes detected! ch ',int2str(ii)]);
    end
end

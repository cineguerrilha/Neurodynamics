% Coherence and coordinate
PFC_ch = 4;
VH_ch = 9;
DH_ch = 16;

ChannelsReg = [PFC_ch VH_ch DH_ch];

[Cdf,tc,fc]=ch_time(detrend(data1000(:,DH_ch)),detrend(data1000(:,PFC_ch)),2000,1500,[1 20],1000);
[Cdv,tc,fc]=ch_time(detrend(data1000(:,DH_ch)),detrend(data1000(:,VH_ch)),2000,1500,[1 20],1000);
[Cvf,tc,fc]=ch_time(detrend(data1000(:,VH_ch)),detrend(data1000(:,PFC_ch)),2000,1500,[1 20],1000);

save Coherence Cdf Cdv Cvf tc fc ChannelsReg

%%
% Theta Coherence

T1 = [7 10];
for ii=1:length(tc)
    DFT1(ii,1)=max(Cdf(fc>T1(1) & fc<T1(2),ii));
    DVT1(ii,1)=max(Cdv(fc>T1(1) & fc<T1(2),ii));
    VFT1(ii,1)=max(Cvf(fc>T1(1) & fc<T1(2),ii));
end


if size(aux1000,2)>size(aux1000,1)
    aux1000=aux1000';
end

for ii=1:size(aux1000,2)
AA(ii)=mean(aux1000(:,ii));
end
AuxCh=find(AA>0);

[pks locs]=findpeaks(aux1000(:,AuxCh));
fps=1000/(locs(2)-locs(1));
TCoord=round(locs);

tc1000=tc*1000;
Coord=Coord(1:length(TCoord),:);
%%
DF=resample(smooth(DFT1,20),500,50);
map=colormap(jet(length(DF)));

if length(Coord)<length(DF)
scatter(Coord(:,1),Coord(:,2),40,map(1:length(Coord),:),'fill');
colormap('jet')
colorbar
else
    scatter(Coord(1:length(DF),1),Coord(1:length(DF),2),40,map,'fill');
    colormap('jet')
    colorbar
end

title('Dorsal PFC coherence')

%%
DF=resample(smooth(DVT1,20),500,50);
map=colormap(jet(length(DF)));

if length(Coord)<length(DF)
scatter(Coord(:,1),Coord(:,2),40,map(1:length(Coord),:),'fill');
colormap('jet')
colorbar
else
    scatter(Coord(1:length(DF),1),Coord(1:length(DF),2),40,map,'fill');
    colormap('jet')
    colorbar
end

title('Dorsal Ventral coherence')

%%
DF=resample(smooth(VFT1,20),500,50);
map=colormap(jet(length(DF)));

if length(Coord)<length(DF)
scatter(Coord(:,1),Coord(:,2),40,map(1:length(Coord),:),'fill');
colormap('jet')
colorbar
else
    scatter(Coord(1:length(DF),1),Coord(1:length(DF),2),40,map,'fill');
    colormap('jet')
    colorbar
end

title('Ventral mPFC coherence')
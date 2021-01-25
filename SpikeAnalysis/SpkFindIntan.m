%%

FN='animal2_210116';
files=dir([FN,'*.int'])

OutDir=['spk/',FN];
mkdir(OutDir);

%%


FNo=numel(files);

for jj=1:FNo
    
    [t,amps,y,aux] = read_intan_data_leao(files(jj).name);
    files(1).name
    ChannelNo=size(y,1);
for ii=1:ChannelNo
    
    dd=eegfilt(double(y(ii,1:100000)),25000,500,3000);
    plot(dd(2000:99000))
    hold on
    sdd=std(dd(2000:99000))*-5*ones(length(dd(2000:99000)),1);
    plot(sdd,'r--')
    hold off
    ii
    if length(find(dd(2000:99000)<std(dd(2000:99000))*-5))>20
        data=double(y(ii,:));
        eval(['save ',OutDir,'/',FN,'_',int2str(jj),'_ch_',int2str(ii),' data']);
        disp('Spikes detected!');
    end
    %pause
%    a(ii,1)=ii;
%    a(ii,2)=input('Spikes?');
end

end

%%
% Create a text file with all file names for Quiroga's wave_clus analysis
fid=fopen('Files.txt','w');
FN='*.mat';
files=dir([FN])
FNo=numel(files);
for ii=1:FNo
    fprintf(fid,[files(ii).name,'\n']);
end
fclose(fid)
%%
Get_spikes
Do_clustering
%%

FN='ms2*';
files=dir([FN])
FNo=numel(files);

for jj=1:FNo
    movefile(files(jj).name,[files(jj).name,'.mat']);
end


%%

% Check spike times

FN='times_*';
files=dir([FN])
FNo=numel(files);

for jj=1:FNo
load (files(jj).name)
files(jj).name
NoClusters = max(cluster_class(:,1))+1;

edges=(0:60)*1000;

for ii=1:NoClusters
    NeuNo=cluster_class(cluster_class(:,1)==ii-1,2);
    N = histc(NeuNo,edges);
    bar(edges,N,'histc');
    disp(['Cluster No. ',int2str(ii-1)]);
    pause
end
end

%%
FN='nic';
files=dir([FN,'*.int'])


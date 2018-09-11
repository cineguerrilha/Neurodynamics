IntFName='Animal_M1_Salina_60minAfter_151126_210840.int';
[t,amps,y,aux] = read_intan_data_leao(IntFName);

%%
% Resample
data1000=double(y(:,1:25:end));

%%
% Calculate PSD for all channels
for ii=1:16
    [p(:,ii)  f]=pwelch(detrend(data1000(ii,:)),4000,3000,2^17,1000);
    subplot(4,4,ii), plot(f,p(:,ii))
    xlim([3 12])
end

%%
% Hilbert for 2 thetas all channels
for ii=1:16
    tt2(ii,:) = eegfilt(data1000(ii,:),1000,4,6);
    tt1(ii,:) = eegfilt(data1000(ii,:),1000,7,9);
    Xt1(ii,:)=hilbert(tt1(ii,:));
    Xt2(ii,:)=hilbert(tt2(ii,:));
end

%%
% Plot all PSDs
% Theta 2
figure(1)

for ii=1:16
    subplot(4,4,ii), plot(f,p(:,ii),'k')
    %hold off
    xlim([2 12])
    title(['Channel ',int2str(ii)])
end


% Find Theta 2 peaks
figure(1)

for ii=1:16
    subplot(4,4,ii)
    hold on
    PeakTheta2(ii,2) = max(p(f>4 & f<6,ii));
    FT=find(p(:,ii)==PeakTheta2(ii,2));
    PeakTheta2(ii,1) = f(FT(1));
    plot(PeakTheta2(ii,1),PeakTheta2(ii,2),'go')
    hold off
    xlim([2 12])
end

MaxT2Ch=find(PeakTheta2(:,2)==max(PeakTheta2(:,2)));

ii=MaxT2Ch;
    
subplot(4,4,ii)
hold on
plot(f,p(:,ii),'r')

    xlim([2 12])
    title(['Channel ',int2str(ii),' P = ',num2str(max(PeakTheta2(:,2)))])
    hold off
    
%%
% Theta 1
% Plot all PSDs
figure(1)

for ii=1:16
    subplot(4,4,ii), plot(f,p(:,ii),'k')
    %hold off
    xlim([2 12])
    title(['Channel ',int2str(ii)])
end


% Find Theta 2 peaks
figure(1)

for ii=1:16
    subplot(4,4,ii)
    hold on
    PeakTheta1(ii,2) = max(p(f>7 & f<8,ii));
    FT=find(p(:,ii)==PeakTheta1(ii,2));
    PeakTheta1(ii,1) = f(FT(1));
    plot(PeakTheta1(ii,1),PeakTheta1(ii,2),'go')
    hold off
    xlim([2 12])
end

MaxT1Ch=find(PeakTheta1(:,2)==max(PeakTheta1(:,2)));

ii=MaxT1Ch;
    
subplot(4,4,ii)
hold on
plot(f,p(:,ii),'r')

    xlim([2 12])
    title(['Channel ',int2str(ii),' P = ',num2str(max(PeakTheta1(:,2)))])
    hold off
    
%%
t1Ch=1;
t2Ch=1;

subplot(2,1,1),plot(abs(Xt1(t1Ch,:)))
title('Theta 1')

subplot(2,1,2),plot(abs(Xt2(t2Ch,:)))
title('Theta 2')

%%
% Calculate distance and speed
FrameRate=20;
CoorFName=[IntFName(1:end-4),'_Coord.mat'];
load(CoorFName);
D(1)=0;
for ii=2:size(Coord,1)
D(ii-1)=sqrt((Coord(ii,1)-Coord(ii-1,1))^2+(Coord(ii,2)-Coord(ii-1,2))^2);
end

V=smooth(abs(diff(D)));
tVideo = (1:size(Coord,1));
tLFP = (1:length(data1000))/1000;

%%
% Correlate theta 1 and 2 with Speed
for ii=1:16
    t1=resample(smooth(abs(Xt1(ii,:)),100),FrameRate,1000);
    LenV=min([length(t1) length(V)]);
    R=corrcoef(t1(1:LenV),V(1:LenV));
    rT1(ii)=R(2,1);
    
    t2=resample(smooth(abs(Xt2(ii,:)),100),FrameRate,1000);
    LenV=min([length(t2) length(V)]);
    R=corrcoef(t2(1:LenV),V(1:LenV));
    rT2(ii)=R(2,1);
end

%%
% Plot PSDs and correlation coefficients
figure(1)

for ii=1:16
    subplot(4,4,ii), plot(f,p(:,ii))
    xlim([2 12])
    title(['r = ',num2str(rT1(ii))])
end

%%
% theta 2
FrameRate=15;

ii=MaxT1Ch;  % Max theta 2 Hilbert
ii=9;
t1=resample(smooth(abs(Xt1(ii,:)),100),FrameRate,1000);
a=colormap('jet');

% Scale Theta2 in 64 values

MinT1=min(t1);
MaxT1=max(t1-MinT1);
t1Scaled = round(((t1-MinT1)/MaxT1)*63+1);

%plot(Coord(:,1),Coord(:,2),'k')

hold on
for jj=1:size(Coord,1)
    plot(Coord(jj,1),Coord(jj,2),'.','Color',a(t1Scaled(jj),:),'MarkerFaceColor',a(t1Scaled(jj),:))
end
hold off
cd '/Users/Tort/Desktop/2011_OsanTortAmaralcodes/Richardson'

clear all

load('004.mat') %1, 4, 7


%%


plot(fired1/10/1000,ones(size(fired1)),'ko')

hold on

plot(fired2/10/1000,2*ones(size(fired2)),'bo')
plot(fired3/10/1000,3*ones(size(fired3)),'ro')

hold off

ylim([0 4])

% %

% xlim([0 1]+0)
%%


strings{1} = '001.mat'
strings{2} = '004.mat'
strings{3} = '007.mat'

srate = 10000;

clear fired*

for j=1:3

load(strings{j}) %1, 4, 7

subplot(2,2,j)


spiketimes1 = zeros(1,max(fired1(end),fired2(end)));
spiketimes2 = spiketimes1;

spiketimes1(fired1)=1;
spiketimes2(fired2)=1;

% use this option if you want to compare the CCG peaks across groups (this
% does not depends on the number of spikes)
[CCG lags] = xcorr(spiketimes1,spiketimes2,1*srate,'coeff');

% absolute, non normalized cross-correlogram (which depends on the number
% of spikes)
% [CCG lags] = xcorr(spiketimes1,spiketimes2,1*srate);

% %

% smoothing
CCG = smooth(CCG,100);
%%%

bar(lags/srate*1000,CCG,'k')

xlim([-200 200])


set(gcf,'color','white')
set(gca,'fontsize',14)

xlabel('Time (ms)')

ylimits = ylim()
ylim([0 ylimits(2)])

% ylim([0 1])

% ylabel('Counts')



% %


I = find(lags/srate*1000 > -50 & lags/srate*1000 < 50);
I2 = find(lags/srate*1000 > -500 & lags/srate*1000 < 500);
I2 = setdiff(I2,I);


synchronyindex = max(CCG(I))/sqrt(length(fired1)*length(fired2));
synchronyindex = max(CCG(I))/max(CCG(I2))

ylabel(['Cell 1 and 2; ' ' Sync Index = ' num2str(synchronyindex)])
title(strings{j})

ylim([0 3]/1000)

end
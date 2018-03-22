

% filter twice just in case...
%lg= eegfilt(lfp,srate,4,8);
%lg= eegfilt(lg,srate,4,8);
lg=lfp;

% if you want only the biggest peak per theta cycle, use this
% [pks loc]=findpeaksMATLAB(lg,'minpeakdistance',round(srate*0.1));

% if you want all peaks, use this
[pks loc]=findpeaks(lg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%


% % % % if you want to use a threshold to get the larger peaks, run this:
% amplg=abs(hilbert(lg));
% thresh = mean(amplg)+2*std(amplg);
% II = find(amplg>thresh);
% loc=intersect(loc,II);

  MEANLFP = zeros(1,srate+1);
      use=0;
for j=1:length(loc)
   if loc(j)>srate/2+1 & loc(j) < (length(LFP)-srate/2+1)
       use=use+1;
    
        MEANLFP = MEANLFP+LFP((loc(j)-srate/2):(loc(j)+srate/2));

   end
end

meansignal=(MEANLFP)/use;


subplot(1,1,1)
plot(-1/2:dt:1/2,(meansignal),'k-','linewidth',2)
xlim([-0.4 0.4])

%%
% % doing all channels centered by the peaks of ref channel

clear meansignalall
con2 = 0;
for ch=depth_NN
      
    %%%%%
    % program here to do the loading as you want....
    channel = ch;
LFP = lfp(channel,:);
    %%%%
    
    
con2 = con2 + 1;

% filter each channel
%lg = eegfilt(LFP,srate,30,55);%
 lg=LFP; 
% theta=LFP;

LGMEDIO = zeros(1,srate+1);
theta=lfp;
use=0;
for j=1:length(loc)
   if loc(j)>srate/2+1 & loc(j) < (length(theta)-srate/2+1)
       use=use+1;
       LGMEDIO = LGMEDIO+lg((loc(j)-srate/2):(loc(j)+srate/2));
%        THETAMEDIO = THETAMEDIO+lfp((loc(j)-srate/2):(loc(j)+srate/2))';

   end
end

    meansignal=(LGMEDIO)/use;

    meansignalall(con2,:)=meansignal;

end


%%
% 

figure(2)
for ch=1:16
   
subplot(1,1,1)
plot(-1/2:dt:1/2,meansignalall(ch,:)/60-ch,'k-','linewidth',2)
% xlim([-0.05 0.05])    
hold on
end
hold off

% axis tight

%%
% computing CSD
clear CSD
con3 = 1;
for ch=2:15
    con3 = con3 + 1;
    CSD(con3-1,:) = - meansignalall(con3-1,:)+2*meansignalall(con3,:)-meansignalall(con3+1,:);

end

%%

figure(5)
clf
contourf(-1/2:dt:1/2,2:con3,CSD(end:-1:1,:), 100,'linecolor','none')

% %
% axis xy
hold on
con4 = 0;
for ch=1:16
    con4 = con4 + 1;
    plot(-1/2:dt:1/2,meansignalall(con4,:)/50-con4/1.1+16.1,'k-','linewidth',2)
    hold on
end

hold off


ylim([0 con4+1])
% xlim([-0.02 0.02])

colorbar
% caxis([-2 2])

% end
% end

% axis tight
% axis off

% caxis([-60 60])


% ylim([6 16])
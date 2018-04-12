%% Run this if you have used edrloadAnnara
[dd, h, EDRFile, EDRPath] = edrloadAnnara;
d=dd(:,2);  % Check if the data is in channel

plot(d)

si=h.DT;

% d=d(1:2:end);
% si=si*2;
%%
% IF YOUR SIGNAL HAS NO DRIFT
% skip the cell bellow
f1=mean(d(1000:1000));
close all
%% Condition the signal
% Positivity bias (peaks are positive)
r = 6;          % r : asymmetry parameter
% Regularization parameters
amp = 0.8;
lam0 = 0.5*amp;
lam1 = 5*amp;
lam2 = 4*amp;
fc = 0.00002;
disp('Calculating baseline')
tic
[x1, f1, cost] = beads(d, 1, fc, r, lam0, lam1, lam2);
toc
close all
%%
% Here you will separate an event
% First you need to zoom with the zoom tool of the figure (lupa)
% Press 'enter'
% then you will see crosses on the matlab figure
% You will click at the beginning and end of an event

disp('Subtracting baseline and smoothing')
disp('1 s of data will be erased in each corner')
dBaseLine=smooth(d-f1,100);
dBaseLine=dBaseLine(25000:end-25000);
plot(dBaseLine)
title('Zoom in to select an event')
axis('tight')
disp('Zoom around one event')
pause
title('Click to separate an event')
g=ginput(2);

%%
% Single event
SEv=dBaseLine(round(g(1,1)):round(g(2,1)));
plot(SEv)


title('click at the beginning of the event')
g2=ginput(1);
plot(SEv(round(g2(1,1)):end))
SEvFit=SEv(round(g2(1,1)):end);
t=1:length(SEvFit);
%%
plot(SEvFit)

b0=[2060.49577484988 2728.72806808829 156.379023864282 279.320339523915 0.499989127856847 -.2];

[b,r,j] = nlinfit(t',SEvFit,'PSP_fit',b0);
hold on
plot(t,PSP_fit(b,t),'r')
hold off
SEvFit=PSP_fit(b,t);
%%
% Run correlation coefficients to detect events
tic
% gui_active(1);      % will add an abort button
% hProg = progressbar( [],0,'Detecting events' );
for ii=1:length(dBaseLine)-length(SEvFit)
    C=corrcoef(dBaseLine(ii:(ii-1)+length(SEvFit)),SEvFit);
    CVec(ii)=C(2,1);
%     hProg = progressbar( hProg,1/(length(dBaseLine)-length(SEvFit)));
%         if ~gui_active
% 	                break;
%         end
end
% progressbar( hProg,-1 );
toc
%%
CVec2=zeros(length(CVec),1);
CVec2(CVec>.95)=1; % detection threshold

% plot(dBaseLine)
% hold on
% plot(5*CVec2)
% hold off

%Plot the located peaks
[pks locs]=findpeaks(CVec2);
plot(dBaseLine)
hold on
plot(locs,0,'ro')
hold off

%%
clear SynEvents
BL=100;
EL=3000;
for ii=1:length(locs)
    if locs(ii)+EL<length(dBaseLine)
    SynEvents(:,ii)=dBaseLine(locs(ii)-BL:locs(ii)+EL);
    end
end

plot(SynEvents,'k')
hold on
plot(mean(SynEvents'),'r')
hold off

%[FileName,PathName,FilterIndex] = uiputfile;
FileName=EDRFile(1:end-4);
save(FileName,'d','h','SynEvents','EDRPath','locs')

%%
close all

SEv=mean(SynEvents');
SEv=SEv-mean(SEv(1:10));
plot(SEv)


title('click at the beginning of the event')
g2=ginput(1);
plot(SEv(round(g2(1,1)):end))
SEvFit=SEv(round(g2(1,1)):end)';
t=1:length(SEvFit);

SEvFit=SEvFit*-1;
plot(SEvFit)

HW=length(find(SEvFit>max(SEvFit)/2))
%b0=[150 10 56.37902 279.320339523915 0.001 -.2];
Peak=find(SEvFit==max(SEvFit));
Rise=SEvFit(1:Peak);
Rise=Rise-min(Rise);
Rise=Rise/max(Rise);

Decay=SEvFit(Peak+1:end);
Decay=Decay-min(Decay);
Decay=Decay/max(Decay);

deact=inline('((1-b(1)).*exp(-x./b(2))+b(1)+exp(-x./b(3)))*b(4)','b','x');
Act=inline('(1-exp(-x./b(1)))','b','x');

b0Act=[5];
[bAct,r,j]=nlinfit((1:length(Rise))-1,Rise',Act,b0Act);

b0Decay=[0.1; 50; 300; 1.1];
[bDecay,r,j] = nlinfit((1:length(Decay))-1,Decay',deact,b0Decay);

disp('Press enter')
pause
subplot(211),plot(Rise)
title('Activation')
hold on
plot(Act(bAct,(1:length(Rise))-1),'r')
hold off

subplot(212),plot(Decay)
title('Deactivation')
hold on
plot(deact(bDecay,(1:length(Decay))-1),'r')
hold off

% [b,r,j] = nlinfit(t,SEvFit,'PSP_fit',b0);
% 
% plot(t,PSP_fit(b,t),'r')
% hold off
% SEvFit=PSP_fit(b,t);

SynParams=[bAct(1);bDecay(1:3);HW;max(SEvFit)]
disp('Press enter')
clear all

%%
t=(1:length(SynEvents))/20;
plot(t,SynEvents,'k')
hold on
h=plot(t,mean(SynEvents'),'r');
hold off
set(h,'LineWidth',2)
xlim([0 100])
box off
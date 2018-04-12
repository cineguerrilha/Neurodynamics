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
%%
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
plot(t,PSP_fit(b,t))
hold off
SEvFit=PSP_fit(b,t);
%%
for ii=1:length(dBaseLine)-length(SEvFit)
    C=corrcoef(dBaseLine(ii:(ii-1)+length(SEvFit)),SEvFit);
    CVec(ii)=C(2,1);
end

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
    SynEvents(:,ii)=dBaseLine(locs(ii)-BL:locs(ii)+EL);
end

plot(SynEvents,'k')
hold on
plot(mean(SynEvents'),'r')
hold off
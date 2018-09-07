function [cxx,t,f]=ch_time(X,Y,Window,Overlap,F,SF)

% Calculates coherence vs. time sliding a window of
% mscohere.
% [cxx,t,f]=ch_time(X,Y,Window,Overlap,SF);
%[cxx,t,f]=ch_time(LFP(:,1),LFP(:,2),6000,5500,[0 20],2000);
% -----------------------------------------------------------
% Outputs:
% cxx: coherence matrix
% t: time vector
% f: frequency vector
% -----------------------------------------------------------
% Inputs:
% X and Y: input time series
% Window: the length of the window in sample for mscohere
% Overlap: number of overlaping samples between each window
% F: Two elemnet vector frequencies with frequencies to be
%       displayed (e.g. [0 30], calculates coherence from
%       0 to 30Hz
% SF: Sampling frequency

WindowInc = Window-Overlap;
L = length(X);

% Here I filter because of movement artfacts
% X=eegfilt(X',2000,2,F(2)+10);
% Y=eegfilt(Y',2000,2,F(2)+10);


IFinal=Window;
IStart=1;
Cnt=1;
while (IFinal<L)
    x=X(IStart:IFinal);
    y=Y(IStart:IFinal);
    [C ff]=mscohere(x,y,[],[],2^17,SF);
    cxx(:,Cnt)=C(ff>=F(1) & ff<=F(2));
    t(Cnt)=(WindowInc*Cnt)/SF;
    Cnt=Cnt+1;
    IStart=IStart+WindowInc;
    IFinal=IFinal+WindowInc;
end
% 
% plot(x)
% hold on
% plot(y,'r')
% hold off
% pause 
% plot(ff,C)

f=ff(ff>=F(1) & ff<=F(2));

imagesc(t,f,cxx)
colorbar
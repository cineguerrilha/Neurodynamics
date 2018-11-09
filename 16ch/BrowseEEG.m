% Plots the PSD of an EEG trace below the mouse pointer
% Usage:
% 
% Data with channels as columns and 1000Hz sampling rate
% samples = the amount of samples before and after the point where the
% mouse is.
% ID is the amount of points in the y axis between ea channel

ID=2000;
samples=3000;

global curr_point

hold off

% ElM=[6 11 3 14 1 16 2 15 5 12 4 13 7 10 8 9];
% data=y(ElM,1:25:end);
% data=data';

[m,n]=size(data);

d2=zeros(m,n);

for ii=1:n
    d2(:,ii)=data(:,ii)+ii*ID;
end

ff=figure(1);
hh=plot(d2,'k');
axis('tight');

set(ff, 'WindowButtonMotionFcn', @(obj, event)PlotEEGCallback(obj, event, data,samples,ID,m,n))
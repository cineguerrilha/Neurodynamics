%% Measure sag 
SagChannel = 1;  %channel in which the seg will be measured
sig1=squeeze(d(:,1,SagChannel));
t=0:1/(si*1e-3):(length(sig1)-1)*(1/(si*1e-3));
h=figure(101)
plot(t,sig1)
title('Click on sag')
g=ginput(1);
Sag=g(1);
plot(t,sig1)
title('Click on steady state')
g=ginput(1);
SS=g(1);
title('Click on depolarization')
g=ginput(1);
depol=g(1);

%%
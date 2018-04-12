function y=PSP_fit(b,x)
Amp=b(1);
tauAct=b(2);
tauD1=b(3);
tauD2=b(4);
D1D2=b(5);
S1=b(6);
y=Amp.*((1-exp(-x./tauAct)).*((1-D1D2).*exp(-x./tauD1)).*D1D2.*exp(-x./tauD2))+S1;
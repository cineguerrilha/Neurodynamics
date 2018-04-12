function dV=integrateAP(d);

for ii=2:length(d)
	dV(ii-1)=(d(ii)-d(ii-1))/2;
end
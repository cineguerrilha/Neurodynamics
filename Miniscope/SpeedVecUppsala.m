SpeedSteps=100;
StepDelay=0.6;
FixedStepTime=60;


TTot=(2*SpeedSteps*StepDelay+FixedStepTime)*1000;
STmsec=StepDelay*1000;
V=zeros(1,TTot);
cnt=0;
for ii=1:SpeedSteps
    V((ii-1)*STmsec+1:ii*STmsec)=cnt;
    cnt=cnt+1/SpeedSteps;
end
OffSet=ii*STmsec;
V(OffSet+1:OffSet+(FixedStepTime*1000))=cnt;
OffSet=OffSet+(FixedStepTime*1000);
for ii=1:SpeedSteps
    V(OffSet+(ii-1)*STmsec+1:ii*STmsec+OffSet)=cnt;
    cnt=cnt-1/SpeedSteps;
end
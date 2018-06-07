function Samples=ReadMiniscopeControlLog(fname)
% read binary data from the MiniscopeControl program
% Usage
% Samples=ReadMiniscopeControlLog(fname);
% where fname is the file name...

fileID = fopen(fname);
a=fread(fileID,250,'char');
EoS=find(a==10);
EndOfString=EoS(1);
EndOfNumSample=EoS(2);
S1=(char(a(EndOfString+1:EndOfNumSample-2)))';

ChannelNo=length(find(a(1:EndOfString)==9));
NumSamples = str2double(S1);
disp(['The file contains ',S1,' in ',int2str(ChannelNo),' channels']);
disp('Channel names');
disp(char(a(1:EndOfString-2)'));
if a(EndOfString-1)~=13
    disp('Problem finding the end of the string, data may be corrupted')
end

if a(EndOfNumSample-1)~=13
    disp('Problem finding the end of the Num Samples, data may be corrupted')
end

fclose(fileID);


fileID = fopen(fname);
a=fread(fileID,EndOfNumSample,'char');

% read all the stupid samples
StrSamples=fread(fileID,'char');
%s2=fread(fileID,1100,'double');

feof(fileID)
fclose(fileID);

% Change all commas to dots
StrSamples(StrSamples==44)=46;

%find all string ends
NoStr=find(StrSamples==9);

StrInit=0;
for ii=1:length(NoStr)
    Samples(ii)=str2double(char(StrSamples(StrInit+1:NoStr(ii))'));
    StrInit=NoStr(ii);
end

Samples=reshape(Samples',[ChannelNo,NumSamples]);
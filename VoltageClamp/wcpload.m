function [d,t,Header]=wcpload(FName)

Fid = fopen(FName,'r');
Version = fread(Fid,[1,1024],'char');

Version(Version==0)=[];
fclose(Fid);



l10=find(Version==10); % newline (\n)
l13=find(Version==13); % return (\r)

if (length(l10)==length(l13))
    cnt=1;
    for ii=1:length(l13)
        Str=char(Version(cnt:l13(ii)));
        Str=strrep(Str,',','.');
        Header{ii} = cellstr(Str);
        cnt = l13(ii)+2;
        try
            eval(char(Header{ii}));
        catch exception
            disp([char(Header{ii}), ' Not Evaluated...']);
        end
    end
end



Fid = fopen(FName,'r');

HeaderSize = (round((NC-1)/8)+1)*1024;

Version = fread(Fid,[1,HeaderSize],'char');

l10=find(Version==10); % newline (\n)
l13=find(Version==13); % return (\r)

if (length(l10)==length(l13))
    cnt=1;
    for ii=1:length(l13)
        Str=char(Version(cnt:l13(ii)));
        Str=strrep(Str,',','.');
        Header{ii} = cellstr(Str);
        cnt = l13(ii)+2;
        try
            eval(char(Header{ii}));
        catch exception
            disp([char(Header{ii}), ' Not Evaluated...']);
        end
    end
end

Data = fread(Fid,'int16');
HeaderSize
length(Data)
%Data = (Data/ADCMAX)*AD;

fclose(Fid)

for ii=1:NC
    %dd=Data(2+((ii-1)*2):(ii-1)*2+2:end);
    eval(['Offset=YO',int2str(ii-1)]);
    %Offset = Offset + NC*1024;
    dd=Data(ii:NC:end);
    dd=reshape(dd,[length(dd)/NR,NR]);
    %dd=dd(Offset:end,:);
    eval(['Gain=YG',int2str(ii-1)]);
%    disp(['Gain=YG',int2str(ii-1)])

d(ii).Ch=dd*(1/(ADCMAX*Gain));
g=length(dd);

end

t=(1:length(dd))*DT;
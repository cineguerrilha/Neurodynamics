function [Data,Time,Header,Analysis]=wcpload(FName)

Fid = fopen(FName,'r');
tmpheader = fread(Fid,[1,1024],'char');

    function out = getHeader(rawheader)
        headercmd  = strsplit(char(rawheader),[char(13) char(10)]);
        for h = 1 : 25
            var{h} = strrep(headercmd{h}(1:strfind(headercmd{h},'=')-1),char(10),'');
            val{h} = headercmd{h}((strfind(headercmd{h},'=')+1):end);
            
            if isnan(str2double(val{h}))
                cmd = ['out.' var{h} ' = ''' val{h} ''';'];
            else
                cmd = ['out.' var{h} ' = ' val{h} ';'];
            end
            
            eval(cmd)
        end
    end

tmpHeader = getHeader(tmpheader);
NC        = tmpHeader.NC;
clear tmpHeader

frewind(Fid)

HeaderSize = ((round(NC-1)/8)+1)*1024;
header = fread(Fid,[1,HeaderSize],'char');
Header = getHeader(header);

for r = 1 : Header.NR
    Analysis(r).record_status     = char(fread(Fid,8,'char')');
    Analysis(r).record_type       = char(fread(Fid,4,'char')');
    Analysis(r).group_number      = fread(Fid,1,'float32');
    Analysis(r).time_recorded     = fread(Fid,1,'float32');
    Analysis(r).sampling_interval = fread(Fid,1,'float32');
    Analysis(r).ad_range          = fread(Fid,NC,'float32');
    Analysis(r).marker            = char(fread(Fid,18,'char')');
    Analysis(r).values            = fread(Fid,244,'float32');
    waste                         = char(fread(Fid,2,'char')')-0;
    
    Data(r,:) = fread(Fid,Header.NBD*256,'int16');
end
Data   = (Data/Header.ADCMAX)*Header.AD;
Time   = (1:length(Data))*Header.DT;
end
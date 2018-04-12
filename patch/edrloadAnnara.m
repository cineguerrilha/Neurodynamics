function [data, h, EDRFile, EDRPath] = edrloadAnnara

[file,PathName,FilterIndex] = uigetfile('*','EDR file')
% function [data, h] = import_edr(file)

EDRFile = file;
EDRPath = PathName;


% Imports .edr file to matrix

% for use with files output by WinEDR,

%   http://spider.science.strath.ac.uk/sipbs/page.php?show=software_ses

% but created independently

%
 
% ---------------inputs------------------------------

% file      .edr file name ( e.g. 'File_001.EDR')

%

% ---------------outputs-----------------------------

% data      m x (n+1) matrix of data, where n is number of channels

%               and m is total number of samples

% h         structure array with header data

%

% created by Peter Weir, California Institute of Technology, June, 2007

% no guarantees

% Adapted from import_abf by Michele Giugliano (http://www.giugliano.info)



if ~strncmpi(fliplr(file),'rde.',4);

    file = strcat(file,'.EDR');

end



fid = fopen(file);



num_left = 2048;

while ~feof(fid)

    s = fgetl(fid);

    num_left = num_left-length(s);

    if num_left<0, break, end

    k = strfind(s,'=');

    if ~(isempty(k))

        key = s(1:k-1);

        if strncmp(key,'YN',2) | strncmp(key,'YU',2) | strcmp(key,'TU') | strcmp(key,'ID') | strcmp(key,'BAK') | strcmp(key,'WCPFNAM')

            h.(key) = s(k+1:length(s));

        else

            h.(key) = str2num(s(k+1:length(s)));

        end

    end

end



fseek(fid, h.NBH, 'bof');

data = fread(fid, h.NP, 'short');

data = reshape(data,h.NC,h.NP/h.NC)';



for Ch = 0:h.NC-1

    YCFCh = strcat('YCF',int2str(Ch));

    data(:,Ch+1) = (h.AD/((h.ADCMAX+1)*h.(YCFCh)))*data(:,Ch+1);

end

time = [0:h.DT:h.DT*(h.NP/h.NC-1)];

data = [time' data];



fclose(fid);
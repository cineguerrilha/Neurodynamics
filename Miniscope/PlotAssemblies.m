load('temporal.mat')
CALCIUM_FLUORESCENCE_CONVERSION('~/','CT',C_temporal,1/30,1)
CALCIUM_FLUORESCENCE_PROCESSING( [ '~/' 'CT' '/' 'CT' '_CALCIUM-FLUORESCENCE.mat' ] )

SGC_ASSEMBLY_DETECTION( [ '~/' 'CT' '/' 'CT' '_ACTIVITY-RASTER.mat' ] )

load('C.mat')
CALCIUM_FLUORESCENCE_CONVERSION('~/','C',C,1/30,1)
CALCIUM_FLUORESCENCE_PROCESSING( [ '~/' 'C' '/' 'C' '_CALCIUM-FLUORESCENCE.mat' ] )
SGC_ASSEMBLY_DETECTION( [ '~/' 'C' '/' 'C' '_ACTIVITY-RASTER.mat' ] )
%%
ICA_ASSEMBLY_DETECTION( [ '~/' 'CT' '/' 'CT' '_CALCIUM-FLUORESCENCE.mat' ] )
ICA_ASSEMBLY_DETECTION( [ '~/' 'C' '/' 'C' '_CALCIUM-FLUORESCENCE.mat' ] )
%%
fileID = fopen('timestamp.dat','r');
dataArray = textscan(fileID, '%f%f%f%f%[^\n\r]', 'Delimiter', '\t', 'EmptyValue' ,NaN,'HeaderLines' ,1, 'ReturnOnError', false);
camNum = dataArray{:, 1};
frameNum = dataArray{:, 2};
sysClock = dataArray{:, 3};
buffer1 = dataArray{:, 4};
clearvars dataArray;
fclose(fileID);

miniscopeCam=0;
TimeMiniscope = sysClock(camNum==miniscopeCam);
TimeMiniscope(1)=0;
%%

[ImGrey, ImRGB]=UnitImage(A_temporal,[0 .3 0]);
figure(1)
image(ImRGB)
title('Detected Units')
%pause
%%
Assemblies_Length=length(cs_assemblies);
Assemblies=cs_assemblies;
for ii=1:Assemblies_Length
    [ImGrey, ImRGB_A]=UnitImage(A_temporal(:,:,Assemblies{ii}),[.5 0 0]);
    figure(2)
    for jj=1:length(Assemblies{ii})
        plot(C_temporal(Assemblies{ii}(jj),:)+jj*20)
        hold on
    end
    hold off
    figure(1)
    image(ImRGB+ImRGB_A)
    title(['Assembly ',int2str(ii),' in ',int2str(Assemblies_Length)])
    pause
end

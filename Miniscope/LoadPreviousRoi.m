function ms=LoadPreviousRoi(ms)

[baseFileName, folder] = uigetfile('*.mat', 'Select the ms mat file');

fullFileName = fullfile(folder, baseFileName);
MsStruct=load(fullFileName);

    ms.fluorThresh = MsStruct.ms.fluorThresh;
    ms.goodFrame = ms.meanFluorescence>=ms.fluorThresh;
    ms.alignmentROI=MsStruct.ms.alignmentROI;
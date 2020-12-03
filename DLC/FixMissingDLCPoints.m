function [NewTrack] = FixMissingDLCPoints(VideoFile, TrackCSV, Thr, NoFixPoints, CoordPoint, FirstFrame)
%[NewTrack] = FixMissingDLCPoints(VideoFile, TrackCSV, Thr, NoFixPoints, CoordPoint)
%Input arguments
% VideoFile: Video file name
% TrackCSV: Array with DLC tracking results
% Thr: Likelihood threshold
% Number of points to retrack
% first columns of these points
% FirstFrame: first movie frame to start retracking
%To open the CSV file, use:
% TrackCSV=csvread('20201125DLC_resnet50_SomPlaceNov26shuffle1_1030000filtered.csv',3,0);
% these files have 3 columns per tracking point: x,y,likelihood
% and one columns with the frame number (1st)
VidObj=VideoReader(VideoFile);
NewTrack = TrackCSV;
TotalFrames = VidObj.Duration*VidObj.FrameRate
MaxFrames = min([TotalFrames size(TrackCSV,1)])
for ii=FirstFrame:MaxFrames
    if TrackCSV(ii,CoordPoint+2)<Thr
        disp(['Likelihood = ',num2str(TrackCSV(ii,CoordPoint+2))])
        disp(['FrameNo = ',num2str(TrackCSV(ii,CoordPoint+2)),'   ii = ',num2str(ii)]);
        Img=read(VidObj,ii);
        disp('Click on the first tracking point');
        Img=read(VidObj,ii);
        figure(1)
        imagesc(Img)
        title(num2str(ii));
        [x,y]=ginput(1);
        NewTrack([CoordPoint CoordPoint+1 CoordPoint+2],ii)=[x y 1.5];
    end
end
close(VidObj)
end


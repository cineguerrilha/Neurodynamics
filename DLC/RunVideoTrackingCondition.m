function [FrameNo, TimeVec, Out] = RunVideoTrackingCondition(VideoFileName,Condition, X)
% This function reads video and tracking files amd perform some logical
% operation with the tracking coordinates or likelihood
% Usage:
% [FrameNo, TimeVec] = RunVideoTrackingCondition(VideoFileName,Condition)
% VideoFileName is the Video file name. The tracking CSV file has to have
% the same name as the video file
% Condition:
% 'dist' calculaate the distance between tracking coordinates
% X should then be an array with minimal distance thresholds (negative
% X values) or maximal distance thresholds (positive X values).
% How to assemble X:
% let's say for example that your tracking has 4 body parts (B1, B2, B3, B4), 
% your condition is:
% find the frames in which B1, B2 and B3 need to be less than 10 pixels
% away from B4, then X would be equal to:
% X = [0 0 0 10; 0 0 0 10; 0 0 0 10; 0 0 0 10];
% Now, B1 has to be 10 pixels away from B3 and B2 has to be 10 pixels away
% from B4:
% X = [0 0 10 0; 0 0 0 10; 0 0 0 0; 0 0 0 0];
% When Condition = 'prob'
% X is a vector with a threshold in which the likelihood has to be greater
CSVFile=[VideoFileName(1:end-4),'.csv'];
TrackCSV=csvread(CSVFile,3,0);
if Condition=='dist'
    N=size(X,1);
    TrackPoints=size(TrackCSV,1);
    ThrLength=sum(sum(X~=0));
    D=zeros(TrackPoints, ThrLength);
    cnt=1;
    for ii=1:N
        for jj=1:N            
            if X(ii,jj)~=0
                for Lines=1:TrackPoints
                    x1=TrackCSV(Lines, 2+((ii-1)*3));
                    x2=TrackCSV(Lines, 2+((jj-1)*3));
                    y1=TrackCSV(Lines, 3+((ii-1)*3));
                    y2=TrackCSV(Lines, 3+((jj-1)*3));
                    D(Lines,cnt)=sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
                end
                thr_D(cnt)=X(ii,jj);
                cnt=cnt+1;
            end
        end
    end
    TimeVec = 0;
    Out.D=D;
    Out.CSV = TrackCSV;
    DistColumns = size(D,2);
    cnt=1;
    for Lines=1:length(D)
        for ii=1:DistColumns
            Conditions(ii)=D(Lines,ii)<thr_D(ii);
        end
        if sum(Conditions)==DistColumns
            FrameNo(cnt)=Lines;
            cnt=cnt+1;
        end
    end
end

if Condition=='prob'
    N=length(X);
    TrackPoints=size(TrackCSV,1);
    for Lines=1:TrackPoints
        for ii=1:N
            Conditions(ii)=TrackCSV(Lines,4+((ii-1)*3))>X(ii);
        end
        if sum(Conditions)==N
            FrameNo(Lines)=Lines;
        end
    end
    TimeVec=0;
    Out=0;
end

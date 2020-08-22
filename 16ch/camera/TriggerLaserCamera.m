% create GUI
flagCap=0; %live preview
flagTra=1; %tracking
flagExi=0; %exit

fh = figure('Position',[200 200 200 200],...
       'Toolbar','none',...
       'Menubar', 'none',...
       'NumberTitle','Off',...
       'Name','Camera view GUI');   
ph = uipanel('Parent',fh,'Units','pixels',...
           'Position',[20 20 120 130]);
       
bh1 = uicontrol(ph,'Style','pushbutton',...
           'Callback', 'close;flagTra=0;flagExi=1;',...
           'String','Exit','Position',[20 40 80 30]);
       
%%
% Create video input object. 
vid = videoinput('winvideo',1,'YUY2_640x480')
vid.ReturnedColorSpace = 'grayscale';
% Set video input object properties for this application.
vid.TriggerRepeat = 100;
vid.FrameGrabInterval = 1;

% Set value of a video source object property.
vid_src = getselectedsource(vid);
vid_src.Tag = 'motion detection setup';

% Create a figure window.
figure; 

% Start acquiring frames.
start(vid)
pause(1)
vid.FramesAvailable
% Calculate difference image and display it.
%while(vid.FramesAvailable >= 2)
while(flagExi==0)
    if vid.FramesAvailable > 0
    [data,time] = getdata(vid,1); 
    time
    imshow(data);
    drawnow     % update figure window
    end
    pause(.01)
end

stop(vid)
%% 
% tracking (modified by Helton)
clear all
clc
%% 
% video cam configuration
hVideoIn = vision.VideoPlayer;
hVideoIn.Name  = 'Original Video';

% sizeCam1='YUY2_160x120';
% sizeCam2='YUY2_640x480';
vi

% vid.LoggingMode = 'disk&memory';
% diskLogger = avifile('F:\helton\dropBox\Dropbox\uppsala\proj_behavior_camera_Sony_Andor\videoFile_0001.avi', 'Compression', 'None', 'Quality', 75, 'keyframepersec', 2.14, 'FPS', 15);
% vid.DiskLogger = diskLogger;
% set(vid,'FramesPerTrigger', 1);
% set(vid,'TriggerRepeat', Inf);

imageSnap = getsnapshot(vid);
imwrite(mat2gray(imageSnap),'imTemp.tif','tif');
%% 
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
% bh2 = uicontrol(ph,'Style','pushbutton',...
%            'Callback', 'flagTra=1;',...
%            'String','Tracking','Position',[20 60 80 30]);
% bh3 = uicontrol(ph,'Style','pushbutton',...
%            'Callback', 'preview(vid);',...
%            'String','Video Capture','Position',[20 100 80 30]);

% Create the text label for the timestamp
% hTextLabel = uicontrol('style','text','String','Timestamp', ...
%     'Units','normalized',...
%     'Position',[0.85 -.04 .15 .08]);
%% 
% Initialization
% Initialize required variables such as the threshold value for the cross
% correlation and the decomposition level for Gaussian Pyramid
% decomposition.
threshold = single(0.89);
level = 2;
%%
% Create three gaussian pyramid System objects for decomposing the target
% template and decomposing the Image under Test(IUT). The decomposition is
% done so that the cross correlation can be computed over a small region
% instead of the entire original size of the image.
hGaussPymd1 = vision.Pyramid('PyramidLevel',level);
hGaussPymd2 = vision.Pyramid('PyramidLevel',level);
hGaussPymd3 = vision.Pyramid('PyramidLevel',level);
%%
% Create a System object to rotate the image by angle of pi before
% computing multiplication with the target in the frequency domain which is
% equivalent to correlation.
hRotate1 = vision.GeometricRotator('Angle', pi);
%% 
% Create two 2-D FFT System objects one for the image under test and the
% other one for the target. 
hFFT2D1 = vision.FFT;
hFFT2D2 = vision.FFT;
%% 
% Create a System object to perform 2-D inverse FFT after performing
% correlation (equivalent to multiplication) in the frequency domain. 
hIFFFT2D = vision.IFFT;
%% 
% Create 2-D convolution System object to average the image energy in tiles
% of the same dimension of the target.
hConv2D = vision.Convolver('OutputSize','Valid');
%% 
% Select areas
useDefaultTarget = false;
tru=zeros(4,4);
%--> select target 
 [Img, roi, numberOfTargets, target_image] = ...
   videopattern_gettemplate3(useDefaultTarget);
%-->regiao especifica para laser
 [Img2, roi2, numberOfTargets2, target_image2] = ...
   videopattern_gettemplate3(useDefaultTarget);
    roi2=[roi2(2) roi2(1) roi2(4) roi2(3)];
    tru(:,2)=roi2';
%% 
% Downsample the target image by a predefined factor using the
% gaussian pyramid System object. You do this to reduce the amount of
% computation for cross correlation.
target_image = single(target_image);
target_dim_nopyramid = size(target_image);
target_image_gp = step(hGaussPymd1, target_image);
target_energy = sqrt(sum(target_image_gp(:).^2));

% Rotate the target image by 180 degrees, and perform zero padding so that
% the dimensions of both the target and the input image are the same.
target_image_rot = step(hRotate1, target_image_gp);
[rt, ct] = size(target_image_rot);
Img = single(Img);
Img = step(hGaussPymd2, Img);
[ri, ci]= size(Img);
r_mod = 2^nextpow2(rt + ri);
c_mod = 2^nextpow2(ct + ci);
target_image_p = [target_image_rot zeros(rt, c_mod-ct)];
target_image_p = [target_image_p; zeros(r_mod-rt, c_mod)];

% Compute the 2-D FFT of the target image
target_fft = step(hFFT2D1, target_image_p);

% Initialize constant variables used in the processing loop.
target_size = repmat(target_dim_nopyramid', [1, numberOfTargets]);
gain = 2^(level);
num_rows = (ri - rt) + 1;
Im_p = zeros(r_mod, c_mod, 'single'); % Used for zero padding
C_ones = ones(rt, ct, 'single');      % Used to calculate mean using conv

%% 
% Create a System object to calculate the local maximum value for the
% normalized cross correlation.
hFindMax = vision.LocalMaximaFinder( ...
            'Threshold', single(-1), ...
            'MaximumNumLocalMaxima', numberOfTargets, ...
            'NeighborhoodSize', floor(size(target_image_gp)/2)*2 - 1);
  %%
% Create a System object to draw a bounding box around the tracked target.
hDrawBBox = vision.ShapeInserter( ...
                'BorderColor', 'Custom', ...
                'CustomBorderColor', [0 1 0]);
hDrawBBox2 = vision.ShapeInserter( ...
                 'BorderColor', 'Custom', ...
                 'CustomBorderColor', [1 0 0]);             
%% 
% Text to Show
htextinsX = vision.TextInserter( ...
        'Text', 'x=%4d', ...
        'Location',  [0 0], ...
        'Color', [0 0 255], ...
        'FontSize', 12);
htextinsY = vision.TextInserter( ...
        'Text', 'y=%4d', ...
        'Location',  [15 0], ...
        'Color', [0 0 255], ...
        'FontSize', 12);
%%
% Initialize figure window for plotting the normalized cross correlation
% value
hPlot = videopatternplots('setup',numberOfTargets, threshold);
%% 
% Stream Processing Loop
% Create a processing loop to perform pattern matching on the input video.
% This loop uses the System objects you instantiated above. The loop is
% stopped when you reach the end of the input file, which is detected by
% the |VideoFileReader| System object.

start(vid);
%textWin(1:15,1:30,:) = 0; 

while (flagExi==0)
    
    %tic;
    Im = getdata(vid, 1, 'single');
    %step(hVideoIn, Im);
    
    %Im = step(hVideoIn);
    Im_gp = step(hGaussPymd3, Im);

    % Frequency domain convolution.
    Im_p(1:ri, 1:ci) = Im_gp;    % Zero-pad
    img_fft = step(hFFT2D2, Im_p);
    corr_freq = img_fft .* target_fft;
    corrOutput_f = step(hIFFFT2D, corr_freq);
    corrOutput_f = corrOutput_f(rt:ri, ct:ci);
    
    % Calculate image energies and block run tiles that are size of
    % target template.
    IUT_enegy = (Im_gp).^2;
    IUT = step(hConv2D, IUT_enegy, C_ones);
    IUT = sqrt(IUT);
    
    % Calculate normalized cross correlation.
    norm_Corr_f = (corrOutput_f) ./ (IUT * target_energy);
    index = step(hFindMax, norm_Corr_f);

    % Calculate linear indices.
    linear_index = index(1, :) + index(2, :) * num_rows + 1;

    norm_Corr_f_linear = norm_Corr_f(:);
    norm_Corr_value = norm_Corr_f_linear(linear_index);
    detect = (norm_Corr_value > threshold);
    target_roi = zeros(4, length(detect));
    target_roi(:, detect) = [gain.*index(:,detect); target_size(:,detect)];
  
    %config text for show
    %Im(1:20,1:40,:) = 0;
    % insert target to plot
    tru(:,1)=target_roi;
    %insert center of target to plot
    Ctarget_roi(1) = floor(target_roi(1)+ target_roi(3)/2); 
    Ctarget_roi(2) = floor(target_roi(2)+ target_roi(4)/2);
    tru(:,3)=[Ctarget_roi(1)-2 Ctarget_roi(2)-2 4 4]';

    %--> selecionando cor do plot (on-off) laser
    if (tru(1,3)>tru(1,2) && tru(1,3)<tru(1,2)+ tru(3,2) &&...
        tru(2,3)>tru(2,2) && tru(2,3)<tru(2,2)+ tru(4,2));
    %disp('red-> laser on')  
        Imf = step(hDrawBBox2, cat(3,Im, Im, Im), tru(:,1:3));       
    else
            Imf = step(hDrawBBox, cat(3,Im, Im, Im), tru(:,1:3));
    %disp('green -> laser off')     
    end
    %image_out = step(htextins, textWin, position);
    %step(hVideoIn,  image_out); 
    % Plot normalized cross correlation.
    %videopatternplots('update',hPlot,norm_Corr_value);
    %%%step(hROIPattern, Imf); 
    posY = Ctarget_roi(1); 
    posX = Ctarget_roi(2);
    
    Imftext=step(htextinsX, Imf, int32(posX));
    Imftext=step(htextinsY, Imftext, int32(posY));
    
    step(hVideoIn, Imftext);
 %toc;  
end

stoppreview(vid);
delete(vid);
%% 
% Release
% Here you call the release method on the System objects to close any open
% files and devices.
%release(hVideoSrc);
release(hVideoIn);

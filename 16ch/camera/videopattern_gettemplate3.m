function [img, roi, numTargets, target_img] = videopattern_gettemplate3(frameTemplate)
%VIDEOPATTERN_GETTEMPLATE Helper function used in videopatternmatching demo
%to get the template pattern to track.

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/08/30 02:59:40 $
% modificado (Helton)

numTargets = 1;

% Read the first frame of the input video and display it on the screen
% reader = mmreader('vipboard.avi');
% img = reader.read(120);
%img = frameTemplate; 
t = Tiff('imTemp.tif', 'r');
img = t.read();

%img = rgb2gray(img);
% Pick some initial location for the target rectangle
roi = [15 100 67 39];
target_img = imcrop(img,roi);

hf = figure('Color', get(0, 'defaultuicontrolbackgroundcolor'), ...
  'Name', 'Target pattern', ...
  'NumberTitle', 'off');
imshow(img);

useDefaultTarget = false;
if useDefaultTarget
  numTargets = 2;
  % Show the pattern
  rectangle('Position', roi, 'EdgeColor',[0 1 0]);
  pause(2);
  close(hf);
  return;
else

h = imrect(gca, roi);
api = iptgetapi(h);
api.setColor([0 1 0]);
api.addNewPositionCallback(@(p) title(mat2str(p)));

% Don't allow the rectangle to be dragged outside of image boundaries
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
api.setDragConstraintFcn(fcn);

yshift = 10;
% uicontrol(hf, 'style', 'text', 'Units', 'Pixels', ...
%     'String', 'Number of targets:', ...
%     'Fontsize', 12, ...
%     'Position', [80 yshift 150 20]);

uicontrol(hf, 'style', 'text', 'Units', 'Pixels', ...
    'String', 'Number of templates:', ...
    'Fontsize', 12, ...
    'Position', [280 yshift 150 20]);

hEditBox = uicontrol(hf, 'style', 'edit', 'Units', 'Pixels', ...
    'String', '1', ...
    'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Position', [430 yshift 100 20]);
% uicontrol(hf, 'style', 'pushbutton', 'Units', 'Pixels', ...
%     'String', 'Submit', ...
%     'Position', [340 yshift 100 20], ...
%     'Callback', @submitFcn);
% uiwait;

uicontrol(hf, 'style', 'pushbutton', 'Units', 'Pixels', ...
    'String', 'Ok', ...
    'Position', [540 yshift 100 20], ...
    'Callback', @submitFcn);
uiwait;

end

    function submitFcn(src, eventData) %#ok<INUSD,INUSD>
        roi = api.getPosition();
        
        % Extract the template data
        target_img = imcrop(img,roi);
        % assignin('base','target_img', target_img);
        
        if any(size(target_img) < 20) || any(size(target_img) > 1000) %default is 100
            errordlg('Target height and width must be between 20 and 100 pixels.',...
                'Invalid dimensions');
            return;
        end
        
                numTargets = round(str2double(get(hEditBox, 'String')));
        if numTargets < 1
            warndlg('Number of targets must be greater than or equal to 1. Setting the number of targets to 1.', 'Invalid number of targets');
            numTargets = 1;
        end
        close(hf);
    end 
  
end



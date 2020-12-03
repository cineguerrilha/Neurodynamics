function [ImGrey, ImRGB]=UnitImage(A,RGB,Orientation)
%Image with all detected units
%Im=UnitImage(A,RGB);
%Inputs
% A (3d array with spatial foot prints)
% RGB (normalization on rgb from 0 to 1, e.g. [1 1 1], 
% units are drawn white)
% Orientation = 1 if the A array is Neurons, Height, Width
% otherwise Neurons, heigth and width
if Orientation==1
    Neurons=size(A,1);
    for ii=1:Neurons
        AA(:,:,ii) = A(ii,:,:);
    end
end

[H,W,F]=size(A); 
ImGrey=zeros(H,W);
for ii=1:F
    ImGrey=ImGrey+A(:,:,ii);
end
MaxPixel=max(max(ImGrey));
%ImGrey=ImGrey./MaxPixel;

for ii=1:3
ImRGB(:,:,ii)=ImGrey*RGB(ii)*255;
end
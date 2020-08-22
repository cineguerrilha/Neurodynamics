function [ImGrey, ImRGB]=UnitImage(A,RGB)
%Image with all detected units
%Im=UnitImage(A,RGB);
%Inputs
% A (3d array with spatial foot prints)
% RGB (normalization on rgb from 0 to 1, e.g. [1 1 1], 
% units are drawn white)
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
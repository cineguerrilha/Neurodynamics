%%-- Coherence in the open field
% Calculate distance and speed
FrameRate=20;

for ii=2:size(Coord,1)
D(ii-1)=sqrt((Coord(ii,1)-Coord(ii-1,1))^2+(Coord(ii,2)-Coord(ii-1,2))^2);
end

V=smooth(abs(diff(D)));
V(size(Coord,1))=V(end);
tVideo = ((1:size(Coord,1))-1)/FrameRate;


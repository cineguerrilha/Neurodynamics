CSVFile='20201125DLC_resnet50_SomPlaceNov26shuffle1_1030000filtered.csv';
TrackCSV=csvread(CSVFile,3,0);
xColumn=2;
Coord=TrackCSV(:,[xColumn xColumn+1]);
for ii=2:size(Coord,1)
D(ii-1)=sqrt((Coord(ii,1)-Coord(ii-1,1))^2+(Coord(ii,2)-Coord(ii-1,2))^2);
end
V=smooth(abs(diff(D)));
%%
load Sliced8Polygons.mat
for ii=1:length(Areas)
    PolygonIn(:,ii)=inpolygon(Coord(:,1),Coord(:,2),Areas(ii).PG.Vertices(:,1),Areas(ii).PG.Vertices(:,2));
end

%%
for ii=1:size(Coord,1)
    FZ=find(PolygonIn(ii,:)==1);
    if isempty(FZ)
        TrackZone(ii,1)=-1;
    else
        TrackZone(ii,1)=FZ(1);
    end
end
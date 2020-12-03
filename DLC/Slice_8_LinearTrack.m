% Slice 8 track
% this script creates polygons for place cell calculation
% Using the Potiplex 8 track
% First point start after the common segment
% Check the 8_labelled_figure for reference

VidObj=VideoReader(VideoFile);
FirstFrame = 1000;
Img=read(VidObj,FirstFrame);
%close VidObj
%%
imagesc(Img)
disp('Label Inner walls - A 9 points')
for ii=1:9
    [x,y]=ginput(1);
    I_A(ii,:)=[x,y];
    text(x,y,['I_A',num2str(ii)])
end

hold on
plot(I_A(:,1),I_A(:,2),'r')

disp('Label Outer walls - A')
for ii=1:9
    [x,y]=ginput(1);
    O_A(ii,:)=[x,y];
    text(x,y,['O_A',num2str(ii)])
end
hold on
plot(O_A(:,1),O_A(:,2),'r')

%%
disp('label 2nd arena')

disp('Label Inner walls - B')
for ii=1:8
    [x,y]=ginput(1);
    I_B(ii,:)=[x,y];
    text(x,y,['I_B',num2str(ii)])
end

hold on
plot(I_B(:,1),I_B(:,2),'g')

disp('Label Outer walls - B')
for ii=1:8
    [x,y]=ginput(1);
    O_B(ii,:)=[x,y];
    text(x,y,['O_B',num2str(ii)])
end
hold on
plot(O_B(:,1),O_B(:,2),'r')

%%
for ii=1:8
    X(ii,:)=[I_A(ii,1) I_A(ii+1,1) O_A(ii+1,1) O_A(ii,1)];
    Y(ii,:)=[I_A(ii,2) I_A(ii+1,2) O_A(ii+1,2) O_A(ii,2)];
    Areas(ii).PG = polyshape(X(ii,:),Y(ii,:));
end

for ii=1:7
    X(ii+8,:)=[I_B(ii,1) I_B(ii+1,1) O_B(ii+1,1) O_B(ii,1)];
    Y(ii+8,:)=[I_B(ii,2) I_B(ii+1,2) O_B(ii+1,2) O_B(ii,2)];
    Areas(ii+8).PG = polyshape(X(ii+8,:),Y(ii+8,:));
end
%%
close
imagesc(Img)
hold on
for ii=1:15
    [Cx Cy] = centroid(Areas(ii).PG);
    text(Cx,Cy,['Region', num2str(ii)])
    plot(Areas(ii).PG)
end
hold off

save Sliced8Polygons X Y Areas
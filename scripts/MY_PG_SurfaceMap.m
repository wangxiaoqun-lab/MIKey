function F = MY_PG_SurfaceMap(PG_NIIfile1,PG_NIIfile2,LIBpath)



cd(LIBpath);
topo = gifti('Other.Marmoset.R.CLOSED.142238.topo');
coord = gifti('Other.Marmoset.R.Fiducial.142238.coord');

Vertices = coord.vertices;
Faces = topo.faces;

Vol = spm_vol('Other.Marmoset.R.Segment_GraphErrorCorrected.nii');
M = Vol.mat;
off = M(1:3,4);
ReV = sqrt(sum(M(1:3,1:3).^2));
IMG0 = spm_read_vols(Vol);

% NIIfile
Vol = spm_vol(PG_NIIfile1);
IMG = spm_read_vols(Vol);
IMGn = IMG;        
IMGf = flip(IMG,1);
NodeNum = size(Vertices,1);
cn1 = zeros(NodeNum,1);
cf1 = zeros(NodeNum,1);
p = find(IMG0~=0);
LOC = spm_read_vols(spm_vol('LOC.nii'));
[a,b,c]=size(LOC);
pin = reshape(LOC,[a b*c]);
for i = 1:NodeNum
    loc = pin(:,i);
    loc(loc==0)=[];
    cn1(i) = mean(IMGn(loc));
    cf1(i) = mean(IMGf(loc));
end
%}

Vol = spm_vol(PG_NIIfile2);
IMG = spm_read_vols(Vol);
IMGn = IMG;        
IMGf = flip(IMG,1);
NodeNum = size(Vertices,1);
cn2 = zeros(NodeNum,1);
cf2 = zeros(NodeNum,1);
p = find(IMG0~=0);
LOC = spm_read_vols(spm_vol('LOC.nii'));
[a,b,c]=size(LOC);
pin = reshape(LOC,[a b*c]);
for i = 1:NodeNum
    loc = pin(:,i);
    loc(loc==0)=[];
    cn2(i) = mean(IMGn(loc));
    cf2(i) = mean(IMGf(loc));
end



cr = MY_display_ColorMap_RGB(cn1,cn2);
cl = MY_display_ColorMap_RGB(cf1,cf2);

maxx = max(Vertices);
minn = min(Vertices);

F = figure('Color',[1 1 1]);

set(F,'position',[660 300 980 600]);%[1 41 1920 962]
% Left Lateral View
posVec = [0+0.01 1/3+1/6+0.02 1/3-0.01+0.05 1/3];
subplot('position',posVec);
patch('vertices', double(Vertices),...
    'faces', double(Faces),...
    'SpecularStrength',0,...
    'FaceVertexCData',cl,...
    'facecolor','interp',...
    'edgecolor','none');
axis equal;view(-90,0);
set(gca,'xdir','reverse');
xlim([minn(1),maxx(1)]);
ylim([minn(2),maxx(2)]);
zlim([minn(3),maxx(3)]);
axis off;
light('position',[40 40 40]);

% Right Lateral View
posVec = [2/3-0.05 1/3+1/6+0.02 1/3-0.01+0.05 1/3];
subplot('position',posVec);
patch('vertices', double(Vertices),...
    'faces', double(Faces),...
    'SpecularStrength',0,...
    'FaceVertexCData',cr,...
    'facecolor','interp',...
    'edgecolor','none');
axis equal;view(90,0);
xlim([minn(1),maxx(1)]);
ylim([minn(2),maxx(2)]);
zlim([minn(3),maxx(3)]);
axis off;
light('position',[40 40 40]);

% Left Central View
posVec = [0+0.01 0+1/6-0.02 1/3-0.01+0.05 1/3];
subplot('position',posVec);
patch('vertices', double(Vertices),...
    'faces', double(Faces),...
    'SpecularStrength',0,...
    'FaceVertexCData',cl,...
    'facecolor','interp',...
    'edgecolor','none');
axis equal;view(90,0);
xlim([minn(1),maxx(1)]);
ylim([minn(2),maxx(2)]);
zlim([minn(3),maxx(3)]);
set(gca,'xdir','reverse');
axis off;
light('position',[-40 -40 40]);

% Right Central View
posVec = [2/3-0.05 0+1/6-0.02 1/3-0.01+0.05 1/3];
subplot('position',posVec);
patch('vertices', double(Vertices),...
    'faces', double(Faces),...
    'SpecularStrength',0,...
    'FaceVertexCData',cr,...
    'facecolor','interp',...
    'edgecolor','none');
axis equal;view(-90,0);
xlim([minn(1),maxx(1)]);
ylim([minn(2),maxx(2)]);
zlim([minn(3),maxx(3)]);
axis off;
light('position',[-40 -40 40]);

% Left Dorsal View
posVec = [1/3+0.05 0+1/6 1/6-0.05 2/3];
subplot('position',posVec);
patch('vertices', double(Vertices),...
    'faces', double(Faces),...
    'SpecularStrength',0,...
    'FaceVertexCData',cl,...
    'facecolor','interp',...
    'edgecolor','none');
axis equal;view(0,90);
xlim([minn(1),maxx(1)]);
ylim([minn(2),maxx(2)]);
zlim([minn(3),maxx(3)]);
set(gca,'xdir','reverse');
axis off;
light('position',[40 40 40]);

% Right Dorsal View
posVec = [1/2 0+1/6 1/6-0.05 2/3];
subplot('position',posVec);
patch('vertices', double(Vertices),...
    'faces', double(Faces),...
    'SpecularStrength',0,...
    'FaceVertexCData',cr,...
    'facecolor','interp',...
    'edgecolor','none');
axis equal;view(0,90);
xlim([minn(1),maxx(1)]);
ylim([minn(2),maxx(2)]);
zlim([minn(3),maxx(3)]);
axis off;
light('position',[40 40 40]);

end


function cRGB = MY_display_ColorMap_RGB(cdata1,cdata2)

% cdata1(isnan(cdata1))=0;
% cdata2(isnan(cdata2))=0;
% cdata1 = (cdata1-mean(cdata1))./std(cdata1);
% cdata2 = (cdata2-mean(cdata2))./std(cdata2);
% cdata1 = cdata1/max(cdata1);
% cdata2 = cdata2/max(cdata2);
cdata1 = cdata1-nanmean(cdata1);
cdata2 = cdata2-nanmean(cdata2);
Num=numel(cdata1);
cRGB = zeros([Num,3]);
X0=max(abs(cdata1));
Y0=max(abs(cdata2));

for cloop=1:Num
   A = cdata1(cloop);
   B = cdata2(cloop);
   
   if A>1;Q=A/X0;r=1;g=1-Q;b=1-Q;
   elseif A<1 && B>0;Q=B/Y0;r=1-Q;g=1;b=1-Q;
   elseif A<0 && B<0;Q=-B/Y0;r=1-Q;g=1-Q;b=1;
   else; r=1;g=1;b=1;
   end
   cRGB(cloop,:)=[r,g,b];
end


end

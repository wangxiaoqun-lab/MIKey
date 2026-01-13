function MY_Generate_GIF_from_NII(CCNIIfile,AtlasTable,TemplateNII,WholeMaskNII,GIFname)

% CCNIIfile: 4D CC matrix for different Seeds
% AtlasTable: table format
% GIFname: string

Vol = spm_vol(CCNIIfile);
AtlasROI = [AtlasTable.right,AtlasTable.left];
for iter = 1:numel(Vol)
    StatFile = fullfile([CCNIIfile,',',num2str(iter)]);
    IMG_RGB = Colormap( 'statfile',StatFile,...
                        'bgmfile',TemplateNII,...
                        'denoi_profile',WholeMaskNII,...
                        'slice',12:2:80,...
                        'bar_value',[-0.4 -0.01 0.1 0.4],...
                        'dest',pwd,...
                        'mapname',num2str(iter),...
                        'cluster',10);
    
    [row,col] = find(AtlasROI==iter);
    ROIname = [AtlasTable.ROI{row},'///',AtlasTable.Name{row},'///(',AtlasTable.abbre{row},')'];
    if col==1;ROIname=[ROIname,'///Right'];else;ROIname=[ROIname,'///Left'];end
    c = AtlasTable.abbre{row};if col==1;c=[c,'_Right'];else;c=[c,'_Left'];end
    SerName{iter,1} = c;
    
    I = zeros(size(IMG_RGB,1)+20,size(IMG_RGB,2),size(IMG_RGB,3));
    I(21:end,:,:) = IMG_RGB;
    I = insertText(I,[0,0],ROIname,'FontSize',18,'TextColor',[255 255 255],...
        'BoxColor',[0 0 0],'BoxOpacity',0,'AnchorPoint','LeftTop');
    
%     cd('D:\rsfMRI_marmoset\FigureProcessing\Seed-based\TIFF2');
%     I = imresize3(I,[size(I,1)*3,size(I,2)*3,3]);
%     [A,map] = rgb2ind(uint8(I),255);
%     c(c=='/')='-';
%     imwrite(A,map,[c,'.tif'],'tif');
    if iter==1;I4d=zeros([size(I),numel(Vol)]);end
    I4d(:,:,:,iter) = I;
end
a = AtlasROI';b=a(:);b(isnan(b))=[];
I4d1 = I4d(:,:,:,b);I4d1(:,:,:,246)=0;
I4d2 = cat(1,I4d1(:,:,:,1:2:end),I4d1(:,:,:,2:2:end));

for iter = 1:round(numel(Vol)/2)
    [A,map] = rgb2ind(uint8(I4d2(:,:,:,iter)),255);
    if iter == 1
        imwrite(A,map,GIFname,'gif','LoopCount',Inf,'DelayTime',.5);
    else
        imwrite(A,map,GIFname,'gif','WriteMode','append','DelayTime',.5);
    end
end

end
cd G:\code\code\mouse_template;
head = spm_vol('Template_Mouse.nii');
img1 = spm_read_vols(head);
img = img1(:,1:8:264,:);
for i = 1:size(img,2)
    temp = squeeze(img(:,i,:));
    subimage(:,:,i) = imresize(temp,[114 80],'bilinear');
end
% img = permute(img,[1 3 2]);
head.fname = 'small_Template.nii';
head.dim = size(subimage);
head.pinfo = [1;0;352];
head.descrip = 'spm - template';
head.mat = [3,0,0,-115;0,3,0,-80;0,0,10,-40;0,0,0,1];
spm_write_vol(head, subimage);

head = spm_vol('Label_Mouse.nii');
img1 = spm_read_vols(head);
img = img1(:,1:8:264,:);
for i = 1:size(img,2)
    temp = squeeze(img(:,i,:));
    subimage(:,:,i) = imresize(temp,[114 80],'bilinear');
end
% img = permute(img,[1 3 2]);
head.fname = 'small_Label.nii';
head.dim = size(subimage);
head.pinfo = [1;0;352];
head.descrip = 'spm - template';
head.mat = [3,0,0,-115;0,3,0,-80;0,0,10,-40;0,0,0,1];
spm_write_vol(head, subimage);
function test_mikey_custom_labels
% SERVER ONLY. Requires real SPM; creates only isolated temporary fixtures.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,work)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));
assert(~isempty(which('spm_vol')),'Add SPM before running this server check.');
reference=spm_vol(fullfile(root,'share_temp','brainmask_Mouse_v38.nii'));
atlases=MIKey_atlas_catalog();
for i=1:numel(atlases)
    file=fullfile(root,'share_temp',atlases(i).labelFile);
    [data,ids]=MIKey_read_label(file,reference);
    assert(isequal(ids,unique(data(data~=0))));
    fprintf('%s: %d present IDs, range [%g,%g]\n',atlases(i).labelFile,numel(ids),min(ids),max(ids));
end
% Missing, large and signed IDs must be retained, not used as matrix indices.
labels=reshape([0 2 2 1000000 -7 0 1000000 -7],[2 2 2]);
file=fullfile(work,'sparse_float.nii');head=writeImage(file,labels,eye(4));
[loaded,ids]=MIKey_read_label(file,head);assert(isequal(ids,[-7;2;1000000]));
images=cat(4,reshape(1:8,[2 2 2]),reshape(11:18,[2 2 2]),reshape(21:28,[2 2 2]));
[ts,rowIDs]=MIKey_roi_timeseries(images,loaded);
assert(isequal(rowIDs,[-7;2;1000000]));
assert(isequal(ts,[6.5 16.5 26.5;2.5 12.5 22.5;5.5 15.5 25.5]));
gzip(file,work);[gz,compressedIDs]=MIKey_read_label([file '.gz'],head);
assert(isequal(gz,loaded) && isequal(ids,compressedIDs));
% Meaningful rejection cases must identify their cause, not blame storage type.
writeImage(fullfile(work,'fractional.nii'),labels+0.25,eye(4));
expect(@()MIKey_read_label(fullfile(work,'fractional.nii')),'MIKey:LabelValues');
writeImage(fullfile(work,'nearly_integer.nii'),labels+1e-7,eye(4));
expect(@()MIKey_read_label(fullfile(work,'nearly_integer.nii')),'MIKey:LabelValues');
writeImage(fullfile(work,'empty.nii'),zeros(2,2,2),eye(4));
expect(@()MIKey_read_label(fullfile(work,'empty.nii')),'MIKey:LabelValues');
nonfinite=labels;nonfinite(1)=NaN;
writeImage(fullfile(work,'nonfinite.nii'),nonfinite,eye(4));
expect(@()MIKey_read_label(fullfile(work,'nonfinite.nii')),'MIKey:LabelValues');
shifted=head;shifted.mat(1,4)=3;
expect(@()MIKey_read_label(file,shifted),'MIKey:LabelGrid');
resized=head;resized.dim(1)=3;
expect(@()MIKey_read_label(file,resized),'MIKey:LabelGrid');
% Prior initialization accepts sparse/signed IDs and fails clearly for no overlap.
maskData=zeros(2,2,2);maskData(1)=1;
mask=writeImage(fullfile(work,'mask.nii'),maskData,eye(4));
expect(@()individualized_parcellation_rsfMRI_v3(images,ones(2,2,2),mask,'prior', ...
    file,0.8,fullfile(work,'unused'),1,0.001,2.5,'UseParallel',false),'MIKey:LabelOverlap');
mask=writeImage(fullfile(work,'fullmask.nii'),ones(2,2,2),eye(4));
expect(@()individualized_parcellation_rsfMRI_v3(images,zeros(2,2,2),mask,'prior', ...
    file,0.8,fullfile(work,'unused'),1,0.001,2.5,'UseParallel',false),'MIKey:LabelOverlap');
disp('MIKEY_CUSTOM_LABELS_PASS');
end
function header=writeImage(filename,data,affine)
header=struct('fname',filename,'dim',[size(data,1) size(data,2) size(data,3)], ...
    'dt',[16 0],'mat',affine,'pinfo',[1;0;0],'n',[1 1],'descrip','MIKey server label fixture');
spm_write_vol(header,double(data));header=spm_vol(filename);
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end
function restore(oldPath,work)
path(oldPath);target=char(java.io.File(work).getCanonicalPath());
parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

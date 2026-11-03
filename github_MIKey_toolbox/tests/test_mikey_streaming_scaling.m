function test_mikey_streaming_scaling(spmPath)
% Real SPM data/geometry equality, chunked gzip copy and cancellation cleanup.
root = fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));MIKey_setup(spmPath);
work = tempname;mkdir(work);rng(26);
source = fullfile(work, 'source.nii');
data = 100 + randn(5,6,4,8);matrix = diag([0.2 0.3 0.4 1]);
for i = 1:8
    v = struct('fname',source,'dim',[5 6 4],'dt',[16 0], ...
        'mat',matrix,'pinfo',[1;0;0],'n',[i 1],'descrip','Streaming test');
    spm_write_vol(v,data(:,:,:,i));
end
destination = fullfile(work,'scaled.nii');
volumes = [];
MIKey_scale_nifti(source,destination,2,@()[],@observe);
out = spm_vol(destination);actual = spm_read_vols(out);
assert(numel(out)==8 && isequal(volumes,1:8));
assert(max(abs(actual(:)-data(:))) < 1e-4);
expected = matrix*2;expected(4,4)=1;
assert(max(abs(out(1).mat(:)-expected(:))) < 1e-6);
raw = bytes(source);zipped = gzip(source,work);
calls = 0;copied = fullfile(work,'copied.nii');
MIKey_copy_nifti(zipped{1},copied,@copyCheckpoint);
assert(isequal(bytes(copied),raw) && calls>2);
MIKey_copy_nifti(source,copied,@()[]);assert(isequal(bytes(copied),raw));
before = dir(fullfile(work,'*.nii'));cancelled = fullfile(work,'cancelled.nii');
try
    MIKey_scale_nifti(source,cancelled,2,@()[],@cancelAtFirstVolume);
    error('MIKey:Test','Expected cancellation.');
catch ME
    assert(strcmp(ME.identifier,'MIKey:Stopped'));
end
after = dir(fullfile(work,'*.nii'));
assert(~exist(cancelled,'file') && isequal({before.name},{after.name}), ...
    'An interrupted run left a partial image.');
calls = 0;
try
    MIKey_copy_nifti(zipped{1},cancelled,@cancelCopy);
    error('MIKey:Test','Expected copy cancellation.');
catch ME
    assert(strcmp(ME.identifier,'MIKey:Stopped'));
end
after = dir(fullfile(work,'*.nii'));
assert(~exist(cancelled,'file') && isequal({before.name},{after.name}));
assert(isequal(bytes(source),raw));
disp('MIKEY_STREAMING_SCALING_PASS');

    function observe(volume,~)
        volumes(end+1)=volume;
    end
    function copyCheckpoint()
        calls=calls+1;
    end
    function cancelAtFirstVolume(volume,~)
        assert(volume==1);error('MIKey:Stopped','Synthetic mid-volume cancellation.');
    end
    function cancelCopy()
        calls=calls+1;
        if calls==3,error('MIKey:Stopped','Synthetic transfer cancellation.');end
    end
end

function value=bytes(path)
fid=fopen(path,'rb');cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
value=fread(fid,Inf,'*uint8');
end

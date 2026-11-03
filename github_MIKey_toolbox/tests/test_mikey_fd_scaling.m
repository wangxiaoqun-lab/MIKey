function test_mikey_fd_scaling
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);addpath(fullfile(root,'scripts'));
physical=[0 0 0 0 0 0;.01 .02 .03 .001 .002 .003;.03 .01 .02 .003 .001 .002];
for method={'power','euclidean'}
    expected=MIKey_framewise_displacement(physical,method{1},5);
    for scale=[1 2.5 10 20]
        scaled=physical;scaled(:,1:3)=scaled(:,1:3)*scale;
        [FD,info]=MIKey_framewise_displacement(scaled,method{1},5*scale,scale);
        assert(max(abs(FD-expected))<1e-12);
        assert(info.version==2 && strcmp(info.spatialUnits,'mm'));
        assert(info.voxelScaleFactor==scale && info.physicalRotationRadius==5);
        assert(FD(1)==0);
    end
end
% A pasted example: 0.318591844636042 scaled mm at scale 20 -> 15.9296 um.
rp=zeros(3,6);rp(2:3,1)=.318591844636042;
FD=MIKey_framewise_displacement(rp,'euclidean',100,20);
assert(abs(FD(2)*1000-15.9295922318021)<1e-10);
for scale={0,-1,NaN,Inf,[],[10 20],true,'20',struct()}
    expect(@()MIKey_framewise_displacement(physical,'power',100,scale{1}),'MIKey:FDScaleFactor');
end
MIKey_config(struct('steps',2:9,'voxelScaleFactor',struct('unused',1)));
expect(@()MIKey_config(struct('steps',10,'voxelScaleFactor',0)),'MIKey:Parameter');
cfg=MIKey_config(struct('steps',10,'voxelScaleFactor',7));state=MIKeyBatchState(cfg,-1);
assert(state.UserData.voxelScaleEdit.Value==7);
work=tempname;mkdir(work);cleanup=onCleanup(@()removeWork(work)); %#ok<NASGU>
image=fullfile(work,'sub-test_desc-scaled_bold.nii');
MIKey_check_fd_scale(image,20); % Older output without a sidecar uses configured scale.
metadata=struct('MIKeyVoxelScaleFactor',20);sidecar=fullfile(work,'sub-test_desc-scaled_bold.json');
writeJSON(sidecar,metadata);MIKey_check_fd_scale(image,20);
MIKey_check_fd_scale([image '.gz'],20);
expect(@()MIKey_check_fd_scale(image,10),'MIKey:FDScaleFactor');
metadata.MIKeyVoxelScaleFactor='20';writeJSON(sidecar,metadata);
expect(@()MIKey_check_fd_scale(image,20),'MIKey:FDScaleFactor');
writeJSON(sidecar,struct('Sources','old'));MIKey_check_fd_scale(image,20);
fid=fopen(sidecar,'w');fprintf(fid,'invalid json');fclose(fid);
expect(@()MIKey_check_fd_scale(image,20),'MIKey:FDScaleFactor');
disp('MIKEY_FD_SCALING_PASS');
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end
function writeJSON(filename,value)
fid=fopen(filename,'w');assert(fid>=0);fprintf(fid,'%s',jsonencode(value));fclose(fid);
end
function removeWork(work)
target=char(java.io.File(work).getCanonicalPath());parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

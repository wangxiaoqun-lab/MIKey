function test_mikey_atlases
% Server-only selection and file-routing checks; no SPM image processing.
root=fileparts(fileparts(mfilename('fullpath')));oldPath=path;oldDirectory=pwd;
work=tempname;mkdir(work);cleanup=onCleanup(@()restore(oldPath,oldDirectory,work)); %#ok<NASGU>
addpath(root);addpath(fullfile(root,'scripts'));
all=MIKey_atlas_catalog();assert(isequal({all.label},{'214','296','428','592','604','1184'}));
for label={'296','592'}
    id=label{1};atlas=MIKey_atlas_catalog(id);assert(isempty(atlas.networkFile));
    image=fullfile(root,'share_temp',atlas.labelFile);assert(exist(image,'file')==2);
    cfg=MIKey_defaults();cfg.steps=13;cfg.fcLabel=id;cfg.parcNetwork=[id 'rois'];
    cfg=MIKey_config(cfg);state=MIKeyBatchState(cfg,-1);
    assert(strcmp(state.UserData.fcLabelDropdown.Value,id));
    pre=MIKey_preflight(cfg);assert(any(strcmp(pre.requiredImages,image)));
    configFile=MIKey_export_config(fullfile(work,['mikey_atlas_' id '.m']),cfg);
    loaded=MIKey_config(configFile);assert(strcmp(loaded.fcLabel,id) && strcmp(loaded.parcNetwork,[id 'rois']));
    cfg.steps=14;[cfg,active]=MIKey_config(cfg);assert(active.groupNetworkPath);
    expect(@()MIKey_builtin_prior(cfg),'MIKey:AtlasNetwork');
    pre=MIKey_preflight(cfg);assert(any(contains(pre.issues,'no bundled AMCP network prior')));
    network=fullfile(work,'provided_network.nii');fid=fopen(network,'w');assert(fid>=0);fclose(fid);
    cfg.groupNetworkPath=network;cfg=MIKey_config(cfg);
    prior=MIKey_builtin_prior(cfg);
    assert(strcmp(prior.label_file,image) && strcmp(prior.network_file,network));
    assert(strcmp(prior.folder_suffix,['prior_mode_' id]));
    state=MIKeyBatchState(cfg,-1);assert(strcmp(state.UserData.groupNetworkEdit.Value,network));
    pre=MIKey_preflight(cfg);assert(any(strcmp(pre.requiredImages,image)) && any(strcmp(pre.requiredImages,network)));
    assert(~any(contains(pre.issues,'no bundled AMCP network prior')));
    for step=15:16
        cfg.steps=step;cfg=MIKey_config(cfg);assert(strcmp(MIKey_group_network(cfg),network));
    end
end
for label={'214','428','604','1184'}
    atlas=MIKey_atlas_catalog(label{1});cfg=MIKey_defaults();cfg.parcNetwork=atlas.parcellation;
    expected=fullfile(root,'share_temp','AMCP_temp',atlas.networkFile);
    assert(strcmp(MIKey_group_network(cfg),expected));
    prior=MIKey_builtin_prior(cfg);assert(strcmp(prior.network_file,expected));
end
MIKey_config(struct('steps',1,'fcLabel','999','parcNetwork','999rois'));
expect(@()MIKey_config(struct('steps',13,'fcLabel','999')),'MIKey:Parameter');
disp('MIKEY_ATLASES_PASS');
end
function expect(fn,id)
try,fn();catch ME,assert(strcmp(ME.identifier,id),getReport(ME));return;end
error('MIKey:Test','Expected %s.',id);
end
function restore(oldPath,oldDirectory,work)
cd(oldDirectory);path(oldPath);
target=char(java.io.File(work).getCanonicalPath());parent=char(java.io.File(tempdir).getCanonicalPath());
assert(strcmpi(fileparts(target),parent));if exist(target,'dir'),rmdir(target,'s');end
end

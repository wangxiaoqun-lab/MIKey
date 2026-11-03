function environment = MIKey_setup(spmPath, codePath)
%MIKEY_SETUP Add only MIKey scripts and SPM root, never genpath(SPM).
root = MIKey_paths();
if nargin < 1, spmPath = ''; end
if nargin < 2, codePath = fullfile(root, 'scripts'); end
addpath(root);
if ~exist(codePath, 'dir')
    error('MIKey:CodePath', 'Scripts directory does not exist: %s', codePath);
end
addpath(codePath);
if ~isempty(spmPath)
    if ~exist(fullfile(spmPath, 'spm.m'), 'file')
        error('MIKey:SPMPath', 'spmPath must contain spm.m: %s', spmPath);
    end
    addpath(spmPath);
end
if isempty(which('spm')) || isempty(which('spm_jobman'))
    error('MIKey:MissingSPM', 'SPM12 not found. Use MIKey_setup(''/absolute/path/spm12'').');
end
spm('defaults', 'fmri');
spm_get_defaults('cmdline', true);
spm_jobman('initcfg');
spm_get_defaults('cmdline', true);
environment = struct('matlab', version, 'release', version('-release'), ...
    'computer', computer, 'spm', spm('Ver'), 'spmFile', which('spm'), ...
    'mikeyFile', which('MIKey'), 'toolboxes', ver);
environment.sourceManifest = sourceManifest(root, codePath);
if ~strcmpi(environment.spm, 'SPM12')
    warning('MIKey:SPMVersion', 'This toolbox was developed with SPM12; found %s.', environment.spm);
end

function manifest = sourceManifest(root, codePath)
directories = unique({root,fullfile(root,'scripts'),codePath},'stable');
files = [];
for directoryIndex = 1:numel(directories)
    files = [files; dir(fullfile(directories{directoryIndex},'*.m'))]; %#ok<AGROW>
end
manifest = struct('file', {}, 'sha256', {});
for i = 1:numel(files)
    filename = fullfile(files(i).folder,files(i).name);
    fid = fopen(filename,'rb');
    if fid < 0, error('MIKey:SourceRead','Cannot read source file: %s',filename); end
    bytes = fread(fid,Inf,'*uint8'); fclose(fid);
    digest = java.security.MessageDigest.getInstance('SHA-256');
    digest.update(bytes);
    checksum = lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
    manifest(end+1) = struct('file',filename,'sha256',checksum); %#ok<AGROW>
end
end
end

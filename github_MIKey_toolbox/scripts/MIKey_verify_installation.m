function report = MIKey_verify_installation()
% Verify published core bytes; user configurations and research data are excluded.
root=fileparts(fileparts(mfilename('fullpath')));
manifestPath=fullfile(root,'docs','maintenance','CODE_SHA256.json');
if ~isfile(manifestPath), error('MIKey:IntegrityManifest','Missing integrity manifest: %s',manifestPath); end
manifest=jsondecode(fileread(manifestPath));
report=struct('ok',true,'checked',0,'missing',{{}},'modified',{{}},'unexpected',{{}},'manifest',manifestPath);
expected={};
for i=1:numel(manifest.files)
    item=manifest.files(i); relative=char(item.path);
    parts=strsplit(strrep(relative,'\','/'),'/');
    if startsWith(relative,'/') || any(ismember(parts,{'..','.'})) || ~isempty(regexp(relative,'[:*?]','once'))
        error('MIKey:IntegrityManifest','Invalid manifest path.');
    end
    expected{end+1}=relative; %#ok<AGROW>
    filename=fullfile(root,relative);
    if ~isfile(filename), report.missing{end+1}=relative; continue; end
    fid=fopen(filename,'rb');
    if fid<0, error('MIKey:IntegrityRead','Cannot read core file: %s',relative); end
    closeFile=onCleanup(@()fclose(fid));
    digest=java.security.MessageDigest.getInstance('SHA-256');
    while ~feof(fid)
        bytes=fread(fid,8*1024*1024,'*uint8');digest.update(bytes);
    end
    clear closeFile;
    checksum=lower(reshape(dec2hex(typecast(digest.digest(),'uint8'),2)',1,[]));
    report.checked=report.checked+1;
    if ~strcmpi(checksum,char(item.sha256)),report.modified{end+1}=relative;end
end
listing=dir(fullfile(root,'scripts','*.m'));
for i=1:numel(listing)
    relative=['scripts/' listing(i).name];
    if ~any(strcmp(relative,expected)), report.unexpected{end+1}=relative;end
end
report.ok=isempty(report.missing) && isempty(report.modified) && isempty(report.unexpected);
fprintf('MIKey integrity: checked=%d; missing=%d; modified=%d; unexpected scripts=%d.\n', ...
    report.checked,numel(report.missing),numel(report.modified),numel(report.unexpected));
for label={'missing','modified','unexpected'}
    values=report.(label{1});
    for i=1:numel(values), fprintf('  %s: %s\n',label{1},values{i});end
end
if report.ok, fprintf('MIKEY_INSTALLATION_INTEGRITY_PASS\n');end
% Not authentication if source and manifest have both been replaced.
end

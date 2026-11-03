function result = MIKey_cleanup_delete(plan, keep, confirmation)
% Delete only the exact reviewed inventory; never recursively delete directories.
if nargin<3 || ~strcmp(confirmation,'DELETE_REVIEWED_FILES')
    error('MIKey:CleanupConfirmation','Review the deletion list and confirm first.');
end
keep=MIKey_cleanup_keep(plan,keep);
% Refuse a forged plan, changed file set, changed sizes/times, or stale GUI view.
fresh=MIKey_cleanup_inventory(plan.bidsPath);
if ~strcmp(fresh.directory,plan.directory) || ~isequaln(fresh.files,plan.files)
    error('MIKey:CleanupChanged','Files changed since the preview. Nothing deleted; rescan and review again.');
end
indices=find(~keep); result=struct('deleted',0,'failed',0,'auditFile','');
if isempty(indices), return; end
previousRecycle=recycle; recycle('off');
restoreRecycle=onCleanup(@() recycle(previousRecycle)); %#ok<NASGU>
[~,auditDirectory]=MIKey_cleanup_guard(plan.bidsPath,'logs');
if ~isfolder(auditDirectory), mkdir(auditDirectory); end
MIKey_cleanup_guard(plan.bidsPath,'logs');
[~,token]=fileparts(tempname); auditRelative=['logs/cleanup-' token '.jsonl'];
[~,auditFile]=MIKey_cleanup_guard(plan.bidsPath,auditRelative);
fid=fopen(auditFile,'wt');
if fid<0, error('MIKey:CleanupAudit','Cannot create cleanup audit: %s',auditFile); end
closer=onCleanup(@closeAudit); %#ok<NASGU>
result.auditFile=auditFile;
record(struct('event','reviewed','time',datestr(now,30),'directory',plan.directory, ...
    'files',{plan.files(indices)},'note','Permanent deletion; no recursive directory removal.'));
for row=reshape(indices,1,[])
    item=plan.files(row);
    try
        [~,filename]=MIKey_cleanup_guard(plan.bidsPath,item.relative);
        [~,~,locked]=MIKey_cleanup_classify(item.relative);
        current=dir(filename);
        if locked || numel(current)~=1 || current.isdir || ...
                current.bytes~=item.bytes || current.datenum~=item.datenum
            error('MIKey:CleanupChanged','File changed or protected: %s',item.relative);
        end
        % Persist intent before deletion. An interrupted attempt stays auditable.
        record(struct('event','deleting','file',item.relative));
        delete(filename);
        if isfile(filename), error('MIKey:CleanupDelete','Deletion did not remove %s',filename); end
        result.deleted=result.deleted+1;
        record(struct('event','deleted','file',item.relative));
    catch ME
        result.failed=result.failed+1;
        record(struct('event','failed','file',item.relative,'error',ME.message));
        break; % Preserve the remaining reviewed files after the first failure.
    end
end
record(struct('event','finished','deleted',result.deleted,'failed',result.failed, ...
    'remaining',numel(indices)-result.deleted-result.failed,'time',datestr(now,30)));
    function closeAudit()
        if fid>=0, fclose(fid); fid=-1; end
    end
    function record(entry)
        if fprintf(fid,'%s\n',jsonencode(entry))<0 || ~isempty(ferror(fid))
            error('MIKey:CleanupAudit','Cannot write audit; cleanup stopped: %s',auditFile);
        end
        % fclose/reopen flushes each record before a destructive operation.
        fclose(fid); fid=fopen(auditFile,'at');
        if fid<0, error('MIKey:CleanupAudit','Cannot reopen audit: %s',auditFile); end
    end
end

function MIKey_cleanup_dialog(parent)
% Interactive permanent cleanup, separate from the processing GUI layout.
if parent.UserData.runControl.Active
    uialert(parent,'Wait until processing has stopped before cleaning files.','Task active'); return;
end
if isfield(parent.UserData,'cleanupWindow') && isvalid(parent.UserData.cleanupWindow)
    figure(parent.UserData.cleanupWindow); return;
end
if ~isfield(parent.UserData,'bidsPath')
    uialert(parent,'Select a BIDS folder first.','No BIDS folder'); return;
end
try
    plan=MIKey_cleanup_inventory(parent.UserData.bidsPath);
catch ME
    uialert(parent,ME.message,'Cannot scan derivatives'); return;
end
window=uifigure('Name','MIKey - Clean Intermediate Files','Position',[80 80 1180 760]);
parent.UserData.cleanupWindow=window;
busy=false; keep=true(numel(plan.files),1); previewOpen=false; reviewWindow=[];
window.CloseRequestFcn=@closeWindow;
uilabel(window,'Position',[20 724 1140 24],'Text',['Scope: ' plan.directory], ...
    'FontWeight','bold','Tooltip',plan.directory);
uilabel(window,'Position',[20 698 1140 22],'Text', ...
    'All subjects, sessions and runs in this directory (top-level GUI filters do not limit cleanup).');
uilabel(window,'Position',[20 674 1140 22],'Text', ...
    'Checked = KEEP. Raw BIDS, masks, configs, logs and unknown files are protected; links are excluded. Opening deletes nothing.');
tabs=uitabgroup(window,'Position',[20 144 1140 524]);
fileTab=uitab(tabs,'Title','Actual files - choose what to keep');
guideTab=uitab(tabs,'Title','Outputs from Steps 1-17');
table=uitable(fileTab,'Position',[5 5 1125 483], ...
    'ColumnName',{'Keep','Step','File (relative to scope)','MiB','Output / protection'}, ...
    'ColumnEditable',[true false false false false], ...
    'ColumnWidth',{50 55 590 75 340},'CellEditCallback',@editKeep);
guide=outputGuide();
uitable(guideTab,'Position',[5 5 1125 483],'Data',guide, ...
    'ColumnName',{'Step','Outputs / purpose'},'ColumnWidth',{60 1040},'ColumnEditable',[false false]);
uilabel(window,'Position',[20 112 85 22],'Text','Keep steps:');
steps=uieditfield(window,'text','Position',[105 112 150 22],'Value','12:17');
uibutton(window,'Position',[265 112 155 24],'Text','Apply keep steps','ButtonPushedFcn',@applySteps);
uibutton(window,'Position',[430 112 110 24],'Text','Keep all','ButtonPushedFcn',@keepAll);
uibutton(window,'Position',[550 112 200 24],'Text','Uncheck generated files','ButtonPushedFcn',@uncheckAll);
summary=uilabel(window,'Position',[20 80 1140 24],'Text','');
uilabel(window,'Position',[20 54 1140 22],'Text', ...
    'Deleting prerequisites prevents later reruns. Paired image/JSON/affine files stay together; Step 12 completion caches may be cleared.');
ready=uicheckbox(window,'Position',[20 20 710 24],'Text','I have stopped all other MIKey jobs using this dataset.','Value',false);
preview=uibutton(window,'Position',[885 20 275 28],'Text','Preview deletion...','ButtonPushedFcn',@showPreview);
refresh();
    function refresh()
        data=cell(numel(plan.files),5);
        for k=1:numel(plan.files)
            f=plan.files(k); label=num2str(f.step); if f.protected, label='-'; end
            data(k,:)={keep(k),label,f.relative,f.bytes/1024^2,f.description};
        end
        table.Data=data;
        summary.Text=sprintf('Keep: %d files. Delete: %d files, %.3f GiB. Logs are retained outside this list.', ...
            nnz(keep),nnz(~keep),sum([plan.files(~keep).bytes])/1024^3);
    end
    function editKeep(~,event)
        if busy || previewOpen, refresh(); return; end
        row=event.Indices(1); keep(row)=logical(event.NewData);
        keep=MIKey_cleanup_keep(plan,keep,row); refresh();
    end
    function applySteps(~,~)
        if busy || previewOpen, return; end
        try
            parsed=MIKey_config(struct('steps',steps.Value)); selected=parsed.steps;
            keep=ismember([plan.files.step],selected)';
            keep=MIKey_cleanup_keep(plan,keep); refresh();
        catch ME, uialert(window,ME.message,'Invalid keep steps'); end
    end
    function keepAll(~,~)
        if busy || previewOpen, return; end
        keep=true(numel(plan.files),1); refresh();
    end
    function uncheckAll(~,~)
        if busy || previewOpen, return; end
        keep=MIKey_cleanup_keep(plan,false(numel(plan.files),1)); refresh();
    end
    function showPreview(~,~)
        if busy || previewOpen, return; end
        if ~ready.Value
            uialert(window,'Stop all other GUI, command-line and scheduler jobs for this dataset, then check the acknowledgement.','Other jobs'); return;
        end
        keep=MIKey_cleanup_keep(plan,keep); refresh(); selected=find(~keep);
        if isempty(selected), uialert(window,'No files are selected for deletion.','Nothing to delete'); return; end
        previewOpen=true;
        review=uifigure('Name','Review Permanent Deletion','Position',[110 120 1100 620]);
        reviewWindow=review;
        review.CloseRequestFcn=@cancelReview;
        uilabel(review,'Position',[20 576 1060 24],'FontWeight','bold','Text', ...
            sprintf('Permanently delete %d files (%.3f GiB). This cannot be undone.',numel(selected),sum([plan.files(selected).bytes])/1024^3));
        uilabel(review,'Position',[20 546 1060 24],'Text',plan.directory,'Tooltip',plan.directory);
        uitextarea(review,'Position',[20 95 1060 440],'Editable',false,'Value',{plan.files(selected).relative}');
        uilabel(review,'Position',[20 62 1060 25],'Text','Raw BIDS originals and protected files are excluded. Confirm only after reviewing this exact list.');
        uibutton(review,'Position',[700 20 180 28],'Text','Cancel','ButtonPushedFcn',@cancelReview);
        confirm=uibutton(review,'Position',[890 20 190 28],'Text','Delete listed files', ...
            'BackgroundColor',[1 .75 .7],'ButtonPushedFcn',@performDelete);
        function cancelReview(~,~)
            if busy, return; end
            previewOpen=false; delete(review);
        end
        function performDelete(~,~)
            if busy, return; end
            if ~isvalid(parent) || parent.UserData.runControl.Active
                uialert(review,'The main GUI is closed or processing is active. Cancel cleanup.','Cannot clean'); return;
            end
            busy=true; succeeded=false; confirm.Enable='off'; preview.Enable='off';
            try
                result=MIKey_cleanup_delete(plan,keep,'DELETE_REVIEWED_FILES');
                message=sprintf('Deleted %d files; failures: %d. Audit: %s',result.deleted,result.failed,result.auditFile);
                previewOpen=false; delete(review);
                plan=MIKey_cleanup_inventory(plan.bidsPath); keep=true(numel(plan.files),1); refresh();
                succeeded=result.failed==0;
                uialert(window,message,'Cleanup result');
            catch ME
                previewOpen=false; delete(review);
                uialert(window,[ME.message ' Rescan by closing and reopening this window before retrying.'],'Cleanup stopped');
                preview.Enable='off';
            end
            busy=false;
            if succeeded, preview.Enable='on'; end
        end
    end
    function closeWindow(~,~)
        if busy, return; end
        if ~isempty(reviewWindow) && isvalid(reviewWindow), delete(reviewWindow); end
        previewOpen=false; delete(window);
    end
end

function guide = outputGuide()
guide={1,'desc-orig copies and desc-scaled BOLD/T2w/fieldmap; raw BIDS originals are never included.'; ...
2,'desc-masked BOLD and T2w. Hand-drawn *_desc-boldbrain_mask / *_desc-anatbrain_mask are protected.'; ...
3,'desc-fieldmap corrected BOLD and recognized SPM fieldmap products.'; ...
4,'desc-slicetimed BOLD.'; ...
5,'desc-realign BOLD, desc-mean boldref and rp_*.txt motion parameters (needed for FD).'; ...
6,'desc-T2coreg T2w and Step 6 registration_qc JSON reports.'; ...
7,'desc-normalized BOLD, desc-T2normalized T2w, normalization parameters and Step 7 QC.'; ...
8,'desc-smoothed BOLD (input for Steps 10 and 12).'; ...
9,'desc-NBPCs.mat: non-brain PCs, needed for Steps 10 and 12.'; ...
10,'desc-regressed<N>pc images and desc-regressionResults.mat: candidate CC/FD results needed by Step 11.'; ...
11,'group_analysis: group_level_noise_estimation MAT/PNG/FIG and best_regression_strategy.mat (needed by Step 12).'; ...
12,'desc-Regressedpc / pcCSF / pcGS / pcCSFGS BOLD and desc-advancedRegressionResults.mat (Steps 13-16 inputs).'; ...
13,'*regionFC_*.mat: ROI FC matrices with ROI IDs and atlas provenance.'; ...
14,'Prior-label parcellation folders, cross-run Dice; shared Steps 14-16 tSNR and inter-subject variability.'; ...
15,'Clustering parcellation folders, maps, FC, Dice, iterations and concatenation_info.'; ...
16,'Voxel-mode parcellation folders, maps, FC, Dice, iterations and concatenation_info.'; ...
17,'Five-class GM/WM/CSF/OT/AIR native/imported/warped/modulated maps, smoothed GM/WM/CSF, bias, deformation and SPM models.'};
end

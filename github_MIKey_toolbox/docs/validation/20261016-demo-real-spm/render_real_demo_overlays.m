function render_real_demo_overlays(runNumber)
% World-coordinate QC images for manual inspection, not publication figures.
if nargin<1,runNumber=1;end
folder=fileparts(mfilename('fullpath'));w=jsondecode(fileread(fullfile(folder,'workspace.json')));
oldPath=path;cleanup=onCleanup(@()path(oldPath)); %#ok<NASGU>
addpath('D:/Program Files/MATLAB/mytoolbox/spm12');
base=fullfile(w.bidsPath,'derivatives','MIKey','sub-001');
stem=sprintf('sub-001_task-rest_run-%02d',runNumber);
bold=fullfile(base,'func',[stem '_desc-mean_boldref.nii']);
t2=fullfile(base,'anat','sub-001_acq-t2fsetra_run-01_desc-masked_T2w.nii');
coreg=fullfile(base,'anat',[stem '_space-bold_desc-T2coreg_T2w.nii']);
normT2=fullfile(base,'anat',[stem '_space-template_desc-T2normalized_T2w.nii']);
normBold=fullfile(base,'func',[stem '_space-template_desc-normalized_bold.nii']);
template=fullfile(w.workspace,'templates','Template_Mouse_v38.nii');
output=fullfile(folder,'overlays');if ~exist(output,'dir'),mkdir(output);end
if runNumber==1
    failed=fullfile(w.workspace,'baseline-qc','failed_candidates',[stem '_desc-step6postQC_T2w.nii']);
    compare(fullfile(w.workspace,'before-initialization_boldref.nii'),fullfile(w.workspace,'before-initialization_T2w.nii'),failed, ...
        fullfile(output,'uninitialized-demo-step6-failure.png'),'Uninitialized demo: before / actual failed SPM candidate');
end
compare(bold,t2,coreg,fullfile(output,[stem '_step6.png']),'Step 6: mean BOLD + T2w');
compare(template,coreg,normT2,fullfile(output,[stem '_step7_T2w.png']),'Step 7: template + T2w');
compare(template,bold,[normBold ',240'],fullfile(output,[stem '_step7_BOLD.png']),'Step 7: template + BOLD (output frame 240/480)');
disp('MIKEY_REAL_SPM_OVERLAYS_SAVED');
end

function compare(reference,before,after,output,label)
r=spm_vol(reference);r=r(1);b=spm_vol(before);b=b(1);a=spm_vol(after);a=a(1);
[x,y,z]=ndgrid(linspace(1,r.dim(1),48),linspace(1,r.dim(2),48),linspace(1,r.dim(3),min(48,r.dim(3))));
values=spm_sample_vol(r,x(:),y(:),z(:),1);intensity=scale(values);
world=r.mat*[x(:)';y(:)';z(:)';ones(1,numel(x))];foreground=world(1:3,intensity>0.1);
lo=min(foreground,[],2);hi=max(foreground,[],2);padding=.08*(hi-lo);lo=lo-padding;hi=hi+padding;
fig=figure('Visible','off','Position',[20 20 1800 900],'Color','w');closeFigure=onCleanup(@()close(fig)); %#ok<NASGU>
names={'Sagittal X','Coronal Y','Axial Z'};
for d=1:3
    axesToDraw=setdiff(1:3,d);u=linspace(lo(axesToDraw(1)),hi(axesToDraw(1)),160);
    v=linspace(lo(axesToDraw(2)),hi(axesToDraw(2)),160);[uu,vv]=ndgrid(u,v);
    for q=1:3
        slice=lo(d)+(0.25+0.25*(q-1))*(hi(d)-lo(d));
        grid=ones(4,numel(uu));grid(d,:)=slice;
        grid(axesToDraw(1),:)=uu(:)';grid(axesToDraw(2),:)=vv(:)';
        rr=sample(r,grid,size(uu));
        for state=1:2
            if state==1,m=b;text='Before';else,m=a;text='After';end
            subplot(3,6,(d-1)*6+(q-1)*2+state);
            imagesc(u,v,scale(rr)');axis image xy;colormap(gray(256));hold on;
            mm=scale(sample(m,grid,size(uu)));
            if max(mm(:))>0,contour(u,v,mm',[.12 .4 .7],'LineColor',[0 .85 .85],'LineWidth',.6);end
            title(sprintf('%s %s = %.1f',text,names{d},slice),'FontSize',9,'Interpreter','none');
            xlabel(sprintf('world axis %d',axesToDraw(1)));ylabel(sprintf('world axis %d',axesToDraw(2)));
        end
    end
end
annotation(fig,'textbox',[.02 .96 .96 .035],'String',[label ' | gray: reference; cyan: moving contours | world units after voxel scaling'], ...
    'EdgeColor','none','HorizontalAlignment','center','Interpreter','none','FontWeight','bold');
set(fig,'PaperPositionMode','auto');print(fig,output,'-dpng','-r110');
end

function values=sample(v,world,shape)
vox=v.mat\world;values=reshape(spm_sample_vol(v,vox(1,:)',vox(2,:)',vox(3,:)',1),shape);
end

function values=scale(values)
values=abs(values);values(~isfinite(values))=0;s=sort(values(:));
low=s(max(1,round(.02*numel(s))));high=s(max(1,round(.98*numel(s))));
values=max(0,min(1,(values-low)/max(eps,high-low)));
end

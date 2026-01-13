function MY_TOPUP_pars_SETUP(root_path,animal_path,folder,Preference,species)


switch lower(Preference)
    case 'reference'
        while 1
            for kk=1:2
                path = [fullfile(root_path,animal_path,filesep),num2str(folder(kk)),'\pdata\1\2dseq'];
                pars            =   get_pars(path);
                pars_ = MY_get_TopUp_pars(fullfile(root_path,animal_path,filesep),folder(kk),'');
                Img             =   read_seq(path,pars);
                dt = 4;
                CUT = min([10,size(Img,4)]);
                Img(:,:,:,CUT+1:end)=[];
                pars_(CUT+1:end,:)=[];
                eval(['I',num2str(kk),'=Img;'])
                eval(['pars_',num2str(kk),'=pars_;'])

            end
            I=cat(4,I1,I2);
            pars_=[pars_1;pars_2];

            A = pars_1(1,:).*pars_2(1,:);
            if ~isempty(find(A==-1))
                break;
            else
                folder(2)=folder(2)-1;
                if folder(2)==folder(1)
                   error('can NOT topup'); 
                end
            end
        end
        switch lower(species)
            case {'mouse'};      Voxel_Multiple = 20;
            case {'rat'};        Voxel_Multiple = 10;
            case {'marmoset'};   Voxel_Multiple = 6;
            case {'monkey'};     Voxel_Multiple = 2;
            case {'human'};      Voxel_Multiple = 1;
        end
        pars.resol = pars.resol * Voxel_Multiple;
        pars.pos0  = pars.pos0  * Voxel_Multiple;
                
        or      =   pars.orient;
        orient  =   pars.m_or;
        dims    =   pars.dims;
        resol   =   pars.resol;   %in mm
        tp      =   pars.tp;
        pos0    =   pars.pos0;
        vect    =   pars.vect;
        
        dims        =   dims(vect);
        
        %MATRIX________________________________________________________________
        orig = pos0./resol;
        off  = double(orig(1:3)).*double(resol(1:3));
        mat  = [ resol(1)     0         0      off(1)
            0      resol(2)     0      off(2)
            0         0      resol(3)  off(3)
            0         0         0        1   ];
        
        if strcmp(or,'axial')
            mat             =   spm_matrix([0 0 0 pi/2 0 0 1 1 1])*mat;
        elseif strcmp(or,'sagittal')
            mat             =   spm_matrix([0 0 0 0 -pi/2 pi 1 1 1])*mat;
        elseif strcmp (or,'coronal')
            mat             =   spm_matrix([0 0 0 0 0 pi 1 1 1])*mat;
        end
        
        path_out=[fullfile(root_path,animal_path,filesep) '\Results\' 'GEEPI.nii'];
        for k = 1:size(I,4)
            Vol(k,1) = struct(  'fname',    path_out,...
                'dim',      size(I(:,:,:,k)),...
                'mat',      mat,...
                'n',        [k,1],...
                'pinfo',    [1;0;0],...
                'descrip',  '',...
                'dt',       [dt 0]);
        end
        spm_write_vol_4D(Vol,I);
        
        ihdr = Vol(1);
        ihdr.fname = fullfile(root_path,animal_path,'Results','meanGEEPI.nii');
        img = mean(I,4);
        spm_write_vol(ihdr,img);
        
        
        filename = fullfile(fullfile(root_path,animal_path,filesep),'Results','GE.txt');
        dlmwrite(filename, num2str(pars_), 'delimiter', '', 'precision', 6);
        
        FSL_Path = fullfile(root_path,'FSL_folder',animal_path);
        mkdir(FSL_Path);
        copyfile(fullfile(root_path,animal_path,'Results','GEEPI.nii'),FSL_Path);
        copyfile(fullfile(root_path,animal_path,'Results','GE.txt'),FSL_Path);
        
    case 'geepi'
        
        FSL_Path = fullfile(root_path,'FSL_folder',animal_path);
        mkdir(FSL_Path);
        
        for kk = folder
            path = fullfile(root_path,animal_path,filesep);
            pars = MY_get_TopUp_pars(path,kk,'');
            filename = fullfile(path,'Results',num2str(kk),'acqparsGE.txt');
            dlmwrite(filename, num2str(pars), 'delimiter', '', 'precision', 6);
            
            
            copyfile(fullfile(path,'Results',num2str(kk),'2dseq.nii'),FSL_Path);
            cd(FSL_Path);
            eval(['!rename,2dseq.nii,2dseq_',num2str(kk),'.nii;']);
            
            %hdr = spm_vol(fullfile(path,'Results',num2str(kk),'2dseq.nii'));
            %fMRI_4D = spm_read_vols(hdr);
            %for h=1:numel(hdr);hdr(h).fname=fullfile(FSL_Path,['2dseq_',num2str(kk),'.nii']);end
            %spm_write_vol_4D(hdr,fMRI_4D);
            filename = fullfile(FSL_Path,['acqparsGE_',num2str(kk),'.txt']);
            dlmwrite(filename, num2str(pars), 'delimiter', '', 'precision', 6);
            
            
        end
end
% This batch script analyses the resting state fMRI dataset
% available from the SPM website using DCM:
%   http://www.fil.ion.ucl.ac.uk/spm/data/spDCM/
% as described in the SPM manual:
%   http://www.fil.ion.ucl.ac.uk/spm/doc/spm12_manual.pdf#Chap:DCM_rsfmri
%__________________________________________________________________________
% Copyright (C) 2014 Wellcome Trust Centre for Neuroimaging

% Adeel Razi
% $Id$

clear;
close all;

fs              = '\';       % platform-specific file separator
dir_base        = 'E:\Tajwar\TMS\TMS_ICA_AROMA\Active\Pre';
% dir_base        = 'E:\Tajwar\TMS\TMS_ICA_AROMA\Active\Post';
% dir_base        = 'E:\Tajwar\TMS\TMS_ICA_AROMA\Sham\Pre';
% dir_base        = 'E:\Tajwar\TMS\TMS_ICA_AROMA\Sham\Post';
dir_functional  = 'func'; % base directory of functional scans (Nifti)
dir_struct      = 'anat';

GLM          = 1;
specify_DCM  = 0;
estimate_DCM = 0;

RT = 2.0; % TR or the reptition time

cd(dir_base)
name_subj = dir('sub-*');


TIME = tic;

parfor s0 = 1 : length(name_subj)
 
    
    disp(['Analysing Subject : ', name_subj(s0).name]);
   
    subj_dir = [dir_base fs name_subj(s0).name fs 'ses-01'];

    f = spm_select('FPList', fullfile(subj_dir, 'ica-aroma-results'), '^denoised.*\.nii$');
%     mvmnt = sprintf('rp_%s',name_subj(s0).name);

    csf_mask_filename = split(name_subj(s0).name,'-');
     clear matlabbatch

  
    if GLM
        glmdir = fullfile(subj_dir,'glm');
        if ~exist(glmdir,'file'), mkdir(glmdir); end
    

        % First GLM specification
        %-----------------------------------------------------------------
        matlabbatch{1}.spm.stats.fmri_spec.dir = {glmdir};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = RT;
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(f);
        %     matlabbatch{glm1}.spm.stats.fmri_spec.global = 'Scaling';

        % First GLM estimation
        %-----------------------------------------------------------------
        matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(glmdir,'SPM.mat')};

        % Extraction of time series from WM and CSF
        %-----------------------------------------------------------------
        matlabbatch{3}.spm.util.voi.spmmat = {fullfile(glmdir,'SPM.mat')};
        matlabbatch{3}.spm.util.voi.adjust = NaN;
        matlabbatch{3}.spm.util.voi.session = 1;
        matlabbatch{3}.spm.util.voi.name = 'CSF';
        matlabbatch{3}.spm.util.voi.roi{1}.sphere.centre = [0 -40 -5]; % 0 -40 -5   
        matlabbatch{3}.spm.util.voi.roi{1}.sphere.radius = 6;
        matlabbatch{3}.spm.util.voi.roi{1}.sphere.move.fixed = 1;
        matlabbatch{3}.spm.util.voi.roi{2}.mask.image = {fullfile(glmdir,'mask.nii')};
        matlabbatch{3}.spm.util.voi.expression = 'i1 & i2';

        matlabbatch{4} = matlabbatch{3};
        matlabbatch{4}.spm.util.voi.name = 'WM';
        matlabbatch{4}.spm.util.voi.roi{1}.sphere.centre = [0 -24 -33]; % 0 -24 -33 for all and 0 -25 -30 for subject # 17 (in pre-TMS)
 
        % Second GLM specification
        %-----------------------------------------------------------------
        
        glmdir = fullfile(subj_dir,'analysis_v4');
        if ~exist(glmdir,'file'), mkdir(glmdir); end
        
        matlabbatch{5}.spm.stats.fmri_spec.dir = {glmdir};
        matlabbatch{5}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{5}.spm.stats.fmri_spec.timing.RT = 2;
        matlabbatch{5}.spm.stats.fmri_spec.sess.scans = cellstr(f);
        matlabbatch{5}.spm.stats.fmri_spec.sess.multi_reg = {
%             fullfile(subj_dir,'func',mvmnt),...
            fullfile(subj_dir,'glm','VOI_CSF_1.mat'),...
            fullfile(subj_dir,'glm','VOI_WM_1.mat'),...
            }';
        %     matlabbatch{4}.spm.stats.fmri_spec.global = 'Scaling';

        % Second GLM estimation
        %-----------------------------------------------------------------
        matlabbatch{6}.spm.stats.fmri_est.spmmat = {fullfile(glmdir,'SPM.mat')};

        % Extraction of time series from specific 11 nodes
        %-----------------------------------------------------------------
        matlabbatch{7}.spm.util.voi.spmmat = {fullfile(glmdir,'SPM.mat')};
        matlabbatch{7}.spm.util.voi.adjust = NaN;
        matlabbatch{7}.spm.util.voi.session = 1;
        matlabbatch{7}.spm.util.voi.name = 'mPFC';
        matlabbatch{7}.spm.util.voi.roi{1}.sphere.centre = [0 62 5]; 
        matlabbatch{7}.spm.util.voi.roi{1}.sphere.radius = 8;
        matlabbatch{7}.spm.util.voi.roi{2}.mask.image = {fullfile(glmdir,'mask.nii')};
        matlabbatch{7}.spm.util.voi.expression = 'i1 & i2';

        matlabbatch{8} = matlabbatch{7};
        matlabbatch{8}.spm.util.voi.name = 'PCC';
        matlabbatch{8}.spm.util.voi.roi{1}.sphere.centre = [0 -43 23];
        matlabbatch{8}.spm.util.voi.roi{3}.mask.image = {spm_select('FPList',fullfile('E:/Tajwar/TMS/rTMS_TBI_pre',strcat('rTMS_TBI_',csf_mask_filename(2),'_01'),'struc'),'^c3.*\.nii$')};
        matlabbatch{8}.spm.util.voi.expression = 'i1 & i2 & ~i3';
        
        matlabbatch{9} = matlabbatch{7};
        matlabbatch{9}.spm.util.voi.name = 'lHP';
        matlabbatch{9}.spm.util.voi.roi{1}.sphere.centre = [-21 -22 -16]; 
        matlabbatch{9}.spm.util.voi.roi{3}.mask.image = {fullfile(dir_base,'stanfordfROI_mask_Lhippo.nii')};
        matlabbatch{9}.spm.util.voi.expression = 'i1 & i2 & i3';

        matlabbatch{10} = matlabbatch{7};
        matlabbatch{10}.spm.util.voi.name = 'rHP';
        matlabbatch{10}.spm.util.voi.roi{1}.sphere.centre = [24 -19 -16]; 
        matlabbatch{10}.spm.util.voi.roi{3}.mask.image = {fullfile(dir_base,'stanfordfROI_mask_Rhippo.nii')};
        matlabbatch{10}.spm.util.voi.expression = 'i1 & i2 & i3';
        
        matlabbatch{11} = matlabbatch{7};
        matlabbatch{11}.spm.util.voi.name = 'lAMG';
        matlabbatch{11}.spm.util.voi.roi{1}.sphere.centre = [-18 -4 -16]; 
        matlabbatch{11}.spm.util.voi.roi{3}.mask.image = {fullfile(dir_base,'wfu_mask_LAmygdala.nii')};
        matlabbatch{11}.spm.util.voi.expression = 'i1 & i2 & i3';
        
        matlabbatch{12} = matlabbatch{7};
        matlabbatch{12}.spm.util.voi.name = 'rAMG';
        matlabbatch{12}.spm.util.voi.roi{1}.sphere.centre = [18 -4 -16]; 
        matlabbatch{12}.spm.util.voi.roi{3}.mask.image = {fullfile(dir_base,'wfu_mask_RAmygdala.nii')};
        matlabbatch{12}.spm.util.voi.expression = 'i1 & i2 & i3';
        
        matlabbatch{13} = matlabbatch{7};
        matlabbatch{13}.spm.util.voi.name = 'dACC';
        matlabbatch{13}.spm.util.voi.roi{1}.sphere.centre = [0 32 23]; 
        matlabbatch{13}.spm.util.voi.expression = 'i1 & i2';
        
        
        matlabbatch{14} = matlabbatch{7};
        matlabbatch{14}.spm.util.voi.name = 'lAI'; 
        matlabbatch{14}.spm.util.voi.roi{1}.sphere.centre = [-39 14 2]; 
        matlabbatch{14}.spm.util.voi.roi{3}.mask.image = {fullfile(dir_base,'wfu_mask_LINS.nii')};
        matlabbatch{14}.spm.util.voi.expression = 'i1 & i2 & i3';
        
        
        matlabbatch{15} = matlabbatch{7};
        matlabbatch{15}.spm.util.voi.name = 'rAI';
        matlabbatch{15}.spm.util.voi.roi{1}.sphere.centre = [39 17 2]; 
        matlabbatch{15}.spm.util.voi.roi{3}.mask.image = {fullfile(dir_base,'wfu_mask_RINS.nii')};
        matlabbatch{15}.spm.util.voi.expression = 'i1 & i2 & i3';
        
        matlabbatch{16} = matlabbatch{7};
        matlabbatch{16}.spm.util.voi.name = 'lDLPFC';
        matlabbatch{16}.spm.util.voi.roi{1}.sphere.centre = [-48 32 14]; 
        matlabbatch{16}.spm.util.voi.expression = 'i1 & i2';
        
        matlabbatch{17} = matlabbatch{7};
        matlabbatch{17}.spm.util.voi.name = 'rDLPFC';
        matlabbatch{17}.spm.util.voi.roi{1}.sphere.centre = [30 53 29]; 
        matlabbatch{17}.spm.util.voi.expression = 'i1 & i2';
        


        
        spm_jobman('run',matlabbatch);
    end  

        % DCM specification
        %--------------------------------------------------------------
    if specify_DCM
        
        glmdir = fullfile(subj_dir,'analysis_v4');
        cd(glmdir)
        load('VOI_PCC_1.mat');
        DCM.xY(1) = xY;
        load('VOI_mPFC_1.mat');
        DCM.xY(2) = xY;
        load('VOI_lHP_1.mat');
        DCM.xY(3) = xY;
        load('VOI_rHP_1.mat');
        DCM.xY(4) = xY;
        load('VOI_lAMG_1.mat');
        DCM.xY(5) = xY;
        load('VOI_rAMG_1.mat');
        DCM.xY(6) = xY;
        load('VOI_dACC_1.mat');
        DCM.xY(7) = xY;
        load('VOI_lAI_1.mat');
        DCM.xY(8) = xY;
        load('VOI_rAI_1.mat');
        DCM.xY(9) = xY;
        load('VOI_lDLPFC_1.mat');
        DCM.xY(10) = xY;
        load('VOI_rDLPFC_1.mat');
        DCM.xY(11) = xY;
 

        DCM.v = length(DCM.xY(1).u); % number of time points
        DCM.n = length(DCM.xY);      % number of regions
        DCM.Y.dt  = RT;
        DCM.Y.X0  = DCM.xY(1).X0;

        for i = 1:DCM.n
            DCM.Y.y(:,i)  = DCM.xY(i).u;
            DCM.Y.name{i} = DCM.xY(i).name;
        end

        Y  = DCM.Y;                             % responses
        v  = DCM.v;                             % number of scans
        n  = DCM.n;                             % number of regions

        DCM.Y.Q    = spm_Ce(ones(1,n)*v);
        DCM.U.u    = zeros(v,1);
        DCM.U.name = {'null'};         

        DCM.a = ones(n,n);
        DCM.b  = zeros(n,n,0);
        DCM.c  = zeros(n,0);
        DCM.d = zeros(n,n,0);

        DCM.TE     = 0.04;
        DCM.delays = repmat(RT,DCM.n,1);

        DCM.options.nonlinear  = 0;
        DCM.options.two_state  = 0;
        DCM.options.stochastic = 0;
        DCM.options.analysis   = 'CSD';
        DCM.options.induced    = 1;
        DCM.options.maxnodes       = 16; % number of modes that we want to use
        %     DCM.options.nograph    = 1;


        str = sprintf('DCM_%s',name_subj(s0).name);
        DCM.name = str;
        save(fullfile(glmdir,str),'DCM');

    end

    % DCM estimation
    %-----------------------------------------------------------------------
    if estimate_DCM
        glmdir = fullfile(subj_dir,'analysis_v4');
        cd(glmdir);
        str = sprintf('DCM_%s',name_subj(s0).name);
        DCM = spm_dcm_fmri_csd(fullfile(glmdir,str));
%         save(fullfile(glmdir,str),'DCM');
        cd('E:\Tajwar\TMS');
        TMS_save_for_parfor(glmdir,str,DCM);
        
    end
end



fprintf('This took %s', duration([0, 0, toc(TIME)]));

% GCM = cellstr(spm_select('FPListRec',fullfile('D:\Tajwar\TMS\TMS_ICA_AROMA','Active','Pre'),'^DCM.*\.mat$');
% spm_dcm_fmri_check(GCM);
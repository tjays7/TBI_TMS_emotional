clear
close all;
%%
GCM_dir = 'D:\Tajwar\TMS\TMS_ICA_AROMA';

cd(GCM_dir)

Pre_Active_Sub = dir('Active\Pre\sub*');
Pre_Sham_Sub = dir('Sham\Pre\sub*');
Post_Active_Sub = dir('Active\Post\sub*');
Post_Sham_Sub = dir('Sham\Post\sub*');

GCM_TBI_Pre_Active  = cellstr((spm_select('FPList', fullfile(GCM_dir,'Active','Pre',{Pre_Active_Sub.name},'ses-01','analysis_v4'), '^DCM.*\.mat$')));
GCM_TBI_Pre_Sham  = cellstr((spm_select('FPList', fullfile(GCM_dir,'Sham','Pre',{Pre_Sham_Sub.name},'ses-01','analysis_v4'), '^DCM.*\.mat$')));
GCM_TBI_Post_Active  = cellstr((spm_select('FPList', fullfile(GCM_dir,'Active','Post',{Post_Active_Sub.name},'ses-01','analysis_v4'), '^DCM.*\.mat$')));
GCM_TBI_Post_Sham  = cellstr((spm_select('FPList', fullfile(GCM_dir,'Sham','Post',{Post_Sham_Sub.name},'ses-01','analysis_v4'), '^DCM.*\.mat$')));

GCM_Pre = [GCM_TBI_Pre_Sham;GCM_TBI_Pre_Active]; 
GCM_Post = [GCM_TBI_Post_Sham;GCM_TBI_Post_Active];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First provide estimated DCM as GCM (Group DCM) cell array. Individual DCMs can be
% estimated by using spm_dcm_fit.m

M = struct();
M.alpha = 1;
M.beta  = 16;
M.hE    = 0;
M.hC    = 1/16;
M.Q = 'single';

N_Pre = length(GCM_Pre);
N_Post = length(GCM_Post);
N1 = length(GCM_TBI_Pre_Active); % length of Pre-Active
N2 = length(GCM_TBI_Pre_Sham); % length of Pre-Sham
N3 = length(GCM_TBI_Post_Active); % length of Post-Active
N4 = length(GCM_TBI_Post_Sham); % length of Post-Sham



%% Design Matrix
% Specify design matrix for N subjects. It should start with a constant column
% Within group differences of Pre-rTMS subjects (-1s for Pre-Sham, 1s for Pre-Active, and then mean-corrected)

C1 = [-ones(N2,1); ones(N1,1)]; % Pre-Sham vs Pre-Active TBI [-1  1]
C1 = C1 - mean(C1);

% Within group differences of Post-rTMS subjects (-1s for Post-Sham, 1s for Post-Active, and then mean-corrected)
C2 = [-ones(N4,1); ones(N3,1)]; % Post-Sham vs Post-Active TBI [-1 1]
C2 = C2 - mean(C2);

% Group difference (-1 for Pre, 1 for Post, and then mean-corrected)
% Effect of Groups i.e. group differences between Pre and Post
C3 = [-ones(N_Pre,1);ones(N_Post,1)];
C3 = C3 - mean(C3);

% Choose field
field = {'A'};

% For Pre
X1 = [ones(N_Pre,1) C1];
M.X = X1;
PEB1     = spm_dcm_peb(GCM_Pre,M,field);
BMA1 = spm_dcm_peb_bmc(PEB1);

% For Post
X2 = [ones(N_Post,1) C2];
M.X = X2;
PEB2     = spm_dcm_peb(GCM_Post,M,field);
BMA2 = spm_dcm_peb_bmc(PEB2);

% For Group Difference
X3 = [ones(N_Pre + N_Post,1) C3];
M.X = X3;

% Estimate model

PEBs = {PEB1; PEB2};
PEB3 = spm_dcm_peb(PEBs, M, field);
BMA3 = spm_dcm_peb_bmc(PEB3);

save('PEB_TBI_preVSpost_v4.mat','BMA3','PEB1','PEB2', 'PEB3','BMA1','BMA2', 'GCM_Pre', 'GCM_Post', 'X1','X2','X3');

spm_dcm_peb_review(BMA3)


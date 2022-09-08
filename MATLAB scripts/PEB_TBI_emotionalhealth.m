clear;
close all;
%%
GCM_dir = 'E:\Tajwar\TMS\TMS_ICA_AROMA';

cd(GCM_dir)

Post_Active_Sub = dir('Active\Post\sub*');
GCM_TBI_Post_Active  = cellstr((spm_select('FPList', fullfile(GCM_dir,'Active','Post',{Post_Active_Sub.name},'ses-01','analysis_v4'), '^DCM.*\.mat$')));

%Post_Sham_Sub = dir('Sham\Post\sub*');
%GCM_TBI_Post_Sham = cellstr((spm_select('FPList', fullfile(GCM_dir,'Sham','Post',{Post_Sham_Sub.name},'ses-01','analysis_v4'), '^DCM.*\.mat$')));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First provide estimated DCM as GCM (Group DCM) cell array. 

M = struct();
M.alpha = 1;
M.beta  = 16;
M.hE    = 0;
M.hC    = 1/16;
M.Q = 'single';

N = length(GCM_TBI_Post_Active); % length of Post-Active
%N = length(GCM_TBI_Post_Sham); 


%% Emotional well-being (VR-36 Test)
%
excel_file_post = xlsread('E:\Tajwar\TMS\XJ Excel Files\info for Tajwar.xlsx','VR36 visit 2');
excel_file_base = xlsread('E:\Tajwar\TMS\XJ Excel Files\info for Tajwar.xlsx','VR36 baseline');


Subj_Post = excel_file_post(:,82);
mentalhealth_Post_all = excel_file_post(:,78);
mentalhealth_Base_all = excel_file_base(:,78);
Active_Sham = excel_file_post(:,83);
mentalhealth_Post_Active = [];
mentalhealth_Base_Active = [];
mentalhealth_Base_Sham = [];
mentalhealth_Post_Sham = [];

for i = 1:length(mentalhealth_Post_all)
    if (Subj_Post(i) && Active_Sham(i))
        mentalhealth_Post_Active = cat(1,mentalhealth_Post_Active,mentalhealth_Post_all(i));
    end
end

for i = 1:length(mentalhealth_Base_all)
    if (Subj_Post(i) && Active_Sham(i))
        mentalhealth_Base_Active = cat(1,mentalhealth_Base_Active,mentalhealth_Base_all(i));
    end
end

for i = 1:length(mentalhealth_Post_all)
    if (Subj_Post(i) && ~Active_Sham(i))
        mentalhealth_Post_Sham = cat(1,mentalhealth_Post_Sham,mentalhealth_Post_all(i));
    end
end

for i = 1:length(mentalhealth_Base_all)
    if (Subj_Post(i) && ~Active_Sham(i))
        mentalhealth_Base_Sham = cat(1,mentalhealth_Base_Sham,mentalhealth_Base_all(i));
    end
end

%% ttest for mentalhealth_Base_Active and mentalhealth_Post_Active
[h,p] = ttest(mentalhealth_Base_all,mentalhealth_Post_all) % h = 0, p = 0.1915 => not sufficient evidence to reject null hypothesis 
[h,p] = ttest(mentalhealth_Base_Active,mentalhealth_Post_Active) % h = 1, p = 0.0114 => May reject null hypothesis
[h,p] = ttest(mentalhealth_Base_Sham,mentalhealth_Post_Sham) % h = 0, p = 0.5126 => Not sufficient evidence to reject null hypothesis

% Unpaired t-test between pre-Active and pre-Sham to see whether they
% belong to the same distribution because pre-Sham mean score of mental health
% is > pre-Active score
[h,p] = ttest2(mentalhealth_Base_Active,mentalhealth_Base_Sham) % h = 0, p = 0.0520

% mean(mentalhealth_Base_Active)
% ans = 57.8182

% mean(mentalhealth_Post_Active)
% ans = 73.0909

% mean(mentalhealth_Base_Sham)
% ans = 70.4000

% After replacing NaN in mentalhealth_Post_Sham with mean:
% mean(mentalhealth_Post_Sham)
% ans = 70.8571

%%
% Normality test for mentalhealth scores for Post Active group


figure; normplot(mentalhealth_Post_all);
figure; hist(mentalhealth_Post_all);
lillietest(mentalhealth_Post_all) % Hypothesis test; if 0 then failure to reject the 
% null hypothesis that the samples are normally distributed

%%
% BOXCOX Power Transformation
[mentalhealth_Post_all, lambda] = boxcox(mentalhealth_Post_all);
figure; normplot(mentalhealth_Post_all);
figure; hist(mentalhealth_Post_all);
lillietest(mentalhealth_Post_all)

%% mean centered mentalhealth score
mentalhealth_Post_Active = mentalhealth_Post_Active - mean(mentalhealth_Post_Active);

%% Replacing NAN in mentalhealth_Post_Sham with mean
for i = 1 : size(mentalhealth_Post_Sham,1)
   if (isnan(mentalhealth_Post_Sham(i)))
        mentalhealth_Post_Sham(i) = nanmean(mentalhealth_Post_Sham);
   end
end
mentalhealth_Post_Sham = mentalhealth_Post_Sham - mean(mentalhealth_Post_Sham);


%% Design Matrix
% Specify design matrix for N subjects. It should start with a constant column

% Choose field
% field = {'A'};

% Significant connections in Active group for pruned PEB for association
% between post rTMS connectivity and mental health data
field = {'A(1,7)', 'A(2,2)', 'A(3,3)', 'A(4,1)', 'A(4,4)', 'A(6,11)', 'A(7,2)', 'A(7,8)', 'A(8,4)', 
        'A(8,8)', 'A(9,2)', 'A(10,2)', 'A(10,7)'};

% Significant connections in Sham group for pruned PEB for association
% between post rTMS connectivity and mental health data
% field = {'A(1,1)', 'A(1,5)', 'A(1,8)','A(1,9)','A(2,2)','A(3,7)','A(3,8)','A(3,9)','A(3,10)',...
%  'A(3,11)','A(4,1)','A(4,2)','A(4,3)','A(4,4)','A(5,1)','A(5,2)','A(5,5)','A(5,6)','A(5,7)',...
%     'A(5,8)','A(5,11)','A(6,1)','A(6,2)','A(6,3)','A(6,5)','A(6,7)','A(6,10)','A(7,2)',...
%     'A(7,7)','A(7,11)','A(8,7)','A(8,8)','A(8,9)','A(8,10)','A(9,2)','A(9,8)','A(9,10)',...
%     'A(10,2)','A(10,7)','A(10,8)','A(10,9)','A(10,10)','A(11,8)','A(11,9)'};

M.X = [ones(N,1) DR_Post_Active];
PEB = spm_dcm_peb(GCM_TBI_Post_Active,M,field);
BMA = spm_dcm_peb_bmc(PEB);

save('PEB_TBI_DR_Active_pruned_withactiveconnections.mat','BMA','PEB','GCM_TBI_Post_Active', 'M');

spm_dcm_peb_review(BMA)


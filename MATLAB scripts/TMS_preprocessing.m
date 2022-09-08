clear

% Define subject parameters and directories
%===========================================================================

direc   = 'D:\Tajwar\TMS\rTMS_TBI_pre';
myFiles = dir(fullfile(direc));
%subfolders = myFiles([myFiles.isdir]);
cd(direc)
subfolders = dir('rTMS*');

%% Initialize SPM

spm('Defaults','fMRI');
spm_jobman('initcfg');

batch = {}; 

for k = 3:length(subfolders)

    SubjectFileName = subfolders(k).name;
    
    f       = spm_select('FPList', fullfile(direc,SubjectFileName,'func'), '^(srTMS|sRTMS).*\.nii$');
    s       = spm_select('FPList', fullfile(direc,SubjectFileName,'struc'), '^(srTMS|sRTMS).*\.nii$');

    clear matlabbatch


%% Realignment
    
    matlabbatch{1}.spm.spatial.realign.estwrite.data = {cellstr(f)};
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    
    
%% Coregistration

matlabbatch{2}.spm.spatial.coreg.estimate.ref = cellstr(spm_file(f(1,:),'prefix','mean'));
matlabbatch{2}.spm.spatial.coreg.estimate.source = cellstr(s);


%% Segmentation

matlabbatch{3}.spm.spatial.preproc.channel.vols  = cellstr(s);
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 1];
matlabbatch{3}.spm.spatial.preproc.warp.write    = [0 1];

%% Normalization

matlabbatch{4}.spm.spatial.normalise.write.subj.def      = cellstr(spm_file(s,'prefix','y_','ext','nii'));
matlabbatch{4}.spm.spatial.normalise.write.subj.resample = cellstr(f);
matlabbatch{4}.spm.spatial.normalise.write.woptions.vox  = [3 3 3];

matlabbatch{5}.spm.spatial.normalise.write.subj.def      = cellstr(spm_file(s,'prefix','y_','ext','nii'));
matlabbatch{5}.spm.spatial.normalise.write.subj.resample = cellstr(spm_file(s,'prefix','m','ext','nii'));
matlabbatch{5}.spm.spatial.normalise.write.woptions.vox  = [1 1 1];

%% Smoothing

matlabbatch{6}.spm.spatial.smooth.data = cellstr(spm_file(f,'prefix','w'));
matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];

% store batch per subject
batch{k} = matlabbatch;

end
%% Preprocessing Batch Execution
TIME = tic;
% Parallel computation for upto 6 batches because my system has 6 cores

parfor k = 3:length(subfolders) 

    
    spm_jobman('run',batch{k});
    
end
fprintf('This took %s', duration([0, 0, toc(TIME)]));


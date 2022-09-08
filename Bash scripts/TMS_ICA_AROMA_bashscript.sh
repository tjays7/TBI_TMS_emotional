#!/bin/bash

### Creating Binary mask using Brain Extraction Tool (BET) FSL

#for val in {001,002,006,007,009,022,023,027,028,033}

#do
#rm -r /mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/ica-aroma-results
#done



do
bet \
/mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/func/sub-${val}_ses-01_task-rest_bold.nii \
/mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/func/sub-${val}_ses-01_task-rest_bold_mask.nii \
-f 0.3 -n -m
done

### Applying ICA-AROMA

for val in {001,002,006,007,009,022,023,027,028,033}
do
python2.7 /mnt/e/venv2/ICA-AROMA/ICA_AROMA.py \
-in /mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/func/sub-${val}_ses-01_task-rest_bold.nii \
-out /mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/ica-aroma-results \
-mc /mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/func/rp_* \
-m /mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/func/sub-${val}_ses-01_task-rest_bold_mask_mask.nii.gz \
-tr 2
done



### Unzip denoised components obtained after ICA-AROMA

for val in {001,002,006,007,009,022,023,027,028,033}
do
gunzip /mnt/d/Tajwar/TMS/TMS_ICA_AROMA/Sham/Post/sub-${val}/ses-01/ica-aroma-results/denoised_func_data_nonaggr.nii.gz
done




## Lei Xie, Zhejiang University of Technology, e-mail:xielei@zjut.edu.cn

#base_dir="/mnt/disk1/HCP_Data/chcp_data"
#base_dir="/mnt/disk1/Difft5T_BIDS/"
base_dir="/mnt/disk1/CNsAtlas-main/ds004910-download/data"
#base_dir="/mnt/disk1/wm_data/chcp_data"
####################################################################################
#default input
MIN_T1=/mnt/disk1/CNsAtlas-main/CNs_MNI/MNI152_T1_1mm.nii.gz
MNI_CNII=/mnt/disk1/CNsAtlas-main/CNs_MNI/MNI152_CNII_Mask.nii.gz
MNI_CNIII=/mnt/disk1/CNsAtlas-main/CNs_MNI/MNI152_CNIII_Mask.nii.gz
MNI_CNV=/mnt/disk1/CNsAtlas-main/CNs_MNI/MNI152_CNV_Mask.nii.gz
MNI_CNVIIVIII=/mnt/disk1/CNsAtlas-main/CNs_MNI/MNI152_CNVIIVIII_Mask.nii.gz
brainstem_ROI=/mnt/disk1/CNsAtlas-main/CNs_MNI/brainstem_ROI.nii.gz

for subject_dir in "$base_dir"/*; do
    #The inputs of your need 
    subject_name=$(basename "$subject_dir")
    #T1=$subject_dir/T1w_acpc_dc_restore_1.20.nii.gz
    id="${subject_name#*-}"
    #T1=$subject_dir/anat/${id}_T1w.nii.gz
    T1=$subject_dir/anat/${subject_name}_T1w.nii.gz
    #Output_fold=$subject_dir/Output_fold
    #mkdir $Output_fold
    #######################################################################################

    MaskGatedFronMNI=$subject_dir/MaskGatedFronMNI
    mkdir $MaskGatedFronMNI

    #registrate MNI_CNs to individual T1 as ROI
    flirt -in $MIN_T1 -ref $T1 -out $MaskGatedFronMNI/MNI2HCP_T1.nii.gz -omat $MaskGatedFronMNI/MNI2HCP.mat
    rm -rf $MaskGatedFronMNI/MNI2HCP_T1.nii.gz
    flirt -in $MNI_CNII -ref $T1 -out $MaskGatedFronMNI/CNII_ROI.nii.gz -init $MaskGatedFronMNI/MNI2HCP.mat -applyxfm
    flirt -in $MNI_CNIII -ref $T1 -out $MaskGatedFronMNI/CNIII_ROI.nii.gz -init $MaskGatedFronMNI/MNI2HCP.mat -applyxfm
    flirt -in $MNI_CNV -ref $T1 -out $MaskGatedFronMNI/CNV_ROI.nii.gz -init $MaskGatedFronMNI/MNI2HCP.mat -applyxfm
    flirt -in $MNI_CNVIIVIII -ref $T1 -out $MaskGatedFronMNI/CNVIIVIII_ROI.nii.gz -init $MaskGatedFronMNI/MNI2HCP.mat -applyxfm
    flirt -in $brainstem_ROI -ref $T1 -out $MaskGatedFronMNI/brainstem_ROI.nii.gz -init $MaskGatedFronMNI/MNI2HCP.mat -applyxfm

    #CNII_seed
    mrcalc $MaskGatedFronMNI/CNII_ROI.nii.gz 0.1 -ge $MaskGatedFronMNI/CNII_Seedimage.nii.gz -datatype uint8 -force

    #CNIII_seed
    mrcalc $MaskGatedFronMNI/CNIII_ROI.nii.gz $MaskGatedFronMNI/brainstem_ROI.nii.gz -add $MaskGatedFronMNI/CNIII_Seedimage.nii.gz -force
    mrcalc $MaskGatedFronMNI/CNIII_Seedimage.nii.gz 0.1 -ge $MaskGatedFronMNI/CNIII_Seedimage.nii.gz -datatype uint8 -force

    #CNV_seed
    mrcalc $MaskGatedFronMNI/CNV_ROI.nii.gz $MaskGatedFronMNI/brainstem_ROI.nii.gz -add $MaskGatedFronMNI/CNV_Seedimage.nii.gz -force
    mrcalc $MaskGatedFronMNI/CNV_Seedimage.nii.gz 0.1 -ge $MaskGatedFronMNI/CNV_Seedimage.nii.gz -datatype uint8 -force

    #CNVIIVIII_seed
    mrcalc $MaskGatedFronMNI/CNVIIVIII_ROI.nii.gz $MaskGatedFronMNI/brainstem_ROI.nii.gz -add $MaskGatedFronMNI/CNVIIVIII_Seedimage.nii.gz -force
    mrcalc $MaskGatedFronMNI/CNVIIVIII_Seedimage.nii.gz 0.1 -ge $MaskGatedFronMNI/CNVIIVIII_Seedimage.nii.gz -datatype uint8 -force

done




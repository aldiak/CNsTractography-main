

## Lei Xie, Zhejiang University of Technology, e-mail:xielei@zjut.edu.cn

#base_dir="/mnt/disk1/HCP_Data/hcp_data1"
#base_dir="/mnt/disk1/wm_data/chcp_data"
#base_dir="/mnt/disk1/testset/CN1"
base_dir="/mnt/disk1/Difft5T_BIDS/"
#base_dir="/mnt/disk1/Alou_drive/data/"
#base_dir="/mnt/disk1/CNsAtlas-main/ds004910-download/data"
####################################################################################
for subject_dir in "$base_dir"/*; do
    #The inputs of your need 
    #The inputs of your need 
    subject_name=$(basename "$subject_dir")
    subject_name="${subject_name#sub-}"    # removes "sub-" from the beginning
    # MS_DTI=$subject_dir/data.nii.gz
    # MS_Bval=$subject_dir/bvals
    # MS_Bvec=$subject_dir/bvecs

    MS_DTI=$subject_dir/dwi/${subject_name}_dwi.nii.gz
    MS_Bval=$subject_dir/dwi/${subject_name}_dwi.bval
    MS_Bvec=$subject_dir/dwi/${subject_name}_dwi.bvec

    # MS_DTI=$subject_dir/dwi/${subject_name}_dwi.nii.gz
    # MS_Bval=$subject_dir/dwi/${subject_name}_dwi.bvals
    # MS_Bvec=$subject_dir/dwi/${subject_name}_dwi.bvecs

    # MS_DTI=$subject_dir/data.nii.gz
    # MS_Bval=$subject_dir/bvals
    # MS_Bvec=$subject_dir/bvecs
    # T1_IMAGE="$subject_dir/T1w_acpc_dc_restore_1.20.nii.gz"
    T1_IMAGE=$subject_dir/anat/${subject_name}_T1w.nii.gz


    #Output_fold=$subject_dir/Output_fold
    Track_out=$subject_dir/Track_out
    MaskGatedFronMNI=$subject_dir/MaskGatedFronMNI
    mkdir $Track_out
    mkdir $Track_out/CNs
    #######################################################################################

    ##
    mrconvert $MS_DTI $Track_out/DWI.mif -fslgrad $MS_Bvec $MS_Bval -force
    #
    dwi2response tournier $Track_out/DWI.mif $Track_out/response.txt -force
    #
    dwi2fod csd $Track_out/DWI.mif $Track_out/response.txt $Track_out/wm_fod.mif -force
    #
    ####sh2peaks wm_fod.mif peaks.nii.gz

    ## you can use iFOD1/iFOD2/SD_Stream

    tckgen -algorithm iFOD1 -angle 45 -maxlen 30 -minlen 10 -step 0.3 -seed_image $MaskGatedFronMNI/CNV_Seedimage.nii.gz -nthreads 12  $Track_out/wm_fod.mif  -select 5000 -cutoff 0.5 $Track_out/SD_Stream_CNV.tck -force 

    tckedit $Track_out/SD_Stream_CNV.tck $Track_out/SD_Stream_CNV.tck -mask $MaskGatedFronMNI/CNV_ROI.nii.gz -force

    tckconvert $Track_out/SD_Stream_CNV.tck $Track_out/SD_Stream_CNV.vtk -force

    tckgen -algorithm iFOD1 -angle 45 -maxlen 30 -minlen 10 -step 0.3 -seed_image $MaskGatedFronMNI/CNVIIVIII_Seedimage.nii.gz -nthreads 12  $Track_out/wm_fod.mif  -select 5000 -cutoff 0.5 $Track_out/SD_Stream_CNVIIVIII.tck -force 

    tckedit $Track_out/SD_Stream_CNVIIVIII.tck $Track_out/SD_Stream_CNVIIVIII.tck -mask $MaskGatedFronMNI/CNV_ROI.nii.gz -force

    tckconvert $Track_out/SD_Stream_CNVIIVIII.tck $Track_out/SD_Stream_CNVIIVIII.vtk -force

    # cd $Track_out/CNs
    # tckedit $Track_out/*.tck CNs.tck -force
    # tckconvert $Track_out/CNs/CNs.tck $Track_out/CNs/CNs.vtk -force

done
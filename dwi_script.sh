#!/bin/bash
# #source /usr/local/anaconda3/bin/activate research
# #python /mnt/disk1/CNsAtlas-main/data.py

# # Purpose: Process DWI data to compute FOD-based DEC map and DTI metrics using MRtrix3
# # Usage: ./dwi_fod_dec_metrics.sh <dwi.nii.gz> <bvals> <bvecs> <mask.nii.gz> <output_dir>
# # Requirements: MRtrix3 installed, input files in NIfTI format, suitable for HARDI (e.g., b=2000–3000 s/mm²)

# # Check if correct number of arguments is provided
# # if [ $# -ne 5 ]; then
# #     echo "Usage: $0 <dwi.nii.gz> <bvals> <bvecs> <mask.nii.gz> <output_dir>"
# #     exit 1
# # fi
#base_dir="/mnt/disk1/5T1"
base_dir="/media/alou/disk2/5T_data/Train_Set"
for subject_dir in "$base_dir"/*; do 
    # Assign input arguments to variables
    DWI=$subject_dir/data.nii.gz
    BVALS=$subject_dir/bvals
    BVECS=$subject_dir/bvecs
    T1_image=$subject_dir/T1w_acpc_dc_restore_1.20.nii.gz
    MASK=$subject_dir/nodif_brain_mask.nii.gz
    OUT_DIR=$subject_dir/

    # Create output directory if it doesn't exist
    #mkdir -p "$OUT_DIR"


    # # Step 1: Convert data to .mif format
    mrconvert $DWI $OUT_DIR/dwi.mif -fslgrad $BVECS $BVALS
    mrconvert $MASK $OUT_DIR/mask.mif

    # Step 2: Create a mask for future processing steps
    #dwi2mask $OUT_DIR/dwi.mif $OUT_DIR/mask.mif

    # Step 3: Estimate response function for CSD
    #echo "Estimating response function for CSD..."
    #dwi2response dhollander $OUT_DIR/dwi.mif $OUT_DIR/wm_response.txt $OUT_DIR/gm_response.txt $OUT_DIR/csf_response.txt -fslgrad $BVECS $BVALS -mask $OUT_DIR/mask.mif -force

    # Step 4: Compute FOD using CSD
    #echo "Computing FOD using CSD..."
    # Performs multishell-multitissue constrained spherical deconvolution, using the basis functions estimated above
    #dwi2fod msmt_csd $OUT_DIR/dwi.mif -mask $OUT_DIR/mask.mif $OUT_DIR/wm_response.txt $OUT_DIR/wmfod.mif $OUT_DIR/gm_response.txt $OUT_DIR/gmfod.mif $OUT_DIR/csf_response.txt $OUT_DIR/csffod.mif

    # Step 5: Generate FOD-based DEC map
    #echo "Generating FOD-based DEC map..."
    #fod2dec $OUT_DIR/wmfod.mif $OUT_DIR/dec.mif -mask $OUT_DIR/mask.mif

    # # Step 6: Fit diffusion tensor model (for FA, MD, AD, RD)
    echo "Fitting diffusion tensor model..."
    dwi2tensor $OUT_DIR/dwi.mif $OUT_DIR/tensor.mif -mask $OUT_DIR/mask.mif -fslgrad $BVECS $BVALS

    # Step 7: Compute tensor metrics (FA, MD, AD, RD)
    echo "Computing tensor metrics..."
    tensor2metric $OUT_DIR/tensor.mif -fa $OUT_DIR/fa.nii.gz -mask $OUT_DIR/mask.mif

    #tckconvert $subject_dir/Output_fold/AtlasToSubject_out/Final_results/CNs_all_VTK.vtk $OUT_DIR/CNs_all_VTK.tck -force
    #mrconvert $T1_image $subject_dir/T1.mif -force

    #tckmap $OUT_DIR/CNs_all_VTK.tck $OUT_DIR/CNs_all_VTK.nii.gz -template $T1_image -force

done

# Script_VTPTOVTK=/mnt/disk1/CNsAtlas-main/data.py 
# /home/alou/Downloads/Slicer-5.8.1-linux-amd64/Slicer --launch python-real $Script_VTPTOVTK 

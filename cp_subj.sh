#!/bin/bash

# Base directory containing the BIDS subjects (sub-*)
base_dir="/mnt/disk1/Difft5T_BIDS/"

# Top-level directory where all processed files will be collected
# This is OUTSIDE the BIDS dataset, one level above
top_new_dir="/mnt/disk1/Difft5T_CNV/"

# Create the top-level output directory if it doesn't exist
mkdir -p "${top_new_dir}"

# Loop over each subject directory (sub-*)
for subject_dir in "$base_dir"/*; do
    # Skip if not a directory
    [ -d "${subject_dir}" ] || continue

    # Extract subject name (e.g., sub-001)
    full_subject_id=$(basename "$subject_dir")
    
    # Remove "sub-" prefix to get just the ID (e.g., 001)
    subject_name="${full_subject_id#sub-}"

    echo "Processing subject: ${full_subject_id} (${subject_name})"

    # Define paths used in your original setup
    Track_out="${subject_dir}/Track_out"
    T1_IMAGE="${subject_dir}/anat/${subject_name}_T1w.nii.gz"  # Using full ID for safety

    # Define subject-specific output folder: /mnt/disk1/Additional_Inputs/001/
    subject_new_dir="${top_new_dir}/${subject_name}"
    mkdir -p "${subject_new_dir}"

    echo "  Target folder: ${subject_new_dir}"

    # 1. Copy CNV.nii.gz from Track_out
    if [ -f "${Track_out}/CNV.nii.gz" ]; then
        cp "${Track_out}/CNV.nii.gz" "${subject_new_dir}/CNV.nii.gz"
        echo "  → Copied CNV.nii.gz"
    else
        echo "  → Warning: CNV.nii.gz not found in ${Track_out}"
    fi

    # 2. Copy T1 image
    if [ -f "${T1_IMAGE}" ]; then
        cp "${T1_IMAGE}" "${subject_new_dir}/T1_image.nii.gz"
        echo "  → Copied T1_image.nii.gz"
    else
        echo "  → Warning: T1 image not found at ${T1_IMAGE}"
    fi

    # 2. Copy T1 image
    if [ -f "${subject_dir}/dwi/dec.nii.gz" ]; then
        cp "${subject_dir}/dwi/dec.nii.gz" "${subject_new_dir}/dec.nii.gz"
        echo "  → Copied dec.nii.gz"
    else
        echo "  → Warning: dec.nii.gz not found at ${subject_dir}/dwi/dec.nii.gz"
    fi

    # 3. Copy T2 image (try T2w first, then FLAIR as fallback)
    T2_IMAGE="${subject_dir}/anat/${subject_name}_T2w.nii.gz"
    if [ -f "${T2_IMAGE}" ]; then
        cp "${T2_IMAGE}" "${subject_new_dir}/T2_image.nii.gz"
        echo "  → Copied T2_image.nii.gz (from T2w)"
    else
        FLAIR_IMAGE="${subject_dir}/anat/${full_subject_id}_FLAIR.nii.gz"
        if [ -f "${FLAIR_IMAGE}" ]; then
            cp "${FLAIR_IMAGE}" "${subject_new_dir}/T2_image.nii.gz"
            echo "  → Copied T2_image.nii.gz (from FLAIR)"
        else
            echo "  → Warning: Neither T2w nor FLAIR found for ${full_subject_id}"
        fi
    fi

    echo "-----------------------------------"
done

echo "All subjects processed!"
echo "Files collected in: ${top_new_dir}"





# #!/bin/bash
# # =============================================================================
# # DTI + MSMT-CSD pipeline – truly incremental & resumable
# # Skips ANY step whose output already exists
# # Includes computation of Directionally Encoded Color (DEC) image using fod2dec
# # Fixed compatibility issues for recent MRtrix3 versions
# # =============================================================================

# base_dir="/mnt/disk1/Difft5T_BIDS/"

# for subject_dir in "$base_dir"/*; do
#     [[ -d "$subject_dir" ]] || continue
#     #subject=$(basename "$subject_dir")
#     subject_name=$(basename "$subject_dir")
#     subject_name="${subject_name#sub-}" 
#     echo "==================================================================="
#     echo "Processing subject: $subject"
#     echo "==================================================================="
#     OUT_DIR="$subject_dir"

#     # ------------------------------------------------------------------
#     # Required inputs – if missing, skip entire subject
#     # ------------------------------------------------------------------
#     DWI="$subject_dir/dwi/${subject_name}_dwi.nii.gz"
#     BVALS="$subject_dir/dwi/${subject_name}_dwi.bval"
#     BVECS="$subject_dir/dwi/${subject_name}_dwi.bvec"
#     MASK="$subject_dir/dwi/${subject_name}_mask.nii.gz"

#     for f in "$DWI" "$BVALS" "$BVECS" "$MASK"; do
#         [[ -f "$f" ]] || { echo "ERROR: Missing $f → skipping subject"; continue 2; }
#     done

#     # ==================================================================
#     # 1. Convert to MRtrix format – only if not already done
#     # ==================================================================
#     if [[ ! -f "$OUT_DIR/Track_out/dwi.mif" || ! -f "$OUT_DIR/dwi/mask.mif" ]]; then
#         echo "Converting to .mif format..."
#         #mrconvert "$DWI" "$OUT_DIR/dwi.mif" -fslgrad "$BVECS" "$BVALS" -force
#         mrconvert "$MASK" "$OUT_DIR/dwi/mask.mif" -force
#     else
#         echo "dwi.mif and mask.mif already exist → skipping conversion"
#     fi

#     # ==================================================================
#     # 2. Response functions (Dhollander) – only if WM response missing
#     # ==================================================================
#     # if [[ ! -f "$OUT_DIR/response_wm.txt" ]]; then
#     #     echo "Estimating response functions (Dhollander)..."
#     #     dwi2response dhollander "$OUT_DIR/Track_out/dwi.mif" \
#     #         "$OUT_DIR/response_wm.txt" \
#     #         "$OUT_DIR/response_gm.txt" \
#     #         "$OUT_DIR/response_csf.txt" \
#     #         -mask "$OUT_DIR/mask.mif" -force
#     # else
#     #     echo "Response functions already exist → skipping"
#     # fi

#     # ==================================================================
#     # 3. MSMT-CSD – only if WM FOD is missing
#     # ==================================================================
#     # if [[ ! -f "$OUT_DIR/Track_out/wm_fod.mif" ]]; then
#     #     echo "Running MSMT-CSD..."
#     #     dwi2fod msmt_csd "$OUT_DIR/dwi.mif" \
#     #         -mask "$OUT_DIR/mask.mif" \
#     #         "$OUT_DIR/response_wm.txt" "$OUT_DIR/wm_fod.mif" \
#     #         "$OUT_DIR/response_gm.txt" "$OUT_DIR/fod_gm.mif" \
#     #         "$OUT_DIR/response_csf.txt" "$OUT_DIR/fod_csf.mif" \
#     #         -force
#     # else
#     #     echo "wm_fod.mif already exists → skipping MSMT-CSD"
#     # fi

#     # ==================================================================
#     # 4. Export WM FOD to NIfTI (optional, for external viewing)
#     # ==================================================================
#     # if [[ ! -f "$OUT_DIR/fod_wm.nii.gz" ]]; then
#     #     echo "Exporting WM FOD to NIfTI..."
#     #     mrconvert "$OUT_DIR/wm_fod.mif" "$OUT_DIR/fod_wm.nii.gz" -force
#     # fi

#     # ==================================================================
#     # 5. Peak extraction – only if main outputs are missing
#     #    (Updated to use current sh2peaks options: -num_peaks instead of -number)
#     # ==================================================================
#     if [[ ! -f "$OUT_DIR/dwi/peaks.nii.gz" ]]; then
#         echo "Extracting up to 9 FOD peaks..."
#         sh2peaks "$OUT_DIR/Track_out/wm_fod.mif" "$OUT_DIR/dwi/peaks.nii.gz" \
#                  -mask "$OUT_DIR/dwi/mask.mif" -num 9 -threshold 0.10 -force
#     fi

#     # if [[ ! -f "$OUT_DIR/peaks5.nii.gz" ]]; then
#     #     echo "Extracting up to 5 FOD peaks..."
#     #     sh2peaks "$OUT_DIR/wm_fod.mif" "$OUT_DIR/peaks5.nii.gz" \
#     #              -mask "$OUT_DIR/mask.mif" -num 5 -threshold 0.07 -force
#     # fi

#     # if [[ ! -f "$OUT_DIR/peak_amp.nii.gz" ]]; then
#     #     echo "Extracting primary peak amplitude..."
#     #     sh2peaks "$OUT_DIR/wm_fod.mif" "$OUT_DIR/peak_amp.nii.gz" \
#     #              -mask "$OUT_DIR/mask.mif" -num 1 -force
#     # fi

#     # ==================================================================
#     # 6. Compute Directionally Encoded Color (DEC) image
#     #    Using dedicated fod2dec command (recommended, modern FOD-based DEC)
#     #    Standard RGB: Red = L-R, Green = A-P, Blue = S-I
#     #    Modulated by FOD integral (default) or primary peak amplitude
#     # ==================================================================
#     if [[ ! -f "$OUT_DIR/dwi/dec.nii.gz" ]]; then
#         echo "Computing DEC image (FOD-based, using fod2dec)..."
#         fod2dec "$OUT_DIR/Track_out/wm_fod.mif" "$OUT_DIR/dwi/dec.nii.gz" -mask "$OUT_DIR/dwi/mask.mif" -force
#         # Alternative: modulate by primary peak amplitude instead of FOD integral
#         # fod2dec "$OUT_DIR/wm_fod.mif" "$OUT_DIR/dec.nii.gz" -mask "$OUT_DIR/mask.mif" -contrast "$OUT_DIR/peak_amp.nii.gz" -force
#     else
#         echo "DEC image (dec.nii.gz) already exists → skipping"
#     fi

#     # ==================================================================
#     # Cleanup intermediate files (optional, comment out if you want to keep them)
#     # ==================================================================
#     rm -f "$OUT_DIR"/response_*.txt
#     rm -f "$OUT_DIR"/fod_gm.mif
#     rm -f "$OUT_DIR"/fod_csf.mif
#     #rm -f "$OUT_DIR"/dwi.mif  # Uncomment to save space

#     echo "FINISHED $subject – all missing steps completed!"
#     echo "==================================================================="
# done

# echo "All subjects processed (incrementally)!"

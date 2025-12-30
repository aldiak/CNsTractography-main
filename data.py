# import os, shutil
# from glob import glob
# import nibabel as nib
# import numpy as np

# import pandas as pd
# import SimpleITK as sitk
# import matplotlib.pyplot as plt
# from tqdm import trange
# import subprocess


# x_1_path = '/mnt/disk1/5T_Processed/2722/T1w_acpc_dc_restore_1.20.nii.gz'#'/home/alou/Desktop/5T/liguoliang_20230713-153421-1079_153459/nif/101915_ON-new_T1.nii.gz'
# x_2_path = '/mnt/disk1/5T_Processed/2722/data.nii.gz'
# #x_path = '/home/alou/Desktop/dataset/00082/00082_T1.nii.gz'
# data = nib.load(x_1_path)
# # #print(type(data))
# data = data.get_fdata()

# data1 = nib.load(x_2_path)
# data1 = data1.get_fdata()
# print(data.shape)
# print(data1.shape)





import vtk
import sys
import os
import re
import glob
from trk2bin import task_trk2binary1


# import vtk
# import os

def VTK2VTP(vtk_path, vtp_path):
    """
    Convert a VTK (Legacy PolyData) file to a VTP (XML PolyData) file.
    
    Args:
        vtk_path (str): Path to the input VTK file.
        vtp_path (str): Path to the output VTP file.
    
    Returns:
        bool: True if conversion is successful, False otherwise.
    """
    # Check if input file exists
    if not os.path.isfile(vtk_path):
        print(f"Error: Input VTK file '{vtk_path}' does not exist.")
        return False

    # Ensure output path has .vtp extension
    if not vtp_path.endswith('.vtp'):
        vtp_path = vtp_path + '.vtp'

    # Read VTK file
    vtk_reader = vtk.vtkPolyDataReader()
    vtk_reader.SetFileName(vtk_path)
    vtk_reader.Update()

    # Check if the input has valid data
    polydata = vtk_reader.GetOutput()
    if not polydata or polydata.GetNumberOfPoints() == 0:
        print(f"Error: No valid points found in VTK file '{vtk_path}'.")
        return False

    # Write to VTP file
    vtp_writer = vtk.vtkXMLPolyDataWriter()
    vtp_writer.SetInputConnection(vtk_reader.GetOutputPort())
    vtp_writer.SetFileName(vtp_path)
    vtp_writer.SetDataModeToBinary()  # Use binary for smaller file size
    vtp_writer.Update()
    vtp_writer.Write()

    # Verify output file was created
    if os.path.isfile(vtp_path):
        print(f"Successfully converted '{vtk_path}' to '{vtp_path}'.")
        return True
    else:
        print(f"Error: Failed to write VTP file '{vtp_path}'.")
        return False
    

import numpy as np
from dipy.io.streamline import load_tractogram, save_tractogram
from dipy.io.stateful_tractogram import Space, StatefulTractogram
from dipy.tracking.streamline import Streamlines
import nibabel as nib  # For reference image/header

def vtk_vtp_to_trk(vtk_vtp_path, reference_nii_path, output_trk_path):
    # Load VTK/VTP polydata
    if vtk_vtp_path.endswith('.vtp'):
        reader = vtk.vtkXMLPolyDataReader()
    else:  # Assume .vtk
        reader = vtk.vtkPolyDataReader()
    reader.SetFileName(vtk_vtp_path)
    reader.Update()
    polydata = reader.GetOutput()
    
    # Extract streamlines from lines (assuming each line cell is a streamline)
    streamlines = []
    lines = polydata.GetLines()
    lines.InitTraversal()
    num_lines = lines.GetNumberOfCells()
    points = polydata.GetPoints()
    
    for i in range(num_lines):
        line = vtk.vtkIdList()
        lines.GetNextCell(line)
        num_pts = line.GetNumberOfIds()
        if num_pts < 2:  # Skip invalid lines
            continue
        streamline = np.zeros((num_pts, 3), dtype=np.float32)
        for j in range(num_pts):
            pt_id = line.GetId(j)
            p = points.GetPoint(pt_id)
            streamline[j] = [p[0], p[1], p[2]]
        streamlines.append(streamline)
    
    if not streamlines:
        raise ValueError("No valid streamlines found in polydata.")
    
    # Load reference image for affine/header
    ref_img = nib.load(reference_nii_path)
    affine = ref_img.affine
    
    # Create and save tractogram
    print(f"Number of streamlines: {len(streamlines)}")
    #for i, streamline in enumerate(streamlines):
        #print(f"Streamline {i} shape: {streamline.shape}")
    streamlines_obj = Streamlines(streamlines)
    print("Streamlines object created")
    sft = StatefulTractogram(streamlines_obj, reference_nii_path, space=Space.RASMM)
    print("StatefulTractogram created")
    save_tractogram(sft, output_trk_path)
    print(f"Converted {vtk_vtp_path} to {output_trk_path}")





if __name__ == '__main__':

    # # mrml_path = sys.argv[1]
    # # vtp_path = sys.argv[2]
    # # # output_path = sys.argv[3]
    # # VTKMerge(mrml_path,vtp_path)
    # # VTPConvert(mrml_path,vtp_path,output_path)
    # # VTP = '/media/brainplan/DATA1/CNsAtlas2024/HCP_CreateAtlasData_OUT/CNsAtlas/cluster5000_5/VTP'
    # # VTK = '/media/brainplan/DATA1/CNsAtlas2024/HCP_CreateAtlasData_OUT/CNsAtlas/cluster5000_5/VTK'
    # #VTP = sys.argv[1]
    # #VTK = sys.argv[2]


    
    # vtpdata='/mnt/disk1/HCP_Data/hcp_data2/sub-102715/Output_fold/AtlasToSubject_out_ukf_5/Final_results/CNs_all_VTK.vtp'
    # vtkdata='/mnt/disk1/HCP_Data/hcp_data2/sub-102715/Output_fold/AtlasToSubject_out_ukf_5/Final_results/CNs_all_VTK.vtk'
    # refdata='/mnt/disk1/HCP_Data/hcp_data2/sub-102715/T1w_acpc_dc_restore_1.20.nii.gz'
    # outputpath='/mnt/disk1/HCP_Data/hcp_data2/sub-102715/Output_fold/AtlasToSubject_out_ukf_5/Final_results/CNs_all_VTK.trk'
    # #VTK2VTP(vtkdata, vtpdata)


    # # Usage
    # vtk_vtp_to_trk(vtpdata, refdata, outputpath)


    # Base directory containing subject folders
    #base_dir = '/mnt/disk1/wm_data/hcp_data'
    #base_dir="/mnt/disk1/testset/CN"
    #base_dir="/mnt/disk1/5T_P/"
    base_dir="/mnt/disk1/Difft5T_BIDS/"
    #base_dir="/mnt/disk1/Alou_drive/data/"
    # Find all subject directories (e.g., sub-102715, sub-100610, etc.)
    # subject_dirs = [d for d in glob.glob(os.path.join(base_dir, 'sub-*')) if os.path.isdir(d)]
    subject_dirs = [os.path.join(base_dir, d) for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))]
    print(subject_dirs)
    
    if not subject_dirs:
        raise ValueError(f"No subject directories found in {base_dir}")
    
    for subject_dir in subject_dirs:
        #print(subject_dir)
        subject_id = os.path.basename(subject_dir)
        subject_id = subject_id.split('sub-', 1)[1]
        print(f"Processing subject: {subject_id}")
        T1=f"{subject_id}_T1w.nii.gz"
        #T1='T1w_acpc_dc_restore_1.20.nii.gz'
        
        # Define file paths
        # vtk_path = os.path.join(subject_dir, 'Output_fold', 'AtlasToSubject_out', 'Final_results', 'CNs_all_VTK.vtk')
        # vtp_path = os.path.join(subject_dir, 'Output_fold', 'AtlasToSubject_out', 'Final_results', 'CNs_all_VTP.vtp')
        vtk_path1 = os.path.join(subject_dir, 'Track_out', 'CNV1.vtk')
        #vtk_path2 = os.path.join(subject_dir, 'Track_out', 'CNVIIVIII.vtk')
        #vtp_path = os.path.join(subject_dir,  'Track_out', 'Final_results', 'CNs_all_VTP.vtp')
        ref_path = os.path.join(subject_dir, 'anat', T1)
        #ref_path = ref_path = os.path.join(subject_dir, T1)
        output_trk_path1 = os.path.join(subject_dir, 'Track_out', 'CNV.trk')
        #output_trk_path2 = os.path.join(subject_dir, 'Track_out', 'CNVIIVIII.trk')
        output_path = os.path.join(subject_dir, 'Track_out', 'CNV.nii.gz')

        # VTK2VTP(vtk_path, vtp_path)
        
        # # Check if input files exist
        # if not os.path.isfile(vtp_path):
        #     print(f"Skipping {subject_id}: VTP file not found at {vtp_path}")
        #     continue
        # if not os.path.isfile(ref_path):
        #     print(f"Skipping {subject_id}: Reference NIfTI file not found at {ref_path}")
        #     continue
        
        # # Ensure output directory exists
        # output_dir = os.path.dirname(output_trk_path)
        # os.makedirs(output_dir, exist_ok=True)
        
        try:
            # Convert .vtp to .trk
            vtk_vtp_to_trk(vtk_path1, ref_path, output_trk_path1)
            task_trk2binary1(output_trk_path1,output_path,ref_path)
            #vtk_vtp_to_trk(vtk_path2, ref_path, output_trk_path2)
        except Exception as e:
            print(f"Error processing {subject_id}: {str(e)}")
            continue


# scil_tractogram_convert /mnt/disk1/Alou_drive/data/sub-242722/Track_out/CNV.trk /mnt/disk1/Alou_drive/data/sub-242722/Track_out/TN.tck --reference /mnt/disk1/Alou_drive/data/sub-242722/anat/242722_T1w.nii.gz

    #vtk_vtp_to_trk('/mnt/disk1/Difft5T_BIDS/sub-242722/Track_out/CNV1.vtk', '/mnt/disk1/Difft5T_BIDS/sub-242722/anat/242722_T1w.nii.gz', '/mnt/disk1/Difft5T_BIDS/sub-242722/Track_out/CNV1.trk')
    #task_trk2binary1('/mnt/disk1/Difft5T_BIDS/sub-242722/Track_out/CNV1.trk','/mnt/disk1/Difft5T_BIDS/sub-242722/Track_out/CNV.nii.gz', '/mnt/disk1/Difft5T_BIDS/sub-242722/anat/242722_T1w.nii.gz')
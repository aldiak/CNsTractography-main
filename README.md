# Automated Tracking of Cranial Nerve II, V, and VII/VIII

---

This repository contains different scripts for cranial nerves fiber tractography, downloading data from openneuro, and converting track to binary map, etc.
<div align=center>
<img src="pic/PIC1.png" width="400px">
</div>

# **Install**
- FSL
- Mrtrix3
- 3D Slicer
---
1.Install FSL, installation documentation is in: https://fsl.fmrib.ox.ac.uk/fsl

2.Install Mrtrix3 with conda:
```
$ conda install -c mrtrix3 mrtrix3
```
3.Install 3D Slicer, installation documentation is in: https://download.slicer.org/

# **How to use**
---
The input files of the following shells need to be modified accordingly.

---
Step 1. Register the seeding and mask in the MNI space to the individual subject
```
bash MaskGatedFronMNI_oth.sh
```
---
Step 2. Fiber tractography for each pair of CNs in seeding and mask
```
bash Track_CSD.sh
```
---
Step 3. The obtained fiber streamline is curated in 3D Slicer to remove false positive fibers

---
Step 4. The resulting fibers are converted to binary map using ```trk2bin.py```.

---
This work was used in our CN II, and V binary segmentation map generation. The ground truth will be publicly available soon. The missing folders can be sent  with resonable request to author.

---
Concact

Alou Diakite

aloudiakite@siat.ac.cn


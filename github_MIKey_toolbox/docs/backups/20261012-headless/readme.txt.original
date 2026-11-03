 MIKey Toolbox: Quick Start Guide 

 I. Environment Setup & Launch 

1.   MATLAB Version:  Ensure you have  MATLAB R2019a or a later version  installed.
2.   SPM12 Dependency:  Download and install SPM12 from its official website: [https://www.fil.ion.ucl.ac.uk/spm/software/spm12/](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/). Add the SPM12 folder to your MATLAB path.
3.   Add MIKey to Path:  Navigate to the MIKey toolbox directory in MATLAB:
    *   Option A: Use the  'cd’ command:  'cd('.\MIKey_toolbox_main\') '
    *   Option B: Add the  'MIKey_toolbox_main' folder and its subfolders to your MATLAB path.
4.   Launch the GUI:  In the MATLAB Command Window, simply type  'MIKey ' and press Enter. The graphical user interface (GUI) will open.



 II. Step-by-Step Workflow Guide 

 Step 1: Select BIDS Folder 
*   Click the  'Selected BIDS Folder'  button.
*    Important:  This toolbox is designed to work  exclusively  with data organized according to the Brain Imaging Data Structure (BIDS) standard. Please ensure your dataset is in strict BIDS format.

 Step 2: Voxel Scaling 
*   This step is crucial because SPM12 is optimized for human neuroimaging.
    *   For  mouse  brain data, set the scaling factor to  20 .
    *   For  rat  brain data, set the scaling factor to  10 .
    *   For human brain data (voxel-level analysis), set the scaling factor to  1 .
*   This process generates a scaled file named  'sub-*_desc-scaled.nii '.

 Step 3: Prepare Brain Masks (External Step) 
*    Before  running the "Mask data" step within MIKey, you must create brain masks for both structural and functional images  externally .
*   Use the scaled file ( 'sub-*_desc-scaled.nii ') from Step 2 to generate the masks.
*    Recommended Workflow:  Efficiently create an initial mask using the automated  MouseBrainExtractor  tool ([https://github.com/MouseSuite/MouseBrainExtractor](https://github.com/MouseSuite/MouseBrainExtractor)), then manually refine it using  ITK-SNAP  ([https://www.itksnap.org](https://www.itksnap.org)).
*    File Placement:  Save the final masks with the filename  'sub-*_brainmask.nii ' in their respective directories:
    *    Functional Mask:   '.\BIDS_path\derivatives\MIKey\sub-*\func\ '
    *    Structural Mask:   '.\BIDS_path\derivatives\MIKey\sub-*\anat\ '

 Step 4-12: Preprocessing Pipeline 
*   Steps 3 through 12 constitute the core preprocessing workflow.
*   You have two options:
    1.   Run Individually:  Execute each step (3, 4, 5, ..., 12) one by one from the GUI.
    2.   Run Batch:  Select all desired steps and click the  'Run Selected Steps'  button to process them automatically in sequence.



 III. Post-Processing & Advanced Analysis 

 Step 13: Functional Connectivity (FC) Calculation 
*   This step calculates Pearson correlation-based FC matrices.
*   It is highly flexible: you can provide your own custom  'Label.nii ' file to define the regions for connectivity analysis.

 Step 14-16: Individualized Parcellation 
*   These steps perform individualized functional network parcellation.
*   You can control the brain region for parcellation by inputting a corresponding mask file generated in earlier steps, allowing for focused analysis on specific areas of interest.

 IV. Tissue Segmentation (AMCP Template) 
*   The tissue segmentation module  defaults to using the high-precision AMCP tissue probability maps  (GM, WM, CSF, OT, AIR).
*    Prerequisite:  You  must  complete  Step 1 and Step 2  (data selection and voxel scaling) before running tissue segmentation.
*   This process involves registering your masked structural image to the standard Allen CCFv3 space.
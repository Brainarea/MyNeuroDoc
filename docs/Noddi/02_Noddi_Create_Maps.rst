
Noddi analysis part 2 : Noddi computation
=========================================

- **Note: Documentation for NODDI toolbox is available here: http://mig.cs.ucl.ac.uk/index.php?n=Tutorial.NODDImatlab**


Get the toolbox
---------------

- In order to compute NODDI files, you need the MATLAB Noddi toolbox, the Nifti Matlab toolbox and SPM12:

  - Download NODDI toolbox: https://www.nitrc.org/projects/noddi_toolbox
  - Download Nifti Matlab: https://github.com/NIFTI-Imaging/nifti_matlab
  - Download SPM12: https://www.fil.ion.ucl.ac.uk/spm/software/download/

- Next you need a Matlab script available in Matlab_files folder of the repository


Run the script
--------------

- Let's open Matlab on CHEAHA, open a new terminal and type:

::

  module load rc/matlab/R2020a

- **Note: Other matlab version are available on CHEAHA, R2020a is working fine but feel free to change if needed**
- Then type matlab in terminal to launch MATLAB
- Open the matlab script you previously downloaded.
- The part to change for your needs is highlighted at the beginning of the script but basically you need to change 3 things:
  - Where all the toolboxes are
  - Path to your data
  - Search for subjects ID
- Once everything is changed, just start the script and wait!!
- A Noddi_files folder will be created containing all NODDI files for each subject !


Run the script on slurm (Cheaha)
--------------------------------

- See SLURM section on preprocessing to learn about Job creation and use.
- Here we use a single-subject version of the Matlab script.

.. warning::

 The Noddi toolbox script needs to be modified for this method to work
 
- Two files are therefore needed to make this work:

  - MRST_NODDI_single_subject_SLURM.m: used in job's script below (modified Matlab script used for single subject)
  - batch_fitting.m: Modified file from Noddi toolbox. Replace one existing in toolbox folder with that one.
  - Both files are available in Matlab_files_SLURM folder of the github repository.

::

  #!/bin/bash
  #SBATCH --partition=medium
  #SBATCH --cpus-per-task=20
  #SBATCH --mem-per-cpu=12000
  #SBATCH --time=15:00:00
  #SBATCH --array=0-41
  module load rc/matlab/R2020a
  cd /data/user/rodolphe/Data/MRST/NODDI/Preprocessed/
  readarray -t FILES < <(find . -maxdepth 1 -type d -name 'CBDm7*' -printf '%P\n')
  cd /data/user/rodolphe/Scripts/Origin/Szaflarski\ lab/MRST/NODDI/Create_noddi_files/
  srun matlab -nodisplay -nodesktop -r \
  "MRST_NODDI_single_subject_SLURM('${FILES[$SLURM_ARRAY_TASK_ID]}',20); quit;"

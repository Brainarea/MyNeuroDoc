Noddi analysis part 3 : Normalization (Warping)
=========================================

Now that the NODDI maps have been created, we need to normalize them so that they will fit an MNI template in order
to do group stats.

Get the Script file
-------------------

The file ``warp_NODDI_Singularith.sh`` is necessary for this step. It works pretty much the same as the files used for preprocessing.
- Copy The ``Warp_template`` folder in your data folder, along the Preprocessed folder created in step 1
- Copy  ``warp_NODDI_Singularith.sh`` in your script folder

Use warping Script
------------------

You can always start a bash shell in the Singularity container, then use the warping script as described in step 1.
Let's use it directly in Cheaha SLURM:

::

#!/bin/bash

  #SBATCH --partition=short
  #SBATCH --cpus-per-task=10
  #SBATCH --mem-per-cpu=12000
  #SBATCH --time=5:00:00
  #SBATCH --array=0-54

  cd /data/user/rodolphe/Data/MRST/NODDI/Preprocessed/
  readarray -t FILES < <(find . -maxdepth 1 -type d -name 'CBD*' -printf '%P\n')

  module load Singularity
  cd /data/user/rodolphe/Toolbox/Singularity_images/

  srun singularity exec \
  --bind /data/user/rodolphe/Data/MRST/NODDI:/data \
  --bind /data/user/rodolphe/Scripts/Origin/Szaflarski\ lab/MRST/NODDI/preprocessing:/myscripts \
  NODDI_docker.simg bash /myscripts/warp_NODDI_Singularity.sh ${FILES[$SLURM_ARRAY_TASK_ID]}


::warning

  Script will create a ``Noddi_files_warped`` folder containing the final noramlized NODDI FILES

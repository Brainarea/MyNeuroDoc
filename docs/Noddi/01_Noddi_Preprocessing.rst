
Noddi analysis part 1: preprocessing
====================================

Cheaha
------

Connect to your CHEAHA account:

- Go to https://rc.uab.edu/ and login
- Click on **My interactive session** on top
- Click on **HPC Desktop** (If no session was previously created)
- Create a new session with following options: 100 hours / long / 20 CPU / 12GB
- Click on **Launch desktop in new Tab**
- Hurray, you are now in your own Linux session on CHEAHA!

Now let's do some magic.

Getting essential files
-----------------------

- All you need is the script file and a config file!
- Both are available at: https://github.com/Brainarea/MyNeuroDoc/tree/main/docs/Noddi/Preproc_Files
- Download both files and put them in a folder on Cheaha.


Getting docker image
--------------------

- All the toolbox and packages analysis you need have been put into a Docker image (yeah!)
- Unfortunately, CHEAHA does not support Docker. However, we can use Singularity which is pretty much the same.
- First let's load Singularity on Cheaha. Open a terminal and type:

::

  module load Singularity

- Next let's convert the Docker image and put it in a folder of your choice (change /path/to/ ):

::

  singularity build /path/to/singularity/NODDI_docker.simg docker://orchid666/myneurodocker:NODDI

- You are now ready to preprocess your images!!


Copy mri images
---------------

- Create a folder for the NODDI analysis, for example : /Noddi_analysis/
- Within that folder, create a Raw_data folder: /Noddi_analysis/Raw_data/
- Put each subject T1 and DWI dicom folder in that Raw_data so you have:

  - /Noddi_analysis/Raw_data/Subject_001/T1/
  - /Noddi_analysis/Raw_data/Subject_001/dMRI/

- **Note: Name of subject folder folders does not matter. T1 folder name needs to start with `` 'T1' `` and DWI folder name needs to start with `` 'dMRI'** ``


Launching docker session
-------------------------

- You are now ready to preprocess your diffusion images
- Let's go to where you put the Singularity image:

::

  cd /path/to/singularity/

- Now let's launch the Docker session and tell it where your stuff is:

::

  singularity shell \
  --bind /Noddi_analysis:/data \
  --bind /path/to/scripts:/myscripts \
  NODDI_docker.simg

- **Note: --bind command is like a mount. First is to tell where the data is, second where the scripts are.**


Preprocessing
-------------

- Your scripts folder has been mounted to /myscript on the Singularity session so let's go there:

::

  cd /myscripts

- Now in order to preprocess one subject, you just need to give its name to the script you have downloaded earlier:

::

  ./preproc_NODDI_Singularity.sh 'Subject_001'

- **Note 1: If you get a Permission denied error, please do a chmod +x on preproc_NODDI_Singularity.sh script**
- **Note 2: Preprocessing can be long so be patient!**
- A 'Preprocessed' folder will be created within your Data folder containing all preprocessed files for each subject.


Preprocessing multiple subjects with parallel
--------------------------------------------

- Now you may want to process several Subjects at once. Fortunately, the person who made the Docker image (me!) also put a nice tool to do so.
- Example of how to do parallel processing with a find command:

::

  raw_dir=/data/Raw_data
  TMPDIR=/tmp
  find ${raw_dir} -name "CBD*" | parallel --eta bash preproc_NODDI_Singularity.sh {/}

- **Note: Be sure to have enough time on your CHEAHA session, preprocessing of multiple subjects in parallel can take hours!!**

Preprocessing multiple subjects with slurm (cheaha)
---------------------------------------------------

Create JOB file
^^^^^^^^^^^^^^^

- Another possibility to do parallel multi-processing is to use SLURM on Cheaha. In order to do that we need to create a job file. Let's start with a simple job for one subject:

::

  #!/bin/bash
  #SBATCH --partition=short
  #SBATCH --cpus-per-task=10
  #SBATCH --mem-per-cpu=12000
  #SBATCH --time=10:00:00
  module load Singularity
  cd /data/user/rodolphe/Toolbox/Singularity_images/
  singularity exec \
  --bind /data/user/rodolphe/Data/MRST/NODDI:/data \
  --bind /data/user/rodolphe/Scripts/Origin/Szaflarski\ lab/MRST/NODDI/preprocessing:/myscripts \
  NODDI_docker.simg bash /myscripts/preproc_NODDI_Singularity.sh 'MRST5012'

- A job works exactly like creating an interactive session and running the preprocessing script through the Singularity container:

  - With #SBATCH options we ask for a type of partition (short, long, medium,...) with a certain number of CPUs, memory per CPU and a duration time.
  - Then the script will load Singularity module, go to directory where singularity image is then launch preprocessing script through singularity image ('singularity exec') with subject ID as argument

- Now we can modify this job in order to process several subject at once:

::

  #!/bin/bash
  #SBATCH --partition=short
  #SBATCH --cpus-per-task=10
  #SBATCH --mem-per-cpu=12000
  #SBATCH --time=10:00:00
  #SBATCH --array=0-4
  module load Singularity
  FILES=("CBDm7015_V1" "CBDm7015_V2" "CBDm7016_V1" "CBDm7017_V1" "CBDm7020_V2")
  cd /data/user/rodolphe/Toolbox/Singularity_images/
  srun singularity exec \
  --bind /data/user/rodolphe/Data/MRST/NODDI:/data \
  --bind /data/user/rodolphe/Scripts/Origin/Szaflarski\ lab/MRST/NODDI/preprocessing:/myscripts \
  NODDI_docker.simg bash /myscripts/preproc_NODDI_Singularity.sh ${FILES[$SLURM_ARRAY_TASK_ID]}

- The new #SBATCH array is telling the system how many jobs we want (It is a range , starting from zero!!). Then we create a list of subject ID (array named FILES). We use  ``${FILES[$SLURM_ARRAY_TASK_ID]}`` in order to access each subject ID. This will create 5 jobs with $SLURM_ARRAY_TASK_ID having a different value in each one on them (from 0 to 4).


- Finally, is it possible to search for subject IDs within a folder instead of manually writing all the ID:

::

  #!/bin/bash
  #SBATCH --partition=short
  #SBATCH --cpus-per-task=10
  #SBATCH --mem-per-cpu=12000
  #SBATCH --time=10:00:00
  #SBATCH --array=0-4
  module load Singularity
  cd /data/user/rodolphe/Data/MRST/NODDI/Preprocessed/
  readarray -t FILES < <(find . -maxdepth 1 -type d -name 'CBDm7*' -printf '%P\n')
  cd /data/user/rodolphe/Toolbox/Singularity_images/
  srun singularity exec \
  --bind /data/user/rodolphe/Data/MRST/NODDI:/data \
  --bind /data/user/rodolphe/Scripts/Origin/Szaflarski\ lab/MRST/NODDI/preprocessing:/myscripts \
  NODDI_docker.simg bash /myscripts/preproc_NODDI_Singularity.sh ${FILES[$SLURM_ARRAY_TASK_ID]}

Use Job files
^^^^^^^^^^^^^

- Now that you have your job save as a file let's use it. Go to rc.uab.edu then click on Jobs>Job composer.
- Create a new job by clicking on 'New job' then 'From Specified path'
- Fill as follow:

  - Path to source: Path to the folder where your script is
  - Name: Give a name to your job (' My Noddi job' for exemple.)
  - Script name: Put the name of your script.
  - Click save

- Your Job should be in the list with the code displayed on the bottom right.
- Click Submit to start your job, it will first be 'Queued' waiting for resource allocation, then it will be "Running".

MREG analysis part 2: preprocessing
====================================

Cheaha
------

Connect to your CHEAHA account:

- Go to https://rc.uab.edu/ and login
- Click on **My interactive session** on top
- Click on **HPC Desktop** (If no session was previously created)
- Create a new session with following options: chose what you need
- Click on **Launch desktop in new Tab**
- Hurray, you are now in your own Linux session on CHEAHA!


Getting docker image
--------------------

- All the toolbox and packages analysis you need have been put into a Docker image (yeah!)
- Unfortunately, CHEAHA does not support Docker. However, we can use Singularity which is pretty much the same.
- First let's load Singularity on Cheaha. Open a terminal and type:

::

  module load Singularity

- Next let's convert the Docker image and put it in a folder of your choice (change /path/to/ ):

::

  singularity build /path/to/singularity/NIPYPE_docker.simg docker://orchid666/myneurodocker:NIPYPE

- You are now ready to preprocess your images!!


Launching docker session
-------------------------

- You are now ready to preprocess your MREG images
- Let's go to where you put the Singularity image:

::

  cd /path/to/singularity/

- Now let's launch the Docker session and tell it where your stuff is:

::

singularity shell \
--bind /Mreg_analysis:/data \
--bind /path/to/scripts:/myscripts \
NIPYPE_docker.simg
source activate neuro

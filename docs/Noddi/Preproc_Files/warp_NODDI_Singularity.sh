#!/bin/bash

## Base variables. Change if needed
subject=$1
basedir=/data/Preprocessed/${subject}
tempdir=/data/Warp_template
SUBJ_T1=$basedir/T1
SUBJ_NODDI=$basedir/Noddi_files
SUBJ_WARPED=$basedir/Noddi_files_warped
mkdir $SUBJ_WARPED

3dMedianFilter -irad 2 -prefix ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new.3mm.nii ${SUBJ_NODDI}/${subject}_NODDI_ficvf_new.nii
3dMedianFilter -irad 2 -prefix ${SUBJ_WARPED}/${subject}_NODDI_odi.3mm.nii ${SUBJ_NODDI}/${subject}_NODDI_odi.nii
3dMedianFilter -irad 2 -prefix ${SUBJ_WARPED}/${subject}_NODDI_fiso.3mm.nii ${SUBJ_NODDI}/${subject}_NODDI_fiso.nii
3dMedianFilter -irad 2 -prefix ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm.nii ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.nii


3dQwarp -base ${tempdir}/mni_icbm152_t1_tal_nlin_sym_09a_masked.nii -source ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm.nii -resample -minpatch 3 -blur 0 3 -useweight -Qfinal -penfac 0.5 -iwarp -maxlev 14 -prefix ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm_warp
3dNwarpApply -nwarp ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm_warp_WARP+tlrc -source ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new.3mm.nii -master ${tempdir}/mni_icbm152_t1_tal_nlin_sym_09a_masked.nii -prefix ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new_3mm_warp
3dNwarpApply -nwarp ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm_warp_WARP+tlrc -source ${SUBJ_WARPED}/${subject}_NODDI_odi.3mm.nii -master ${tempdir}/mni_icbm152_t1_tal_nlin_sym_09a_masked.nii -prefix ${SUBJ_WARPED}/${subject}_NODDI_odi_3mm_warp
3dNwarpApply -nwarp ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm_warp_WARP+tlrc -source ${SUBJ_WARPED}/${subject}_NODDI_fiso.3mm.nii -master ${tempdir}/mni_icbm152_t1_tal_nlin_sym_09a_masked.nii -prefix ${SUBJ_WARPED}/${subject}_NODDI_fiso_3mm_warp


3dcalc -a ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm_warp+tlrc -expr 'a' -prefix ${SUBJ_T1}/${subject}_T1_ns_deob_acpc.3mm_warp_final.nii
3dcalc -a ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new_3mm_warp+tlrc -expr 'a' -prefix ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new_3mm_warp_final.nii
3dcalc -a ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new_3mm_warp+tlrc -expr '(within(a,0,.95))*a' -prefix ${SUBJ_WARPED}/${subject}_NODDI_ficvf_new_3mm_warp_thresh95_final.nii
3dcalc -a ${SUBJ_WARPED}/${subject}_NODDI_odi_3mm_warp+tlrc -expr 'a' -prefix ${SUBJ_WARPED}/${subject}_NODDI_odi_3mm_warp_final.nii
3dcalc -a ${SUBJ_WARPED}/${subject}_NODDI_fiso_3mm_warp+tlrc -expr 'a' -prefix ${SUBJ_WARPED}/${subject}_NODDI_fiso_3mm_warp_final.nii

## Cleaning

cd ${SUBJ_WARPED}
rm *.BRIK
rm *.HEAD
rm *3mm.nii

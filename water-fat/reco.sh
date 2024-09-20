#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.
# 
# Authors:
# 2020 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
# 
# This script is used to create results for 
# moba water/fat separation abd R2* mapping
# 

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

ADD_OPTS=""
if bart moba --interface 2>&1 | grep -q normalize_scaling >/dev/null 2>&1 ; then
	ADD_OPTS+="--normalize_scaling --scale_data 5000 --scale_psf 1000 "
fi
if bart moba --interface 2>&1 | grep -q temporal_damping >/dev/null 2>&1 ; then
	ADD_OPTS+="--temporal_damping 0.9"
elif bart moba --interface 2>&1 | grep -q \"T\" >/dev/null 2>&1 ; then
	ADD_OPTS+="-T 0.9"
fi
echo $ADD_OPTS

if ! ../physics_utils/gpu_check.sh ; then
       echo "bart with GPU support is required!" >&2
       exit 1
fi

source ../physics_utils/data_loc.sh
RAW="${DATA_LOC}"/ME-FLASH
if [ ! -f "$RAW".cfl ] ; then
	printf "Error: Rawdata %s not found, either download is using load_all.sh or set DATA_ARCHIVE correctly!\n" "$RAW" >&2
	exit 1
fi


# --- dimensions ---
NSMP=$(bart show -d  0 $RAW)
FSMP=$((NSMP))
NMEA=$(bart show -d 10 $RAW)

NSPK=33
NECO=7
GIND=2 # small golden angle

# --- TE ---
bart ones 1 1 temp_1
bart scale 1.37 temp_1 temp_TE_1.coo
bart scale 2.71 temp_1 temp_TE_2.coo
bart scale 4.05 temp_1 temp_TE_3.coo
bart scale 5.39 temp_1 temp_TE_4.coo
bart scale 6.73 temp_1 temp_TE_5.coo
bart scale 8.07 temp_1 temp_TE_6.coo
bart scale 9.41 temp_1 temp_TE_7.coo

bart join 0 temp_TE_*.coo temp_TE

bart reshape $(bart bitmask 0 1 2 3 4 5) 1 1 1 1 1 $NECO temp_TE TE

rm temp_1.{cfl,hdr} temp_TE_*.coo

# --- coil compression ---
bart cc -A -p 10 $RAW temp_kdat0

# --- reformat k-space data ---
bart transpose 1 2 temp_kdat0 temp_kdat1
bart transpose 0 1 temp_kdat1 temp_kdat2

bart reshape $(bart bitmask 2 5) $NECO $NSPK temp_kdat2 temp_kdat3
bart transpose 2 5 temp_kdat3 kdat_prep

rm temp_kdat*.{cfl,hdr}


BASERES=$(( FSMP / 2 ))
OVERGRID=1.5

# --- calculate trajectory ---
./meco_traj.sh -F $FSMP -s $GIND kdat_prep traj_prep GDC

# --- WFR2S (water/fat separated R2* mapping) ---
echo ">>> multi-echo water/fat separated R2* and B0 mapping"

for (( F=0; F < $NMEA; F +=1 )); do

	FF=$(printf "%03d" ${F})

	bart slice 10 $F traj_prep traj_1f
	bart slice 10 $F kdat_prep kdat_1f

	# compute init (3-point water/fat separation)

	bart extract 5 0 3 TE TE_e
	bart extract 5 0 3 traj_1f traj_1fe
	bart extract 5 0 3 kdat_1f kdat_1fe

	bart moba $ADD_OPTS -O -G -m0 -i6 -R2 --fat_spec_0 -g -o$OVERGRID -t traj_1fe kdat_1fe TE_e R_m0_1fe

	bart extract 6 0 2 R_m0_1fe temp_init_wf
	bart extract 6 2 3 R_m0_1fe temp_init_fB0

	IMX=$(bart show -d 0 R_m0_1fe)
	IMY=$(bart show -d 1 R_m0_1fe)

	bart zeros 16 $IMX $IMY 1 1 1 1 1 1 1 1 1 1 1 1 1 1 temp_init_zeros

	bart join 6 temp_init_wf temp_init_zeros temp_init_fB0 R_M1_init_F${FF}.coo

	# moba reconstruction: multi-echo R2* mapping

	bart moba $ADD_OPTS  -G -m1 -rQ:1 -rS:0 -rW:3:$(bart bitmask 6):1 -u0.01 -i8 -C100 -R3 --fat_spec_0 -k --kfilter-2 -d4 -g -o$OVERGRID -I R_M1_init_F${FF}.coo -t traj_1f kdat_1f TE R_M1_F${FF}.coo

done

#bart join 10 `seq -s" " -f "R_M1_F%g" 0 $((NMEA-1))` R_M1
bart join 10 R_M1_F*.coo R_M1
bart resize -c 0 $BASERES 1 $BASERES R_M1 R_WFR2S
rm R_M1_*F*.coo

# --- output water, fat, R2*, and B0 maps ---
bart slice 6 0 R_WFR2S RECON_WATER
bart slice 6 1 R_WFR2S RECON_FAT
bart slice 6 2 R_WFR2S RECON_R2S
bart slice 6 3 R_WFR2S RECON_B0FIELD

# --- mask ---
bart scale 1 RECON_FAT RECON_WF
bart fmac -A RECON_WATER RECON_WF
bart cabs RECON_WF RECON_WF_ABS

bart threshold -B 170 RECON_WF_ABS mask

bart fmac RECON_WATER mask RECON_WATER_mask
bart fmac RECON_FAT mask RECON_FAT_mask
bart fmac RECON_R2S mask RECON_R2S_mask
bart fmac RECON_B0FIELD mask RECON_B0FIELD_mask

rm TE_e.{cfl,hdr} traj_1f*.{cfl,hdr} kdat_1f*.{cfl,hdr} R_M1.{cfl,hdr} temp_*.{cfl,hdr}



# frame 0 is used for Figure 3

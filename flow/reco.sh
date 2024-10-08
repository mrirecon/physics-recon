#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.
# 
# Authors:
# 2020 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
# 
# This script is used to create results for moba flow
# 

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

SCALE_OPTS=""
if bart moba --interface 2>&1 | grep -q normalize_scaling >/dev/null 2>&1 ; then
	SCALE_OPTS="--normalize_scaling --scale_data 5000 --scale_psf 1000 "
fi

TD_OPTS=""
if bart moba --interface 2>&1 | grep -q temporal_damping >/dev/null 2>&1 ; then
	TD_OPTS="--temporal_damping 0.9"
elif bart moba --interface 2>&1 | grep -q \"T\" >/dev/null 2>&1 ; then
	TD_OPTS="-T 0.9"
fi

echo $SCALE_OPTS $TD_OPTS

GPU="-g"
if ! ../physics_utils/gpu_check.sh ; then
       echo "bart with GPU support is recommended!" >&2
       GPU=""
fi

source ../physics_utils/data_loc.sh
RAW="${DATA_LOC}"/PC-FLASH
if [ ! -f "$RAW".cfl ] ; then
	printf "Error: Rawdata %s not found, either download is using load_all.sh or set DATA_ARCHIVE correctly!\n" "$RAW" >&2
	exit 1
fi


# create venc index array
bart zeros 6 1 1 1 1 1 1 temp_0
bart  ones 6 1 1 1 1 1 1 temp_1

bart join 5 temp_0 temp_1 VENC_ARRAY

rm temp_*.{cfl,hdr}


# read in raw data
NSMP=$(bart show -d  0 $RAW)
GIND=7
NSET=$(bart show -d 11 $RAW)

NSPK=$(bart show -d  1 $RAW)
NFRM=$(bart show -d 10 $RAW)

BASERES=$(( NSMP / 2 ))

bart reshape $(bart bitmask 0 1 2) 1 $NSMP $NSPK $RAW kdat1

bart cc -A -p 10 kdat1 kdat2
bart transpose 5 11 kdat2 kdat_prep1

rm kdat1.{cfl,hdr} kdat2.{cfl,hdr}

bart extract 10 0 100 kdat_prep1 kdat_prep

# calculate trajectory
bart traj -x $NSMP -y $NSPK -t $NFRM -s $GIND -c traj_none
bart traj -x $NSMP -y $NSPK -t $NFRM -s $GIND -c -O -q $(BART_DEBUG_LEVEL=0 bart estdelay -R traj_none kdat_prep) traj_ring

bart repmat 5 2 traj_ring traj_prep1

bart extract 10 0 100 traj_prep1 traj_prep

# --- model-based velocity mapping ---
bart moba $SCALE_OPTS $TD_OPTS -G -m4 --sobolev_a 220 -b0:1 -i6 -R2 -d4 $GPU -o1.5 -t traj_prep kdat_prep VENC_ARRAY R_M4

# crop images
bart resize -c 0 $BASERES 1 $BASERES R_M4 R_PHASE_CONTRAST

bart slice 6 0 R_PHASE_CONTRAST MAG
bart slice 6 1 R_PHASE_CONTRAST PHI

#VENC=150 / 500
bart scale .3 PHI VEL

rm PHI.{cfl,hdr} R_M4.{cfl,hdr}

# --- parallel imaging reconstruction ---
bart moba $TD_OPTS -G -m5 --sobolev_a 220 -i6 -R2 -d4 $GPU -o1.5 -t traj_prep kdat_prep VENC_ARRAY R_M5

# crop images
bart resize -c 0 $BASERES 1 $BASERES R_M5 R_M5_crop

bart slice 6 0 R_M5_crop R_PE0
bart slice 6 1 R_M5_crop R_PE1

bart fmac -C R_PE0 R_PE1 R_PHASE_DIFFERENCE

# frame 81 is used for Figure 4

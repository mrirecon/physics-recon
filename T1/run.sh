#!/bin/bash
# 
# Copyright 2021. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020-2021
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"


source ../utils/data_loc.sh
RAW="${DATA_LOC}"/IR-FLASH
READ=$(bart show -d0 $RAW)
PHS1=$(bart show -d1 $RAW)
TIME=$(bart show -d10 $RAW)
NBR=$((READ / 2))
TR=4100
GA=7
lambda=0.09
SPOKES=20


./prep.sh -s$READ -T$TR -G$GA -p$(($TIME * $PHS1)) -f$SPOKES $RAW T1-data.coo T1-traj.coo T1-TI

./reco.sh -R$lambda -T$TR T1-TI T1-traj.coo T1-data.coo T1-reco T1-sens

./post.sh -T$TR -r$NBR T1-reco T1-sens T1-mask T1-reco_${NBR}.coo T1-reco_t1map

bart slice 6 0 T1-reco_${NBR}.coo Mss
bart slice 6 1 T1-reco_${NBR}.coo M0
bart slice 6 2 T1-reco_${NBR}.coo R1s

# create synthesized T1-weighted images by moba
bart fmac T1-TI R1s tmp_result
bart scale  -- -1.0 tmp_result tmp_result1
bart zexp tmp_result1 tmp_exp
bart saxpy 2. M0 Mss tmp_result2
bart fmac tmp_exp tmp_result2 tmp_result3
bart repmat 5 $(($TIME * $PHS1 / $SPOKES)) Mss tmp_Mss
bart saxpy -- -1.0 tmp_result3 tmp_Mss synthesized_T1_images

# join (Mss, M0, R1s) and T1 maps into one image (Figure 2B, top)
bart join 0 Mss M0 R1s T1-reco_t1map T1-reco_maps

rm tmp_result*.{cfl,hdr} tmp_exp.{cfl,hdr} tmp_Mss.{cfl,hdr}



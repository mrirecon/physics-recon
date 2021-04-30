#!/bin/bash
# 
# Copyright 2021. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020-2021
# xiaoqing.wang@med.uni-goettingen.de
#
set -e

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi


source ../utils/data_loc.sh
RAW="${DATA_LOC}"/ME-SE

READ=$(bart show -d0 $RAW)
PHS1=$(bart show -d1 $RAW)
NBR=$((READ / 2))

lambda=0.001

GA=1
og=1.25
TE=9900
NECO=16
NEXC=$((PHS1 / NECO))
NSPK=$NEXC

./prep.sh -s$READ -R$TE -G$GA -p$PHS1 -f$NEXC -e$NECO $RAW T2-data.coo T2-traj.coo T2-TE

bart moba -F -i10 -n -C300 -j$lambda -d4 -g -t T2-traj.coo T2-data.coo T2-TE T2-reco T2-sens.coo

bart resize -c 0 $NBR 1 $NBR T2-reco tmp_maps

# final output
# use the same mask as T1
bart transpose 0 1 ../T1/T1-mask tmp_mask
bart flip $(bart bitmask 1) tmp_mask mask

# parameter maps (M0, R2)
bart transpose 0 1 tmp_maps tmp_reco
bart flip $(bart bitmask 1) tmp_reco tmp_reco_maps

# M0
bart slice 6 0 tmp_reco_maps tmp_M0
bart fmac mask tmp_M0 M0

# R2 and T2
bart slice 6 1 tmp_reco_maps tmp_R2
bart invert tmp_R2 tmp_T2
bart scale 0.1 tmp_T2 tmp_T2_scaled
bart fmac mask tmp_R2 R2
bart fmac mask tmp_T2_scaled T2

# join (M0, R2) and T2 maps into one image (Figure 2B, bottom)
bart join 0 M0 R2 T2 T2-reco_maps

# create synthesized T2-weighted images by moba
bart fmac T2-TE R2 tmp_result
bart scale 10. tmp_result tmp_result1
bart scale  -- -1.0 tmp_result1 tmp_result
bart zexp tmp_result tmp_exp
bart fmac tmp_exp M0 synthesized_T2_images


rm tmp*.{cfl,hdr} *.coo




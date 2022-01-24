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
SPOKES=20
NSPK_ALL=$(($TIME * $PHS1))
nf1=$(($NSPK_ALL / $SPOKES))
lambda=0.0015
coeff=4 # number of coefficients for subspace reco

bart scale 2. ../T1/T1-sens tmp_sens

../T1/prep.sh -s$READ -T$TR -G$GA -p$(($TIME * $PHS1)) -f$SPOKES $RAW T1-data.coo T1-traj.coo T1-TI

./reco.sh -r$lambda -s$READ -T$TR -C$coeff -n$nf1 -f$SPOKES T1-traj.coo T1-data.coo tmp_sens reco_coeff_maps reco_imgs

./post.sh reco_imgs T1-TI T1-subspace-T1map T1-subspace-imgs T1-subspace-coeff-maps

rm tmp*.{cfl,hdr} T1-*.coo T1-TI.{cfl,hdr}


# create plots

./plot_simu_T1.sh
./plot_simu_mgre.sh



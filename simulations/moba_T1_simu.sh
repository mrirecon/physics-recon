#!/bin/bash
# 
# Copyright 2020. Uecker Lab, University Medical Center Göttingen.
#
# Authors: Xiaoqing Wang and Nick Scholand, 2020
# nick.scholand@med.uni-goettingen.de
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

if ../physics_utils/version_check.sh ; then
	ADD_OPTS="--normalize_scaling --other pinit=1:1:1.5:1 --scale_data 5000 --scale_psf 1000"
else
	ADD_OPTS=""
fi
echo $ADD_OPTS

# generating a numerical phantom using BART
# Simulation parameters
TR=0.0041
DIM=384
SPOKES=1
REP=1020
NC=8
NBR=$(( $DIM / 2 ))

# create trajectory
bart traj -x $DIM -y $SPOKES -t $REP -c -r -G _traj
bart transpose 5 10 {_,}traj
bart scale 0.5 traj _traj1

# create geometry basis functions
bart phantom -s$NC -T -k -b -t _traj1 _basis_geom

# create simulation basis functions
bart signal -F -I -n$REP -r$TR  -1 3:3:1 -2 1:1:1 _basis_simu_water
bart signal -F -I -n$REP -r$TR  -1 0.2:2.2:10 -2 0.045:0.045:1 _basis_simu_tubes

bart scale 1. _basis_simu_tubes _basis_simu_sdim_tubes
bart join 6 _basis_simu_water _basis_simu_sdim_tubes _basis_simu

# create simulated dataset
bart fmac -s $(bart bitmask 6) _basis_geom _basis_simu _phantom_ksp
bart phantom -x$NBR -T mask

# add noise to the simulated dataset 
for (( i=0; i <= 7; i++ )) ; do

        bart slice 3 $i _phantom_ksp _phantom_ksp$i
        bart noise -n200 _phantom_ksp$i tmp_ksp_$i.coo
done

bart join 3 tmp_ksp_*.coo _phantom_ksp2
rm tmp_ksp_*.coo


#------------------------------------------------------
#------------- Nonlinear model-based reco -------------
#------------------------------------------------------

SPOKES_BIN=20
REP_BIN=$(($REP / $SPOKES_BIN))

bart reshape $(bart bitmask 4 5) $SPOKES_BIN $REP_BIN _phantom_ksp2 _phantom_ksp3
bart transpose 4 2 _phantom_ksp3 phantom_ksp
bart reshape $(bart bitmask 4 5) $SPOKES_BIN $REP_BIN traj _traj1
bart transpose 4 2 _traj1 traj

#scale1=$(($TR * $SPOKES_BIN))
#scale2=$(($TR * $SPOKES_BIN / 2))
scale1=0.082
scale2=0.041

bart index 5 $REP_BIN tmp1.coo
bart scale $scale1 tmp1.coo tmp2.coo
bart ones 6 1 1 1 1 1 $REP_BIN tmp1.coo 
bart saxpy $scale2 tmp1.coo tmp2.coo TI

ITER=12

REG=0.05
bart moba $ADD_OPTS -L -l1 -i$ITER -g -C300 -d4 -j$REG -o1.0 -n -R3 -t traj phantom_ksp TI moba_simu_T1 sens
bart resize -c 0 $NBR 1 $NBR moba_simu_T1 moba_simu_T1_${NBR}

bart fmac mask moba_simu_T1_${NBR} moba_simu_T1_masked
bart looklocker -t0. -D0. moba_simu_T1_masked tmp
bart transpose 0 1 tmp T1


rm tmp*.{cfl,hdr} _*.{cfl,hdr} phantom*.{cfl,hdr} sens*.{cfl,hdr} traj*.{cfl,hdr} mask*.{cfl,hdr} TI*.{cfl,hdr}



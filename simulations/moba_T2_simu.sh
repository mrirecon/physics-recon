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

# generating a numerical phantom using BART
# Simulation parameters
TE=0.0099
DIM=384
NEXT=25
NECO=16
NC=8
NBR=$(( $DIM / 2 ))

# create trajectory
bart traj -x $DIM -y 1 -t $(($NECO*$NEXT)) -c -r -G _traj
bart transpose 5 10 _traj traj
bart scale 0.5 traj _traj1

# create geometry basis functions
bart phantom -s$NC -T -k -b -t _traj1 _basis_geom

# create simulation basis functions
bart signal -T -n$NECO -e$TE  -1 1:1:1 -2 1:1:1 _basis_simu_water
bart signal -T -n$NECO -e$TE  -1 1:1:1 -2 0.02:0.22:10 _basis_simu_tubes

bart join 7 _basis_simu_water _basis_simu_tubes _basis_simu
bart transpose 6 7 _basis_simu _basis_simu1

# create simulated dataset
bart reshape $(bart bitmask 4 5) $NECO $NEXT _basis_geom _basis_geom1
bart transpose 4 5 _basis_geom1 _basis_geom2
bart fmac -s $(bart bitmask 6) _basis_geom2 _basis_simu1 _phantom_ksp
bart phantom -x$NBR -T mask

# add noise to the simulated dataset 
for (( i=0; i <= 7; i++ )) ; do

        bart slice 3 $i _phantom_ksp _phantom_ksp$i
        bart noise -n200 _phantom_ksp$i tmp_ksp_$i.coo
done

bart join 3 tmp_ksp_*.coo _phantom_ksp_1
rm tmp_ksp_*.coo

bart transpose 4 2 _phantom_ksp_1 phantom_ksp

bart reshape $(bart bitmask 4 5) 16 25 traj _traj2
bart transpose 4 5 _traj2 _traj3
bart transpose 4 2 _traj3 traj

#------------------------------------------------------
#------------- Nonlinear model-based reco -------------
#------------------------------------------------------

bart index 5 $NECO tmp1.coo
bart scale $TE tmp1.coo TE

ITER=15

REG=0.004
bart moba -F -l1 -i$ITER -C400 -d4 -j$REG -g -o1.0 -B0.1 -n -t traj phantom_ksp TE moba_simu_T2 sens

bart resize -c 0 $NBR 1 $NBR moba_simu_T2 moba_simu_T2_${NBR}

bart slice 6 1 moba_simu_T2_${NBR} tmp_R2
bart invert tmp_R2 tmp_T2
bart fmac mask tmp_T2 tmp1
bart scale 0.1 tmp1 tmp2
bart transpose 0 1 tmp2 T2


rm tmp*.{cfl,hdr}  _*.{cfl,hdr} 


#!/bin/bash
# 
# Copyright 2021. Uecker Lab, University Medical Center Göttingen.
#
# Authors: Xiaoqing Wang and Nick Scholand, 2020-2021
# nick.scholand@med.uni-goettingen.de
# xiaoqing.wang@med.uni-goettingen.de
#

set -euo pipefail

if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo "\$TOOLBOX_PATH is not set correctly!" >&2
    exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

if ../physics_utils/nscaling_version_check.sh ; then
	MOBA_ADD_OPTS="--normalize_scaling --other pinit=1:1:1.5:1 --scale_data 5000 --scale_psf 1000"
else
	MOBA_ADD_OPTS=""
fi
echo $MOBA_ADD_OPTS

if ../physics_utils/simu_short_TR_version_check.sh ; then
	SIGNAL_ADD_OPTS="--short-TR-LL-approx"
else
	SIGNAL_ADD_OPTS=""
fi
echo $SIGNAL_ADD_OPTS

if ../physics_utils/gpu_check.sh ; then
       echo "bart with GPU support is required!" >&2
       exit 1
fi

# generating a numerical phantom using BART
# Simulation parameters
TR=0.0205
DIM=384
SPOKES=1
REP=208
NC=8
NBR=$(( $DIM / 2 ))

# create trajectory
bart traj -x $DIM -y $SPOKES -t $REP -c -r -G _traj
bart transpose 5 10 _traj traj
bart scale 0.5 traj traj1

# create geometry basis functions
bart phantom -s$NC -T -k -b -t traj1 _basis_geom

# create simulation basis functions
bart signal $SIGNAL_ADD_OPTS -F -I -n$REP -r$TR  -1 3:3:1 -2 1:1:1 _basis_simu_water
bart signal $SIGNAL_ADD_OPTS -F -I -n$REP -r$TR  -1 0.2:2.2:10 -2 0.045:0.045:1 _basis_simu_tubes

bart scale 1. _basis_simu_tubes _basis_simu_sdim_tubes
bart join 6 _basis_simu_water _basis_simu_sdim_tubes _basis_simu

# create simulated dataset
bart fmac -s $(bart bitmask 6) _basis_geom _basis_simu phantom_ksp
bart phantom -x$NBR -T mask

# add noise to the simulated dataset 
for (( i=0; i <= 7; i++)) ; do

        bart slice 3 $i phantom_ksp phantom_ksp$i
        bart noise -n200 phantom_ksp$i tmp_ksp_$i.coo
done

bart join 3 tmp_ksp_*.coo phantom_ksp_1
rm tmp_ksp_*.coo

# create the reference T1 (noiseless) 
bart index 6 10 tmp_T1s
bart scale 0.2 tmp_T1s tmp_T1s_1
bart ones 7 1 1 1 1 1 1 10 tmp_ones_T1s
bart saxpy 0.2 tmp_ones_T1s tmp_T1s_1 tmp_T1s_2
bart ones 7 1 1 1 1 1 1 1 tmp_ones_T1s_1
bart scale 3.0 tmp_ones_T1s_1 tmp_ones_T1s_2
bart join 6 tmp_ones_T1s_2 tmp_T1s_2 ref_T1s
bart phantom -T -b -x$NBR phan_T1
bart fmac -s $(bart bitmask 6) phan_T1 ref_T1s tmp
bart transpose 0 1 tmp phan_ref_T1s
bart invert phan_ref_T1s phan_ref_R1s

# create a zero map 
dim0=$(bart show -d0 phan_ref_R1s)
dim1=$(bart show -d1 phan_ref_R1s)
bart zeros 2 $dim0 $dim1 zero_map

#------------------------------------------------------
#------------- Nonlinear model-based reco -------------
#------------------------------------------------------

bart index 5 $REP tmp1.ra
bart scale $TR tmp1.ra TI

array=(0.05 0.1 0.2 0.5) # regularization strengths
ITER=10

for (( i=0; i<${#array}; i++ ));
do      
        REG=${array[i]}
        bart moba $MOBA_ADD_OPTS -L -l2 -i$ITER -k -g -C300 -d4 -j$REG -o1.0 -R3 -n -t traj phantom_ksp_1 TI moba_reco_${i} sens_${i}
done

#-----------------------------------------------
#------------- Linear subspace reco ------------
#-----------------------------------------------

# Generate a dictionary for IR LL 
nR1s=1000
nMss=100
TR2=$TR
bart signal $SIGNAL_ADD_OPTS -F -I -1 5e-3:5:$nR1s -3 1e-2:1:$nMss -r$TR2 -n$REP dicc

bart reshape $(bart bitmask 6 7) $((nR1s * nMss)) 1 dicc dicc1
bart squeeze dicc1 dicc2
bart svd -e dicc2 U S V

bart scale 3.0 sens_3 sens1

export ITER=100
export REG=0.1

# number of coefficients for subspace reco
for (( i=2; i <= 5; i++)) ; do

        bart extract 1 0 ${i} U basis
        bart transpose 1 6 basis basis1
        bart transpose 0 5 basis1 basis_${i}

        bart pics -RQ:$REG -i$ITER -t traj -d4 -B basis_${i} phantom_ksp_1 sens1 subspace_reco_C${i}
done


# regularization parameters for subspace reco
array=(0.05 0.1 0.2 0.5)
nCoe=4 
echo $nCoe
bart extract 1 0 $nCoe U basis
bart transpose 1 6 basis basis1
bart transpose 0 5 basis1 basis_${nCoe}

for (( i=0; i<${#array}; i++ ));
do      
        REG=${array[i]}
        bart pics -RQ:$REG -i$ITER -t traj -d4 -B basis_${nCoe} phantom_ksp_1 sens1 subspace_reco_R${i}
done




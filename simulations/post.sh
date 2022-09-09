#!/bin/bash
# 
# Copyright 2021. Uecker Lab, University Medical Center Göttingen.
#
# Authors: Xiaoqing Wang and Nick Scholand, 2020-2021
# nick.scholand@med.uni-goettingen.de
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
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

#------------------------------------------------------
#------------- Nonlinear model-based reco -------------
#------------------------------------------------------


array=(0.05 0.1 0.2 0.5) # regularization strengths
ITER=10

for (( i=0; i<${#array}; i++ ));
do      
        bart resize -c 0 $NBR 1 $NBR moba_reco_${i} tmp_reco
        bart fmac mask tmp_reco tmp_reco_masked
        bart looklocker -t0. -D0. tmp_reco_masked tmp
        bart transpose 0 1 tmp moba_T1_masked_$i
        bart saxpy -- -1.0 moba_T1_masked_$i phan_ref_T1s tmp1
        bart fmac tmp1 phan_ref_R1s moba_T1_rela_diff_${i}

	bart copy moba_T1_masked_${i} moba_T1_masked_${i}.coo
	bart copy moba_T1_rela_diff_${i} moba_T1_rela_diff_${i}.coo
done

#-----------------------------------------------
#------------- Linear subspace reco ------------
#-----------------------------------------------

# Generate a dictionary for IR LL 

# number of coefficients for subspace reco
for (( i=2; i <= 5; i++)) ; do

        nCoe=$((i))
        echo $nCoe
        bart resize -c 0 $NBR 1 $NBR subspace_reco_C${i} tmp
        bart fmac mask tmp tmp_masked

        # project "nCoe" coefficient maps to images and 
        # perform pixel-wise fitting to obtain T1 map
        bart fmac -s $(bart bitmask 6) basis_${i} tmp_masked imgs_C${i}

        python3 ../physics_utils/mapping_pixelwise.py imgs_C${i} T1 TI maps_C${i}

        bart extract 2 0 3 maps_C${i} tmp1
        bart transpose 2 6 tmp1 tmp2

        bart looklocker -t0.0 -D0.0 tmp2 tmp3
        bart scale 0.5 tmp3 T1map_C${i}
        bart fmac mask T1map_C${i} tmp4 
        bart transpose 0 1 tmp4 subspace_T1map_C${i}

        bart saxpy -- -1.0 subspace_T1map_C${i} phan_ref_T1s subspace_diff_T1map_C${i}
        bart fmac subspace_diff_T1map_C${i} phan_ref_R1s subspace_T1_rela_diff_C${i}

	bart copy subspace_T1map_C${i} subspace_T1map_C${i}.coo
	bart copy subspace_T1_rela_diff_C${i} subspace_T1_rela_diff_C${i}.coo
done

# regularization parameters for subspace reco
array=(0.05 0.1 0.2 0.5)
nCoe=4 


for (( i=0; i<${#array}; i++ ));
do      
        bart resize -c 0 $NBR 1 $NBR subspace_reco_R${i} tmp
        bart fmac mask tmp tmp_masked

        # project "nCoe" coefficient maps to images and 
        # perform pixel-wise fitting to obtain T1 map
        bart fmac -s $(bart bitmask 6) basis_${nCoe} tmp_masked imgs_R${i}

        python3 ../physics_utils/mapping_pixelwise.py imgs_R${i} T1 TI maps_R${i}

        bart extract 2 0 3 maps_R${i} tmp1
        bart transpose 2 6 tmp1 tmp2

        bart looklocker -t0.0 -D0.0 tmp2 tmp3
        bart scale 0.5 tmp3 T1map_R${i}
        bart fmac mask T1map_R${i} tmp4
        bart transpose 0 1 tmp4 subspace_T1map_R${i}

        bart saxpy -- -1.0 subspace_T1map_R${i} phan_ref_T1s subspace_diff_T1map_R${i}
        bart fmac subspace_diff_T1map_R${i} phan_ref_R1s subspace_T1_rela_diff_R${i}

	bart copy subspace_T1map_R${i} subspace_T1map_R${i}.coo
	bart copy subspace_T1_rela_diff_R${i} subspace_T1_rela_diff_R${i}.coo
done

rm tmp*.{cfl,hdr}



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

array=(0.05 0.1 0.2 0.5) # regularization strengths

for (( i=0; i<${#array}; i++ ));
do      
        python3 ../utils/save_maps.py moba_T1_masked_${i} viridis 0 2.0 moba_T1_masked_${i}.png
        python3 ../utils/save_maps.py moba_T1_rela_diff_${i} viridis 0 0.4 moba_T1_rela_diff_${i}.png
done

beg=0
end=$(( ${#array} - 1 ))

bart join 0 moba_T1_masked_*.coo tmp
bart join 0 phan_ref_T1s tmp moba_T1maps_masked 
bart join 0 moba_T1_rela_diff_*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 moba_T1maps_rela_diff
bart join 1 moba_T1maps_masked moba_T1maps_rela_diff Fig_6C

#-----------------------------------------------
#------------- Linear subspace reco ------------
#-----------------------------------------------

# number of coefficients for subspace reco
for (( i=2; i <= 5; i++)) ; do

        python3 ../utils/save_maps.py subspace_T1map_C${i} viridis 0 2.0 subspace_T1map_C${i}.png
        python3 ../utils/save_maps.py subspace_T1_rela_diff_C${i} viridis 0 0.4 subspace_T1_rela_diff_C${i}.png
done

bart join 0 subspace_T1map_C*.coo tmp
bart join 0 phan_ref_T1s tmp subspace_T1maps
bart join 0 subspace_T1_rela_diff_C*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 subspace_T1maps_rela_diff
bart join 1 subspace_T1maps subspace_T1maps_rela_diff Fig_6A

rm tmp*.{cfl,hdr}

# regularization parameters for subspace reco
array=(0.05 0.1 0.2 0.5)
nCoe=4 

for (( i=0; i<${#array}; i++ ));
do      
        python3 ../utils/save_maps.py subspace_T1map_R${i} viridis 0 2.0 subspace_T1map_R${i}.png
        python3 ../utils/save_maps.py subspace_T1_rela_diff_R${i} viridis 0 0.4 subspace_T1_rela_diff_R${i}.png
done


bart join 0 subspace_T1map_R*.coo tmp
bart join 0 phan_ref_T1s tmp subspace_T1maps
bart join 0 subspace_T1_rela_diff_R*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 subspace_T1maps_rela_diff
bart join 1 subspace_T1maps subspace_T1maps_rela_diff Fig_6B

rm tmp*.{cfl,hdr}



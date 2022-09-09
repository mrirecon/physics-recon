#!/bin/bash

if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo "\$TOOLBOX_PATH is not set correctly!" >&2
    exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"
# 

# Figure 6


# Figure 6A
bart join 0 subspace_T1map_C*.coo tmp
bart join 0 phan_ref_T1s tmp subspace_T1maps
bart join 0 subspace_T1_rela_diff_C*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 subspace_rela_diff_Coeff
bart join 1 subspace_T1maps subspace_rela_diff_Coeff Figure_6A

# individual images
python3 ../physics_utils/save_maps.py phan_ref_T1s viridis 0 2.0 ref_T1.png

for (( i=2; i <= 5; i++)) ; do
        python3 ../physics_utils/save_maps.py subspace_T1map_C${i} viridis 0 2.0 subspace_T1map_C${i}.png
        python3 ../physics_utils/save_maps.py subspace_T1_rela_diff_C${i} viridis 0 0.4 subspace_T1_rela_diff_C${i}.png
done


# Figure 6B
bart join 0 subspace_T1map_R*.coo tmp
bart join 0 phan_ref_T1s tmp subspace_T1maps
bart join 0 subspace_T1_rela_diff_R*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 subspace_rela_diff_Reg
bart join 1 subspace_T1maps subspace_rela_diff_Reg Figure_6B

# individual images
array=(0.05 0.1 0.2 0.5)
nCoe=4
for (( i=0; i<${#array}; i++ ));
do
        python3 ../physics_utils/save_maps.py subspace_T1map_R${i} viridis 0 2.0 subspace_T1map_R${i}.png
        python3 ../physics_utils/save_maps.py subspace_T1_rela_diff_R${i} viridis 0 0.4 subspace_T1_rela_diff_R${i}.png
done


# Figure 6C
bart join 0 moba_T1_masked_*.coo tmp
bart join 0 phan_ref_T1s tmp moba_T1maps_masked 
bart join 0 moba_T1_rela_diff_*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 moba_T1maps_rela_diff
bart join 1 moba_T1maps_masked moba_T1maps_rela_diff Figure_6C

# individual images
array=(0.05 0.1 0.2 0.5)
for (( i=0; i<${#array}; i++ ));
do
        python3 ../physics_utils/save_maps.py moba_T1_masked_${i} viridis 0 2.0 moba_T1_masked_${i}.png
        python3 ../physics_utils/save_maps.py moba_T1_rela_diff_${i} viridis 0 0.4 moba_T1_rela_diff_${i}.png
done

rm tmp*.{cfl,hdr}


bart join 1 Figure_6A Figure_6B Figure_6C Figure_6

bart transpose 0 1 Figure_6 Figure_6_1
python3 ../physics_utils/save_maps.py Figure_6_1 viridis 0 2 Figure6.png


python3 ../physics_utils/normalize_relative_error.py

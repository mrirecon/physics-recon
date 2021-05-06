#!/bin/bash
# 

# Figure 6


# Figure 6A
bart join 0 subspace_T1map_C*.coo tmp
bart join 0 phan_ref_T1s tmp subspace_T1maps
bart join 0 subspace_T1_rela_diff_C*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 subspace_rela_diff_Coeff
bart join 1 subspace_T1maps subspace_rela_diff_Coeff Figure_6A


# Figure 6B
bart join 0 subspace_T1map_R*.coo tmp
bart join 0 phan_ref_T1s tmp subspace_T1maps
bart join 0 subspace_T1_rela_diff_R*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 subspace_rela_diff_Reg
bart join 1 subspace_T1maps subspace_rela_diff_Reg Figure_6B


# Figure 6C
bart join 0 moba_T1_masked_*.coo tmp
bart join 0 phan_ref_T1s tmp moba_T1maps_masked 
bart join 0 moba_T1_rela_diff_*.coo tmp1
bart join 0 zero_map tmp1 tmp2
bart scale 4.0 tmp2 moba_T1maps_rela_diff
bart join 1 moba_T1maps_masked moba_T1maps_rela_diff Figure_6C

rm tmp*.{cfl,hdr}


bart join 1 Figure_6A Figure_6B Figure_6C Figure_6

bart transpose 0 1 Figure_6 Figure_6_1
python3 ../utils/save_maps.py Figure_6_1 viridis 0 2 Figure6.png

python3 ../utils/normalize_relative_error.py



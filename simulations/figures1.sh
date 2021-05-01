#!/bin/bash


#------- T1 ------

cfl2png -z1 -CV -A -l0 -u2.0 T1 T1_simu.png

# plot quantitative values against reference
./create_refs_ROIs.sh

bart fmac T1 ROIs T1_ROIs

python3 ../utils/plot_T1T2_reference.py T1_ROIs ref_T1s T1 Figure2A_1
python3 ../utils/save_maps.py T1 viridis 0 2 T1_map.png


#------- T2 ------

cfl2png -z1 -CV -A -l0 -u0.2 T2 T2_simu.png

# plot quantitative values against reference
./create_refs_ROIs.sh

bart fmac T2 ROIs T2_ROIs

python3 ../utils/plot_T1T2_reference.py T2_ROIs ref_T2s T2 Figure2A_2
python3 ../utils/save_maps.py T2 magma 0 0.3 T2_map.png



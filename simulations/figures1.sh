#!/bin/bash

# Figure 2A

#------- T1 ------

# plot quantitative values against reference
./create_refs_ROIs.sh

bart fmac T1 ROIs T1_ROIs

python3 ../physics_utils/plot_T1T2_reference.py T1_ROIs ref_T1s T1 Figure2A_T1_plot

bart transpose 0 1 T1 Sim_T1
python3 ../physics_utils/save_maps.py Sim_T1 viridis 0 2 Figure2A_Sim-T1.png


#------- T2 ------

# plot quantitative values against reference
./create_refs_ROIs.sh

bart fmac T2 ROIs T2_ROIs

python3 ../physics_utils/plot_T1T2_reference.py T2_ROIs ref_T2s T2 Figure2A_T2_plot

bart transpose 0 1 T2 Sim_T2
python3 ../physics_utils/save_maps.py Sim_T2 magma 0 0.3 Figure2A_Sim-T2.png



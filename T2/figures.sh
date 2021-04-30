#!/bin/bash


# export all parameter maps
cfl2png -z1 -CV -A -l0 -u0.2 T2 reco_T2.png
python3 ../utils/save_maps.py T2 magma 0 0.15 T2_map.png
python3 ../utils/save_maps.py M0 gray 0 4.0 M0_map.png
python3 ../utils/save_maps.py R2 gray 0 2.0 R2_map.png



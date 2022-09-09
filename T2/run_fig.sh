#!/bin/bash

# Figure2B (Bottom)

bart scale 0.0375 M0 tmp_M0
bart scale 0.075 R2 tmp_R2

bart flip $(bart bitmask 0) tmp_M0 tmp_M0_1
bart flip $(bart bitmask 0) tmp_R2 tmp_R2_1
bart flip $(bart bitmask 0) T2 tmp_T2_1

# output (M0, R2) (Figure2B Bottom)
bart join 0 tmp_M0_1 tmp_R2_1 Figure2B_Bottom
cfl2png -z1 -A -l0 -u0.15 Figure2B_Bottom Figure2B_Bottom.png

# output T2 map with colormap
bart transpose 0 1 tmp_T2_1 Moba_T2
python3 ../physics_utils/save_maps.py Moba_T2 magma 0 0.15 Figure2B_Bottom_Moba-T2.png

# output individual maps for svg
cfl2png -z1 -A -l0 -u0.15 tmp_M0_1 Figure2B_Bottom_M0.png
cfl2png -z1 -A -l0 -u0.15 tmp_R2_1 Figure2B_Bottom_R2.png


rm tmp*.{hdr,cfl}

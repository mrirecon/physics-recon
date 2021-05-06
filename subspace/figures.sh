#!/bin/bash

# Figure 7A and Figure 7B (Top)

# output the subspace coefficients (Figure 7A)
bart flip $(bart bitmask 0) coeff0 tmp_coeff0
bart flip $(bart bitmask 0) coeff1 tmp_coeff1
bart flip $(bart bitmask 0) coeff2 tmp_coeff2
bart flip $(bart bitmask 0) coeff3 tmp_coeff3

bart join 0 tmp_coeff0 tmp_coeff1 tmp_coeff2 tmp_coeff3 subspace_coeffs
cfl2png -z1 -A -l0 -u1.5e-4 subspace_coeffs Figure7A_x1.png
cfl2png -z1 -A -l0 -u3e-5 subspace_coeffs Figure7A_x5.png


# output representative T1-weighted images (Figure 7B Top)
bart scale 44500 reco_imgs tmp_reco_imgs
bart transpose 0 1 tmp_reco_imgs tmp_reco_imgs1
bart flip $(bart bitmask 0 1) tmp_reco_imgs1 tmp_reco_imgs2
bart slice 5 0 tmp_reco_imgs2 Subspace_Synth40
bart slice 5 5 tmp_reco_imgs2 Subspace_Synth400
bart slice 5 10 tmp_reco_imgs2 Subspace_Synth800
bart slice 5 50 tmp_reco_imgs2 Subspace_Synth4000

bart flip $(bart bitmask 0) T1-subspace-T1map tmp_subspace-T1map

bart join 0 Subspace_Synth40 Subspace_Synth400 Subspace_Synth800 Subspace_Synth4000 Figure7B_Top
cfl2png -z1 -A -l0 -u2.0 Figure7B_Top Figure7B_Top.png

# output the T1 map with colormap
bart transpose 0 1 tmp_subspace-T1map Subspace_T1
python3 ../utils/save_maps.py Subspace_T1 viridis 0 2.0 Figure7B_Subspace-T1.png

# create plots
python3 plot_subspace_T1.py
python3 plot_subspace_mgre.py


rm tmp*.{hdr,cfl}

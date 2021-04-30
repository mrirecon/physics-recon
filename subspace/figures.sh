#!/bin/bash

# export the final T1 map
cfl2png -z1 -CV -A -l0 -u2.0 T1-subspace-T1map subspace_reco_T1.png

python3 ../utils/save_maps.py T1-subspace-T1map viridis 0 2.0 T1_map.png

python3 ../utils/save_maps.py coeff0 gray 0 1.5e-4 coeff0.png
python3 ../utils/save_maps.py coeff1 gray 0 1.5e-4 coeff1.png
python3 ../utils/save_maps.py coeff2 gray 0 1.5e-4 coeff2.png
python3 ../utils/save_maps.py coeff3 gray 0 1.5e-4 coeff3.png

python3 ../utils/save_maps.py coeff0 gray 0 3e-5 coeff0_x5.png
python3 ../utils/save_maps.py coeff1 gray 0 3e-5 coeff1_x5.png
python3 ../utils/save_maps.py coeff2 gray 0 3e-5 coeff2_x5.png
python3 ../utils/save_maps.py coeff3 gray 0 3e-5 coeff3_x5.png

bart slice 5 0 reco_imgs reco_imgs_0
bart slice 5 5 reco_imgs reco_imgs_1
bart slice 5 10 reco_imgs reco_imgs_2
bart slice 5 50 reco_imgs reco_imgs_3

python3 ../utils/save_maps.py reco_imgs_0 gray 0 4.5e-5 sub_space_reco_imgs_0.png
python3 ../utils/save_maps.py reco_imgs_1 gray 0 4.5e-5 sub_space_reco_imgs_1.png
python3 ../utils/save_maps.py reco_imgs_2 gray 0 4.5e-5 sub_space_reco_imgs_2.png
python3 ../utils/save_maps.py reco_imgs_3 gray 0 4.5e-5 sub_space_reco_imgs_3.png


# create plots
python3 plot_subspace_T1.py
python3 plot_subspace_mgre.py


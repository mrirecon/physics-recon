#!/bin/bash


# export all parameter maps
cfl2png -z1 -CV -A -l0 -u2.0 T1-reco_t1map reco_T1.png

python3 ../utils/save_maps.py T1-reco_t1map viridis 0 2.0 T1_map.png
python3 ../utils/save_maps.py Mss gray 0 3.0 Mss_map.png
python3 ../utils/save_maps.py M0 gray 0 2.5 M0_map.png
python3 ../utils/save_maps.py R1s gray 0 3.0 R1s_map.png

# output representative T1-weighted images (for Figure 7B bottom)
bart slice 5 0 synthesized_T1_images reco_imgs_0
bart slice 5 5 synthesized_T1_images reco_imgs_1
bart slice 5 10 synthesized_T1_images reco_imgs_2
bart slice 5 50 synthesized_T1_images reco_imgs_3

python3 ../utils/save_maps.py reco_imgs_0 gray 0 4.0 moba_reco_imgs_0.png
python3 ../utils/save_maps.py reco_imgs_1 gray 0 4.0 moba_reco_imgs_1.png
python3 ../utils/save_maps.py reco_imgs_2 gray 0 4.0 moba_reco_imgs_2.png
python3 ../utils/save_maps.py reco_imgs_3 gray 0 4.0 moba_reco_imgs_3.png



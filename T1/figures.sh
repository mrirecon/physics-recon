#!/bin/bash

# Figure 2B (Top) and Figure 7B (Bottom)

# output (Mss, M0, R1s) (Figure 2B Top)
bart scale 0.6667 Mss tmp_Mss
bart scale 0.8 M0 tmp_M0
bart scale 0.6667 R1s tmp_R1s

bart flip $(bart bitmask 0) tmp_Mss tmp_Mss_1
bart flip $(bart bitmask 0) tmp_M0 tmp_M0_1
bart flip $(bart bitmask 0) tmp_R1s tmp_R1s_1
bart flip $(bart bitmask 0) T1-reco_t1map tmp_T1_1

bart join 0 tmp_Mss_1 tmp_M0_1 tmp_R1s_1 Figure2B_Top
cfl2png -z1 -A -l0 -u2.0 Figure2B_Top Figure2B_Top.png


# output representative T1-weighted images (Figure 7B Bottom)
bart flip $(bart bitmask 0) synthesized_T1_images tmp_synthesize
bart scale 0.5 tmp_synthesize tmp_synthesize2
bart slice 5 0 tmp_synthesize2 Moba_Synth40
bart slice 5 5 tmp_synthesize2 Moba_Synth400
bart slice 5 10 tmp_synthesize2 Moba_Synth800
bart slice 5 50 tmp_synthesize2 Moba_Synth4000

bart join 0 Moba_Synth40 Moba_Synth400 Moba_Synth800 Moba_Synth4000 Figure7B_Bottom
cfl2png -z1 -A -l0 -u2.0 Figure7B_Bottom Figure7B_Bottom.png

# output T1 map with colormap
bart transpose 0 1 tmp_T1_1 Moba_T1
python3 ../utils/save_maps.py Moba_T1 viridis 0 2.0 Figure2B-7B_Moba-T1.png

rm tmp*.{hdr,cfl}

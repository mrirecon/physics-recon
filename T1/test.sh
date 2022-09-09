#!/bin/bash

set -e

# verified with BART v0.6.00-203-g660a00a
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure2/2B/T1-reco_09 T1-reco

# verified with BART v0.6.00-205-g8596106
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure7/synthesize_T1_images synthesized_T1_images

#bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure2/2B/T1-reco_09_t1map T1-reco_t1map
bart nrmse -t 0.006 /home/ague/archive/projects/2021/physics-recon_rev3/Figure2/2B/T1-reco_09_t1map T1-reco_t1map

echo ok
exit 0


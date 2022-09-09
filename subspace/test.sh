#!/bin/bash
set -e

# verfied with BART v0.6.00-203-g660a00a
#bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure7/reco_coeff_maps reco_coeff_maps

bart nrmse -t 0.007 /home/ague/archive/projects/2021/physics-recon_rev3/Figure7/reco_coeff_maps reco_coeff_maps

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure7/T1-subspace-imgs T1-subspace-imgs

echo ok
exit 0


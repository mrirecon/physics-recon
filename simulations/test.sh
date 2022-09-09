#!/bin/bash
set -e


# verfied with BART v0.6.00-203-g660a00a
# moba T1
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure2/2A/moba_simu_T1_reg0.05 moba_simu_T1

# moba T2
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure2/2A/moba_simu_T2_reg0.004 moba_simu_T2



# verfied with BART v0.6.00-203-g660a00a
# subspace vs moba
# moba part
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/moba_reco_0 moba_reco_0

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/moba_reco_1 moba_reco_1

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/moba_reco_2 moba_reco_2

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/moba_reco_3 moba_reco_3

# subspace part
# subspace size
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_C2 subspace_reco_C2

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_C3 subspace_reco_C3

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_C4 subspace_reco_C4

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_C5 subspace_reco_C5

# regularization parameters
bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_R0 subspace_reco_R0

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_R1 subspace_reco_R1

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_R2 subspace_reco_R2

bart nrmse -t 0.0005 /home/ague/archive/projects/2021/physics-recon_rev3/Figure6/subspace_reco_R3 subspace_reco_R3

echo ok

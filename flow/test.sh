#/bin/bash
set -e

# verified with BART v0.6.00-156-g21153f2
# bart nrmse -t 0.00001 /home/ague/archive/projects/2020/Physics-Recon/flow_model/MAG MAG
# bart nrmse -t 0.0001 /home/ague/archive/projects/2020/Physics-Recon/flow_model/VEL VEL

# new: BART v0.6.00-203-g660a00a
bart nrmse -t 0.00009 /home/ague/archive/projects/2021/physics-recon_rev3/Figure4/R_PHASE_CONTRAST R_PHASE_CONTRAST

#bart nrmse -t 0.00004 /home/ague/archive/projects/2021/physics-recon_rev3/Figure4/R_PHASE_DIFFERENCE R_PHASE_DIFFERENCE
bart nrmse -t 0.00012 /home/ague/archive/projects/2021/physics-recon_rev3/Figure4/R_PHASE_DIFFERENCE R_PHASE_DIFFERENCE
# 0.00012 is needed, because otherwise it might fail on certain GPUs in semi-rare cases
echo ok
exit 0


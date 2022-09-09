#!/bin/bash
set -e

# veryfied with BART v0.6.00-148-g5c7586c
# bart nrmse -t 0.01 /home/ague/archive/projects/2020/Physics-Recon/meco_model/RECON_FAT RECON_FAT
# bart nrmse -t 0.01 /home/ague/archive/projects/2020/Physics-Recon/meco_model/RECON_WATER RECON_WATER
# bart nrmse -t 0.02 /home/ague/archive/projects/2020/Physics-Recon/meco_model/RECON_R2S RECON_R2S

# new: BART v0.6.00-203-g660a00a
# the masked files are created from R_WFR2S
#bart nrmse -t 0.007 /home/ague/archive/projects/2021/physics-recon_rev3/Figure3/R_WFR2S R_WFR2S
bart nrmse -t 0.008 /home/ague/archive/projects/2021/physics-recon_rev3/Figure3/R_WFR2S R_WFR2S


REF_DIR="/home/ague/archive/projects/2021/physics-recon_rev3/Figure3"


# veryfied BART v0.6.00-205-g8596106

#bart nrmse -t 0.007 ${REF_DIR}/RECON_WATER_mask RECON_WATER_mask
bart nrmse -t 0.008 ${REF_DIR}/RECON_WATER_mask RECON_WATER_mask
#bart nrmse -t 0.007 ${REF_DIR}/RECON_FAT_mask RECON_FAT_mask
bart nrmse -t 0.009 ${REF_DIR}/RECON_FAT_mask RECON_FAT_mask

#bart nrmse -t 0.007 ${REF_DIR}/RECON_R2S_mask RECON_R2S_mask
bart nrmse -t 0.027 ${REF_DIR}/RECON_R2S_mask RECON_R2S_mask

#bart nrmse -t 0.025 ${REF_DIR}/RECON_B0FIELD_mask RECON_B0FIELD_mask
bart nrmse -t 0.012 ${REF_DIR}/RECON_B0FIELD_mask RECON_B0FIELD_mask

echo ok.
exit 0


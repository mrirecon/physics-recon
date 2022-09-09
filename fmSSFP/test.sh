#!/bin/bash
set -e

# verified with BART v0.6.00-139-g3262405
bart nrmse -t 0.001 fmSSFP-reco /home/ague/archive/projects/2020/Physics-Recon/fmSSFP/fmSSFP-reco

echo ok
exit 0


#! /bin/bash
# post-processing for a reconstructed slice of the fmSSFP data set
# argument 1 (optional): reconstructed subspace coefficients
# argument 2 (optional): corresponding basis 
# ------------------------------
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

export BART_COMPAT_VERSION="v0.6.00"
export PATH=$TOOLBOX_PATH:$PATH
if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo "\$TOOLBOX_PATH is not set correctly!" >&2
    exit 1
fi

# combine coefficients by root-of-sum-of-squares
# and use to create mask
bart rss `bart bitmask 6` fmSSFP-reco reco_rss
bart threshold -B 1E-4 reco_rss mask

# compute synthesized phase-cycled bSSFP data sets
bart fmac -s `bart bitmask 6` fmSSFP-reco basis bSSFPsyn



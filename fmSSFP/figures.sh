#! /bin/bash
# post-processing for a reconstructed slice of the fmSSFP data set
# argument 1 (optional): reconstructed subspace coefficients
# argument 2 (optional): corresponding basis 
# ------------------------------
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace


export PATH=$TOOLBOX_PATH:$PATH
if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo '$TOOLBOX_PATH is not set correctly!' >&2
    exit 1
fi

# write out pngs
cfl2png -z1 -CM reco_rss RSS_magn
cfl2png -z1 -CM fmSSFP-reco reco_magn
cfl2png -z1 -CP fmSSFP-reco reco_phas
cfl2png -z1 -CM mask mask

# taking preparation scans into account
preps=1000
parts=40
phases=404
offset=$(( $preps / $parts))
for (( phase=0; phase<360; phase+=90))
do
    getphase=$(( (360 - $offset + $phase) % $phases ))
    bart extract 5 $getphase $(( $getphase + 1 )) bSSFPsyn bSSFPsyn-deg-$phase
    cfl2png -z1 -l 0.0 -u 0.605 -CM bSSFPsyn-deg-$phase bSSFPsyn-deg-$phase
done


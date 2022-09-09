#! /bin/bash
# post-processing for a reconstructed slice of the fmSSFP data set
# argument 1 (optional): reconstructed subspace coefficients
# argument 2 (optional): corresponding basis 
# ------------------------------
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace


if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo '$TOOLBOX_PATH is not set correctly!' >&2
    exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

ORIENT="-x1 -y0 -FZ"

# write out pngs
cfl2png $ORIENT -z1 -CM reco_rss Figure8_RSS
cfl2png $ORIENT -z1 -CM fmSSFP-reco Figure8_magn
cfl2png $ORIENT -z1 -CP fmSSFP-reco Figure8_phase
cfl2png $ORIENT -z1 -CM mask Figure8_mask

# taking preparation scans into account
preps=1000
parts=40
phases=404
offset=$(( $preps / $parts))
for (( phase=0; phase<360; phase+=90))
do
    getphase=$(( (360 - $offset + $phase) % $phases ))
    bart extract 5 $getphase $(( $getphase + 1 )) bSSFPsyn bSSFPsyn-deg-$phase
    cfl2png $ORIENT -z1 -l 0.0 -u 0.605 -CM bSSFPsyn-deg-$phase Figure8_bSSFP-Synth-$phase
done


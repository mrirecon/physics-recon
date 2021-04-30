#!/bin/bash
set -euo pipefail


if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH


# Simulation parameters
TR=0.0205
DIM=384
SPOKES=1
REP=208
NC=8
NBR=$(($DIM / 2))

# Generate a dictionary for IR LL 
nR1s=1000
nMss=100
TR2=$TR
bart signal -F -I -1 5e-3:5:$nR1s -3 1e-2:1:$nMss -r$TR2 -n$REP dicc0

bart reshape $(bart bitmask 6 7) $((nR1s * nMss)) 1 dicc0 dicc1
bart squeeze dicc1 T1_dict
bart svd -e T1_dict T1_U T1_S T1_V

rm dicc0.{cfl,hdr} dicc1.{cfl,hdr}


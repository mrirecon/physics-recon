#!/bin/bash
# 
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

usage="Usage: $0 [-r lambda] [-s read] [-T TR] [-C coeff] [-n num_of_frames] [-f nspokes_per_frame] <traj> <ksp> <sens> <out_coeff> <out_imgs>"

if [ $# -lt 5 ] ; then

        echo "$usage" >&2
        exit 1
fi


while getopts "hr:s:T:C:n:f:" opt; do
	case $opt in
	h) 
		echo "$usage"
		exit 0 
		;;		
	r) 
		lambda=${OPTARG}
		;;
	s) 
		read=${OPTARG}
		;;
        T) 
		TR=${OPTARG}
		;;
        C) 
		coeff=${OPTARG}
		;;
        n) 
		nf=${OPTARG}
		;;
        f) 
		np_per_frame=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))

traj=$(readlink -f "$1")
ksp=$(readlink -f "$2")
sens=$(readlink -f "$3")
reco_maps=$(readlink -f "$4")
reco_imgs=$(readlink -f "$5")

lambda=$lambda
NBR=$((read / 2))



if [ ! -e $traj ] ; then
        echo "Input traj file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi

if [ ! -e $ksp ] ; then
        echo "Input ksp file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi

if [ ! -e ${sens}.cfl ] ; then
        echo "Input sens file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"


#WORKDIR=$(mktemp -d)
# Mac: http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR


# generate IR LL temporal basis and do PCA
nR1s=1000
nMss=100

#TR1=`calc $TR*$np_per_frame*0.000001`
TR1=0.081
bart signal -F -I -1 5e-3:5:$nR1s -3 1e-2:1:$nMss -r$TR1 -n$nf dicc
bart reshape $(bart bitmask 6 7) $((nR1s * nMss)) 1 dicc dicc1
bart squeeze dicc1 dicc
bart svd -e dicc U S V

nCoe=$coeff 
bart extract 1 0 $nCoe U basis
bart transpose 1 6 basis basis1
bart transpose 0 5 basis1 basis_${nCoe}

# scale traj for subspace reco
bart scale 1.25 $traj traj1

# subspace reco
ITER=250

bart pics -SeH -d5 -RW:$(bart bitmask 0 1):$(bart bitmask 6):$lambda -i$ITER -t traj1 -B basis_${nCoe} $ksp $sens reco

bart resize -c 0 $NBR 1 $NBR reco $reco_maps

# project coefficient maps to images
bart fmac -s $(bart bitmask 6) basis_${nCoe} $reco_maps $reco_imgs



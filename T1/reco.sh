#!/bin/bash
# 
# Copyright 2021. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020-2021
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

usage="Usage: $0 [-R lambda] <TI> <traj> <ksp> <output> <output_sens>"

if [ $# -lt 4 ] ; then

        echo "$usage" >&2
        exit 1
fi


while getopts "hR:T:" opt; do
	case $opt in
	h) 
		echo "$usage"
		exit 0 
		;;		
	R) 
		lambda=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))

TI=$(readlink -f "$1")
traj=$(readlink -f "$2")
ksp=$(readlink -f "$3")
reco=$(readlink -f "$4")
sens=$(readlink -f "$5")

lambda=$lambda

if [ ! -e ${TI}.cfl ] ; then
        echo "Input TI file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi

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

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

if ../physics_utils/version_check.sh ; then
	ADD_OPTS="--normalize_scaling --other pinit=1:1:1.5:1 --scale_data 5000 --scale_psf 1000 --img_dims 320:320:1"
else
	ADD_OPTS=""
fi
echo $ADD_OPTS

#WORKDIR=$(mktemp -d)
# Mac: http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR


# model-based T1 reconstruction:

START=$(date +%s)

which bart
bart version


OMP_NUM_THREADS=1 nice -n10 bart moba -L -g -i10 -d4 -B0.3 -C300 -s0.475 -k -R3 -o1.25 $ADD_OPTS -j$lambda -n -t $traj $ksp $TI $reco $sens

END=$(date +%s)
DIFF=$(($END - $START))
echo "Reconstruction took $DIFF seconds."



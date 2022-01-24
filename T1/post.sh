#!/bin/bash
# 
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

usage="Usage: $0 [-T TR] [-r res] <reco> <sens> <mask> <reco_origsize> <t1map>"

if [ $# -lt 3 ] ; then

        echo "$usage" >&2
        exit 1
fi
while getopts "hT:r:" opt; do
	case $opt in
	h) 
		echo "$usage"
		exit 0 
		;;		
	T) 
		TR=${OPTARG}
		;;
	r) 
		res=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))


reco=$(readlink -f "$1")
sens=$(readlink -f "$2")
mask=$(readlink -f "$3")
reco_origsize=$(readlink -f "$4")
t1map=$(readlink -f "$5")
TR=$TR
res=$res

if [ ! -e ${reco}.cfl ] ; then
        echo "Input file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"



# WORKDIR=$(mktemp -d)
# Mac: http://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR


bart looklocker -t0.0 -D15.3e-3 $reco map 
bart resize -c 0 $res 1 $res $reco tmp_reco
bart resize -c 0 $res 1 $res map tmp_t1map

# creating mask
bart resize -c 0 $res 1 $res $sens tmp_sens
bart rss $(bart bitmask 3) tmp_sens tmp_sens_rss
bart slice 6 0 tmp_reco tmp_M0
bart fmac tmp_sens_rss tmp_M0 tmp_M0_rss
bart cabs tmp_M0_rss tmp_M0_rss_abs
bart threshold -B 2.5E-2 tmp_M0_rss_abs $mask

# final output

# parameter maps (Mss, M0, R1*)
bart fmac $mask tmp_reco tmp_reco1
bart transpose 0 1 tmp_reco1 tmp_reco
bart flip $(bart bitmask 1) tmp_reco $reco_origsize

# T1 map
bart fmac $mask tmp_t1map tmp_t1map1
bart transpose 0 1 tmp_t1map1 tmp_t1map
bart flip $(bart bitmask 1) tmp_t1map $t1map



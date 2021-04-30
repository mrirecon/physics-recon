#!/bin/bash
# 
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
#
# Author: Xiaoqing Wang, 2020
# xiaoqing.wang@med.uni-goettingen.de
#

set -e


helpstr=$(cat <<- EOF
Preparation of traj, data and inversion times for IR Radial FLASH.

-s sample size 
-R repetition time 
-G nth tiny golden angle
-p total number of spokes
-f number of spokes per frame (k-space)
-h help

EOF
)

usage="Usage: $0 [-h] [-s sample] [-T TR] [-G GA] [-p nspokes] [-f nspokes_per_frame] <input> <out_data> <out_traj> <out_TI>"


while getopts "hEs:T:G:p:f:" opt; do
	case $opt in
	h) 
		echo "$usage"
		echo "$helpstr"
		exit 0 
		;;		
	s) 
		sample_size=${OPTARG}
		;;
	T) 
		TR=${OPTARG}
		;;
	G) 
		GA=${OPTARG}
		;;
	p) 	
		nspokes=${OPTARG}
		;;
	f) 	
		nspokes_per_frame=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))

sample_size=$sample_size #e.g. 512
TR=$TR
GA=$GA
nf=1
nspokes=$nspokes
nspokes_per_frame=$nspokes_per_frame

nf1=$((nspokes/nspokes_per_frame))
nspokes=$((nf1 * nspokes_per_frame))

echo $nf1
echo $nspokes


input=$(readlink -f "$1")
out_data=$(readlink -f "$2")
out_traj=$(readlink -f "$3")
out_TI=$(readlink -f "$4")


if [ ! -e ${input}.cfl ] ; then
        echo "Input file does not exist." >&2
        echo "$usage" >&2
        exit 1
fi

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi


WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR

nstate=180;


#-----------------------------
# Prepare data
#-----------------------------

bart extract 10 0 $nspokes $input ksp1
bart transpose 1 10 ksp1 ksp2

bart transpose 1 2 ksp2 temp
bart transpose 0 1 temp dataT


bart transpose 3 11 dataT dataT_temp
bart reshape $(bart bitmask 2 10) $nspokes_per_frame $nf1 dataT_temp dataT_temp1
bart transpose 3 11 dataT_temp1 dataT_final
bart cc -A -p 8 dataT_final data_final_cc
bart transpose 5 10 data_final_cc $out_data 


#-----------------------------
# Prepare traj
#-----------------------------

# Get trajectories 
bart traj -r -D -G -x$sample_size -y1 -s$GA -t$nspokes traj

bart extract 10 $((nspokes-nstate))  $nspokes traj traj_extract 
bart transpose 2 10 traj_extract traj_extract1
bart flip $(bart bitmask 2) traj_extract1 traj_extract_flip 

bart extract 2 $((nspokes-nstate)) $nspokes dataT dataT_extract
bart flip $(bart bitmask 2) dataT_extract dataT_extract_flip

# Calculate trajectory and do gradient delay correction
bart traj -D -r -G -x$sample_size -y1 -s$GA -t$nspokes -q $(bart estdelay traj_extract_flip dataT_extract_flip) trajn

bart reshape $(bart bitmask 2 10) $nspokes_per_frame $nf1 trajn traj 
bart transpose 5 10 traj $out_traj


#-----------------------------
# Prepare TI 
#-----------------------------

bart index 5 $nf1 tmp1.coo
# use local index from newer bart with older bart
#./index 5 $num tmp1.coo
bart scale $(($nspokes_per_frame * $TR)) tmp1.coo tmp2.coo
bart ones 6 1 1 1 1 1 $nf1 tmp1.coo 
bart saxpy $((($nspokes_per_frame / 2) * $TR)) tmp1.coo tmp2.coo tmp3.coo
bart scale 0.000001 tmp3.coo $out_TI


#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.
# 
# Authors:
# 2020 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
# 
# This script is used to compute multi-echo trajecotry
# 

set -e

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi

helpstr=$(cat <<- EOF
compute multi-echo traj
-F full sample size
-s golden angle index
-h help
EOF
)

usage="Usage: $0 [-h] [-F sample] [-s golden index] <input kdat> <output traj> <output GDC>"

FSMP=1
GIND=2

while getopts "hF:s:" opt; do
	case $opt in
	h) 
		echo "$usage"
		echo "$helpstr"
		exit 0 
		;;		
	F) 
		FSMP=${OPTARG}
		;;
	s)
		GIND=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done

shift $(($OPTIND -1 ))

KDAT=$(readlink -f "$1") # INPUT k-space data
TRAJ=$(readlink -f "$2") # OUTPUT trajectory
GDC=$(readlink -f "$3") # OUTPUT gradient-delay coefficients


# --- dimensions ---
NSMP=$(bart show -d  1 $KDAT)
NSPK=$(bart show -d  2 $KDAT)
NECO=$(bart show -d  5 $KDAT)
NMEA=$(bart show -d 10 $KDAT)
NSLI=$(bart show -d 13 $KDAT)


# --- trajectory without gradient delay correction ---
bart traj -x $NSMP -d $FSMP -y $NSPK -t $NMEA -r -s $GIND -D -E -e $NECO -c $TRAJ


CTR_SLI_NR=$(( ($NSLI == 1) ? (0) : ( NSLI/2 ) ))

bart slice 13 $CTR_SLI_NR $KDAT temp_kdat
bart slice 13 $CTR_SLI_NR $TRAJ temp_traj

bart reshape $(bart bitmask 2 10) 1 $(( NSPK * NMEA )) temp_kdat temp_kdat_estdelay
bart reshape $(bart bitmask 2 10) 1 $(( NSPK * NMEA )) temp_traj temp_traj_estdelay

# number of spokes for GDC

TOT_SPK=$(( NSPK * NMEA ))

if [ ${TOT_SPK} -gt 80 ]; then
	NSPK4GDC=80
else
	NSPK4GDC=$((TOT_SPK))
fi

bart resize -c 10 $NSPK4GDC temp_kdat_estdelay temp_kdat_estdelay_t
bart resize -c 10 $NSPK4GDC temp_traj_estdelay temp_traj_estdelay_t

echo "> GDC using the central slice $CTR_SLI_NR and $NSPK4GDC spokes"

bart transpose 2 10 temp_kdat_estdelay_t temp_kdat_estdelay_a
bart transpose 2 10 temp_traj_estdelay_t temp_traj_estdelay_a

bart zeros 16 3 1 1 1 1 $NECO 1 1 1 1 1 1 1 1 1 1 $GDC

for (( I=0; I < $NECO; I++ )); do

	IECO=$(printf "%02d" $I)

	bart slice 5 $IECO temp_kdat_estdelay_a temp_kdat_estdelay_${IECO}
	bart slice 5 $IECO temp_traj_estdelay_a temp_traj_estdelay_${IECO}

	CTR=$(( FSMP/2 ))
	DIF=$(( FSMP - NSMP ))
	RADIUS=$(( CTR - DIF ))

	# the echo position for even echoes are flipped

	ECOPOS=$(( ($IECO%2 == 0) ? (RADIUS) : (RADIUS - 1) ))
	LEN=$(( ECOPOS * 2 ))

	if [ $(($IECO%2)) -eq 1 ]; then # even echoes
		bart flip $(bart bitmask 1) temp_kdat_estdelay_${IECO} temp_kk
		bart flip $(bart bitmask 1) temp_traj_estdelay_${IECO} temp_tt
	else
		bart scale 1 temp_kdat_estdelay_${IECO} temp_kk
		bart scale 1 temp_traj_estdelay_${IECO} temp_tt
	fi

	bart resize 1 $LEN temp_kk temp_kk_r
	bart resize 1 $LEN temp_tt temp_tt_r

	bart estdelay -R temp_tt_r temp_kk_r temp_GDC_$IECO.coo
done

bart join 5 temp_GDC_*.coo $GDC

bart traj -x $NSMP -d $FSMP -y $NSPK -t $NMEA -r -s $GIND -D -E -e $NECO -c -O -V $GDC $TRAJ

rm temp_*.{cfl,hdr} temp_GDC_*.coo



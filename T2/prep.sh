#!/bin/bash
set -e

helpstr=$(cat <<- EOF
Preparation of traj, data and echo time for Fast Spin Echo

-s sample size 
-R repetition time 
-G nth tiny golden angle
-p total number of spokes
-f number of spokes per frame (k-space, excitations)
-e number of echos
-h help

EOF
)

usage="Usage: $0 [-h] [-s sample] [-R TE] [-G GA] [-p nspokes] [-f excitations] [-e echos] <input> <out_data> <out_traj> <out_TI>"


while getopts "hEs:R:G:p:f:e:" opt; do
	case $opt in
	h) 
		echo "$usage"
		echo "$helpstr"
		exit 0 
		;;		
	s) 
		sample_size=${OPTARG}
		;;
	R) 
		TE=${OPTARG}
		;;
	G) 
		GA=${OPTARG}
		;;
	p) 	
		nspokes=${OPTARG}
		;;
	f) 	
		excitations=${OPTARG}
		;;
	e) 	
		echos=${OPTARG}
		;;
	\?)
		echo "$usage" >&2
		exit 1
		;;
	esac
done
shift $(($OPTIND -1 ))

sample_size=$sample_size #e.g. 512
TE=$TE
GA=$GA
nf=1
nspokes=$nspokes
excitations=$excitations



input=$(readlink -f "$1")
out_data=$(readlink -f "$2")
out_traj=$(readlink -f "$3")
out_TE=$(readlink -f "$4")


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



#-----------------------------
# Prepare data
#-----------------------------

bart transpose 1 5 $input tmp

bart reshape $(bart bitmask 5 6) $echos $excitations tmp tmp1

bart transpose 6 2 tmp1 tmp

bart transpose 0 1 tmp $out_data

#-----------------------------
# Prepare traj
#-----------------------------

# Get trajectories 
bart traj -D -r -G -x$sample_size -y1 -s$GA -t$nspokes tmp_trajn
bart reshape $(bart bitmask 5 10) $echos $excitations tmp_trajn tmp_traj
bart transpose 10 2 tmp_traj $out_traj

#-----------------------------
# Prepare TE 
#-----------------------------

bart index 5 $echos tmp1.coo
# use local index from newer bart with older bart
#./index 5 $num tmp1.coo
bart scale $TE  tmp1.coo tmp2.coo
bart ones 6 1 1 1 1 1 $echos tmp1.coo 
bart saxpy $TE tmp1.coo tmp2.coo tmp3.coo
bart scale 0.000001 tmp3.coo $out_TE
rm tmp*

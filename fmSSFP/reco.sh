#! /bin/bash
# reconstruct fmSSFP data set with subspace constraint
# according to Roeloffs et al., MRM 2018
# ------------------------------
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

PI=3.14159

if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo "\$TOOLBOX_PATH is not set correctly!" >&2
    exit 1
fi
export PATH="$TOOLBOX_PATH":"$PATH"
export BART_COMPAT_VERSION="v0.6.00"

WORKDIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
trap 'rm -rf "$WORKDIR"' EXIT
cd $WORKDIR

# -------------------------------
source $__dir/../physics_utils/data_loc.sh
RAW="${DATA_LOC}"/fmSSFP
if [ ! -f "$RAW".cfl ] ; then
	printf "Error: Rawdata %s not found, either download is using load_all.sh or set DATA_ARCHIVE correctly!\n" "$RAW" >&2
	exit 1
fi


OUT=$__dir/"$(basename -- $RAW)-reco"

#if [ -e "$OUT.hdr" ]; then
#    echo "File $OUT already exists!"
#    exit 1
#fi

P=4
VCOILS=10
REG=0.002
LLRBLK=8
ITERATIONS=100
FOV=1
SPOKES=$(bart show -d2 $RAW) # total number spokes
SPT=$(( $SPOKES / $P )) # spokes per turn
PHS1=$(bart show -d1 $RAW)
READ_NOOS=$(( $PHS1 / 2 ))


# create DFT basis
bart delta 16 $(bart bitmask 5 6) $P eye
bart crop 6 $P eye eye_c 
bart resize -c 5 $SPOKES eye_c eye_cl
bart fft -u $(bart bitmask 5) eye_cl $__dir/basis

#GD=`DEBUG_LEVEL=0 bart estdelay -R -n21 -r1.5 traj meas_cc`
GD="0.114442:0.058800:-0.068824" # gradient delays were determined on the DC partition of the full 3D stack-of-stars data 
echo $GD

bart traj -q$GD -r -c -D -x$PHS1 -y$SPT traj_st_1
bart repmat 3 $P traj_st_1 traj_f_1
bart reshape $(bart bitmask 2 3) $SPOKES 1 traj_f_1 traj_1

# perform channel compression on combined data
bart cc -p$VCOILS -A -S $RAW meas_cc

# apply inverse nufft 
bart nufft -i -d$PHS1:$PHS1:1 traj_1 meas_cc img

# transform back to k-space and compute sensitivities
bart fft -u $(bart bitmask 0 1 2) img ksp

# transpose because we already support off-center calibration region
# in dim 0 but here we might have it in 2
bart transpose 0 2 ksp ksp2
bart ecalib -S -t0.01 -m1 ksp2 sens2
bart transpose 0 2 sens2 sens

# transform data
bart transpose 2 5 meas_cc meas_t
bart transpose 2 5 traj_1 traj_t

# reconstruction with subspace constraint
bart pics -SeH -d5 -R L:3:3:$REG -i$ITERATIONS -f$FOV \
    -t traj_t -B $__dir/"basis" meas_t sens out

bart crop 0 $READ_NOOS out out_c
bart crop 1 $READ_NOOS out_c $OUT

exit 0


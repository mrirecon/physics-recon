#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.
# 
# Authors:
# 2020 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
# 
# This script is used to create dictionnary for 
# multi-gradient-echo signals
# 

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"



# --- dimension ---

NECO=401 # $(bart show -d 5 mgre_signal)
NRELAX=256 # $(bart show -d 6 mgre_signal)
NFIELD=256 # $(bart show -d 8 mgre_signal)


# --- simulate signal ---

START_NR=8

bart signal -G -n ${NECO} -e 0.000125 -0 -200:201.6:${NFIELD} -1 3:3:1 -2 0.001:0.1:${NRELAX} tempsub_mgre_signal

bart extract 5 ${START_NR} $NECO tempsub_mgre_signal mgre_signal 

# --- TE (ms) ---

bart index 5 $NECO tempsub_ind
bart scale 0.125 tempsub_ind tempsub_TE
bart extract 5 ${START_NR} $NECO tempsub_TE TE


# --- svd ---

bart squeeze mgre_signal mgre_signal_s
bart reshape $(bart bitmask 0 1 2) $(( NECO - START_NR )) $(( NRELAX * NFIELD )) 1 mgre_signal_s mgre_signal_sr

bart svd -e mgre_signal_sr mgre_U mgre_S mgre_VH

rm tempsub_*.{cfl,hdr}



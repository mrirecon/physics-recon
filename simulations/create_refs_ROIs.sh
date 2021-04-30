#!/bin/bash
# 
# Copyright 2020. Uecker Lab, University Medical Center Göttingen.
#
# Authors: Xiaoqing Wang and Nick Scholand, 2020
# nick.scholand@med.uni-goettingen.de
# xiaoqing.wang@med.uni-goettingen.de
#

set -e

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi

# create reference T1 
bart index 6 10 tmp_T1s
bart scale 0.2 tmp_T1s tmp_T1s_1
bart ones 7 1 1 1 1 1 1 10 tmp_ones_T1s
bart saxpy 0.2 tmp_ones_T1s tmp_T1s_1 tmp_T1s_2
bart ones 7 1 1 1 1 1 1 1 tmp_ones_T1s_1
bart scale 3.0 tmp_ones_T1s_1 tmp_ones_T1s_2
bart join 6 tmp_ones_T1s_2 tmp_T1s_2 ref_T1s

# create reference T2 
bart index 6 10 tmp_T2s
bart scale 0.02 tmp_T2s tmp_T2s_1
bart ones 7 1 1 1 1 1 1 10 tmp_ones_T2s
bart saxpy 0.02 tmp_ones_T2s tmp_T2s_1 tmp_T2s_2
bart ones 7 1 1 1 1 1 1 1 tmp_ones_T2s_1
bart scale 1.0 tmp_ones_T2s_1 tmp_ones_T2s_2
bart join 6 tmp_ones_T2s_2 tmp_T2s_2 ref_T2s

rm tmp*.{cfl,hdr}

# create ROIs
NBR=192
bart phantom -T -b -x$NBR phan_T1

#bart morph -e -b 5 phan_T1 tmp_ROIs
bart ones 2 5 5 tmp_ones
bart conv $(bart bitmask 0 1) phan_T1 tmp_ones tmp_ROIs
bart threshold -B 24.5 tmp_ROIs tmp_ROIs

bart transpose 0 1 tmp_ROIs ROIs

rm tmp*.{cfl,hdr}


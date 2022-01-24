#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.
# 
# Authors:
# 2020 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
# 
# This script is used to create results for 
# moba water/fat separation abd R2* mapping
# 

set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"



# --- cfl2png ---

python3 cfl2png_wf.py

cp png_moba_wf/Fat_000.png Figure3_Fat.png
cp png_moba_wf/fB0_000.png Figure3_B0.png
cp png_moba_wf/R2S_000.png Figure3_R2star.png
cp png_moba_wf/Water_000.png Figure3_Water.png


#!/bin/bash
# Copyright 2020. Uecker Lab, University Medical Center Goettingen.
# All rights reserved. Use of this source code is governed by
# a BSD-style license which can be found in the LICENSE file.
# 
# Authors:
# 2020 Zhengguo Tan <zhengguo.tan@med.uni-goettingen.de>
# 
# This script is used to create results for moba flow
# 

set -e

export PATH=$TOOLBOX_PATH:$PATH

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi

# --- cfl2png ---
python3 cfl2png_flow.py

cp png_moba_flow/MAG_081.png Figure4_Top_Left.png
cp png_moba_flow/VEL_081.png Figure4_Top_Right.png
cp png_phasediff_flow/MAG_081.png Figure4_Bottom_Left.png
cp png_phasediff_flow/VEL_081.png Figure4_Bottom_Right.png


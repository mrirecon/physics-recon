#!/bin/bash

if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo "\$TOOLBOX_PATH is not set correctly!" >&2
    exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.6.00"

## individual reconstructions

for dir in T1 T2 subspace simulations water-fat flow fmSSFP ; do

	echo $dir
	cd $dir
	./run.sh
	cd ..
done


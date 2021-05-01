#!/bin/bash

export PATH=$TOOLBOX_PATH:$PATH
if [ ! -e $TOOLBOX_PATH/bart ] ; then
    echo '$TOOLBOX_PATH is not set correctly!' >&2
    exit 1
fi

## individual reconstructions

for dir in T1 T2 subspace simulations water-fat flow fmSSFP ; do

	echo $dir
	cd $dir
	./figures.sh
	cd ..
done


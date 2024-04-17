#!/bin/bash
# returns success if GPU is supported

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

if bart version -V 2>&1 | grep -q "CUDA=1" >/dev/null 2>&1 ; then
	exit 0
else
	exit 1
fi


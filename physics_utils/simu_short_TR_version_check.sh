#!/bin/bash
# returns success if --short-TR-LL-approx exists (as the default changed)

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

if bart signal --interface 2>&1 | grep -q \"short-TR-LL-approx\" >/dev/null 2>&1 ; then
	exit 0
else
	exit 1
fi


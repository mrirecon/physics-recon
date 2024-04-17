#!/bin/bash
# returns success if temporal dampening is configurable (and therefore, the default changed)

if [ ! -e $TOOLBOX_PATH/bart ] ; then
       echo "\$TOOLBOX_PATH is not set correctly!" >&2
       exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

if bart moba --interface 2>&1 | grep -q \"T\" >/dev/null 2>&1 ; then
	exit 0
else
	exit 1
fi


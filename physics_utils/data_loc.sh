#!/bin/bash

set +u

FOLDER=$(dirname $(readlink -f $BASH_SOURCE))
REPO_NAME=$(<"$FOLDER"/../meta/name)

if [ ! -d ${DATA_ARCHIVE}/${REPO_NAME} ] ; then
        DATA_LOC=$(realpath "$FOLDER"/../data)
else
        DATA_LOC=${DATA_ARCHIVE}/${REPO_NAME}
fi

set -u
export DATA_LOC

#! /bin/bash
# $1: *.svg with linked and arranged pngs
# is converted to *.pdf via inkscape command line

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace


FILE=$1
OUT=`basename $FILE .svg`.pdf

# Figure in Publication was generated with Inkscape 1.0 (cario 1.16.0)
# Inkscape's CLI for pdf rendering changed,
# to use the following command, Inkscape >= 1.0 is required
inkscape $FILE --export-area-drawing --batch-process --export-type=pdf --export-filename=$OUT


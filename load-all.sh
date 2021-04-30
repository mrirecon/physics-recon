#!/bin/bash

## data loading

ZENODO_RECORD=4381986

echo "Downloading and verifying...."

for file in fmSSFP IR-FLASH  ME-FLASH  ME-SE  PC-FLASH; do

    if [ -f $file.cfl ]; then

        echo "File $file already exists."

    else

        ./load.sh ${ZENODO_RECORD} $file.cfl ./data
        ./load.sh ${ZENODO_RECORD} $file.hdr ./data
    fi
done

echo "Download completed"




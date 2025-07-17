#!/bin/bash
# Script that runs the dvpd compiler and then all the render scripts
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DVPD_FILE_NAME=$1
INI_FILE_PATH=$2
python3 $SCRIPT_DIR/../../processes/dvpdc/__main__.py $DVPD_FILE_NAME.dvpd.json --ini_file=$INI_FILE_PATH \
    && exit 0

exit 1
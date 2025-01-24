#!/bin/bash
# Script that runs the dvpd compiler and then all the render scripts
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DVPI_FILE_NAME=$1
INI_FILE_PATH=$2
OPTIONAL_ARG=""
if [ $# -ge 3]; then
    OPTIONAL_ARG="$3"
fi

if [ -z "$OPTIONAL_ARG" ]; then 
    python3 $SCRIPT_DIR/../../processes/generate_dbt_models/__main__.py $DVPI_FILE_NAME --ini_file=$INI_FILE_PATH $OPTIONAL_ARG
else
    python3 $SCRIPT_DIR/../../processes/generate_dbt_models/__main__.py $DVPI_FILE_NAME --ini_file=$INI_FILE_PATH 
fi
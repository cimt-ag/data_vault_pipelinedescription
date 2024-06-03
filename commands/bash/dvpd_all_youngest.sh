#!/bin/bash
# Script that runs the dvpd compiler and then all the render scripts
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
python3 $SCRIPT_DIR/../../processes/dvpdc/__main__.py @youngest $@ \
    && python3 $SCRIPT_DIR/../../processes/render_ddl/main.py @youngest $@ \
    && python3 $SCRIPT_DIR/../../processes/render_documentation/__main__.py @youngest $@ \
    && python3 $SCRIPT_DIR/../../processes/render_operations_list/__main__.py @youngest $@ \
    && python3 $SCRIPT_DIR/../../processes/render_dev_sheet/main.py @youngest $@ \
    && exit 0

exit 1
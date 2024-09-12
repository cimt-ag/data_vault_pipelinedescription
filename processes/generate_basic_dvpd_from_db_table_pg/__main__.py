#!/usr/bin/env python310
# =====================================================================
# Part of the Data Vault Pipeline Description Reference Implementation
#
#  Copyright 2023 Matthias Wegner mattywausb@gmail.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  =====================================================================


import argparse
import json
import os
import sys

from pathlib import Path

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from lib.configuration import configuration_load_ini
from lib.connection_pg import pg_getConnection_via_inifile

#conn = pg_getConnection_via_inifile("connection_pg_dev.ini","willibald_source")


def main(dvpd_filename,
              ini_file,print_html):

    params = configuration_load_ini(ini_file, 'rendering',['dvpd_default_directory','documentation_directory'])
    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)
    print(params['dvpd_default_directory'])
    if not dvpd_file_path.exists():
        raise Exception(f"file not found {dvpd_file_path.as_posix()}")
    print(f"Rendering documentation from {dvpd_file_path.name}")

    column_labels='Field Name,Field Type,Data Vault Target(s)'
    if 'documentation_column_labels' in params:
        column_labels=params['documentation_column_labels']

    dvpd = parse_json_file(dvpd_file_path)
    pipeline_name = dvpd["pipeline_name"]
    if isinstance(dvpd['fields'], (dict, list)):
        html = create_documentation(dvpd,column_labels)
        if print_html:
            print(html)
        target_directory=Path(params['documentation_directory'])
        if not target_directory.exists():
            target_directory.mkdir(parents=True)
        out_file_Path = target_directory.joinpath(f'{pipeline_name}.html')
        with open(out_file_Path, "w") as file:
            file.write(html)
    else:
        print(fields)

    print (f"Completed rendering documentation from {dvpd_file_path.name}")



########################################################################################################################

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
            description="generate a basic dvpd from the database table ",
            usage = "Add option -h for further instruction"
    )
    parser.add_argument("schema_name", help="schema name of the table")
    parser.add_argument("table_name", help="name of the table")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--print", help="Print html to console",  action='store_true')

    args = parser.parse_args()
    dvpd_filename = args.dvpd_file_name

    if dvpd_filename == '@youngest':
        dvpd_filename = get_name_of_youngest_dvpd_file(ini_file=args.ini_file)

    main(dvpd_filename=dvpd_filename,
              ini_file=args.ini_file,
                print_html=args.print)

    print("--- documentation render complete ---")
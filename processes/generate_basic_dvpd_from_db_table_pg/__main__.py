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


def get_pg_table_column_list(db_connection, schema_name, table_name):
    """Gets essential column data of a table"""
    db_repo_cursor = db_connection.cursor()
                                     #0
    db_repo_cursor.execute("""SELECT column_name , /* 0 */
                                     data_type , /* 1 */
                                     character_maximum_length, /* 2 */
                                     numeric_precision, /* 3 */
                                     numeric_scale, /* 4 */
                                     datetime_precision /* 5 */
                            FROM INFORMATION_SCHEMA.COLUMNS 
                            WHERE TABLE_SCHEMA = lower(%s)
                            AND TABLE_NAME = lower(%s) order by 1""",
                           (schema_name.lower(), table_name.lower()))
    type_translation={'character varying':{'column_type':'VARCHAR' ,'add_charlength':True,'add_numeric_precision':False},
                      'character': {'column_type': 'CHAR', 'add_charlength': True,'add_numeric_precision': False},
                      'numeric': {'column_type': 'NUMERIC', 'add_charlength': False,'add_numeric_precision': True},
                      }
    table_columns = []
    column_row = db_repo_cursor.fetchone()
    while column_row:
        if column_row[1] in type_translation:
            translation=type_translation[ column_row[1] ]
            if translation['add_charlength']:
                column_type=f"{translation['column_type']}({ column_row[2]})"
            elif translation['add_numeric_precision']:
                column_type = f"{translation['column_type']}({column_row[3]},{column_row[4]})"
            else:
                column_type = f"{translation['column_type']}"
        else:
            column_type= column_row[1]
        table_column={'column_name': column_row[0],
                      'column_type': column_type}
        table_columns.append(table_column)
        column_row = db_repo_cursor.fetchone()

    if len(table_columns)  == 0:
        raise Exception(f"no columns collected for {schema_name}.{table_name} . Does this object exist?")

    return table_columns


def main(schema_name, table_name,  ini_file, db_connection):

    params = configuration_load_ini(ini_file, 'generator',['dvpd_generator_directory'])
    pipeline_name = schema_name+"."+table_name
    dvpd_filename=pipeline_name+".dvpd.json"
    dvpd_file_path = Path(params['dvpd_generator_directory']).joinpath(dvpd_filename)

    # get all columns
    table_columns=get_pg_table_column_list(db_connection,schema_name, table_name,)
    print(json.dumps(table_columns, indent=2, sort_keys=True))


    #retirev column statistics

    # assemble final dvpd json



    print (f"Completed rendering documentation from {dvpd_file_path.name}")



########################################################################################################################

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
            description="generate a basic dvpd from the database table ",
            usage = "Add option -h for further instruction"
    )
    parser.add_argument("schema_name", help="schema name of the table")
    parser.add_argument("table_name", help="name of the table")
    parser.add_argument("--dvpdc_ini_file", help="Name of the ini file of dvpdc", default='./dvpdc.ini')
    parser.add_argument("--connection_ini_file", help="Name of the ini file with the db connection properties", default='./connection_pg.ini')
    parser.add_argument("--connection_ini_section", help="Name of the section in th ini file to use", default='willibald_source')

    args = parser.parse_args()

    db_connection=pg_getConnection_via_inifile(args.connection_ini_file,args.connection_ini_section)


    main(schema_name=args.schema_name, table_name= args.table_name,
              ini_file=args.dvpdc_ini_file, db_connection=db_connection
                )

    print("--- generation of dvpd complete ---")
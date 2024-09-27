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
from datetime import datetime

from pathlib import Path

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from lib.configuration import configuration_load_ini
from lib.connection_pg import pg_getConnection_via_inifile

g_metadata={}

SAMPLE_SIZE_LIMIT=999999

def print_g_metadata():
    print(json.dumps(g_metadata, indent=2, sort_keys=True))


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
        table_column={'field_name': column_row[0],
                      'field_type': column_type}
        table_columns.append(table_column)
        column_row = db_repo_cursor.fetchone()

    if len(table_columns)  == 0:
        raise Exception(f"no columns collected for {schema_name}.{table_name} . Does this object exist?")

    return table_columns


def determine_key_participation(table_column, db_connection, schema_name, table_name):
    db_repo_cursor = db_connection.cursor()
    sql_string=f"""select constraint_type from information_schema.key_column_usage    cu
                    join information_schema.table_constraints tc 
                        on tc.table_schema = cu.table_schema 
                        and tc.table_name=cu.table_name 
                        and tc.constraint_name=cu.constraint_name
                    WHERE cu.TABLE_SCHEMA = '{schema_name.lower()}'
                    AND cu.TABLE_NAME = '{table_name.lower()}'
                    and cu.column_name=lower('{ table_column['field_name']}')
                    """
    db_repo_cursor.execute(sql_string)

    column_row = db_repo_cursor.fetchone()
    table_column['is_primary_key']=False
    table_column['is_foreign_key'] = False
    while column_row:
        if column_row[0]=='PRIMARY KEY':
            table_column['is_primary_key'] = True
        if column_row[0]=='FOREIGN KEY':
            table_column['is_foreign_key'] = True
        column_row = db_repo_cursor.fetchone()

def measure_count_of_nulls(table_column, db_connection, schema_name, table_name):
    db_repo_cursor = db_connection.cursor()
    sql_string=f"""with sample as (
                    SELECT {table_column['field_name']} the_column 
                    FROM {schema_name.lower()}.{table_name.lower()}
                    LIMIT {SAMPLE_SIZE_LIMIT}
                    ) select count(1) from sample where the_column is null
                            """
    db_repo_cursor.execute(sql_string)


    column_row = db_repo_cursor.fetchone()
    while column_row:
        table_column['count_of_nulls']=column_row[0]
        column_row = db_repo_cursor.fetchone()

def measure_null_values(table_column, db_connection, schema_name, table_name):
    db_repo_cursor = db_connection.cursor()
    sql_string=f"""with sample as (
                    SELECT {table_column['field_name']} the_column 
                    FROM {schema_name.lower()}.{table_name.lower()}
                    LIMIT {SAMPLE_SIZE_LIMIT}
                    ) select count(1) from sample where the_column is null
                            """
    db_repo_cursor.execute(sql_string)

    column_row = db_repo_cursor.fetchone()
    while column_row:
        table_column['null_values']=column_row[0]
        column_row = db_repo_cursor.fetchone()

def measure_cardinality(table_column, db_connection, schema_name, table_name):
    db_repo_cursor = db_connection.cursor()
    sql_string=f"""with sample as (
                        select {table_column['field_name']} as the_column 
                        FROM {schema_name.lower()}.{table_name.lower()}
                            LIMIT 999999
                ) SELECT count(distinct the_column) from sample """
    db_repo_cursor.execute(sql_string)


    column_row = db_repo_cursor.fetchone()
    while column_row:
        table_column['cardinality']=column_row[0]
        column_row = db_repo_cursor.fetchone()

def get_row_count(db_connection, schema_name, table_name):
    db_repo_cursor = db_connection.cursor()
    sql_string=f"""select count(1) 
                        FROM {schema_name.lower()}.{table_name.lower()}"""
    db_repo_cursor.execute(sql_string)

    column_row = db_repo_cursor.fetchone()
    row_count=None
    while column_row:
        row_count=column_row[0]
        column_row = db_repo_cursor.fetchone()
    return row_count


def render_field_order_string(table_column,row_count_sample):
    """Creates a string that will be used to order the fields in the dvpd"""
    field_order_string=""
    if table_column ['is_primary_key']:
        field_order_string+="0"      # primary key fields first
    else:
        field_order_string += "1"

    if table_column ['is_foreign_key']:
        field_order_string+="0"     # foreign key fields second
    else:
        field_order_string += "1"

    if table_column ['null_values']<row_count_sample:
        field_order_string += "0"  # field with data third
    else:
        field_order_string += "1"  # empty field last

    field_order_string +="_/_"+table_column['field_name']  # finally order by name

    table_column['field_order_string']=field_order_string



def main(schema_name, table_name, ini_file, db_connection, target_schema_tag=None):
    global g_metadata


    params = configuration_load_ini(ini_file, 'generator',['dvpd_generator_directory'])

    # create all the source dependent names of the model
    pipeline_name = schema_name+"_"+table_name+"_px"
    if target_schema_tag is None:
        main_sattelite_name=table_name+"_"+table_name+"_px_sat"
        main_hub_name=table_name+"_hub"
        link_name = table_name+"_"+"bbbbbb_lnk"
        esat_name = table_name+"_"+"bbbbbb_esat"
    else:
        main_sattelite_name=target_schema_tag + "_aaaaaa__"+table_name+"_px_sat"
        main_hub_name=target_schema_tag + "_"+table_name+"_hub"
        link_name = table_name + "_" + "bbbbbb_lnk"
        esat_name = table_name + "_" + "bbbbbb_esat"

    main_hk_name="hk_"+main_hub_name[:-4]
    lk_name="lk_"+link_name[:-4]



    row_count=get_row_count( db_connection, schema_name, table_name)

    if row_count > SAMPLE_SIZE_LIMIT:
        row_count_sample=SAMPLE_SIZE_LIMIT
    else:
        row_count_sample = row_count


    g_metadata={'table_name':table_name,
               'schema_name':schema_name,
                'row_count':row_count}


    # get all columns

    table_columns=get_pg_table_column_list(db_connection,schema_name, table_name)
    g_metadata['table_columns']=table_columns

    #retrieve column statistics
    for table_column in table_columns:
        measure_null_values(table_column, db_connection, schema_name, table_name)
        measure_cardinality(table_column,db_connection,schema_name, table_name)
        table_column['duplicates']=row_count_sample-table_column['cardinality']
        determine_key_participation(table_column, db_connection, schema_name, table_name)
        render_field_order_string(table_column,row_count_sample)

    #print_g_metadata()


    # assemble final dvpd json
    dvpd=[]
    dvpd.append(    '{')
    dvpd.append('\t"dvpd_version": "0.6.2",')
    dvpd.append( f'\t"pipeline_name": "{pipeline_name}",')
    dvpd.append( '\t"stage_properties": [{"stage_schema": "stage_rvlt"}],')
    dvpd.append( f'\t"purpose": "Load from {schema_name}.{table_name} into raw vault",')
    dvpd.append( f'\t"record_source_name_expression": "{schema_name}.{table_name}",')
    dvpd.append( f'\t"analysis_full_row_count":{row_count},')
    dvpd.append( f'\t"analysis_sample_row_count":{row_count_sample},')
    dvpd.append( '\t"data_extraction": {')
    dvpd.append( '\t\t"fetch_module_name": "none - this is a pure ddl and documentation dvpd"')
    dvpd.append( '\t},')
    dvpd.append( '"fields":[')

    table_columns_sorted = sorted(table_columns, key=lambda d: d['field_order_string']   )

    max_column_name_length=0
    max_type_declaration_length=0
    for table_column in  table_columns_sorted:
        if len(table_column['field_name']) > max_column_name_length:
            max_column_name_length = len(table_column['field_name'])
        if len(table_column['field_type']) > max_type_declaration_length:
            max_type_declaration_length= len(table_column['field_type'])

    field_elements=[]
    field_order_group=table_columns_sorted[0]['field_order_string'][:3]
    first_field=True
    for table_column in  table_columns_sorted:
            if not table_column['field_order_string'].startswith(field_order_group): # add separator row for every group
                field_elements.append("")
                field_order_group=table_column['field_order_string'][:3]
            if first_field:
                field_element="\t {"
                first_field = False
            else:
                field_element="\t,{"
            field_name_string=f'"field_name":"{table_column["field_name"]}",'
            field_element +=f'{field_name_string.ljust(max_column_name_length+16)}'
            field_type_string=f'"field_type":"{table_column["field_type"].upper()}",'
            field_element +=f'{field_type_string.ljust(max_type_declaration_length+16)}'

            if field_order_group[0]=='0':  #  a primary key element
                field_element += '\t"targets":[{"table_name":"' + main_hub_name + '"}]'
            elif field_order_group[0:2]=='10':  # a foreign  key element will be assigned to second hub
                field_element += '\t"targets":[{"table_name":"bbbbbb_hub"}]'
            else:
                field_element+='\t"targets":[{"table_name":"'+main_sattelite_name+'"}]\t'
            for analytic_tag in ['is_primary_key','is_foreign_key','cardinality','duplicates','null_values']:
                field_element+=f',"{analytic_tag}":"{table_column[analytic_tag]}"'
            field_element+='}'
            field_elements.append(field_element)

    dvpd.append("\n".join(field_elements))
    dvpd.append('\t],') # end of fields array

    dvpd.append('	"data_vault_model": [')
    dvpd.append('		{"schema_name": "rvlt_xxxxxx"')
    dvpd.append('		, "tables": [')
    dvpd.append('				{"table_name": "'+main_hub_name+'"')
    dvpd.append('						,"table_stereotype": "hub"')
    dvpd.append('						,"hub_key_column_name": "'+main_hk_name+'"')
    dvpd.append('				}')
    dvpd.append('				,{"table_name": "'+main_sattelite_name+'"')
    dvpd.append('						,"table_stereotype": "sat"')
    dvpd.append('						,"satellite_parent_table": "'+main_hub_name+'"')
    dvpd.append(f'						,"diff_hash_column_name": "rh_'+main_sattelite_name+'"')
    dvpd.append('				}')
    dvpd.append('				,{"table_name": "bbbbbb_hub"')
    dvpd.append('						,"table_stereotype": "hub"')
    dvpd.append('						,"hub_key_column_name": "hk_bbbbbb"')
    dvpd.append('				}')
    dvpd.append('				,{"table_name": "'+link_name+'"')
    dvpd.append('						,"table_stereotype": "lnk"')
    dvpd.append('						,"link_key_column_name": "'+lk_name+'"')
    dvpd.append('						,"link_parent_tables": ["'+main_hub_name+'"')
    dvpd.append('											   ,"bbbbbb_hub"]')
    dvpd.append('				}')
    dvpd.append('				,{"table_name": "'+esat_name+'"')
    dvpd.append('						,"table_stereotype": "sat"')
    dvpd.append('						,"satellite_parent_table": "'+link_name+'"')
    dvpd.append('				}')
    dvpd.append('			]')
    dvpd.append('		}')
    dvpd.append('	]')
    dvpd.append('}')

    # write dvpd to file
    dvpd_generator_directory = Path(params['dvpd_generator_directory'])
    if not os.path.isdir(dvpd_generator_directory):
        print(f"creating dir: {dvpd_generator_directory}")
        dvpd_generator_directory.mkdir(parents=True)

    dvpd_filename=pipeline_name+".dvpd.json"
    dvpd_file_path =dvpd_generator_directory.joinpath(dvpd_filename)
    dvpd_text="\n".join(dvpd)
    with open(dvpd_file_path, 'w') as file:
        file.write(dvpd_text)

    # create human readable data profile report
    report=[]
    report.append(f'Data profile of "{schema_name}.{table_name}" at {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')
    report.append(80*'-')
    report.append( f'Table row count: {str(row_count).rjust(8)}')
    report.append( f'Sample row count:{str(row_count_sample).rjust(8)}')
    report.append('')


    report.append("Name".ljust(max_column_name_length)+ " PK  FK  Cardin.  duplic.  null cnt")
    for table_column in  table_columns_sorted:
        # ['is_primary_key','is_foreign_key','cardinality','duplicates','null_values']
        if table_column ['is_primary_key']:
            key_marker=" P  "
        else:
            key_marker = " .  "
        if table_column ['is_foreign_key']:
            key_marker+=" F  "
        else:
            key_marker+= " .  "
        measure_string=str(table_column ['cardinality']).rjust(8)
        measure_string+=str(table_column ['duplicates']).rjust(9)
        measure_string+=str(table_column ['null_values']).rjust(9)

        report.append(f"{table_column['field_name'].ljust(max_column_name_length)}{key_marker}{measure_string}")

    report_filename=pipeline_name+".data_profile.txt"
    report_file_path =dvpd_generator_directory.joinpath(report_filename)
    report_text="\n".join(report)
    with open(report_file_path, 'w') as file:
        file.write(report_text)

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
    parser.add_argument("--connection_ini_file", help="Name of the ini file with the source db connection properties", default='./connection_pg.ini')
    parser.add_argument("--connection_ini_section", help="Name of the section in the ini file to use", default='willibald_source')

    args = parser.parse_args()

    db_connection=pg_getConnection_via_inifile(args.connection_ini_file,args.connection_ini_section)


    main(schema_name=args.schema_name, table_name= args.table_name,
              ini_file=args.dvpdc_ini_file, db_connection=db_connection
                )

    print("--- generation of dvpd complete ---")
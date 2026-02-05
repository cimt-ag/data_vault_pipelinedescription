#!/usr/bin/env python310
# =====================================================================
# Part of the Data Vault Pipeline Description Reference Implementation
#
#  Copyright 2026 Matthias Wegner mattywausb@gmail.com
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

# Purpose: Render a sql statement, that stage the result of a table/view into a stage table
#          as declared by a dvpi file


import json
#import configparser
import os
import sys
import argparse
from pathlib import Path
import re

# Include data_vault_pipelinedescription folder into
project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from lib.configuration import configuration_load_ini

class MissingFieldError(Exception):
    def __init__(self, message):
        super().__init__(message)

output_file=None


def render_for_all_parsesets(dvpi_filepath, documentation_directory, stage_column_naming_rule='stage'):
    """
    Checks main requirements and creates files for every parse set and calls the rendering function
    """
    global  output_file

    # load the dvpi and check
    with open(dvpi_filepath, 'r') as file:
        dvpi = json.load(file)

    if 'parse_sets' not in dvpi:
        raise MissingFieldError("The keyword 'parse_sets' is missing in the DVPI.")
    parse_sets = dvpi.get('parse_sets', [])

    if 'data_extraction' not in dvpi:
        raise MissingFieldError("The keyword 'data_extraction' is missing in the DVPI.")
    data_extraction_ppt=dvpi['data_extraction']

    if 'fetch_module_name' not in data_extraction_ppt:
        raise MissingFieldError("The keyword 'data_extraction.fetch_module_name' is missing in the DVPI.")
    if data_extraction_ppt['fetch_module_name'] != 'transformation_view':
        print("Ignoring DVPI, since data extraction fetch module name is not 'transformation_view'")
        return 0

    if 'view_schema' not in data_extraction_ppt:
        raise MissingFieldError("The keyword 'data_extraction.view_schema' is missing in the DVPI.")
    if 'view_name'  not in data_extraction_ppt:
        raise MissingFieldError("The keyword 'data_extraction.view_name' is missing in the DVPI.")

    view_schema=data_extraction_ppt['view_schema']
    view_name = data_extraction_ppt['view_name']


    for parse_set in parse_sets:
        stage_table_name = parse_set['stage_properties'][0]['stage_table_name']
        report_file_name = "insert_" + view_name + "_to_" + stage_table_name +".sql"
        report_sheet_file_path = documentation_directory.joinpath(report_file_name)
        with open(report_sheet_file_path, "w") as output_file:
            render_insert_for_parse_set(output_file,parse_set,view_schema,view_name,stage_column_naming_rule)


def render_insert_for_parse_set(output_file,parse_set,view_schema,view_name,stage_column_naming_rule):

    if 'record_source_name_expression' not in parse_set:
        raise MissingFieldError("The keyword 'record_source_name_expression' is missing in the DVPI/parse_set.")
    record_source_expression=parse_set['record_source_name_expression']

    meta_column_expressions={'meta_load_date':'current_timestamp',
                             'meta_load_process_id':'-999',
                             'meta_record_source':record_source_expression,
                             'meta_deletion_flag': 'false'
                             }

    stage_table_name = parse_set['stage_properties'][0]['stage_table_name'] #todo: instead of [0] search for declaration of this platform (very late feature)
    stage_schema = parse_set['stage_properties'][0]['stage_schema'] #todo: instead of [0] search for declaration of this platform (very late feature)



    stage_columns = sorted(parse_set['stage_columns'],key=sortkey_of_stage_column)
    fields=parse_set['fields']


    column_name_to_stage_name_dict={}
    if stage_column_naming_rule=='combined':
        column_name_to_stage_name_dict=assemble_column_name_to_stage_name_dict(stage_columns)

    insert_columns = []  # in this array we collect the target column and select expression pairs

    for stage_column_ppt in stage_columns:
        stage_column_name = stage_column_ppt['stage_column_name']
        stage_column_class = stage_column_ppt['stage_column_class']

        if stage_column_class.startswith('meta'):
            if stage_column_class not in meta_column_expressions:
                raise AssertionError(f"unknown meta stage_column_class! '{stage_column_class}'")
            insert_column={'stage_column_name':stage_column_name,'select_expression':meta_column_expressions[stage_column_class]}
            insert_columns.append(insert_column)
            continue

        if stage_column_class=='hash':
            hash_definition=get_hash_definition_by_name(stage_column_ppt['hash_name'], parse_set['hashes'])
            if 'direct_key_field' in hash_definition:
                raise AssertionError(f"'hash' stage column '{stage_column_name}' references  a 'direct_key_field' hash. This is invalid.")
            hash_field_list_string=assemble_hash_field_list_string(hash_definition,fields)
            sql_expression=f"lib.DV_HASH(CONCAT_WS('{hash_definition['hash_concatenation_seperator']}'"+hash_field_list_string+"))"
            insert_column={'stage_column_name':stage_column_name,'select_expression':sql_expression}
            insert_columns.append(insert_column)
            continue


        if stage_column_class == 'data' or stage_column_class == 'direct_key':
            match stage_column_naming_rule:
                case 'stage':
                    final_column_name=stage_column_name
                case 'combined':
                    final_column_name=determine_combined_stage_column_name(stage_column_ppt,column_name_to_stage_name_dict)
                case _:
                    raise AssertionError(f"unknown stage_column_naming_rule! '{stage_column_naming_rule}'")
            insert_column = {'stage_column_name': final_column_name, 'select_expression': stage_column_ppt['field_name']}
            insert_columns.append(insert_column)
            continue

        raise AssertionError(f"unhandled column class during insert column collection")

    # >>>>>>>>>>  finally write the statement  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    output_file.write(f"-- vvvvv BEGIN OF GENERATED INSERT TO STAGE STATEMENT vvvvv \n\n")

    output_file.write(f"insert into {stage_schema}.{stage_table_name} (\n")

    column_list=[]
    expression_list = []
    for insert_column in insert_columns:
        column_list.append(insert_column['stage_column_name'])
        expression_list.append("\n"+insert_column['select_expression']+" AS "+insert_column['stage_column_name'])
    output_file.write(",\n".join(column_list))

    output_file.write("\n)\n") # Close insert column list

    output_file.write("select ")
    output_file.write(",".join(expression_list))
    output_file.write(f"from {view_schema}.{view_name};\n\n")

    output_file.write(f"-- ^^^^^ END OF GENERATED INSERT TO STAGE STATEMENT ^^^^^ \n\n")

def sortkey_of_stage_column(stage_column):
    stage_column_class_rank={
        'hash':'B',
        'direct_key':'C',
        'data':'D'
    }
    stage_column_class=stage_column['stage_column_class']
    if stage_column_class.startswith('meta'):
        return 'A_'+stage_column['stage_column_name']

    prefix=stage_column_class_rank.get(stage_column_class,'Z')
    return prefix+'_'+stage_column['stage_column_name']


def assemble_hash_field_list_string(hash_definition,fields):
    """Returns the comma separatedn hash member fields including all converions function wrappings"""

    timestamp_db_type_list=['TIMESTAMP','DATETIME']

    if hash_definition['column_class'] == 'key':
        hash_fields_sorted=sorted(hash_definition['hash_fields'], key=lambda d: "{:03d}".format(
            d.get('parent_declaration_position', 0)) + '_/_' + d['field_target_table'] + '_/_' + str(
            d['prio_in_key_hash']) + '_/_' + d['field_target_column'])
    else: # this is a diff hash
        hash_fields_sorted=sorted(hash_definition['hash_fields'],
                                    key=lambda d: '_' + str(d['prio_in_diff_hash']) + '_/_' + d[
                                        'field_target_column'])

    hash_timestamp_format_sqlstyle=hash_definition['hash_timestamp_format_sqlstyle']

    hash_field_expression_list=[]
    for hash_field in hash_fields_sorted: # rewrite hash_field into conversion expression depending on db type
        source_field=get_field_by_name(hash_field['field_name'],fields)
        if db_type_is_numerical(source_field['field_type']):
            hash_field_expression=f"cast({hash_field['field_name']} as varchar(40))"
        elif db_type_is_timestamp(source_field['field_type']):
            hash_field_expression = f"to_varchar({hash_field['field_name']},'{hash_timestamp_format_sqlstyle}')"
        elif db_type_is_time(source_field['field_type']):
            hash_field_expression = f"to_varchar({hash_field['field_name']},'HH24:MI:SS')"
        elif db_type_is_date(source_field['field_type']):
            hash_field_expression = f"to_varchar({hash_field['field_name']},'YYYY-MM-DD')"
        else:
            hash_field_expression=hash_field['field_name']
        hash_field_expression_list.append(hash_field_expression)


    return ','.join(hash_field_expression_list)

def db_type_is_numerical (db_type):
    numerical_db_type_list = ['DECIMAL', 'NUMBER', 'NUMERIC', 'INTEGER', 'FLOAT', 'DOUBLE PRECISION', 'MONEY']
    for type_to_search_for in numerical_db_type_list:
        if type_to_search_for in db_type:
            return True
    return False

def db_type_is_timestamp (db_type):
    timestamp_db_type_list=['TIMESTAMP','DATETIME']
    for type_to_search_for in timestamp_db_type_list:
        if type_to_search_for in db_type:
            return True
    return False

def db_type_is_date (db_type):
    db_type_list=['DATE']
    for type_to_search_for in db_type_list:
        if type_to_search_for in db_type:
            return True
    return False

def db_type_is_time (db_type):
    db_type_list=['TIME']
    for type_to_search_for in db_type_list:
        if type_to_search_for in db_type:
            return True
    return False

def get_field_by_name(field_name,fields):
    for field_ppt in fields:
        if field_ppt['field_name'] ==field_name:
            return field_ppt
    raise AssertionError(f"Could not find '{field_name}' in fields of DVPI")



def get_hash_definition_by_name(hash_name, hashes):
    for hash_definition in hashes:
        if hash_definition['hash_name']==hash_name:
            return hash_definition
    raise AssertionError(f"Could not find hash definition in DVPI for hash name '{hash_name}'")


def assemble_column_name_to_stage_name_dict(stage_columns):
    """Collect the stage names for every target column name
       This is needed to create the best target based stage column name
      ( This whole mechanic will later be moved into a dvpd preprocessor,
       so the rule must only be implemented once)"""
    column_name_to_stage_name_dict = {}
    for stage_column_ppt in stage_columns:
        stage_name = stage_column_ppt['stage_column_name']
        if 'targets' in stage_column_ppt:
            for target_entry in stage_column_ppt['targets']:
                column_name = target_entry['column_name']
                if column_name not in column_name_to_stage_name_dict:
                    column_name_to_stage_name_dict[column_name]=[stage_name]
                elif stage_name not in  column_name_to_stage_name_dict[column_name]:
                    column_name_to_stage_name_dict[column_name].append(stage_name)

    return column_name_to_stage_name_dict


def determine_combined_stage_column_name(stage_column,column_name_to_stage_name_dict):
    """
                Stage     Target     Result
    1:1         BK1  (1)  BK1   (1)  BK1

    1:1         BK2  (1)  BK2a  (1)  BK2a

    n:1         BK3a (1)  t.BK3 (2)  BK3_BK3a
                BK3b (1)  u.BK3 (2)  BK3_BK3b

    1:n         BK4  (2)  BK4a  (1)  BK4a_BK4b
                BK4  (2)  BK4b  (1)  BK4a_BK4b

    m:n         BK5a (2)  t.BK5 (2)  BK5a
                BK5b (2)  t.BK5 (2)  BK5b
                BK5a (2)  u.BK5 (2)
                BK5b (2)  u.BK5 (2)
    ( This whole mechanic will later be moved into a dvpd preprocessor,
       so the rule must only be implemented once)
    """
    if 'targets' not in stage_column: # no targest annotated
        return stage_column['stage_column_name']

    if len(stage_column['targets'])==0: # no targest annotated
        return stage_column['stage_column_name']

    stage_column_name=stage_column['stage_column_name']
    stage_targets = stage_column['targets']

    if len(stage_targets) == 1:  # stage column has only one target
        target_column_name = stage_targets[0]['column_name']
        if len(column_name_to_stage_name_dict[target_column_name]) == 1 or target_column_name==stage_column_name:    # target name is unique (1:1) or same
            final_column_name = target_column_name
        else:                                                          # different targets take same source (1:n)
            final_column_name = target_column_name+"__"+stage_column_name
    else:                                                              # stage column has multiple targets
        all_targets_have_single_source=True
        for target_column in stage_targets:
            if len(column_name_to_stage_name_dict[target_column['column_name']]) > 1:
                all_targets_have_single_source = False
                break
        if all_targets_have_single_source:                             # n:1
            target_column_names= []
            for target_column in stage_targets:
                if target_column['column_name'] not in target_column_names:
                   target_column_names.append(target_column['column_name'])
            final_column_name = "__".join(target_column_names)
        else:                                                          # m:n is not solvable, fall back to original field name
            final_column_name = stage_column_name

    return final_column_name



def get_name_of_youngest_dvpi_file(dvpi_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpi_default_directory):
        if not os.path. isfile(dvpi_default_directory+'/'+file_name):
            continue
        file_mtime=os.path.getmtime( dvpi_default_directory+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file

########################   MAIN ################################
if __name__ == '__main__':

    print("=== render insert stage from a view  ===")

    description_for_terminal = "Process dvpi at the given location to render a statement, that inserts data from a view into the stage table."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name',  help='Name the file to process. File must be in the configured dvpi_default_directory.Use @youngest to parse the youngest.')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--stage_column_naming_rule", help="Rule to use for stage column naming [stage,combined]", default='#notset#')
    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'rendering', ['dvpi_default_directory','insert_to_stage_from_a_view_directory'])

    if args.stage_column_naming_rule =='#notset#':
        stage_column_naming_rule=params.get('stage_column_naming_rule','stage')
    else:
        stage_column_naming_rule=args.stage_column_naming_rule

    dvpi_default_directory = Path(params['dvpi_default_directory'])
    insert_to_stage_from_a_view_directory = Path(params['insert_to_stage_from_a_view_directory'])

    # create target directory
    if not os.path.isdir(insert_to_stage_from_a_view_directory):
        print(f"creating dir: "+insert_to_stage_from_a_view_directory.name)
        insert_to_stage_from_a_view_directory.mkdir(parents=True)
    
    dvpi_file_name=args.dvpi_file_name
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")

    render_for_all_parsesets(dvpi_file_path, insert_to_stage_from_a_view_directory
                             , stage_column_naming_rule=stage_column_naming_rule)

    print("--- render insert stage from a view complete ---\n")

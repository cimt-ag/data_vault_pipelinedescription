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

def get_missing_number_for_digits(digits: int):
    result = '9'*digits
    return result

def get_missing_for_string_length(length:int = 13, must_be_fixed_length=False):
    result = '!#!missing!#!'
    if length < 13:
        result = '#' * length
    else:
        if must_be_fixed_length:
            result += ' ' * (length-13)
    return "'"+result+"'"

def create_ghost_records(full_name, columns):
    null_record_column_class_map = {'meta_load_process_id': '0',
                                    'meta_load_date': 'CURRENT_TIMESTAMP',
                                    'meta_record_source': "'SYSTEM'",
                                    'meta_deletion_flag': 'false',
                                    'meta_load_enddate': 'lib.far_future_date()',
                                    'key': 'lib.hash_key_for_delivered_null()',
                                    'parent_key': 'lib.hash_key_for_delivered_null()',
                                    'diff_hash': 'lib.hash_key_for_delivered_null()',
                                    'business_key': 'null',
                                    'dependent_child_key': 'null',
                                    'content': 'null',
                                    'content_untracked': 'null'}

    const_for_missing_map = {
                            'VARCHAR': '!#!missing!#!',
                            'CHAR': 'use_get_missing_for_string_length',
                            'TEXT': "'!#!missing!#!'",
                            'INT': '999999999',
                            'INTEGER': '999999999',
                            'SMALLINT': '9999',
                            'BIGINT': '999999999999999999',
                            'DECIMAL': 'use_get_missing_number_for_digits_function',
                            'NUMERIC': 'use_get_missing_number_for_digits_function',
                            'FLOAT': 'NaN',
                            'REAL': 'NaN',
                            'DOUBLE': 'NaN',
                            'BOOLEAN': 'null',
                            'DATE': '2998-11-30',
                            'DATETIME': '2998-11-30 00:00:00.000',
                            'TIMESTAMP': '2998-11-30 00:00:00.000',
                            'TIME': '00:00',
                            'BYTE': '-99'
                            }

    missing_record_column_class_map = {'meta_load_process_id': '0',
                                    'meta_load_date': 'CURRENT_TIMESTAMP',
                                    'meta_record_source': "'SYSTEM'",
                                    'meta_deletion_flag': 'true',
                                    'meta_load_enddate': 'lib.far_future_date()',
                                    'key': 'lib.hash_key_for_missing()',
                                    'parent_key': 'lib.hash_key_for_missing()',
                                    'diff_hash': 'lib.hash_key_for_missing()',
                                    'business_key': 'const_missing_data',
                                    'dependent_child_key': 'const_missing_data',
                                    'content': 'const_missing_data',
                                    'content_untracked': 'const_missing_data'}
    
    column_names = []
    values_for_null = []
    values_for_missing = []
    for column in columns:
        column_names.append(column['column_name'])
        column_class = column['column_class']
        values_for_null.append(null_record_column_class_map[column_class])
        value_for_missing = missing_record_column_class_map[column_class]
        if value_for_missing == 'const_missing_data': 
            column_type = column['column_type']
            # Extract the base SQL type and optional parameters
            match = re.match(r'(\w+)(?:\((\d+),?\s*(\d*)\))?', column_type)
            base_type, length, scale = match.groups()
            if scale == '':
                scale = None
            if length != None:
                length = int(length)
            if scale != None:
                scale = int(scale)
            base_type = base_type.upper()
            nullable = True if 'is_nullable' in column and column['is_nullable']==True else False
            value_for_missing = const_for_missing_map[base_type]
            # print(f'base_type: {base_type} | nullable: {nullable} | const_for_missing: {value_for_missing}\n')
            if nullable and base_type not in ['VARCHAR', 'TEXT', 'CHAR']:
                value_for_missing = 'NULL'
            else: # use const_for_missing_data
                if base_type == 'VARCHAR':
                    if length == None:
                        value_for_missing = get_missing_for_string_length()
                    else:
                        value_for_missing = get_missing_for_string_length(length)
                if base_type == 'CHAR':
                    if length == None:
                        value_for_missing = get_missing_for_string_length(1, True)
                    else:
                        value_for_missing = get_missing_for_string_length(length, True)
                if value_for_missing == 'use_get_missing_number_for_digits_function':
                    if length == None: 
                        value_for_missing = get_missing_number_for_digits(18)
                    else:
                        if scale == None or scale == '':
                            value_for_missing = get_missing_number_for_digits(length)
                        else:
                            value_for_missing = get_missing_number_for_digits(length - scale)
        

        values_for_missing.append(value_for_missing)

    ddl_start = "INSERT INTO {} (\n".format(full_name)
    ddl_start += ',\n'.join(column_names) +'\n) VALUES (\n'
    ddl_null = '-- Ghost Record for delivered NULL Data\n' + ddl_start + ',\n'.join(values_for_null) + '\n);'
    ddl_missing = '-- Ghost Record for missing data due to business rule\n' + ddl_start + ',\n'.join(values_for_missing) + '\n);'

    result = '\n\n' + ddl_null + '\n\n' + ddl_missing
    return result


def render_primary_key_clause(table):

    table_stereotype=table['table_stereotype']
    if table_stereotype in ('sat') and table['is_multiactive']:
        return ""  ## no pk for multiactive satellites

    pk_column_list=[]
    for column in table['columns']:
        column_class=column['column_class']
        if table_stereotype in ('hub', 'lnk') and column_class=='key':
            pk_column_list.append(column['column_name'])
        if table_stereotype == 'sat' and column_class in ('parent_key','meta_load_date'):
            pk_column_list.append(column['column_name'])

    ddl_text=""
    if len(pk_column_list)>0:
        full_name = "{}.{}".format(table['schema_name'], table['table_name'])
        pk_name= table['table_name']+"_PK"
        ddl_text= f"\n\nALTER TABLE {full_name} ADD CONSTRAINT {pk_name} PRIMARY KEY({','.join(pk_column_list)});"
    return ddl_text

def assemble_column_name_and_stage_name_dict(parse_set):
    """Collect the stage names for every target column name and vice versa over all load operations"""
    column_name_to_stage_name_dict = {}
    stage_name_to_column_name_dict ={}
    for load_operation in parse_set['load_operations']:
        if 'data_mapping' in load_operation:
            for column in load_operation['data_mapping']:
                column_name=column['column_name']
                stage_name=column['stage_column_name']
                if column_name not in column_name_to_stage_name_dict:
                    column_name_to_stage_name_dict[column_name]=[stage_name]
                elif stage_name not in  column_name_to_stage_name_dict[column_name]:
                    column_name_to_stage_name_dict[column_name].append(stage_name)
                if stage_name not in stage_name_to_column_name_dict:
                    stage_name_to_column_name_dict[stage_name]=[column_name]
                elif column_name not in stage_name_to_column_name_dict[stage_name]:
                    stage_name_to_column_name_dict[stage_name].append(column_name)

    return column_name_to_stage_name_dict,stage_name_to_column_name_dict

def assemble_stage_with_target_column_type_dict(parse_set,tables):
    stage_with_target_column_type_dict={}
    for stage_column in parse_set["stage_columns"]:
        if stage_column['stage_column_class'] != "data":
            continue
        table_name = None
        column_name = None
        for load_operation in parse_set['load_operations']:  # scan all operations for a mapping the current stage column
            if 'data_mapping' not in load_operation:
                continue
            for column_mapping in load_operation['data_mapping']:
                if column_mapping['stage_column_name']==stage_column['stage_column_name']:
                    table_name=load_operation['table_name']
                    column_name=column_mapping['column_name']
                    break
            if table_name != None:
                break
        # at this point we should have a hit, so search for the column type definition
        if table_name == None:
            raise Exception(f"Stage column '{stage_column['stage_column_name']}' is not mapped in any operation. This should not happen")
        column_type=None
        for table in tables:
            if table['table_name']==table_name:
                for column in table['columns']:
                    if column['column_name']==column_name: #gotcha
                        column_type=column['column_type']
                        break
                if column_type != None:
                    break
        stage_with_target_column_type_dict[stage_column['stage_column_name']]=column_type #finally we know

    return stage_with_target_column_type_dict


def determine_combined_stage_column_name(stage_column_name, stage_name_to_column_name_dict,
                                         column_name_to_stage_name_dict):
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
    """

    if len(stage_name_to_column_name_dict[stage_column_name]) == 1:    # stage column has only one target
        target_column_name = stage_name_to_column_name_dict[stage_column_name][0]
        if len(column_name_to_stage_name_dict[target_column_name]) == 1 or target_column_name==stage_column_name:    # target name is unique (1:1) or same
            final_column_name = target_column_name
        else:                                                          # different targets take same source (1:n)
            final_column_name = target_column_name+"__"+stage_column_name
    else:                                                              # stage column has multiple targets
        all_targets_have_single_source=True
        for target_column_name in stage_name_to_column_name_dict[stage_column_name]:
            if len(column_name_to_stage_name_dict[target_column_name]) > 1:
                all_targets_have_single_source = False
                break
        if all_targets_have_single_source:                             # n:1
            final_column_name = "__".join(stage_name_to_column_name_dict[stage_column_name])
        else:                                                          # m:n
            final_column_name = stage_column_name

    return final_column_name


def parse_json_to_ddl(filepath, ddl_render_path,add_ghost_records=False,add_primary_keys=True,stage_column_naming_rule='stage'):
    """creates all ddl scripts and stres them in files
    special parameter: stage column naming , field= use field name, when available, stage=use stagename (might create duplicates), combine=combine stage and field name, when different
    combined stage column mappings tries to name the stage column like the target column. To prevent using the same stage column name for different content
    the following scenarios are mitigated as follows:
    single stage column -> equally named target columns: use target column name
    single stage column -> multiple differently named target columns: use concatinated target column names
    multiple stage columns -> equally named target column(s): use target column name_append stage column name
    """
    with open(filepath, 'r') as file:
        data = json.load(file)

    # Check for missing fields
    if 'tables' not in data:
        raise MissingFieldError("The field 'tables' is missing in the DVPI.")
    
    if 'parse_sets' not in data:
        raise MissingFieldError("The field 'parse_sets' is missing in the DVPI.")

    # Extract tables and stage tables
    tables = data.get('tables', [])
    parse_sets = data.get('parse_sets', [])

    ddl_statements = []
    schema_count = {}
    schema_sats = {}

    # Generate DDL for tables
    for table in tables:
        # Check for missing fields 
        if 'schema_name' not in table:
            raise MissingFieldError("The field 'schema_name' is missing from the DVPI.")
        schema_name = table['schema_name']
        if schema_name in schema_count:
            schema_count[schema_name] += 1
        else:
            schema_count[schema_name] = 1
        
        table_stereotype = table['table_stereotype']
        if table_stereotype=='sat':
            if schema_name in schema_sats:
                schema_sats[schema_name] += 1
            else:
                schema_sats[schema_name] = 1

        if 'table_name' not in table:
            raise MissingFieldError("The field 'table_name' is missing from the DVPI.")
        table_name = table['table_name']

        full_name = "{}.{}".format(schema_name, table_name)
        columns = table['columns']
        # print(f"columns:\n{columns}")
        column_statements = []
        for column in columns:
            stage_column_name = column['column_name']
            col_type = column['column_type']
            nullable = "NULL" if 'is_nullable' in column and column['is_nullable']==True else "NOT NULL"
            comment = column['column_content_comment'] if 'column_content_comment' in column else None
            column_statement = "{} {} {}".format(stage_column_name, col_type, nullable)
            if comment is not None:
                column_statement = "{} COMMENT '{}'".format(column_statement, comment)
            column_statements.append(column_statement)
        column_statements = ',\n'.join(column_statements)

        table_comment = f"COMMENT='{table['table_comment']}'" if 'table_comment' in table else ''

        ddl = f"-- generated script for {full_name}"
        ddl += f"\n\n-- DROP TABLE {full_name};\n\nCREATE TABLE {full_name} {table_comment} (\n{column_statements}\n);"

        if add_primary_keys:
            ddl += render_primary_key_clause(table)

        if add_ghost_records:
            ddl += create_ghost_records(full_name, columns)

        ddl +="\n-- end of script --"

        ddl_statements.append(ddl)

        # create schema dir if not exists
        schema_path = ddl_render_path / schema_name
        if not os.path.isdir(schema_path):
            print(f"creating dir: {schema_path}")
            schema_path.mkdir(parents=True)
        
        # save ddl in directory
        table_ddl_path = schema_path / f"table_{table_name}.sql"
        print(table_ddl_path.stem)
        with open(table_ddl_path, 'w') as file:
          file.write(ddl)
        

    # Generate DDL for stage tables
    max_count = max(schema_count.values())
    # Identify all schemas with the maximum count
    schema_with_max_count = [schema for schema, count in schema_count.items() if count == max_count]
    stage_schema_dir = None
    if len(schema_with_max_count)==1:
        stage_schema_dir = schema_with_max_count[0]
    else:
        # Filter schema_sat to keep only schemas with max counts
        filtered_schemas = {key: schema_sats[key] for key in schema_sats if key in schema_with_max_count}
        stage_schema_dir = max(filtered_schemas, key=filtered_schemas.get)
    #print(f'stage_schema_dir: {stage_schema_dir}')


    for parse_set in parse_sets:
        stage_properties = parse_set['stage_properties']
        if len(stage_properties)==1:
            stage_properties = stage_properties[0]
            schema_name = stage_properties['stage_schema']
            table_name = stage_properties['stage_table_name']
            full_name = "{}.{}".format(schema_name, table_name)
        else:
            raise AssertionError("Currently only one stage properties object is supportet!")
            # TODO: implement this case     

        columns = parse_set['stage_columns']
        meta_load_date_column = None
        meta_load_process_id_column = None
        meta_record_source_column = None
        meta_deletion_flag_column = None
        hashkeys = []
        business_keys = []
        content = []
        content_untracked = []

        column_name_to_stage_name_dict={}
        stage_name_to_column_name_dict={}
        stage_with_target_column_type_dict={}
        if stage_column_naming_rule=='combined':
            column_name_to_stage_name_dict,stage_name_to_column_name_dict=assemble_column_name_and_stage_name_dict(parse_set)
            stage_with_target_column_type_dict=assemble_stage_with_target_column_type_dict(parse_set,tables)

        for column in columns:
            stage_column_name = column['stage_column_name']
            stage_column_class = column['stage_column_class']
            col_type=column['column_type']
            nullable = "NULL" if 'is_nullable' in column and column['is_nullable']==True else "NOT NULL"
            match stage_column_class:
                case 'meta_load_date':
                    meta_load_date_column = "{} {} {}".format(stage_column_name, col_type, nullable)
                case 'meta_load_process':
                    meta_load_date_column = "{} {} {}".format(stage_column_name, col_type, nullable)
                case 'meta_load_process_id':
                    meta_load_process_id_column = "{} {} {}".format(stage_column_name, col_type, nullable)
                case 'meta_record_source':
                    meta_record_source_column = "{} {} {}".format(stage_column_name, col_type, nullable)
                case 'meta_deletion_flag':
                    meta_deletion_flag_column = "{} {} {}".format(stage_column_name, col_type, nullable)
                case 'hash':
                    hashkeys.append("{} {} {}".format(stage_column_name, col_type, nullable))
                case 'data':
                    final_column_name=stage_column_name
                    match stage_column_naming_rule:
                        case 'stage':
                            final_column_name=stage_column_name
                        case 'combined':
                            final_column_name=determine_combined_stage_column_name(stage_column_name, stage_name_to_column_name_dict, column_name_to_stage_name_dict)
                            col_type=stage_with_target_column_type_dict[stage_column_name]
                        case _:
                            raise AssertionError(f"unknown stage_column_naming_rule! '{stage_column_naming_rule}'")

                    column_classes = column['column_classes']
                    if 'business_key' in column_classes or 'dependent_child_key' in column_classes:
                        business_keys.append("{} {} {}".format(final_column_name, col_type, nullable))
                    elif 'content_untracked' in column_classes:
                        content_untracked.append("{} {} {}".format(final_column_name, col_type, nullable))
                    elif 'content' in column_classes:
                        content.append("{} {} {}".format(final_column_name, col_type, nullable))
                    else:
                        raise AssertionError(f"unexpected column class! {column_classes} are currently not supported!")
            
        # sort the arrays of the stage columns
        hashkeys.sort()
        business_keys.sort()
        content.sort()
        content_untracked.sort()
        column_statements = [meta_load_date_column, meta_load_process_id_column, meta_record_source_column, meta_deletion_flag_column]
        column_statements = [item for item in column_statements if item is not None] 
        column_statements = ["--metadata"] + column_statements + ["--hash keys"] + hashkeys 
        if len(business_keys) > 0:
            column_statements += ["--business keys"] + business_keys
        if len(content_untracked) > 0:
            column_statements += ["--content untracked"] + content_untracked
        if len(content) > 0:
            column_statements += ["--content"] + content

        column_statements = ',\n'.join(column_statements)
        ddl = f"-- generated script for {full_name}"
        ddl += f"\n\n-- DROP TABLE {full_name};\n\nCREATE TABLE {full_name} (\n{column_statements}\n);"
        ddl += "\n-- end of script --"
        ddl_statements.append(ddl)

        # create schema dir if not  exists
        schema_path = ddl_render_path / stage_schema_dir / 'stage'
        if not os.path.isdir(schema_path):
            print(f"creating dir: {schema_path}")
            schema_path.mkdir()
        
        # save ddl in directory
        table_ddl_path = schema_path / f"table_{table_name}.sql"
        print(table_ddl_path.stem)
        with open(table_ddl_path, 'w') as file:
          file.write(ddl)

    return "\n\n".join(ddl_statements)


def get_name_of_youngest_dvpi_file(dvpi_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpi_default_directory):
        file_mtime=os.path.getmtime( dvpi_default_directory+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file

########################   MAIN ################################
if __name__ == '__main__':
    description_for_terminal = "Process dvpi at the given location to render the ddl statements."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name',  help='Name the file to process. File must be in the configured dvpi_default_directory.Use @youngest to parse the youngest.')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--print", help="print the generated ddl to the console",  action='store_true')
    parser.add_argument("--add_ghost_records", help="Add ghost record inserts to every script",  action='store_true')
    parser.add_argument("--no_primary_keys", help="omit rendering of primary key constraints ",  action='store_true')
    parser.add_argument("--stage_column_naming_rule", help="Rule to use for stage column naming [stage,combined]", default='#notset#')
    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'rendering', ['ddl_root_directory', 'dvpi_default_directory'])

    if args.stage_column_naming_rule =='#notset#':
        stage_column_naming_rule=params.get('stage_column_naming_rule','stage')
    else:
        stage_column_naming_rule=args.stage_column_naming_rule

    if args.no_primary_keys == False:
        no_primary_keys=params.get('no_primary_keys',False) == ('True' or 'true')
        
    else:
        no_primary_keys=args.no_primary_keys

    ddl_render_path = Path(params['ddl_root_directory'], fallback=None)
    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)
    
    dvpi_file_name=args.dvpi_file_name
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")

    ddl_output = parse_json_to_ddl(dvpi_file_path, ddl_render_path
                                        , add_ghost_records=args.add_ghost_records
                                        , add_primary_keys=not no_primary_keys
                                   , stage_column_naming_rule=stage_column_naming_rule)
    if args.print:
        print(ddl_output)

    print("--- ddl render complete ---")

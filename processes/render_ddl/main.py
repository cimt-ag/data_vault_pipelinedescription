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

# global dictionaries
g_model_profile_dict={}
g_current_model_profile=None

class MissingFieldError(Exception):
    def __init__(self, message):
        super().__init__(message)

class DeclarationError(Exception):
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

def format_sqlsnippet(original):
    if original[0] == '$' and original[-1:] == '$':
        result = original.replace('$', '')
    else:
        result = "'" + original + "'"
    return result
def create_ghost_records(full_name, columns):



    far_future_timestamp_sqlsnippet = format_sqlsnippet(g_current_model_profile['far_future_timestamp'])
    key_for_null_ghost_record_sqlsnippet= format_sqlsnippet(g_current_model_profile['key_for_null_ghost_record'])
    key_for_missing_ghost_record_sqlsnippet = format_sqlsnippet(g_current_model_profile['key_for_missing_ghost_record'])


    null_record_column_class_map = {'meta_load_process_id': '0',
                                    'meta_load_date': 'CURRENT_TIMESTAMP',
                                    'meta_record_source': "'SYSTEM'",
                                    'meta_deletion_flag': 'false',
                                    'meta_load_enddate': far_future_timestamp_sqlsnippet,
                                    'key':key_for_null_ghost_record_sqlsnippet,
                                    'parent_key': key_for_null_ghost_record_sqlsnippet,
                                    'diff_hash': key_for_null_ghost_record_sqlsnippet,
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
                            'FLOAT': '9999999.999999',
                            'REAL': '9999999.999999',
                            'DOUBLE': '9999999.999999',
                            'BOOLEAN': 'null',
                            'DATE': "'2998-11-30'",
                            'DATETIME': "'2998-11-30 00:00:00.000'",
                            'TIMESTAMP': "'2998-11-30 00:00:00.000'",
                            'TIME': "'00:00:000'",
                            'BYTE': '-99',
                            'JSON': '\'{ "!#!missing!#!": "missing" }\''
                            }

    missing_record_column_class_map = {'meta_load_process_id': '0',
                                    'meta_load_date': 'CURRENT_TIMESTAMP',
                                    'meta_record_source': "'SYSTEM'",
                                    'meta_deletion_flag': 'true',
                                    'meta_load_enddate':  far_future_timestamp_sqlsnippet,
                                    'key': key_for_missing_ghost_record_sqlsnippet,
                                    'parent_key': key_for_missing_ghost_record_sqlsnippet,
                                    'diff_hash': key_for_missing_ghost_record_sqlsnippet,
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
        if table_stereotype == 'sat' and column_class in ('parent_key'):
            pk_column_list.append(column['column_name'])

    if table_stereotype == 'sat':      # for satellite we add the meta load date as PK second element
        for column in table['columns']:
            if column['column_class'] in ('meta_load_date'):
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

        if 'data_mapping' in load_operation:        # collect the mappings from the data_mappings
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

        for column in load_operation['hash_mappings']: # collect the mappings from the hash_mappings
            if not 'field_name' in column:             # where the hash is provided by a source field
                continue
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


def assemble_stage_with_target_column_type_dict(parse_set,tables, use_target_column_type):
    stage_with_target_column_type_dict={}
    for stage_column in parse_set["stage_columns"]:
        if stage_column['stage_column_class'] != "data":
            continue
        table_name = None
        column_name = None
        for load_operation in parse_set['load_operations']:  # scan all operations for a mapping the current stage column
            for column_mapping in load_operation['hash_mappings']:
                if column_mapping['stage_column_name']==stage_column['stage_column_name']:
                    table_name=load_operation['table_name']
                    column_name=column_mapping['column_name']
                    break
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


def guess_and_pinpoint_model_profile(dvpi):
    """Guess the model profile from the model profile comment in the hashes and 
    set the global model_profile to point to it.
    This is not the final design, but currently the only one to implement profile specific ghost record value rendering"""

    global g_current_model_profile
    g_current_model_profile=None # when no hashes are in the parse set, there will be no need for ghost records and this should not lead to an error

    for parse_set in dvpi['parse_sets']:
        if 'hashes' not in parse_set:
            continue
        for hash_definition in parse_set['hashes']:
            if hash_definition['model_profile_name'] not in g_model_profile_dict:
                raise DeclarationError(f"Declared model_profile '{hash_definition['model_profile_name']}' is unknown")
            g_current_model_profile=g_model_profile_dict[hash_definition['model_profile_name']]
            return


def target_column_type_in_stage(parse_set):
    """
    Checks if a stage column maps to more than one column type in target tables.
    """
    for stage_column in parse_set["stage_columns"]:
        if stage_column["stage_column_class"] != "data":
            continue

        target_types = set()
        for target in stage_column.get("targets", []):
            target_types.add(target["column_type"])

        if len(target_types) > 1:
            print(
                f"TCTS-01: Stage column '{stage_column['stage_column_name']}' maps to multiple types: {target_types}")
            return False

    return True


def parse_json_to_ddl(filepath, ddl_render_path
                      , add_ghost_records=False
                      , add_primary_keys=True
                      , stage_column_naming_rule='stage'
                      , ddl_file_naming_pattern='lll'
                      , ddl_stage_directory_name='stage'
                      , use_target_column_type_in_stage=False):
    """creates all ddl scripts and stores them in files
    special parameter: stage column naming , field= use field name, when available, stage=use stagename (might create duplicates), combine=combine stage and field name, when different
    combined stage column mappings tries to name the stage column like the target column. To prevent using the same stage column name for different content
    the following scenarios are mitigated as follows:
    single stage column -> equally named target columns: use target column name
    single stage column -> multiple differently named target columns: use concatenated target column names
    multiple stage columns -> equally named target column(s): use target column name_append stage column name
    """
    with open(filepath, 'r') as file:
        data = json.load(file)

    # Check for missing fields
    if 'tables' not in data:
        raise MissingFieldError("The field 'tables' is missing in the DVPI.")

    if 'parse_sets' not in data:
        raise MissingFieldError("The field 'parse_sets' is missing in the DVPI.")

    for parse_set in data['parse_sets']:
        if not target_column_type_in_stage(parse_set):
            print("Can not use target column type for stage")
            exit(5)

    print("No column type conflicts detected. Proceeding with DDL generation.")

    guess_and_pinpoint_model_profile(data)
    # todo this needs more precision later, since model profile can be table specific. Depends on more precision in dvpi

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
        if table_stereotype == 'sat':
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
        comment_statements = []

        max_name_length = 0
        for column in columns:
            if len(column['column_name']) > max_name_length:
                max_name_length = len(column['column_name'])

        for column in columns:
            column_name = column['column_name']
            col_type = column['column_type']
            nullable = "NULL" if 'is_nullable' in column and column['is_nullable'] == True else "NOT NULL"
            comment = column['column_content_comment'] if 'column_content_comment' in column else None
            column_statement = "\t{}\t{}\t{}".format(column_name.ljust(max_name_length), col_type.ljust(15), nullable)
            column_statements.append(column_statement)
            if comment is not None:
                comment_statements.append(
                    "COMMENT ON COLUMN {}.{}.{} IS '{}';".format(schema_name, table_name, column_name, comment))

        column_statements = ',\n'.join(column_statements)
        if 'table_comment' in table:
            comment_statements.insert(0, f"COMMENT ON TABLE {schema_name}.{table_name} IS '{table['table_comment']}';")

        comment_statements = '\n'.join(comment_statements)

        ddl = f"-- generated script for {full_name}"
        ddl += f"\n\n-- DROP TABLE {full_name};\n\nCREATE TABLE {full_name} (\n{column_statements}\n);\n\n--COMMENT STATEMENTS\n{comment_statements}"

        if add_primary_keys:
            ddl += render_primary_key_clause(table)

        if add_ghost_records and table_stereotype != 'ref':
            ddl += create_ghost_records(full_name, columns)

        ddl += "\n-- end of script --"

        ddl_statements.append(ddl)

        # create schema dir if not exists
        schema_path = ddl_render_path / schema_name
        if not os.path.isdir(schema_path):
            print(f"creating dir: {schema_path}")
            schema_path.mkdir(parents=True)

        # save ddl in directory
        table_ddl_path = schema_path / f"table_{table_name}.sql"
        if ddl_file_naming_pattern == 'lUl':
            table_ddl_path = schema_path / f"table_{table_name.upper()}.sql"
        print(table_ddl_path.name)
        with open(table_ddl_path, 'w') as file:
            file.write(ddl)

    # Generate DDL for stage tables
    max_count = max(schema_count.values())
    # Identify all schemas with the maximum count
    schema_with_max_count = [schema for schema, count in schema_count.items() if count == max_count]
    stage_schema_dir = None
    if len(schema_with_max_count) == 1:
        stage_schema_dir = schema_with_max_count[0]
    else:
        # Filter schema_sat to keep only schemas with max counts
        filtered_schemas = {key: schema_sats[key] for key in schema_sats if key in schema_with_max_count}
        stage_schema_dir = max(filtered_schemas, key=filtered_schemas.get)
    # print(f'stage_schema_dir: {stage_schema_dir}')

    for parse_set in parse_sets:
        stage_properties = parse_set['stage_properties']
        if len(stage_properties) == 1:
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
        column_statements = []
        column_name_to_stage_name_dict = {}
        stage_name_to_column_name_dict = {}
        stage_with_target_column_type_dict = {}
        if stage_column_naming_rule == 'combined':
            column_name_to_stage_name_dict, stage_name_to_column_name_dict = assemble_column_name_and_stage_name_dict(
                parse_set)
            stage_with_target_column_type_dict = assemble_stage_with_target_column_type_dict(parse_set, tables)

        max_name_length = 0
        for column in columns:
            if len(column['stage_column_name']) > max_name_length:
                max_name_length = len(column['stage_column_name'])

        for column in columns:
            stage_column_name = column['stage_column_name']
            stage_column_class = column['stage_column_class']
            col_type = column['column_type']

            if use_target_column_type_in_stage and 'targets' in column and column['targets']:
                target_types = [target['column_type'] for target in column['targets']]
                col_type = target_types[0]  # Get the first (and only) target column type

            nullable = "NULL" if 'is_nullable' in column and column['is_nullable'] == True else "NOT NULL"
            match stage_column_class:
                case 'meta_load_date':
                    meta_load_date_column = "\t{}\t{}\t{}".format(stage_column_name.ljust(max_name_length),
                                                                  col_type.ljust(15), nullable)
                case 'meta_load_process':
                    meta_load_date_column = "\t{}\t{}\t{}".format(stage_column_name.ljust(max_name_length),
                                                                  col_type.ljust(15), nullable)
                case 'meta_load_process_id':
                    meta_load_process_id_column = "\t{}\t{}\t{}".format(stage_column_name.ljust(max_name_length),
                                                                        col_type.ljust(15), nullable)
                case 'meta_record_source':
                    meta_record_source_column = "\t{}\t{}\t{}".format(stage_column_name.ljust(max_name_length),
                                                                      col_type.ljust(15), nullable)
                case 'meta_deletion_flag':
                    meta_deletion_flag_column = "\t{}\t{}\t{}".format(stage_column_name.ljust(max_name_length),
                                                                      col_type.ljust(15), nullable)
                case 'hash':
                    hashkeys.append(
                        "\t{}\t{}\t{}".format(stage_column_name.ljust(max_name_length), col_type.ljust(15), nullable))
                case 'data':
                    final_column_name = stage_column_name
                    match stage_column_naming_rule:
                        case 'stage':
                            final_column_name = stage_column_name
                        case 'combined':
                            final_column_name = determine_combined_stage_column_name(stage_column_name,
                                                                                     stage_name_to_column_name_dict,
                                                                                     column_name_to_stage_name_dict)
                            col_type = stage_with_target_column_type_dict[stage_column_name]
                        case _:
                            raise AssertionError(f"unknown stage_column_naming_rule! '{stage_column_naming_rule}'")

                    column_classes = column['column_classes']
                    ddl_column_line = "\t{}\t{}\t{}".format(final_column_name.ljust(max_name_length),
                                                            col_type.ljust(15), nullable)
                    if 'parent_key' in column_classes:
                        hashkeys.append(ddl_column_line)
                    elif 'business_key' in column_classes or 'dependent_child_key' in column_classes:
                        business_keys.append(ddl_column_line)
                    elif 'content_untracked' in column_classes:
                        content_untracked.append(ddl_column_line)
                    elif 'content' in column_classes:
                        content.append(ddl_column_line)
                    else:
                        raise AssertionError(f"unexpected column class! {column_classes} are currently not supported!")

        # sort the arrays of the stage columns
        hashkeys.sort()
        business_keys.sort()
        content.sort()
        content_untracked.sort()
        column_statements = [meta_load_date_column, meta_load_process_id_column, meta_record_source_column,
                             meta_deletion_flag_column]
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
        schema_path = ddl_render_path / stage_schema_dir / ddl_stage_directory_name
        if not os.path.isdir(schema_path):
            print(f"creating dir: {schema_path}")
            schema_path.mkdir()

        # save ddl in directory
        table_ddl_path = schema_path / f"table_{table_name}.sql"
        if ddl_file_naming_pattern == 'lUl':
            table_ddl_path = schema_path / f"table_{table_name.upper()}.sql"
        print(table_ddl_path.name)
        with open(table_ddl_path, 'w') as file:
            file.write(ddl)

    return "\n\n".join(ddl_statements)


def get_name_of_youngest_dvpi_file(dvpi_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpi_default_directory):
        if not os.path. isfile( dvpi_default_directory+'/'+file_name):
            continue
        file_mtime=os.path.getmtime( dvpi_default_directory+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file

def search_for_dvpifile_of_test(testnumber):
    params = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpd_model_profile_directory'])
    dvpi_directory = Path(params['dvpi_default_directory'])

    fileprefix="t{:04d}".format(int(testnumber))

    for file in sorted(dvpi_directory.iterdir()):
        if (file.is_file()
            and file.stem.startswith(fileprefix)):
            return file.name

    return None


def load_model_profiles(full_directory_name):
    """Runs through model profile files and tries to load them"""
    directory = Path(full_directory_name)

    name_pattern_matcher=re.compile(".+profile.json$")
    for file in directory.iterdir():
          if file.is_file() and os.path.getsize(file) != 0 and name_pattern_matcher.match(Path(file).name):
                add_model_profile_file(file)


def add_model_profile_file(file_to_process: Path):
    """Parses one model profile file, validates it and adds it to the internal dictionary"""
    global g_model_profile_dict

    file_name=file_to_process.name

    #todo add all mandatory keywords
    mandatory_keys=['model_profile_name','table_key_column_type','table_key_hash_function','table_key_hash_encoding','hash_concatenation_seperator']

    try:
        with open(file_to_process, "r") as dvpd_model_profile_file:
            model_profile_object=json.load(dvpd_model_profile_file)
    except json.JSONDecodeError as e:
        print("WARNING: JSON Parsing error of file "+ file_to_process.as_posix())
        print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        print("Model profile will not be available")
        return

    for mandatory_keyword in mandatory_keys:
        if mandatory_keyword not in model_profile_object:
            raise MissingFieldError( f"'model profile in file '{file_name}' is missing keyword '{mandatory_keyword}'")


    model_profile_name=model_profile_object['model_profile_name']
    model_profile_object['model_profile_file_name']=file_name
    if model_profile_name not in g_model_profile_dict:
        g_model_profile_dict[model_profile_name]=model_profile_object
    else:
        if file_name != g_model_profile_dict[model_profile_name]['model_profile_file_name']:
            raise DeclarationError("duplicate declaration of model profile '{0}' in '{1}'. Already read from '{2}'".format(model_profile_name,file_name,g_model_profile_dict[model_profile_name]['model_profile_file_name']))


########################   MAIN ################################
if __name__ == '__main__':
    description_for_terminal = "Process dvpi at the given location to render the ddl statements."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name',  help='Name the file to process. File must be in the configured dvpi_default_directory.Use @youngest to parse the youngest. @t<number> to use a test result file starting')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--print", help="print the generated ddl to the console",  action='store_true')
    parser.add_argument("--add_ghost_records", help="Add ghost record inserts to every script",  action='store_true')
    parser.add_argument("--no_primary_keys", help="omit rendering of primary key constraints ",  action='store_true')
    parser.add_argument("--stage_column_naming_rule", help="Rule to use for stage column naming [stage,combined]", default='#notset#')
    parser.add_argument("--ddl_file_naming_pattern", choices=['lll', 'lUl'], default='lll'
                            ,help="Define the pattern of the file names. Currently possible patterns. 'lll' all name parts lower case (default). 'lUl' only table name in upper case")
    parser.add_argument("--model_profile_directory",help="Name of the model profile directory")
    parser.add_argument("--use_target_column_type_in_stage", help="Use target column type in stage table",
                        action="store_true")

    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'rendering', ['ddl_root_directory', 'dvpi_default_directory'])

    if args.stage_column_naming_rule =='#notset#':
        stage_column_naming_rule=params.get('stage_column_naming_rule','stage')
    else:
        stage_column_naming_rule=args.stage_column_naming_rule

    ddl_stage_directory_name=params.get('ddl_stage_directory_name','stage')

    if args.no_primary_keys == False:
        no_primary_keys=params.get('no_primary_keys',False) == ('True' or 'true')
        
    else:
        no_primary_keys=args.no_primary_keys

    ddl_render_path = Path(params['ddl_root_directory'], fallback=None)
    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)

    if args.model_profile_directory==None:
        load_model_profiles(params['dvpd_model_profile_directory'])
    else:
        load_model_profiles(args.model_profile_directory)
    
    dvpi_file_name=args.dvpi_file_name
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")
    if dvpi_file_name[:2]=='@t':
        testnumber=dvpi_file_name[2:]
        dvpi_file_name=search_for_dvpifile_of_test(testnumber)
        if dvpi_file_name is None:
            raise Exception(f"Could not find test file for testnumber {testnumber}")

    print("=== ddl render ===")
    print("Reading dvpi file '"+dvpi_file_name+"'\n")
    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")
    print("Generating ddl files:")
    print(f"Option use_target_column_type_in_stage set to {args.use_target_column_type_in_stage}")
    ddl_output = parse_json_to_ddl(dvpi_file_path, ddl_render_path
                                        , add_ghost_records=args.add_ghost_records
                                        , add_primary_keys=not no_primary_keys
                                   , stage_column_naming_rule=stage_column_naming_rule
                                   , ddl_file_naming_pattern=args.ddl_file_naming_pattern
                                   ,ddl_stage_directory_name=ddl_stage_directory_name
                                   ,use_target_column_type_in_stage=args.use_target_column_type_in_stage)
    if args.print:
        print(ddl_output)
    print("--- ddl render complete ---\n")

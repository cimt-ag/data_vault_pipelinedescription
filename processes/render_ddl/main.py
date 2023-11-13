import json
import configparser
import os
import argparse
from pathlib import Path
import re

class MissingFieldError(Exception):
    def __init__(self, message):
        super().__init__(message)

def get_missing_number_for_digits(digits: int):
    result = '-'
    result += '9'*digits
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
                                    'meta_load_date': 'NOW()',
                                    'meta_record_source': "'SYSTEM'",
                                    'meta_deletion_flag': 'false',
                                    'meta_load_enddate': 'lib.get_far_future_date()',
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
                            'INT': '-999999999',
                            'INTEGER': '-999999999',
                            'SMALLINT': '-9999',
                            'BIGINT': '-999999999999999999',
                            'DECIMAL': 'use_get_missing_number_for_digits_function',
                            'NUMERIC': 'use_get_missing_number_for_digits_function',
                            'FLOAT': 'NaN',
                            'REAL': 'NaN',
                            'DOUBLE': 'NaN',
                            'BOOLEAN': 'false',
                            'DATE': 'lib.get_is_missing_date()',
                            'DATETIME': 'lib.get_is_missing_date()',
                            'TIMESTAMP': 'lib.get_is_missing_date()',
                            'TIME': '00:00',
                            }

    missing_record_column_class_map = {'meta_load_process_id': '0',
                                    'meta_load_date': 'NOW()',
                                    'meta_record_source': "'SYSTEM'",
                                    'meta_deletion_flag': 'true',
                                    'meta_load_enddate': 'lib.get_far_future_date()',
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

    ddl_start = "INSERT INTO {} {{\n".format(full_name)
    ddl_start += ',\n'.join(column_names) +'\n} VALUES {\n'
    ddl_null = '-- Ghost Record for delivered NULL Data\n' + ddl_start + ',\n'.join(values_for_null) + '\n}'
    ddl_missing = '-- Ghost Record for missing data due to business rule\n' + ddl_start + ',\n'.join(values_for_missing) + '\n}'

    result = '\n\n' + ddl_null + '\n\n' + ddl_missing
    return result
        



def parse_json_to_ddl(filepath, ddl_render_path):
    with open(filepath, 'r') as file:
        data = json.load(file)

    # Check for missing fields
    if 'tables' not in data:
        raise MissingFieldError("The field 'tables' is missing from the JSON.")
    
    if 'parse_sets' not in data:
        raise MissingFieldError("The field 'parse_sets' is missing from the JSON.")

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
            raise MissingFieldError("The field 'schema_name' is missing from the JSON.")
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
            raise MissingFieldError("The field 'table_name' is missing from the JSON.")
        table_name = table['table_name']

        full_name = "{}.{}".format(schema_name, table_name)
        columns = table['columns']
        # print(f"columns:\n{columns}")
        column_statements = []
        for column in columns:
            col_name = column['column_name']
            col_type = column['column_type']
            nullable = "NULL" if 'is_nullable' in column and column['is_nullable']==True else "NOT NULL"
            column_statements.append("{} {} {}".format(col_name, col_type, nullable))
        column_statements = ',\n'.join(column_statements)
        ddl = f"-- DROP TABLE {full_name}\n\nCREATE TABLE {full_name} (\n{column_statements}\n);"
        
        ddl += create_ghost_records(full_name, columns)
        ddl_statements.append(ddl)

        # create schema dir if not exists
        schema_path = ddl_render_path / schema_name
        if not os.path.isdir(schema_path):
            print(f"creating dir: {schema_path}")
            schema_path.mkdir()
        
        # save ddl in directory
        table_ddl_path = schema_path / f"{table_name}.sql"
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
    print(f'stage_schema_dir: {stage_schema_dir}')


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
        column_statements = []
        for column in columns:
            col_name = column['stage_column_name']
            col_type = column['column_type']
            nullable = "NULL" if 'is_nullable' in column and column['is_nullable']==True else "NOT NULL"
            column_statements.append("{} {} {}".format(col_name, col_type, nullable))
        column_statements = ',\n'.join(column_statements)
        ddl = f"-- DROP TABLE {full_name}\n\nCREATE TABLE {full_name} (\n{column_statements}\n);"
        ddl_statements.append(ddl)

        # create schema dir if not  exists
        schema_path = ddl_render_path / stage_schema_dir / 'stage'
        if not os.path.isdir(schema_path):
            print(f"creating dir: {schema_path}")
            schema_path.mkdir()
        
        # save ddl in directory
        table_ddl_path = schema_path / f"{table_name}.sql"
        with open(table_ddl_path, 'w') as file:
          file.write(ddl)

    return "\n\n".join(ddl_statements)


if __name__ == '__main__':
    config = configparser.ConfigParser()
    # Ensuring the keys are read in a case_sensitive manner
    config.optionxform = str
    # Configuration File is hard-coded, as it should only be configured once - change according to your environment!
    config.read("/home/joscha/data_vault_pipelinedescription/config/dvpdc.ini")
    ddl_render_path = Path(config.get('dvpi_render', 'ddl_render_path', fallback=None))
    
    parser = argparse.ArgumentParser(description='Process dvpi at the given location to render the ddl statmenets.')
     # Define the filepath argument, set a default, and provide a helpful description.
    parser.add_argument('dvpi_path', nargs='?', default="/home/joscha/data_vault_pipelinedescription/testset_and_examples/reference/test20_simple_hub_sat.dvpi.json", help='Path to the file to process. Defaults to "/home/joscha/data_vault_pipelinedescription/testset_and_examples/reference/test20_simple_hub_sat.dvpi.json" if not provided.')
    
    args = parser.parse_args()

    if args.dvpi_path == "/home/joscha/data_vault_pipelinedescription/testset_and_examples/reference/test20_simple_hub_sat.dvpi.json":
        print("Warning: No filepath provided. Using default filepath.")
    
    filepath = ""
    ddl_output = parse_json_to_ddl(args.dvpi_path, ddl_render_path)
    print(ddl_output)

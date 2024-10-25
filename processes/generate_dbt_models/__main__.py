import json
import yaml
import os
import argparse
from pathlib import Path
import sys
import re

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)
from lib.configuration import configuration_load_ini

def extract_yaml_metadata_from_file(filepath):
    # read the file
    with open(filepath, 'r') as file:
        content = file.read()

    # Use regex to find the ddaml_metadata block
    match = re.search(r'{%- set yaml_metadata -%}\n(.*?)\n{%- endset -%}', content, re.DOTALL)
    if match:
        yaml_content = match.group(1)
        # Parse YAML content
        yaml_metadata = yaml.safe_load(yaml_content)
        return yaml_metadata
    else:
        raise ValueError("yaml_metadata block not found in the SQL file")

def write_model_to_file(output_path, model_content):
    directory = os.path.dirname(output_path)
    os.makedirs(directory, exist_ok=True)


    print(f"Writing model to file: {output_path}")
    # Write the model content to the output file
    with open(output_path, 'w') as output_file:
        output_file.write(model_content)
    
    print(f"Model file generated: {output_path}")

def generate_stage_model(parse_set, output_directory) -> str:
    stage_properties = parse_set.get('stage_properties', [{}])[0]
    stage_schema = stage_properties.get('stage_schema')
    stage_table_name = stage_properties.get('stage_table_name')
    record_source = parse_set.get('record_source_name_expression')
    # Assumption is, that a source model is defined according to the record source name
    source_name, source_table_name = record_source.split('.')
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, stage_schema)
    output_file_name = f"{stage_table_name}.sql"
    output_path = os.path.join(output_directory, output_file_name)

    print(f"Generating stage model for table: {stage_table_name}, schema: {stage_schema}")

    config = ["materialized='view'", f"schema='{stage_schema}'"]
    config = ', '.join(config)

    yaml_dict = {'hashed_columns': {}}

    yaml_dict['ldts'] = "'2022-03-11'::timestamp"
    yaml_dict['rsrc'] = '!' + record_source
    yaml_dict['source_model'] = {source_name: source_table_name}

    # Extract hashes from parse_set
    # We assume that the business keys are given in the order they should be concatenated 
    # -> Any logic regarding order must be implemented in the DVPDC!

    for hash_item in parse_set.get('hashes'):
        hash_name = hash_item.get('stage_column_name')
        hash_fields = hash_item.get('hash_fields', [])
        field_names = [field['field_name'] for field in hash_fields]

        if hash_item.get('column_class') == 'diff_hash':
            yaml_dict['hashed_columns'][hash_name] = {
                'is_hashdiff': True
                , 'columns': field_names
            }            
        else: 
            yaml_dict['hashed_columns'][hash_name] = field_names

    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for stage
    model_content = f"""
{{{{ config({config}) }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.stage(source_model=metadata_dict.get('source_model')
                        , ldts=metadata_dict.get('ldts')
                        , rsrc=metadata_dict.get('rsrc')
                        , hashed_columns=metadata_dict.get('hashed_columns') )}}}}
"""

    write_model_to_file(output_path, model_content)
    return stage_table_name

def generate_datavault4dbt_model(dvpi_path, model_dir, write_mode):
    # Load JSON data from the input file
    with open(dvpi_path, 'r') as file:
        data = json.load(file)

    # Generate stage model first
    parse_set = data.get('parse_sets')[0]
    stage_model_name = generate_stage_model(parse_set, model_dir)
    load_operations = parse_set.get('load_operations')
    

    # Iterate over tables in the JSON
    tables = data.get('tables', [])
    print(f"Found {len(tables)} tables to generate models for.")
    for table in tables:
        table_name = table.get('table_name')
        schema_name = table.get('schema_name', 'public')
        table_stereotype = table.get('table_stereotype')

        print(f"Processing table: {table_name}, schema: {schema_name}, stereotype: {table_stereotype}")

        if table_stereotype == "hub":
            generate_hub_model(table, schema_name, model_dir, stage_model_name, load_operations)
#        elif table_stereotype == "sat":
#            generate_sat_model(table, schema_name, model_dir)
        elif table_stereotype == "lnk":
            generate_link_model(table, schema_name, model_dir, stage_model_name, load_operations)
#        else:
#            print(f"Unsupported table stereotype: {table_stereotype}")

def generate_hub_model(table, schema_name, output_directory, stage_model_name, load_operations):
    schema_name = table.get('schema_name')
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'key'), None)
    business_keys = [col['column_name'] for col in columns if col['column_class'] == 'business_key']
    load_operations = [lo for lo in load_operations if lo['table_name'] == table_name]
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, schema_name)
    output_file_name = f"{table_name}.sql"
    output_path = os.path.join(output_directory, output_file_name)

    print(f"Generating hub model for table: {table_name}, hashkey: {hashkey}")

    # If model already exists, import it's yaml_metadata
    if os.path.exists(output_path):
        yaml_dict = extract_yaml_metadata_from_file(output_path)
    else:
        yaml_dict = {'source_models': []}

    yaml_dict['hashkey'] = hashkey
    yaml_dict['business_keys'] = business_keys

    for lo in load_operations:
        source_model = {'name': stage_model_name}
        hash_mapping = lo.get('hash_mappings')[0]           # No need to iterate, since Hubs only have 1 HubKey
        column_name = hash_mapping.get('column_name')
        stage_column_name = hash_mapping.get('stage_column_name')

        if column_name != stage_model_name:
            source_model['hk_column'] = stage_column_name
                
        bk_columns = []
        differing_bk = False
        for data_mapping in lo.get('data_mapping', []):
            column_name = data_mapping.get('column_name')
            stage_column_name = data_mapping.get('stage_column_name')
            bk_columns.append(stage_column_name)
            if  column_name != stage_column_name:
                differing_bk = True
                
        if differing_bk:
            source_model['bk_columns'] = bk_columns

        # remove instances of the same stage_model in the yaml_metadata so we can overwrite it with the new value without having duplicates
        yaml_dict['source_models'] = [item for item in yaml_dict['source_models'] if item.get('name') != stage_model_name]
        yaml_dict['source_models'].append(source_model)

    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'incremental', unique_key = '{hashkey}') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.hub(hashkey=metadata_dict.get('hashkey')
                    , business_keys=metadata_dict.get('business_keys')
                    , source_models=metadata_dict.get('source_models') ) }}}}
"""

    write_model_to_file(output_path, model_content)

def generate_sat_model(table, schema_name, output_directory):
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'parent_key'), None)
    diff_columns = [col['column_name'] for col in columns if col['column_class'] == 'content']

    print(f"Generating sat model for table: {table_name}, hashkey: {hashkey}")

    # Generate YAML metadata for sat
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
hashkey: '{hashkey}'
diff_columns:
  - {"\n  - ".join(diff_columns)}
{{%- endset -%}}
"""

    # Generate model content for sat
    model_content = f"{{{{ config(materialized = 'view') }}}}\n\n{yaml_metadata}\n\n{{{{ datavault4dbt.sat(hashkey=metadata_dict.get('hashkey')\n                    , diff_columns=metadata_dict.get('diff_columns')\n                    ) }}}}"

    write_model_to_file(output_path,  model_content)

def generate_link_model(table, schema_name, output_directory, stage_model_name, load_operations):
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    foreign_hashkeys = [col['column_name'] for col in columns if col['column_class'] in {'parent_key', 'dependent_child_key'}]
    hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'key'), None)
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, schema_name)
    output_file_name = f"{table_name}.sql"
    output_path = os.path.join(output_directory, output_file_name)

    print(f"Generating link model for table: {table_name}, hashkey: {hashkey}")

    # If model already exists, import it's yaml_metadata
    if os.path.exists(output_path):
        yaml_dict = extract_yaml_metadata_from_file(output_path)
    else:
        yaml_dict = {'source_models': []}

    yaml_dict['link_hashkey'] = hashkey
    yaml_dict['foreign_hashkeys'] = foreign_hashkeys

    for lo in load_operations:
        source_model = {'name': stage_model_name}
        fk_column_mapping = {}

        for hash_mapping in lo.get('hash_mappings'):
            # parent keys -> foreign hashkeys | key -> link hashkey
            column_name = hash_mapping.get('column_name')
            stage_column_name = hash_mapping.get('stage_column_name')

            if hash_mapping['hash_class'] == 'key':
                if column_name != stage_column_name:
                    source_model['link_hk'] = stage_column_name
            else:
                fk_column_mapping[column_name] = stage_column_name
                
        for data_mapping in lo.get('data_mapping', []):
            # dependent child key -> foreign hashkeys
            column_name = data_mapping.get('column_name')
            stage_column_name = data_mapping.get('stage_column_name')
            if data_mapping.get('column_class') == 'dependent_child_key':
                fk_column_mapping[column_name] = stage_column_name
                
        if any(k != v for k, v in fk_column_mapping.items()):
            source_model['fk_columns'] = [] 
            # loop to preserve order
            for fk in foreign_hashkeys:
                source_model[fk] = fk_column_mapping[fk]

        # remove instances of the same stage_model in the yaml_metadata so we can overwrite it with the new value without having duplicates
        yaml_dict['source_models'] = [item for item in yaml_dict['source_models'] if item.get('name') != stage_model_name]
        yaml_dict['source_models'].append(source_model)

    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'incremental', unique_key = '{hashkey}') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.hub(hashkey=metadata_dict.get('hashkey')
                    , business_keys=metadata_dict.get('business_keys')
                    , source_models=metadata_dict.get('source_models') ) }}}}
"""

    # Generate YAML metadata for link
    write_model_to_file(output_path, model_content)

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

########################   MAIN ################################

if __name__ == "__main__":
    description_for_terminal = "Process dvpi at the given location to generate dbt models using the datavault4dbt extension."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name',  help='Name the file to process. File must be in the configured dvpi_default_directory.Use @youngest to parse the youngest.')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    args = parser.parse_args()

    # write mode should either be append or overwrite
    params = configuration_load_ini(args.ini_file, 'datavault4dbt', ['model_directory', 'dvpi_default_directory', 'write_mode'])

    model_dir = Path(params['model_directory'])
    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)
    write_mode = params['write_mode']

    dvpi_file_name=args.dvpi_file_name
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"generating DBT models from file {dvpi_file_name}")
    else:
        dvpi_file_name=f"{dvpi_file_name}.dvpi.json"

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")


    generate_datavault4dbt_model(dvpi_file_path, model_dir, write_mode)

    print("--- datavault4dbt model generation complete ---")
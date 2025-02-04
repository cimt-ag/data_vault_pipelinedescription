import os
from pathlib import Path
import yaml
from utils import write_model_to_file,get_verbose_logging



def generate_stage_model(parse_set, output_directory) -> str:
    stage_properties = parse_set.get('stage_properties', [{}])[0]
    stage_schema = stage_properties.get('stage_schema')
    stage_table_name = stage_properties.get('stage_table_name')
    record_source = parse_set.get('record_source_name_expression')
    # Assumption is, that a source model is defined according to the record source name
    if "." in record_source:
        source_name, source_table_name = record_source.split('.')
    else:
        source_name ="generic"
        source_table_name=record_source
        print("! Warning: record source could not be split into source and object. Using 'generic' as source !")
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, stage_schema)
    output_file_name = f"{stage_table_name}.sql"
    output_path = os.path.join(output_directory, output_file_name)

    if get_verbose_logging():
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
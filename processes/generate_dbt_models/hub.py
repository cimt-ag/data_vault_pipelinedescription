import os
import yaml
from pathlib import Path
from utils import write_model_to_file, extract_yaml_metadata_from_file

def generate_hub_model(table, schema_name, output_directory, stage_model_name, load_operations, overwrite = False):
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
    if os.path.exists(output_path) and not overwrite:
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

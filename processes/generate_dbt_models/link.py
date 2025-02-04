import os
import yaml
from pathlib import Path
from utils import write_model_to_file, extract_yaml_metadata_from_file,get_verbose_logging

def generate_link_model(table, schema_name, output_directory, stage_model_name, load_operations, overwrite = False):
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    foreign_hashkeys = [col['column_name'] for col in columns if col['column_class'] in {'parent_key', 'dependent_child_key'}]
    hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'key'), None)
    load_operations = [lo for lo in load_operations if lo['table_name'] == table_name]
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, schema_name)
    output_file_name = f"{table_name}.sql"
    output_path = os.path.join(output_directory, output_file_name)

    if get_verbose_logging():
        print(f"Generating link model for table: {table_name}, hashkey: {hashkey}")

    # If model already exists, import it's yaml_metadata
    if os.path.exists(output_path) and not overwrite:
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
{{{{ datavault4dbt.link(link_hashkey=metadata_dict.get('link_hashkey')
                    , foreign_hashkeys=metadata_dict.get('foreign_hashkeys')
                    , source_models=metadata_dict.get('source_models') ) }}}}
"""

    # Generate YAML metadata for link
    write_model_to_file(output_path, model_content)

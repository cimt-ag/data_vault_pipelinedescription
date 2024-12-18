import os
import yaml
import numpy as np
from pathlib import Path
from utils import write_model_to_file, extract_yaml_metadata_from_file

def generate_multi_active_sat_v1_model(sat_v0, hashkey, hashdiff, ma_attribute, output_path):

    yaml_dict = {'sat_v0': sat_v0
                 , 'hashkey': hashkey
                 , 'hashdiff': hashdiff
                 , 'ma_attribute': ma_attribute
                 , 'add_is_current_flag': True}  # hard-coded - is not specified in DVPI
    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'view') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.ma_sat_v1(sat_v0=metadata_dict.get('sat_v0')
                    , hashkey=metadata_dict.get('hashkey')
                    , hashdiff=metadata_dict.get('hashdiff')
                    , ma_attribute=metadata_dict.get('ma_attribute')
                    , add_is_current_flag=metadata_dict.get('add_is_current_flag') ) }}}}
"""

    write_model_to_file(output_path, model_content)

def generate_multiactive_sat_v0_model(table, output_directory, stage_model_name, load_operations):
    schema_name = table.get('schema_name')
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    parent_hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'parent_key'), None)
    src_hashdiff = next((col['column_name'] for col in columns if col['column_class'] == 'diff_hash'), None)
    src_payload = [col['column_name'] for col in columns if col['column_class'] == 'content']
    load_operations = [lo for lo in load_operations if lo['table_name'] == table_name]
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, schema_name)
    v0_output_file_name = f"{table_name}_v0.sql"
    v0_output_path = os.path.join(output_directory, v0_output_file_name)

    yaml_dict = {}
    yaml_dict['source_model'] = stage_model_name
    yaml_dict['parent_hashkey'] = parent_hashkey
    yaml_dict['src_hashdiff'] = src_hashdiff
    yaml_dict['src_ma_key'] = [dm['stage_column_name'] for dm in load_operations[0]['data_mapping'] if 'is_multi_active_key' in dm and dm['is_multi_active_key'] == True] # currently does not support column name != stage column name!!
    yaml_dict['src_payload'] = np.setdiff1d(np.array(src_payload), np.array(yaml_dict['src_ma_key'])).tolist()

    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'incremental') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.ma_sat_v0(parent_hashkey=metadata_dict.get('parent_hashkey')
                    , src_hashdiff=metadata_dict.get('src_hashdiff')
                    , src_payload=metadata_dict.get('src_payload')
                    , src_ma_key=metadata_dict.get('src_ma_key')
                    , source_model=metadata_dict.get('source_model') ) }}}}
"""

    write_model_to_file(v0_output_path, model_content)

    # Generate SAT_V1
    v1_output_file_name = f"{table_name}_v1.sql"
    v1_output_path = os.path.join(output_directory, v1_output_file_name)
    sat_v0 = f"{table_name}_v0"
    generate_multi_active_sat_v1_model(sat_v0, parent_hashkey, src_hashdiff, yaml_dict['src_ma_key'], v1_output_path)


# -> ESAT
def generate_record_tracking_sat(table, schema_name, output_directory, stage_model_name, load_operations, record_source, overwrite = False):
    schema_name = table.get('schema_name')
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    parent_hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'parent_key'), None)
    load_operations = [lo for lo in load_operations if lo['table_name'] == table_name]
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, schema_name)
    output_file_name = f"{table_name}.sql"
    output_path = os.path.join(output_directory, output_file_name)

    # If model already exists, import it's yaml_metadata
    if os.path.exists(output_path) and not overwrite:
        yaml_dict = extract_yaml_metadata_from_file(output_path)
    else:
        yaml_dict = {'source_models': []}
    
    for lo in load_operations:
        source_model = {'name': stage_model_name}
        relation_name = lo['relation_name']
        source_model['rsrc_static'] = f"{record_source}_{relation_name}" 
        hash_mapping = next((mapping for mapping in lo['hash_mappings'] if mapping['hash_class'] == 'parent_key'), None)           # No need to iterate, since only one Entity is Tracked (Hub or Linkkey)
        column_name = hash_mapping.get('column_name')
        stage_column_name = hash_mapping.get('stage_column_name')

        if column_name != stage_column_name:
            source_model['hk_column'] = stage_column_name

    yaml_dict['source_models'] = [item for item in yaml_dict['source_models'] if item.get('name') != stage_model_name]
    yaml_dict['source_models'].append(source_model)
    yaml_dict['tracked_hashkey'] = parent_hashkey

    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'incremental') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.rec_track_sat(tracked_hashkey=metadata_dict.get('tracked_hashkey')
                    , source_models=metadata_dict.get('source_models') ) }}}}
"""

    write_model_to_file(output_path, model_content)

# Generates the sat_v1 model, which is a view based on the sat_v0
# It calculates the end-date and adds a 'is_current' flag
# This is necessary when working with DBT since we don't want to actually UPDATE any rows in a table (Insert-Only)
def generate_sat_v1_model(sat_v0, hashkey, hashdiff, output_path):

    yaml_dict = {'sat_v0': sat_v0
                 , 'hashkey': hashkey
                 , 'hashdiff': hashdiff
                 , 'add_is_current_flag': True  # hard-coded - is not specified in DVPI
                 , 'include_payload': True}     # hard-coded - is not specified in DVPI
    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'view') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.sat_v1(sat_v0=metadata_dict.get('sat_v0')
                    , hashkey=metadata_dict.get('hashkey')
                    , hashdiff=metadata_dict.get('hashdiff')
                    , include_payload=metadata_dict.get('include_payload')
                    , add_is_current_flag=metadata_dict.get('add_is_current_flag') ) }}}}
"""

    write_model_to_file(output_path, model_content)


# normal SAT
def generate_sat_v0_model(table, schema_name, output_directory, stage_model_name):
    schema_name = table.get('schema_name')
    table_name = table.get('table_name')
    columns = table.get('columns', [])
    parent_hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'parent_key'), None)
    src_hashdiff = next((col['column_name'] for col in columns if col['column_class'] == 'diff_hash'), None)
    src_payload = [col['column_name'] for col in columns if col['column_class'] == 'content']
    # Define the file name and output path
    output_directory = Path.joinpath(output_directory, schema_name)
    v0_output_file_name = f"{table_name}_v0.sql"
    v0_output_path = os.path.join(output_directory, v0_output_file_name)

    yaml_dict = {}
    yaml_dict['source_model'] = stage_model_name
    yaml_dict['parent_hashkey'] = parent_hashkey
    yaml_dict['src_hashdiff'] = src_hashdiff
    yaml_dict['src_payload'] = src_payload

    yaml_metadata = yaml.dump(yaml_dict, sort_keys=False, default_flow_style=False)

    # Generate YAML metadata for stage
    yaml_metadata = f"""
{{%- set yaml_metadata -%}}
{yaml_metadata}
{{%- endset -%}}
"""

    # Generate model content for hub
    model_content = f"""{{{{ config(materialized = 'incremental') }}}}\n\n
{yaml_metadata}\n\n
{{%- set metadata_dict = fromyaml(yaml_metadata) -%}}\n\n
{{{{ datavault4dbt.sat_v0(parent_hashkey=metadata_dict.get('parent_hashkey')
                    , src_hashdiff=metadata_dict.get('src_hashdiff')
                    , src_payload=metadata_dict.get('src_payload')
                    , source_model=metadata_dict.get('source_model') ) }}}}
"""

    write_model_to_file(v0_output_path, model_content)

    # Generate SAT_V1
    v1_output_file_name = f"{table_name}_v1.sql"
    v1_output_path = os.path.join(output_directory, v1_output_file_name)
    sat_v0 = f"{table_name}_v0"
    generate_sat_v1_model(sat_v0, parent_hashkey, src_hashdiff, v1_output_path)

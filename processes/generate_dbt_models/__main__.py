# imports from libraries
import json
import yaml
import os
import argparse
import numpy as np
from pathlib import Path
import sys

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

# imports within project
from lib.configuration import configuration_load_ini
from stage import generate_stage_model
from utils import extract_yaml_metadata_from_file, write_model_to_file, get_name_of_youngest_dvpi_file
from hub import generate_hub_model
from link import generate_link_model
from sat import generate_sat_v0_model, generate_sat_v1_model, generate_multiactive_sat_v0_model, generate_multi_active_sat_v1_model, generate_record_tracking_sat

g_schema_table_dict = {}

def generate_datavault4dbt_model(dvpi_path, model_dir, append_only):
    global g_schema_table_dict

    # Load JSON data from the input file
    with open(dvpi_path, 'r') as file:
        data = json.load(file)

    # Generate stage model first
    parse_set = data.get('parse_sets')[0]
    stage_model_name = generate_stage_model(parse_set, model_dir)
    load_operations = parse_set.get('load_operations')
    record_source = parse_set['record_source_name_expression']

    # Iterate over tables in the JSON
    tables = data.get('tables', [])
    print(f"Found {len(tables)} tables to generate models for.")
    for table in tables:
        table_name = table.get('table_name')
        schema_name = table.get('schema_name', 'public')
        # Only use this logic if we actually need it
        if append_only:
            overwrite = False
        else:
            if schema_name not in g_schema_table_dict:
                g_schema_table_dict[schema_name] = []
            overwrite = False
            if table_name not in g_schema_table_dict[schema_name]:
                overwrite = True
                g_schema_table_dict[schema_name].append(table_name)

        table_stereotype = table.get('table_stereotype')

        print(f"Processing table: {table_name}, schema: {schema_name}, stereotype: {table_stereotype}")

        if table_stereotype == "hub":
            generate_hub_model(table, schema_name, model_dir, stage_model_name, load_operations)
        elif table_stereotype == "sat":
            if table['is_effectivity_sat']:
                generate_record_tracking_sat(table, schema_name, model_dir, stage_model_name, load_operations, record_source, overwrite)
            if 'is_multiactive' in table and table['is_multiactive']:
                generate_multiactive_sat_v0_model(table, model_dir, stage_model_name, load_operations)
            else: 
                generate_sat_v0_model(table, schema_name, model_dir, stage_model_name)
        elif table_stereotype == "lnk":
            generate_link_model(table, schema_name, model_dir, stage_model_name, load_operations)
        else:
            print(f"Unsupported table stereotype: {table_stereotype}")

########################   MAIN ################################
if __name__ == "__main__":
    description_for_terminal = "Process dvpi at the given location to generate dbt models using the datavault4dbt extension."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name', help='Name the file to process. File must be in the configured dvpi_default_directory. Use @youngest to parse the youngest. Use @all to generate the dbt models for all dvpis in the dvpi default directory.')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    args = parser.parse_args()

    # write mode should either be append or overwrite
    params = configuration_load_ini(args.ini_file, 'datavault4dbt', ['model_directory', 'dvpi_default_directory'])

    model_dir = Path(params['model_directory'])
    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)
    dvpi_file_name=args.dvpi_file_name

    if dvpi_file_name == '@all':   # iterate through all dvpi documents within folder and build dbt models based on those
        if not os.path.isdir(dvpi_default_directory):
            raise NotADirectoryError(f"{dvpi_default_directory} not found / is not a directory.")
        
        for dvpi_file_name in os.listdir(dvpi_default_directory):
            dvpi_file_path = os.path.join(dvpi_default_directory, dvpi_file_name)
            generate_datavault4dbt_model(dvpi_file_path, model_dir, False)

    else: # Generate Model based on a single DVPI
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

        generate_datavault4dbt_model(dvpi_file_path, model_dir, True)

    print("--- datavault4dbt model generation complete ---")
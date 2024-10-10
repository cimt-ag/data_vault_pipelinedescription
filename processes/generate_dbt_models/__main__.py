import json
import os

def generate_datavault4dbt_model(dvpi_path, model_dir, write_mode):
    # Load JSON data from the input file
    with open(dvpi_path, 'r') as file:
        data = json.load(file)
    
    # Iterate over tables in the JSON
    for table in data.get('tables', []):
        table_name = table.get('table_name')
        schema_name = table.get('schema_name', 'public')
        columns = table.get('columns', [])
        table_stereotype = table.get('table_stereotype')

        # Prepare YAML metadata content for the datavault4dbt model
        yaml_metadata = ""

        if table_stereotype == "hub":
            # Hub-specific metadata
            hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'key'), None)
            business_keys = [col['column_name'] for col in columns if col['column_class'] == 'business_key']
            source_model = f"dv4dbt_srvlt_{schema_name}_{table_name}"
            
            yaml_metadata = f"""
{%- set yaml_metadata -%}
hashkey: '{hashkey}'
business_keys:
    - {"\n    - ".join(business_keys)}
source_models: {source_model}
{%- endset -%}
"""
            model_content = f"{{{{ config(materialized = 'incremental') }}}}\n\n{yaml_metadata}\n\n{{{{ datavault4dbt.hub(hashkey=metadata_dict.get('hashkey')\n                    , business_keys=metadata_dict.get('business_keys')\n                    , source_models=metadata_dict.get('source_models')\n                    ) }}}}"

        elif table_stereotype == "sat":
            # Satellite-specific metadata
            hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'parent_key'), None)
            diff_columns = [col['column_name'] for col in columns if col['column_class'] == 'content']
            
            yaml_metadata = f"""
{%- set yaml_metadata -%}
hashkey: '{hashkey}'
diff_columns:
    - {"\n    - ".join(diff_columns)}
{%- endset -%}
"""
            model_content = f"{{{{ config(materialized = 'view') }}}}\n\n{yaml_metadata}\n\n{{{{ datavault4dbt.sat(hashkey=metadata_dict.get('hashkey')\n                    , diff_columns=metadata_dict.get('diff_columns')\n                    ) }}}}"

        elif table_stereotype == "lnk":
            # Link-specific metadata
            parent_keys = [col['column_name'] for col in columns if col['column_class'] == 'parent_key']
            hashkey = next((col['column_name'] for col in columns if col['column_class'] == 'key'), None)
            
            yaml_metadata = f"""
{%- set yaml_metadata -%}
hashkey: '{hashkey}'
parent_keys:
    - {"\n    - ".join(parent_keys)}
{%- endset -%}
"""
            model_content = f"{{{{ config(materialized = 'incremental') }}}}\n\n{yaml_metadata}\n\n{{{{ datavault4dbt.link(hashkey=metadata_dict.get('hashkey')\n                    , parent_keys=metadata_dict.get('parent_keys')\n                    ) }}}}"
        else:
            continue  # Skip unsupported stereotypes

        # Define the file name and output path
        output_file_name = f"{table_name}.sql"
        output_path = os.path.join(model_dir, output_file_name)

        # Write the model content to the output file
        with open(output_path, 'w') as output_file:
            output_file.write(model_content)
        
        print(f"Model file generated: {output_path}")


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

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")


    generate_datavault4dbt_model(dvpi_file_path, model_dir, write_mode)

    print("--- operations list render complete ---")
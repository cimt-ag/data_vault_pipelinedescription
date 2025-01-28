import re
import os
import yaml
import json

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
    
    #print(f"Model file generated: {output_path}") # only for DEBUG/TRACE


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
    
    return youngest_file

def get_table_list_for_dvpi(dvpi_file_path):
    with open(dvpi_file_path, 'r') as file:
        dvpi = json.load(file)

    tables = dvpi.get('tables', [])
    table_names = [table['table_name'] for table in tables]
    return table_names
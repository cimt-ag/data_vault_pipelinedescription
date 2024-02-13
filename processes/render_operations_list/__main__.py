import argparse
import json
from pathlib import Path
from lib.configuration import configuration_load_ini

def create_op_list(dvpd):
    """
    this function renders a operations list from a given dvpd
    :param dvpd: json of the dvpd
    :return: (pipeline_name, rendered_operations_list)
    """
    schema_tables = {} # dict which stores tables per schema
    schema_sats = {}  # dict which stores satellites per schema
    op_list = []

    for schema in dvpd['data_vault_model']:
        schema_name = (schema['schema_name'])
        schema_tables[schema_name] = 0
        schema_sats[schema_name] = 0
        
        for table in schema['tables']:
            #print(table['table_name'])
            table_name = table['table_name']
            schema_tables[schema_name] += 1
            if table['table_stereotype'] == "sat":
                schema_sats[schema_name] += 1

            op_list.append(f"table.{schema_name}.{table_name}")
    

    # Generate DDL for stage tables
    max_count = max(schema_tables.values())
    # Identify all schemas with the maximum count
    schema_with_max_count = [schema for schema, count in schema_tables.items() if count == max_count]
    schema_name = None
    if len(schema_with_max_count)==1:
        schema_name = schema_with_max_count[0]
    else:
        # Filter schema_sat to keep only schemas with max counts
        filtered_schemas = {key: schema_sats[key] for key in schema_sats if key in schema_with_max_count}
        schema_name = max(filtered_schemas, key=filtered_schemas.get)
    stage_table_name = dvpd['stage_properties'][0]['stage_table_name']

    op_list.insert(0,f"stage_table.{schema_name}.{stage_table_name}")
    return (dvpd['pipeline_name'],"\n".join(op_list))
            

def main():
    parser = argparse.ArgumentParser(description="Create operations list from DVPD file")
    parser.add_argument("dvpd_file_name", help="DVPD filename")
    dvpd_filename = parser.parse_args().dvpd_file_name
    params = configuration_load_ini('dvpdc.ini', 'rendering', ['dvpd_default_directory', 'operations_list_directory'])
    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)
    op_list_dir = Path(params['operations_list_directory'])

    if not dvpd_file_path.exists():
        raise Exception(f'fiel not found {dvpd_file_path.as_posix()}')
    print(f"Rendering operations list from {dvpd_file_path.name}")

    try:
        with open(dvpd_file_path, 'r') as file:
            dvpd = json.load(file)
            (pipeline_name, op_list) = create_op_list(dvpd)
            print(op_list)
            target_file_path = op_list_dir.joinpath(f"{pipeline_name}.list.txt")
            with open(target_file_path, "w") as file:
                file.write(op_list)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {str(e)}")    
    

if __name__ == "__main__":
    main()
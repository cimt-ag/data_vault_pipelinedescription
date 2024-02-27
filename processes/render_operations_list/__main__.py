import argparse
import json
from pathlib import Path
from lib.configuration import configuration_load_ini

def create_op_list(dvpi):
    """
    this function renders a operations list from a given dvpi
    :param dvpi: json of the dvpi
    :return: (pipeline_name, rendered_operations_list)
    """
    schema_tables = {} # dict which stores tables per schema
    schema_sats = {}  # dict which stores satellites per schema
    op_list = []
    table_dict = {} # key: table-name | value: schema_name


    # Get Table-Info from .tables - except relations-info
    for table in dvpi['tables']:
        schema_name = table['schema_name']
        schema_tables[schema_name] = 0
        schema_sats[schema_name] = 0
        table_name = table['table_name']
        schema_tables[schema_name] += 1
        if table['table_stereotype'] == "sat":
            schema_sats[schema_name] += 1

        table_dict[table_name]=schema_name
    

    # Get Op-List & Relation-Info from .parse_sets[].load_operations
    for parse_set in dvpi['parse_sets']:
        table_op_dict = {}
        # TODO: In the future add functionaility for multiple parse sets
        for load_op in parse_set['load_operations']:
            table_name = load_op['table_name']
            table_op_dict[table_name] = 1 if table_name not in table_op_dict else table_op_dict[table_name]+1
            
        for load_op in parse_set['load_operations']:
            table_name = load_op['table_name']
            schema_name = table_dict[table_name]
            if table_op_dict[table_name] == 1:
                op_list.append(f"table.{schema_name}.{table_name}")
            else:
                relation_name = load_op['relation_name']
                op_list.append(f"table.{schema_name}.{table_name}.[{relation_name}]")


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

    # Get StageTable from .parse_sets[].stage_properties
    # TODO: In the future add functionality for mutliple parse-sets & multiple stage_tables
    for stage_table in dvpi['parse_sets'][0]['stage_properties']:
        stage_table_name = stage_table['stage_table_name']
        op_list.insert(0,f"stage_table.{schema_name}.{stage_table_name}")

    return (dvpi['pipeline_name'],"\n".join(op_list))
            

def main():
    parser = argparse.ArgumentParser(description="Create operations list from DVPI file")
    parser.add_argument("dvpi_file_name", help="DVPI filename")
    dvpi_filename = parser.parse_args().dvpi_file_name
    params = configuration_load_ini('dvpdc.ini', 'rendering', ['dvpi_default_directory', 'operations_list_directory'])
    dvpi_file_path = Path(params['dvpi_default_directory']).joinpath(dvpi_filename)
    op_list_dir = Path(params['operations_list_directory'])

    if not dvpi_file_path.exists():
        raise Exception(f'fiel not found {dvpi_file_path.as_posix()}')
    print(f"Rendering operations list from {dvpi_file_path.name}")

    try:
        with open(dvpi_file_path, 'r') as file:
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
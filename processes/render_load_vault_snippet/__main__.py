import json
import textwrap
import argparse
from pathlib import Path
import os
import sys

# Assuming `lib` is at the root level of your project
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.insert(0, project_root)

# We declare our own exception catch them in the main
class ApplicationException(Exception):
    pass

from lib.configuration import configuration_load_ini


function_names = {
    'hub': 'dvf_get_datavault_hub_elt_sql',
    'lnk': 'dvf_get_datavault_lnk_elt_sql',
    'dlnk': 'dvf_get_datavault_dlnk_elt_sql',
    'esat': 'dvf_get_datavault_esat_elt_sql',
    'sat': 'dvf_get_datavault_sat_elt_sql',
    'msat': 'dvf_get_datavault_msat_elt_sql'
}


def get_columns_by_class(columns):
    columns_by_class = dict()
    for i, c in enumerate(columns):
        if 'column_class' in c:
            column_class = c['column_class']
        if 'hash_class' in c:
            if 'parent_key' in c['hash_class']:
                column_class = 'parent_key'
            else:
                column_class = c['hash_class']
        column_name = c['column_name']
        column_stage_name = c['stage_column_name']
        columns_by_class.setdefault(column_class, {}).setdefault('column_name', []).append(column_name)
        columns_by_class.setdefault(column_class, {}).setdefault('column_stage_name', []).append(column_stage_name)
    #print(columns_by_class)

    if 'content' in columns_by_class and 'content_untracked' in columns_by_class:
        columns_by_class.setdefault('content_all', {})['column_name'] = columns_by_class['content']['column_name'] + columns_by_class['content_untracked']['column_name']
        columns_by_class.setdefault('content_all', {})['column_stage_name'] = columns_by_class['content']['column_stage_name'] + columns_by_class['content_untracked']['column_stage_name']
    if 'content' in columns_by_class and 'content_untracked' not in columns_by_class:
        columns_by_class.setdefault('content_all', {})['column_name'] = columns_by_class['content']['column_name']
        columns_by_class.setdefault('content_all', {})['column_stage_name'] = columns_by_class['content']['column_stage_name']

    # to ensure the same order, also when the stage and vault columns have different names
    for key in columns_by_class.keys():
        column_name_list = columns_by_class[key]['column_name']
        column_stage_name_list = columns_by_class[key]['column_stage_name']
        sorted_column_name_tuple, sorted_column_stage_name_tuple = zip(*sorted(zip(column_name_list, column_stage_name_list)))
        columns_by_class[key]['column_name'] = list(sorted_column_name_tuple)
        columns_by_class[key]['column_stage_name'] = list(sorted_column_stage_name_tuple)
    return columns_by_class


def get_parent_table_name_for_key(columns, key_name):
  for c in columns:
    if c['column_name'] == key_name:
      return c['parent_table_name']

'''def get_tables_by_stereotypes(dvpi_json):
    table_list = dict()
    for table in dvpi_json['tables']:
        if table['table_stereotype'] == 'hub':
            table_list.setdefault('hub', []).append(table['table_name'])
        elif table['table_stereotype'] == 'lnk':
            table_list.setdefault('lnk', []).append(table['table_name'])
        else:
            table_list.setdefault('sat', []).append(table['table_name'])
    return table_list'''

def get_stage_properties(dvpi_json):
    stage_properties = dict()
    stage_properties['stage_schema'] = dvpi_json['parse_sets'][0]['stage_properties'][0]['stage_schema']
    stage_properties['stage_table'] = dvpi_json['parse_sets'][0]['stage_properties'][0]['stage_table_name']
    return stage_properties

def get_tables_with_deletion_detection_from_dvpd(path, pipeline_name=None):
    file_path = path if pipeline_name is None else rf"{path}\{pipeline_name}.dvpd.json"
    with open(file_path, 'r') as file:
        dvpd_data = json.load(file)
    deletion_detection_rules = dvpd_data.get('deletion_detection_rules',[])
    table_list=[]
    for deletion_rule in deletion_detection_rules:
        if deletion_rule['procedure'] == 'stage_comparison':
            return deletion_rule['tables_to_cleanup']
    return table_list



def get_vault_schema_name(dvpi_json):
    return dvpi_json['tables'][0]['schema_name']

def get_load_operations(dvpi_json):
    load_operations = dvpi_json['parse_sets'][0]['load_operations']
    return load_operations

'''def get_table_data_mapping(load_operations, table_name):
    for load in load_operations:
        if load.get('table_name') == table_name:
            return load.get('data_mapping')

def get_table_hash_mapping(load_operations, table_name):
    for load in load_operations:
        if load.get('table_name') == table_name:
            return load.get('hash_mappings')

def get_table_data_and_hash_mapping(load_operations, table_name):
    data_mapping = get_table_data_mapping(load_operations, table_name) or []
    hash_mapping = get_table_hash_mapping(load_operations, table_name) or []
    return data_mapping + hash_mapping'''
    
def get_statement_list_method_definition_for_hub(dvpi_table, dvpi_table_load_operations):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"statement_list = {function_names['hub']}(vault_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_hk_column='{columns_by_class['key']['column_stage_name'][0]}',\n"
    output += f"stage_bk_column_list={columns_by_class['business_key']['column_stage_name']},\n"
    output += f'db_connection=dwh_connection,\n'
    output += "stage_schema=stage_schema,\nstage_table=stage_table,\nmeta_job_instance_id = my_job_instance.get_job_instance_id(),\nmeta_inserted_at = my_job_instance.get_job_started_at() )\n\n"

    output += f"dvf_execute_elt_statement_list(dwh_cursor, statement_list)\n"
    return output

def get_statement_list_method_definition_for_lnk(dvpi_table,dvpi_table_load_operations):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"statement_list = {function_names['dlnk' if 'dependent_child_key' in columns_by_class else 'lnk']}(vault_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_lk_column='{columns_by_class['key']['column_stage_name'][0]}',\n"
    output += f"stage_hk_column_list={columns_by_class['parent_key']['column_stage_name']},\n"
    if 'dependent_child_key' in columns_by_class:
        output += f"stage_dc_column_list={columns_by_class['dependent_child_key']['column_stage_name']},\n"
    output += f'db_connection=dwh_connection,\n'
    output += "stage_schema=stage_schema,\nstage_table=stage_table,\nmeta_job_instance_id = my_job_instance.get_job_instance_id(),\nmeta_inserted_at = my_job_instance.get_job_started_at() )\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, statement_list)\n"
    return output

def get_statement_list_method_definition_for_sat(dvpi_table, tables_with_deletion_detection, dvpi_table_load_operations, include_stage_content_column_list):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"statement_list = {function_names['sat']}(vault_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_hk_column='{columns_by_class['parent_key']['column_stage_name'][0]}',\n"
    output += f"stage_rh_column='{columns_by_class['diff_hash']['column_stage_name'][0]}',\n"
    if include_stage_content_column_list:
        output += f"stage_content_column_list={columns_by_class['content_all']['column_stage_name']},\n"
    output += f"with_deletion_detection={True if dvpi_table['table_name'] in tables_with_deletion_detection else False},\n"
    output += f'db_connection=dwh_connection,\n'
    output += "stage_schema=stage_schema,\nstage_table=stage_table,\nmeta_job_instance_id = my_job_instance.get_job_instance_id(),\nmeta_inserted_at = my_job_instance.get_job_started_at() )\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, statement_list)\n"
    return output

def get_statement_list_method_definition_for_esat(dvpi_table, tables_with_deletion_detection, dvpi_table_load_operations):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"statement_list = {function_names['esat']}(vault_esat_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_lk_column='{columns_by_class['parent_key']['column_stage_name'][0]}',\n"
    output += f"vault_lnk_table='{get_parent_table_name_for_key(dvpi_table['columns'], columns_by_class['parent_key']['column_name'][0])}',\n"
    output += f"vault_driving_key_column_list={dvpi_table['driving_keys'] if 'driving_keys' in dvpi_table else []},\n"
    output += f"stage_driving_key_column_list={dvpi_table['driving_keys'] if 'driving_keys' in dvpi_table else []},\n"
    output += f"with_deletion_detection={True if dvpi_table['table_name'] in tables_with_deletion_detection else False},\n"
    output += f'db_connection=dwh_connection,\n'
    output += "stage_schema=stage_schema,\nstage_table=stage_table,\nmeta_job_instance_id = my_job_instance.get_job_instance_id(),\nmeta_inserted_at = my_job_instance.get_job_started_at() )\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, statement_list)\n"
    return output

def get_statement_list_method_definition_for_msat(dvpi_table, tables_with_deletion_detection, dvpi_table_load_operations, include_stage_content_column_list):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"statement_list = {function_names['msat']}(vault_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_hk_column='{columns_by_class['parent_key']['column_stage_name'][0]}',\n"
    output += f"stage_gh_column='{columns_by_class['diff_hash']['column_stage_name'][0]}',\n"
    if include_stage_content_column_list:
        output += f"stage_content_column_list={columns_by_class['content_all']['column_stage_name']},\n"
    output += f"with_deletion_detection={True if dvpi_table['table_name'] in tables_with_deletion_detection else False},\n"
    output += f'db_connection=dwh_connection,\n'
    output += "stage_schema=stage_schema,\nstage_table=stage_table,\nmeta_job_instance_id = my_job_instance.get_job_instance_id(),\nmeta_inserted_at = my_job_instance.get_job_started_at() )\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, statement_list)\n"
    return output

def get_hash_collision_statement_method_definition_for_hub(dvpi_table, dvpi_table_load_operations):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"hash_collision_check_statement_list = dvf_get_check_hash_collision_hub_elt_sql(vault_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_hk_column='{columns_by_class['key']['column_stage_name'][0]}',\n"
    output += f"stage_bk_column_list={columns_by_class['business_key']['column_stage_name']},\n"
    output += "db_connection=dwh_connection,\n"
    output += "stage_schema=stage_schema,\nstage_table=stage_table)\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, hash_collision_check_statement_list)\n\n"
    return output

def get_hash_collision_statement_method_definition_for_sat(dvpi_table,dvpi_table_load_operations):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping
    columns_by_class = get_columns_by_class(columns_mapping)

    output += f"singularity_check_statement_list = dvf_get_check_singularity_sat_elt_sql(vault_table='{dvpi_table['table_name']}',\n"
    output += f"stage_hk_column='{columns_by_class['parent_key']['column_stage_name'][0]}',\n"
    output += f"stage_rh_column='{columns_by_class['diff_hash']['column_stage_name'][0]}',\n"
    output += "stage_schema=stage_schema,\nstage_table=stage_table )\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, singularity_check_statement_list)\n\n"
    return output

def get_hash_collision_statement_method_definition_for_lnk(dvpi_table, dvpi_table_load_operations):
    output = str()
    data_mapping = dvpi_table_load_operations.get('data_mapping') or []
    hash_mapping = dvpi_table_load_operations.get('hash_mappings') or []
    columns_mapping = data_mapping + hash_mapping

    columns_by_class = get_columns_by_class(columns_mapping)
    output += f"hash_collision_check_statement_list = {'dvf_get_check_hash_collision_dlnk_elt_sql' if 'dependent_child_key' in columns_by_class else 'dvf_get_check_hash_collision_lnk_elt_sql'}(vault_table='{dvpi_table['table_name']}',\n"
    output += f"vault_schema='{dvpi_table['schema_name']}',\n"
    output += f"stage_lk_column='{columns_by_class['key']['column_stage_name'][0]}',\n"
    output += f"stage_hk_column_list={columns_by_class['parent_key']['column_stage_name']},\n"
    if 'dependent_child_key' in columns_by_class:
        output += f"stage_dc_column_list={columns_by_class['dependent_child_key']['column_stage_name']},\n"
    output += "db_connection=dwh_connection,\n"
    output += "stage_schema=stage_schema,\nstage_table=stage_table)\n\n"
    output += "dvf_execute_elt_statement_list(dwh_cursor, hash_collision_check_statement_list)\n\n"
    return output


def generate_lv_snippet_from_dvpi(dvpi_data, tables_with_deletion_detection, include_stage_content_column_list):
    indent_level_1 = " " * 4 * 1
    indent_level_2 = " " * 4 * 2

    load_operations = get_load_operations(dvpi_data)

    stage_properties = get_stage_properties(dvpi_data)

    output_all = textwrap.indent(f"# general constants\nstage_schema = '{stage_properties['stage_schema']}'\n" f"stage_table = '{stage_properties['stage_table']}'\n\n\ndwh_cursor = dwh_connection.cursor()\n\n\n",indent_level_2)

    print("Generating code for the following tables: load operations")
    # todo: arrange code to load in stereotype specific order: hubs, links, sats, references
    for load_operations_for_table in load_operations:
        print(f"\t{load_operations_for_table.get('table_name')}: {load_operations_for_table.get('relation_name')}")
        # todo: change the table stereotype identification from naming convention to dvpi property evaluation
        if load_operations_for_table.get('table_name').split('_')[-1] == 'hub':
            for table in dvpi_data['tables']:
                if table['table_name'] == load_operations_for_table.get('table_name'):
                    output = "# --------"+load_operations_for_table.get('table_name')+"-------\n\n"
                    output += get_hash_collision_statement_method_definition_for_hub(table, load_operations_for_table)
                    output += get_statement_list_method_definition_for_hub(table, load_operations_for_table)
                    output_all += textwrap.indent(output, indent_level_2) + '\n'


        if load_operations_for_table.get('table_name').split('_')[-1] == 'lnk':
            for table in dvpi_data['tables']:
                if table['table_name'] == load_operations_for_table.get('table_name'):
                    output = "# --------" + load_operations_for_table.get('table_name') + "-------\n\n"
                    output += get_hash_collision_statement_method_definition_for_lnk(table,load_operations_for_table)
                    output += get_statement_list_method_definition_for_lnk(table,load_operations_for_table)
                    output_all += textwrap.indent(output, indent_level_2) + '\n'

        if load_operations_for_table.get('table_name').split('_')[-1] == 'dlnk':
            for table in dvpi_data['tables']:
                if table['table_name'] == load_operations_for_table.get('table_name'):
                    output = "# --------" + load_operations_for_table.get('table_name') + "-------\n\n"
                    output += get_hash_collision_statement_method_definition_for_lnk(table,load_operations_for_table)
                    output += get_statement_list_method_definition_for_lnk(table,load_operations_for_table)
                    output_all += textwrap.indent(output, indent_level_2) + '\n'


        if load_operations_for_table.get('table_name').split('_')[-1] == 'esat':
            for table in dvpi_data['tables']:
                if table['table_name'] == load_operations_for_table.get('table_name'):
                    output = "# --------" + load_operations_for_table.get('table_name') + "-------\n\n"
                    output += get_statement_list_method_definition_for_esat(table, tables_with_deletion_detection, load_operations_for_table)
                    output_all += textwrap.indent(output, indent_level_2) + '\n'


        if load_operations_for_table.get('table_name').split('_')[-1] == 'msat':
            for table in dvpi_data['tables']:
                if table['table_name'] == load_operations_for_table.get('table_name'):
                    output = "# --------" + load_operations_for_table.get('table_name') + "-------\n\n"
                    output += get_statement_list_method_definition_for_msat(table, tables_with_deletion_detection, load_operations_for_table, include_stage_content_column_list)
                    output_all += textwrap.indent(output, indent_level_2) + '\n'


        if load_operations_for_table.get('table_name').split('_')[-1] == 'sat':
            for table in dvpi_data['tables']:
                if table['table_name'] == load_operations_for_table.get('table_name'):
                    output = "# --------" + load_operations_for_table.get('table_name') + "-------\n\n"
                    output += get_hash_collision_statement_method_definition_for_sat(table,load_operations_for_table)
                    output += get_statement_list_method_definition_for_sat(table, tables_with_deletion_detection, load_operations_for_table, include_stage_content_column_list)
                    output_all += textwrap.indent(output, indent_level_2) + '\n'

    return output_all



def replace_code_in_file_between_markers(file_name, snippet_code, start_marker, end_marker):
    # Read the existing file content

    print(f"Adding snippet to python file'{file_name}'")
    try:
        with open(file_name, 'r') as file:
            py_script_lines = file.readlines()
    except FileNotFoundError as fnf:
        print(fnf)
        raise ApplicationException("Could read python file")

    # Find the start and end markers
    start_index = None
    end_index = None
    for i, line in enumerate(py_script_lines):
        if start_marker in line:
            start_index = i
        if end_marker in line:
            end_index = i

    if start_index is None:
        print(f"File does not contain start marker: '{start_marker}' ")
    if end_index is  None:
        print(f"File does not contain end marker: '{end_marker}' ")
    if start_index is None or end_index is  None:
        raise ApplicationException("Start marker or Endmarker not found in load vault python file")
    if start_index > end_index:
        raise ApplicationException("Endmarker is placed before start marker")

    # Replace the content between the markers with the new code
    py_script_lines = py_script_lines[:start_index + 1] + [snippet_code] + py_script_lines[end_index:]

    # Write the updated content back to the file
    try:
        with open(file_name, 'w') as file:
            file.writelines(py_script_lines)
    except FileNotFoundError as fnf:
        print(fnf)
        raise ApplicationException("Could not write python file")



def get_name_of_youngest_dvpi_file(dvpi_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpi_default_directory):
        if not os.path. isfile( dvpi_default_directory+'/'+file_name):
            continue
        file_mtime=os.path.getmtime( dvpi_default_directory+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file

def search_for_dvpifile_of_test(testnumber):
    params = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpd_model_profile_directory'])
    dvpi_directory = Path(params['dvpi_default_directory'])

    fileprefix="t{:04d}".format(int(testnumber))

    for file in sorted(dvpi_directory.iterdir()):
        if (file.is_file()
            and file.stem.startswith(fileprefix)):
            return file.name

    return None


def render_load_vault_snippet(dvpi_file_name, ini_file, put_snippet_into_load_vault_py, start_marker, end_marker, project_pipeline_name, load_vault_py_filename, include_stage_content_column_list):
    params = configuration_load_ini(ini_file, 'rendering',
                                    ['load_vault_snippet_directory', 'dvpi_default_directory'])

    if put_snippet_into_load_vault_py:
        if 'dwh_processes_directory' not in params:
            raise ApplicationException('you need to configure "dwh_processes_directory", when you set option "put_snippet_into_load_vault_py"')

    lvs_render_path = Path(params.get('load_vault_snippet_directory', None))
    dvpi_default_directory = Path(params.get('dvpi_default_directory', None))
    dvpd_default_directory = Path(params.get('dvpd_default_directory', None))



    print("=== Render load_vault snippet ===")
    print("Reading dvpi file " + dvpi_file_name)
    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
        dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)

    with open(dvpi_file_path, 'r') as dvpi_file:
        try:
            dvpi_data = json.load(dvpi_file)
        except:
            print(f"*** Error when parsing file {dvpi_file.name} ***")
            exit(1)

    dvpi_pipeline_name = dvpi_data.get("pipeline_name")
    dvpd_filename =  dvpi_data.get("dvpd_filename")

    print("Reading dvpd file " + dvpd_filename)
    dvpd_file_path = Path(dvpd_filename)
    if not dvpd_file_path.exists():
        dvpd_file_path = dvpd_default_directory.joinpath(dvpd_file_path)
        if not dvpd_file_path.exists():
            print(f"could not find file {dvpd_filename}")


    if project_pipeline_name is None:
        project_pipeline_name = dvpi_pipeline_name

    tables_with_deletion_detection = get_tables_with_deletion_detection_from_dvpd(dvpd_file_path)
    Snippet_code = generate_lv_snippet_from_dvpi(dvpi_data, tables_with_deletion_detection, include_stage_content_column_list)

    # write load_vault snippet to file
    lvs_render_path.mkdir(parents=True, exist_ok=True)
    lvs_filename = dvpi_file_name.replace('.dvpi.json', '.txt')
    lvs_file_path = lvs_render_path.joinpath(lvs_filename)

    print("Writing load_vault snippet to " + lvs_file_path.as_posix())

    with open(lvs_file_path, 'w') as file:
        file.writelines(Snippet_code)


    if put_snippet_into_load_vault_py :
        dwh_processes_directory = Path(params.get('dwh_processes_directory', None))
        load_vault_py_path = dwh_processes_directory.joinpath(f'{project_pipeline_name}', f'{load_vault_py_filename}')

        replace_code_in_file_between_markers(load_vault_py_path, Snippet_code, start_marker, end_marker)

        print(f"Code inserted into {load_vault_py_path} between markers")



def main():
    description_for_terminal = "Process dvpi at the given location to render the load_vault code snippet."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name',  help='Name the file to process. File must be in the configured dvpi_default_directory.Use @youngest to parse the youngest. @t<number> to use a test result file starting')
    parser.add_argument("--put_snippet_into_load_vault_py", help="The code snippet will additionally be inserted/replaced betwenn the start and end marker in the load_vault.py of the process.",  action='store_true')
    parser.add_argument("--start_marker",help="Start marker.",default="# ---- BEGIN LOAD VAULT SNIPPET ----")
    parser.add_argument("--end_marker",help="End marker",default="# ---- END LOAD VAULT SNIPPET ----")
    parser.add_argument("--project_pipeline_name", help="Pipeline name in your DWH project.")
    parser.add_argument("--project_load_vault_file", help="Name of the py load vault file in your DWH project", default='load_vault.py')
    parser.add_argument("--include_stage_content_column_list", help="Add stage_content_column_list parameter to sql generator function call", action='store_true')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'rendering', ['dvpi_default_directory'])

    dvpi_default_directory = Path(params.get('dvpi_default_directory', None))

    dvpi_file_name = args.dvpi_file_name if '.dvpi.json' in args.dvpi_file_name or args.dvpi_file_name == '@youngest' else args.dvpi_file_name + '.dvpi.json'

    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")
    if dvpi_file_name[:2] == '@t':
        testnumber = dvpi_file_name[2:]
        dvpi_file_name = search_for_dvpifile_of_test(testnumber)
        if dvpi_file_name is None:
            raise ApplicationException(f"Could not find test file for testnumber {testnumber}")

    render_load_vault_snippet(dvpi_file_name=dvpi_file_name,
                              ini_file=args.ini_file,
                              put_snippet_into_load_vault_py=args.put_snippet_into_load_vault_py,
                              start_marker=args.start_marker,
                              end_marker=args.end_marker,
                              project_pipeline_name=args.project_pipeline_name,
                              load_vault_py_filename=args.project_load_vault_file,
                              include_stage_content_column_list=args.include_stage_content_column_list
                              )


if __name__ == '__main__':
    try:
        main()
    except ApplicationException as ae:
        print("ERROR: >"+str(ae)+"<")
        print("*** load_vault snippet render aborted ***")
        exit(1)

    print("--- load_vault snippet render complete ---")
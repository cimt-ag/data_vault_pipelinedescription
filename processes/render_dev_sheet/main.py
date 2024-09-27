import json
#import configparser
import os
import sys
import argparse
from pathlib import Path
import re

# Include data_vault_pipelinedescription folder into
project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from lib.configuration import configuration_load_ini

class MissingFieldError(Exception):
    def __init__(self, message):
        super().__init__(message)

g_report_file=None

def assemble_column_name_and_stage_name_dict(parse_set):
    """Collect the stage names for every target column name and vice versa over all load operations"""
    column_name_to_stage_name_dict = {}
    stage_name_to_column_name_dict ={}
    for load_operation in parse_set['load_operations']:
        if 'data_mapping' in load_operation:
            for column in load_operation['data_mapping']:
                column_name=column['column_name']
                stage_name=column['stage_column_name']
                if column_name not in column_name_to_stage_name_dict:
                    column_name_to_stage_name_dict[column_name]=[stage_name]
                elif stage_name not in  column_name_to_stage_name_dict[column_name]:
                    column_name_to_stage_name_dict[column_name].append(stage_name)
                if stage_name not in stage_name_to_column_name_dict:
                    stage_name_to_column_name_dict[stage_name]=[column_name]
                elif column_name not in stage_name_to_column_name_dict[stage_name]:
                    stage_name_to_column_name_dict[stage_name].append(column_name)

        for column in load_operation['hash_mappings']: # collect the mappings from the hash_mappings
            if not 'field_name' in column:             # where the hash is provided by a source field
                continue
            column_name=column['column_name']
            stage_name=column['stage_column_name']
            if column_name not in column_name_to_stage_name_dict:
                column_name_to_stage_name_dict[column_name]=[stage_name]
            elif stage_name not in  column_name_to_stage_name_dict[column_name]:
                column_name_to_stage_name_dict[column_name].append(stage_name)
            if stage_name not in stage_name_to_column_name_dict:
                stage_name_to_column_name_dict[stage_name]=[column_name]
            elif column_name not in stage_name_to_column_name_dict[stage_name]:
                stage_name_to_column_name_dict[stage_name].append(column_name)


    return column_name_to_stage_name_dict,stage_name_to_column_name_dict

def assemble_stage_with_target_column_type_dict(parse_set,tables):
    stage_with_target_column_type_dict={}
    for stage_column in parse_set["stage_columns"]:
        if stage_column['stage_column_class'] != "data":
            continue
        table_name = None
        column_name = None
        for load_operation in parse_set['load_operations']:  # scan all operations for a mapping the current stage column
            if 'data_mapping' in load_operation:
                for column_mapping in load_operation['data_mapping']:
                    if column_mapping['stage_column_name']==stage_column['stage_column_name']:
                        table_name=load_operation['table_name']
                        column_name=column_mapping['column_name']
                        break
            for hash_mapping in load_operation['hash_mappings']:  # scan the  hash_mappings
                if not 'field_name' in hash_mapping:  # where the hash is provided by a source field
                    continue
                if hash_mapping['stage_column_name']==stage_column['stage_column_name']:
                     table_name=load_operation['table_name']
                     column_name=hash_mapping['column_name']
                     break
            if table_name != None:
                break
        # at this point we should have a hit, so search for the column type definition
        if table_name == None:
            raise Exception(f"Stage column '{stage_column['stage_column_name']}' is not mapped in any operation. This should not happen")
        column_type=None
        for table in tables:
            if table['table_name']==table_name:
                for column in table['columns']:
                    if column['column_name']==column_name: #gotcha
                        column_type=column['column_type']
                        break
                if column_type != None:
                    break
        stage_with_target_column_type_dict[stage_column['stage_column_name']]=column_type #finally we know

    return stage_with_target_column_type_dict


def determine_combined_stage_column_name(stage_column_name, stage_name_to_column_name_dict,
                                         column_name_to_stage_name_dict):
    """
                Stage     Target     Result
    1:1         BK1  (1)  BK1   (1)  BK1

    1:1         BK2  (1)  BK2a  (1)  BK2a

    n:1         BK3a (1)  t.BK3 (2)  BK3_BK3a
                BK3b (1)  u.BK3 (2)  BK3_BK3b

    1:n         BK4  (2)  BK4a  (1)  BK4a_BK4b
                BK4  (2)  BK4b  (1)  BK4a_BK4b

    m:n         BK5a (2)  t.BK5 (2)  BK5a
                BK5b (2)  t.BK5 (2)  BK5b
                BK5a (2)  u.BK5 (2)
                BK5b (2)  u.BK5 (2)
    """

    if len(stage_name_to_column_name_dict[stage_column_name]) == 1:    # stage column has only one target
        target_column_name = stage_name_to_column_name_dict[stage_column_name][0]
        if len(column_name_to_stage_name_dict[target_column_name]) == 1 or target_column_name==stage_column_name:    # target name is unique (1:1) or same
            final_column_name = target_column_name
        else:                                                          # different targets take same source (1:n)
            final_column_name = target_column_name+"__"+stage_column_name
    else:                                                              # stage column has multiple targets
        all_targets_have_single_source=True
        for target_column_name in stage_name_to_column_name_dict[stage_column_name]:
            if len(column_name_to_stage_name_dict[target_column_name]) > 1:
                all_targets_have_single_source = False
                break
        if all_targets_have_single_source:                             # n:1
            final_column_name = "__".join(stage_name_to_column_name_dict[stage_column_name])
        else:                                                          # m:n
            final_column_name = stage_column_name

    return final_column_name


def operation_loadable_by_convention(load_operation,stage_column_to_final_column_name_dict):
    for hash_mapping in load_operation['hash_mappings']:
        if hash_mapping['column_name']!=hash_mapping['stage_column_name']:
            return False

    if 'data_mapping' not in load_operation:
        return True
    for data_mapping in load_operation['data_mapping']:
        if data_mapping['column_name']!=stage_column_to_final_column_name_dict[data_mapping['stage_column_name']]:
            return False
    return True


def create_op_list(dvpi):
    """
    this function renders a operations list from a given dvpi
    :param dvpi: json of the dvpi
    :return: rendered_operations_list
    """
    schema_tables = {}  # dict which stores tables per schema
    schema_sats = {}  # dict which stores satellites per schema
    op_list = []
    table_dict = {}  # key: table-name | value: schema_name

    # Get Table-Info from .tables - except relations-info
    for table in dvpi['tables']:
        schema_name = table['schema_name']
        schema_tables[schema_name] = 0
        schema_sats[schema_name] = 0
        table_name = table['table_name']
        schema_tables[schema_name] += 1
        if table['table_stereotype'] == "sat":
            schema_sats[schema_name] += 1

        table_dict[table_name] = schema_name

    # Get Op-List & Relation-Info from .parse_sets[].load_operations
    for parse_set in dvpi['parse_sets']:
        table_op_dict = {}
        # TODO: In the future add functionaility for multiple parse sets
        for load_op in parse_set['load_operations']:
            table_name = load_op['table_name']
            table_op_dict[table_name] = 1 if table_name not in table_op_dict else table_op_dict[table_name] + 1

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
    if len(schema_with_max_count) == 1:
        schema_name = schema_with_max_count[0]
    else:
        # Filter schema_sat to keep only schemas with max counts
        filtered_schemas = {key: schema_sats[key] for key in schema_sats if key in schema_with_max_count}
        schema_name = max(filtered_schemas, key=filtered_schemas.get)

    # Get StageTable from .parse_sets[].stage_properties
    # TODO: In the future add functionality for mutliple parse-sets & multiple stage_tables
    for stage_table in dvpi['parse_sets'][0]['stage_properties']:
        stage_table_name = stage_table['stage_table_name']
        op_list.insert(0, f"stage_table.{schema_name}.{stage_table_name}")

    return  "\n".join(op_list)


def get_load_description(load_operation, stage_column_to_final_column_name_dict):
    description_rows=[]
    for hash_mapping in load_operation['hash_mappings']:
        change_marker = " "
        if hash_mapping['stage_column_name'] != hash_mapping['column_name']:
            change_marker = "*"
        description_rows.append("\t\t{} {}: {}  >  {}".format(change_marker, hash_mapping['hash_class'],hash_mapping['stage_column_name'], hash_mapping['column_name']))

    if 'data_mapping' in load_operation:
        #description_rows.append("\n")
        for data_mapping in load_operation['data_mapping']:
            stage_coulumn_name=stage_column_to_final_column_name_dict[data_mapping['stage_column_name']]
            change_marker=" "
            if stage_coulumn_name!=data_mapping['column_name']:
                change_marker="*"
            description_rows.append(
                "\t\t{} {}: {}  >  {} ".format(change_marker,data_mapping['column_class'],stage_coulumn_name, data_mapping['column_name']))
    return "\n".join(description_rows)


def get_table_from_tables(tables, table_name):
    for table in tables:
        if table['table_name']==table_name:
            return table
    raise Exception(f"dvpi is inconsistent. Table '{table_name}' referenced but not defined.")



def render_dev_cheat_sheet(dvpi_filepath, documentation_directory, stage_column_naming_rule='stage'):
    """
    renders a cheat sheet, that contains all crucial information for the developer
    """
    global  g_report_file
    with open(dvpi_filepath, 'r') as file:
        dvpi = json.load(file)

    # Check for missing fields
    if 'tables' not in dvpi:
        raise MissingFieldError("The field 'tables' is missing in the DVPI.")
    
    if 'parse_sets' not in dvpi:
        raise MissingFieldError("The field 'parse_sets' is missing in the DVPI.")

    # Extract tables and stage tables
    tables = dvpi.get('tables', [])
    parse_sets = dvpi.get('parse_sets', [])
    tables=dvpi['tables']
    report_file_name = dvpi['pipeline_name']+".devsheet.txt"
    report_sheet_file_path = documentation_directory.joinpath(report_file_name)

    with open(report_sheet_file_path, "w") as g_report_file:
        g_report_file.write(f"Data vault pipeline developer cheat sheet \n")
        print("---")
        g_report_file.write(f"rendered from  {dvpi_filepath.stem}\n\n")
        g_report_file.write(f"pipeline name:  {dvpi['pipeline_name']}\n\n")


        for parse_set in parse_sets:
            g_report_file.write("------------------------------------------------------\n")
            g_report_file.write(f"record source:  {parse_set['record_source_name_expression']}\n\n")



            g_report_file.write(f"Source fields:\n")
            max_name_length = 0
            fields=parse_set['fields']
            for field in fields:
                if len(field['field_name']) > max_name_length:
                    max_name_length = len(field['field_name'])
            for field in parse_set['fields']:
                g_report_file.write(
                    f"       {field['field_name'].ljust(max_name_length)}  {field['field_type']}\n")

            g_report_file.write("\n\n------------------------------------------------------\n")
            g_report_file.write(f"Table List:\n")
            g_report_file.write(create_op_list(dvpi))

            stage_properties = parse_set['stage_properties']
            if len(stage_properties) == 1:
                stage_properties = stage_properties[0]
                schema_name = stage_properties['stage_schema']
                table_name = stage_properties['stage_table_name']
                full_name = "{}.{}".format(schema_name, table_name)
            else:
                raise AssertionError("Currently only one stage properties object is supportet!")
                # TODO: implement this case

            g_report_file.write("\n\n------------------------------------------------------\n")
            g_report_file.write(f"stage table:  {full_name}\n")

            g_report_file.write(f"Field to Stage mapping:\n")

            columns = parse_set['stage_columns']

            column_name_to_stage_name_dict={}
            stage_name_to_column_name_dict={}
            stage_with_target_column_type_dict={}
            if stage_column_naming_rule=='combined':
                column_name_to_stage_name_dict,stage_name_to_column_name_dict=assemble_column_name_and_stage_name_dict(parse_set)
                stage_with_target_column_type_dict=assemble_stage_with_target_column_type_dict(parse_set,tables)

            hash_keys = []
            business_keys = []
            content = []
            content_untracked = []
            field_to_stage_dict={}
            stage_column_to_final_column_name_dict = {}

            for column in columns:
                stage_column_name = column['stage_column_name']
                stage_column_class = column['stage_column_class']
                col_type=column['column_type']
                if stage_column_class == 'data':
                    match stage_column_naming_rule:
                        case 'stage':
                            final_column_name=stage_column_name
                        case 'combined':
                            final_column_name=determine_combined_stage_column_name(stage_column_name, stage_name_to_column_name_dict, column_name_to_stage_name_dict)
                            col_type=stage_with_target_column_type_dict[stage_column_name]
                        case _:
                            raise AssertionError(f"unknown stage_column_naming_rule! '{stage_column_naming_rule}'")

                    column_classes = column['column_classes']
                    field_name=column['field_name']
                    field_to_stage_dict[field_name]=final_column_name # add the fineal column name to the field dict for later use
                    stage_column_to_final_column_name_dict[stage_column_name]=final_column_name
                    if 'parent_key'  in column_classes:
                        hash_keys.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    elif 'business_key' in column_classes or 'dependent_child_key' in column_classes:
                        business_keys.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    elif 'content_untracked' in column_classes:
                        content_untracked.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    elif 'content' in column_classes:
                        content.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    else:
                        raise AssertionError(f"unexpected column class! {column_classes} are currently not supported!")
            
            # sort the arrays of the stage columns
            hash_keys.sort()
            business_keys.sort()
            content.sort()
            content_untracked.sort()
            stage_column_info = []
            if len(hash_keys) > 0:
                stage_column_info += ["\t--hash keys"] + hash_keys
            if len(business_keys) > 0:
                stage_column_info += ["\t--business keys"] + business_keys
            if len(content) > 0:
                stage_column_info += ["\n\t--content"] + content
            if len(content_untracked) > 0:
                stage_column_info += ["\n\t--content untracked"] + content_untracked

            stage_column_info = ',\n'.join(stage_column_info)
            g_report_file.write(stage_column_info)

            # now provide the hash composition information
            g_report_file.write("\n\n------------------------------------------------------\n")
            g_report_file.write("Hash value composition\n")
            for hash_value in parse_set['hashes']:
                g_report_file.write(f"\n{hash_value['stage_column_name']} ({hash_value['column_class']})\n")
                if hash_value['column_class'] == 'key':
                    hash_fields_sorted = sorted(hash_value['hash_fields'], key=lambda d: "{:03d}".format(
                        d.get('parent_declaration_position', 0)) + '_/_' + d['field_target_table'] + '_/_' + str(
                        d['prio_in_key_hash']) + '_/_' + d['field_target_column'])
                else:
                    hash_fields_sorted = sorted(hash_value['hash_fields'],
                                                key=lambda d: '_' + str(d['prio_in_diff_hash']) + '_/_' + d[
                                                    'field_target_column'])
                for hash_field in hash_fields_sorted:
                    g_report_file.write(f"\t\t{field_to_stage_dict[hash_field['field_name']]} \n")

            # finally list the load operations and annotate special constellations
            g_report_file.write("\n\n------------------------------------------------------\n")
            g_report_file.write("Table load method\n")
            g_report_file.write("(STAGE >  VAULT)\n\n")
            for load_operation in parse_set['load_operations']:
                table_name=load_operation['table_name']
                table=get_table_from_tables(tables,table_name)
                relation_name=load_operation['relation_name']
                if operation_loadable_by_convention(load_operation,stage_column_to_final_column_name_dict):
                    g_report_file.write(f"{table_name} ({relation_name}) can be loaded by convention\n")
                else:
                    g_report_file.write(f"{table_name} ({relation_name}) needs explicit loading:\n")
                if 'driving_keys' in table:
                    driving_key_string=",".join(table['driving_keys'])
                    g_report_file.write(f"\t\t! Driving keys: {driving_key_string} \n")
                load_description=get_load_description(load_operation,stage_column_to_final_column_name_dict)
                g_report_file.write(f"{load_description}\n\n")


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

########################   MAIN ################################
if __name__ == '__main__':
    description_for_terminal = "Process dvpi at the given location to render the developer sheet."
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpi_file_name',  help='Name the file to process. File must be in the configured dvpi_default_directory.Use @youngest to parse the youngest.')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--stage_column_naming_rule", help="Rule to use for stage column naming [stage,combined]", default='#notset#')
    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'rendering', ['dvpi_default_directory','documentation_directory'])

    if args.stage_column_naming_rule =='#notset#':
        stage_column_naming_rule=params.get('stage_column_naming_rule','stage')
    else:
        stage_column_naming_rule=args.stage_column_naming_rule

    dvpi_default_directory = Path(params['dvpi_default_directory'])
    documentation_directory = Path(params['documentation_directory'])

    # create target directory
    if not os.path.isdir(documentation_directory):
        print(f"creating dir: "+documentation_directory.name)
        documentation_directory.mkdir(parents=True)
    
    dvpi_file_name=args.dvpi_file_name
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")

    render_dev_cheat_sheet(dvpi_file_path, documentation_directory
                                        , stage_column_naming_rule=stage_column_naming_rule)

    print("--- dev developers sheet render complete ---")

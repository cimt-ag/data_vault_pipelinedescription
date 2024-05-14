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

    return column_name_to_stage_name_dict,stage_name_to_column_name_dict

def assemble_stage_with_target_column_type_dict(parse_set,tables):
    stage_with_target_column_type_dict={}
    for stage_column in parse_set["stage_columns"]:
        if stage_column['stage_column_class'] != "data":
            continue
        table_name = None
        column_name = None
        for load_operation in parse_set['load_operations']:  # scan all operations for a mapping the current stage column
            if 'data_mapping' not in load_operation:
                continue
            for column_mapping in load_operation['data_mapping']:
                if column_mapping['stage_column_name']==stage_column['stage_column_name']:
                    table_name=load_operation['table_name']
                    column_name=column_mapping['column_name']
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


def get_load_description(load_operation, stage_column_to_final_column_name_dict):
    description_rows=[]
    for hash_mapping in load_operation['hash_mappings']:
        description_rows.append("\t\t{}  >  {}".format(hash_mapping['stage_column_name'], hash_mapping['column_name']))

    if 'data_mapping' in load_operation:
        description_rows.append("\n")
        for data_mapping in load_operation['data_mapping']:
            description_rows.append(
                "\t\t{}: {}  >  {} ".format(data_mapping['column_class'],stage_column_to_final_column_name_dict[data_mapping['stage_column_name']], data_mapping['column_name']))
    return "\n".join(description_rows)


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

    report_file_name = dvpi['pipeline_name']+".devcheat.txt"
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



            stage_properties = parse_set['stage_properties']
            if len(stage_properties) == 1:
                stage_properties = stage_properties[0]
                schema_name = stage_properties['stage_schema']
                table_name = stage_properties['stage_table_name']
                full_name = "{}.{}".format(schema_name, table_name)
            else:
                raise AssertionError("Currently only one stage properties object is supportet!")
                # TODO: implement this case


            g_report_file.write(f"\n\nstage table:  {full_name}\n")

            g_report_file.write(f"Field to Stage mapping:\n")

            columns = parse_set['stage_columns']

            column_name_to_stage_name_dict={}
            stage_name_to_column_name_dict={}
            stage_with_target_column_type_dict={}
            if stage_column_naming_rule=='combined':
                column_name_to_stage_name_dict,stage_name_to_column_name_dict=assemble_column_name_and_stage_name_dict(parse_set)
                stage_with_target_column_type_dict=assemble_stage_with_target_column_type_dict(parse_set,tables)

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
                    if 'business_key' in column_classes or 'dependent_child_key' in column_classes:
                        business_keys.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    elif 'content_untracked' in column_classes:
                        content_untracked.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    elif 'content' in column_classes:
                        content.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
                    else:
                        raise AssertionError(f"unexpected column class! {column_classes} are currently not supported!")
            
            # sort the arrays of the stage columns
            business_keys.sort()
            content.sort()
            content_untracked.sort()
            stage_column_info = []
            if len(business_keys) > 0:
                stage_column_info += ["\t--business keys"] + business_keys
            if len(content) > 0:
                stage_column_info += ["\n\t--content"] + content
            if len(content_untracked) > 0:
                stage_column_info += ["\n\t--content untracked"] + content_untracked

            stage_column_info = ',\n'.join(stage_column_info)
            g_report_file.write(stage_column_info)

            # now provide the hash composition information
            g_report_file.write("\n\nHash value composition\n----------------------\n")
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
            g_report_file.write("\n\nTable load method\n----------------------\n")
            g_report_file.write("(STAGE >  VAULT)\n\n")
            for load_operation in parse_set['load_operations']:
                table_name=load_operation['table_name']
                relation_name=load_operation['relation_name']
                if operation_loadable_by_convention(load_operation,stage_column_to_final_column_name_dict):
                    g_report_file.write(f"{table_name} ({relation_name}) can be loaded by convention\n\n")
                else:
                    g_report_file.write(f"{table_name} ({relation_name}) needs explicit loading:\n")
                    load_description=get_load_description(load_operation,stage_column_to_final_column_name_dict)
                    g_report_file.write(f"{load_description}\n\n")


def get_name_of_youngest_dvpi_file(dvpi_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpi_default_directory):
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

    dvpi_default_directory = Path(params['dvpi_default_directory'], fallback=None)
    documentation_directory = Path(params['documentation_directory'], fallback=None)
    
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

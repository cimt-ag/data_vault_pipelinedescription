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

output_file=None


def render_for_all_parsesets(dvpi_filepath, documentation_directory, stage_column_naming_rule='stage'):
    """
    Checks main requirements and creates files for every parse set and calls the rendering function
    """
    global  output_file

    # load the dvpi and check
    with open(dvpi_filepath, 'r') as file:
        dvpi = json.load(file)


    if 'record_source_name_expression' not in dvpi:
        raise MissingFieldError("The keyword 'record_source_name_expression' is missing in the DVPI.")
    record_source_expression=dvpi['record_source_name_expression']

    if 'parse_sets' not in dvpi:
        raise MissingFieldError("The keyword 'parse_sets' is missing in the DVPI.")
    parse_sets = dvpi.get('parse_sets', [])

    if 'data_extraction' not in dvpi:
        raise MissingFieldError("The keyword 'data_extraction' is missing in the DVPI.")
    data_extraction_ppt=dvpi['data_extraction']

    if 'fetch_module_name' not in data_extraction_ppt:
        raise MissingFieldError("The keyword 'data_extraction.fetch_module_name' is missing in the DVPI.")
    if data_extraction_ppt['fetch_module_name'] != 'transformation_view':
        print("Ignoring DVPI, since data extraction fetch module name is not 'transformation_view'")
        return 0

    if 'view_schema' is not in data_extraction_ppt:
        raise MissingFieldError("The keyword 'data_extraction.view_schema' is missing in the DVPI.")
    if 'view_name' is not in data_extraction_ppt:
        raise MissingFieldError("The keyword 'data_extraction.view_name' is missing in the DVPI.")

    view_schema=data_extraction_ppt['view_schema']
    view_name = data_extraction_ppt['view_name']


    for parse_set in parse_sets:
        stage_table_name = parse_set['stage_properties']['stage_table_name']
        report_file_name = "insert_" + view_name + "_to_" + stage_table_name +".sql"
        report_sheet_file_path = documentation_directory.joinpath(report_file_name)
        with open(report_sheet_file_path, "w") as output_file:
            render_insert_for_parse_set(output_file,parse_set,view_schema,view_name,record_source_expression,stage_column_naming_rule)


def get_meta_expression(stage_column_class):
    """ Provides the SQL expression to be used for the different meta columns"""
    match stage_column_class:
        case 'meta_load_date':
            return '{instance_start_timestamp}'
        case 'meta_load_process_id':
            return '{instance_run_id}'
        case ''



    if stage_column_class ==


def render_insert_for_parse_set(output_file,parse_set,view_schema,view_name,record_source_expression,stage_column_naming_rule)

    meta_column_expressions=[{'meta_load_date':'current_timestamp'},
                             {'meta_load_process_id':'-999'},
                             {'meta_record_source':record_source_expression},
                             {'meta_deletion_flag': 'false'}
                             ]

    output_file.write(f"-- === BEGIN OF GENERATED INSERT TO STAGE STATEMENT === \n\n")


    stage_table_name = parse_set['stage_properties']['stage_table_name']
    stage_schema = parse_set['stage_properties']['stage_schema']


    stage_columns = parse_set['stage_columns']


    column_name_to_stage_name_dict={}
    if stage_column_naming_rule=='combined':
        column_name_to_stage_name_dict=assemble_column_name_to_stage_name_dict(stage_columns)

    insert_columns = []  # in this array we collect the target column and select expression pairs

    for stage_column_ppt in stage_columns:
        stage_column_name = stage_column_ppt['stage_column_name']
        stage_column_class = stage_column_ppt['stage_column_class']

        if stage_column_class.startswith('meta'):
            if stage_column_class not in meta_column_expressions:
                raise AssertionError(f"unknown meta stage_column_class! '{stage_column_class}'")
            insert_column={'stage_column_name':stage_column_name,'select_expression':meta_column_expressions[stage_column_class]}
            insert_columns.append(insert_column)
            continue

        if stage_column_class=='hash':
            hash_ppt=get_hash_ppt_by_name(stage_column_ppt['hash_name'], parse_set['hashes'])
            hash_input_string=assemble_hash_concat_expression(hash_ppt)
            sql_expression="lib.DV_HASH("+hash_input_string+")"
            insert_column={'stage_column_name':stage_column_name,'select_expression':sql_expression}
            insert_columns.append(insert_column)


        if stage_column_class == 'data' or stage_column_class == 'direct_key':
            match stage_column_naming_rule:
                case 'stage':
                    final_column_name=stage_column_name
                case 'combined':
                    final_column_name=determine_combined_stage_column_name(stage_column_ppt,column_name_to_stage_name_dict)
                case _:
                    raise AssertionError(f"unknown stage_column_naming_rule! '{stage_column_naming_rule}'")

            column_classes = stage_column_ppt['column_classes']
            field_name=stage_column_ppt['field_name']
            field_to_stage_dict[field_name]=final_column_name # add the fineal column name to the field dict for later use
            stage_column_to_final_column_name_dict[stage_column_name]=final_column_name
            if len(stage_column_ppt['targets'])==0:  # this stage column is not mapped to any target
                unmapped.append("\t\t{}  >  {}".format(field_name.ljust(max_name_length),final_column_name))
            elif 'key' in column_classes or 'parent_key'  in column_classes:
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
        stage_column_info += ["\n\t--business keys"] + business_keys
    if len(unmapped) > 0:
        stage_column_info += ["\n\t--business keys only for hashes"] + unmapped
    if len(content) > 0:
        stage_column_info += ["\n\t--content"] + content
    if len(content_untracked) > 0:
        stage_column_info += ["\n\t--content untracked"] + content_untracked

    stage_column_info = '\n'.join(stage_column_info)
    output_file.write(stage_column_info)

    output_file.write(SECTION_END_STRING)

    # >>>>>>>>>>  hash composition information    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    output_file.write("Composition of hash columns that must be calculated\n")
    output_file.write(SECTION_HEAD_SEPARATOR_STRING)

    for hash_definition in parse_set['hashes']:
        if 'direct_key_field' in hash_definition:
            continue  # no need to print the trivial direct copy
        output_file.write(f"\n{hash_definition['stage_column_name']} ({hash_definition['column_class']})\n")
        if hash_definition['column_class'] == 'key':
            hash_fields_sorted=sorted(hash_definition['hash_fields'], key=lambda d: "{:03d}".format(
                d.get('parent_declaration_position', 0)) + '_/_' + d['field_target_table'] + '_/_' + str(
                d['prio_in_key_hash']) + '_/_' + d['field_target_column'])
        else:
            hash_fields_sorted=sorted(hash_definition['hash_fields'],
                                        key=lambda d: '_' + str(d['prio_in_diff_hash']) + '_/_' + d[
                                            'field_target_column'])
        for hash_field in hash_fields_sorted:
            output_file.write(f"\t\t{field_to_stage_dict[hash_field['field_name']]} \n")


    output_file.write(SECTION_END_STRING)



    # iteration over parse sets complete at this point (yes we need to refactor this)
    output_file.write("\n\n--- END OF GENERATED INSERT TO STAGE STATEMENT   ---\n")




def assemble_column_name_to_stage_name_dict(stage_columns):
    """Collect the stage names for every target column name
       This is needed to create the best target based stage column name
      ( This whole mechanic will later be moved into a dvpd preprocessor,
       so the rule must only be implemented once)"""
    column_name_to_stage_name_dict = {}
    for stage_column_ppt in stage_columns:
        stage_name = stage_column_ppt['stage_column_name']
        if 'targets' in stage_column_ppt:
            for target_entry in stage_column_ppt['targets']:
                column_name = target_entry['column_name']
                if column_name not in column_name_to_stage_name_dict:
                    column_name_to_stage_name_dict[column_name]=[stage_name]
                elif stage_name not in  column_name_to_stage_name_dict[column_name]:
                    column_name_to_stage_name_dict[column_name].append(stage_name)

    return column_name_to_stage_name_dict


def determine_combined_stage_column_name(stage_column,column_name_to_stage_name_dict):
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
    ( This whole mechanic will later be moved into a dvpd preprocessor,
       so the rule must only be implemented once)
    """
    if 'targets' not in stage_column: # no targest annotated
        return stage_column['stage_column_name']

    if len(stage_column['targets'])==0: # no targest annotated
        return stage_column['stage_column_name']

    stage_column_name=stage_column['stage_column_name']
    stage_targets=stage_column['targets']

    if len(stage_targets) == 1:  # stage column has only one target
        target_column_name =stage_targets['column_name']
        if len(column_name_to_stage_name_dict[target_column_name]) == 1 or target_column_name==stage_column_name:    # target name is unique (1:1) or same
            final_column_name = target_column_name
        else:                                                          # different targets take same source (1:n)
            final_column_name = target_column_name+"__"+stage_column_name
    else:                                                              # stage column has multiple targets
        all_targets_have_single_source=True
        for target_column in stage_targets:
            if len(column_name_to_stage_name_dict[target_column['column_name']) > 1:
                all_targets_have_single_source = False
                break
        if all_targets_have_single_source:                             # n:1
            target_column_names=[]
            for target_column in stage_targets:
                target_column_names.append(target_column['column_name'])
            final_column_name = "__".join(target_column_names)
        else:                                                          # m:n is not solvable, fall back to original field name
            final_column_name = stage_column_name

    return final_column_name



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

    print("=== render insert stage from a view  ===")

    description_for_terminal = "Process dvpi at the given location to render a statement, that inserts data from a view into the stage table."
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

    params = configuration_load_ini(args.ini_file, 'rendering', ['dvpi_default_directory','insert_to_stage_from_a_view_directory'])

    if args.stage_column_naming_rule =='#notset#':
        stage_column_naming_rule=params.get('stage_column_naming_rule','stage')
    else:
        stage_column_naming_rule=args.stage_column_naming_rule

    dvpi_default_directory = Path(params['dvpi_default_directory'])
    insert_to_stage_from_a_view_directory = Path(params['insert_to_stage_from_a_view_directory'])

    # create target directory
    if not os.path.isdir(insert_to_stage_from_a_view_directory):
        print(f"creating dir: "+insert_to_stage_from_a_view_directory.name)
        insert_to_stage_from_a_view_directory.mkdir(parents=True)
    
    dvpi_file_name=args.dvpi_file_name
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])
        print(f"Rendering from file {dvpi_file_name}")

    dvpi_file_path = Path(dvpi_file_name)
    if not dvpi_file_path.exists():
       dvpi_file_path = dvpi_default_directory.joinpath(dvpi_file_name)
       if not dvpi_file_path.exists():
            print(f"could not find file {args.dvpi_file_name}")

    render_for_all_parsesets(dvpi_file_path, insert_to_stage_from_a_view_directory
                             , stage_column_naming_rule=stage_column_naming_rule)

    print("--- render insert stage from a view complete ---\n")

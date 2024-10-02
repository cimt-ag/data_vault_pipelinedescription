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



def get_name_of_youngest_dvpd_file(dvpd_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpd_default_directory):
        if not os.path. isfile( dvpd_default_directory+'/'+file_name):
            continue
        file_mtime=os.path.getmtime( dvpd_default_directory+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file


def get_list_of_dvpd_files(dvpd_default_directory):
    list_of_files=[]
    for file_name in os.listdir( dvpd_default_directory):
        if not os.path.isfile( dvpd_default_directory+'/'+file_name):
            continue
        list_of_files.append(file_name)
    return list_of_files

def migrate_dvpd(source_file_path, target_file_path):
    with open(source_file_path, 'r') as file:
        try:
            source_dvpd= json.load(file)
        except json.JSONDecodeError as e:
            print("ERROR: JSON Parsing error. File will be skipped " + source_file_path.name)
            return

    # evaluate schema_table_name properties
    stage_table_name_syntax_addition=None
    if 'stage_properties' in source_dvpd:
        for stage_properties_entry in source_dvpd['stage_properties']:
            if not 'stage_table_name' in stage_properties_entry:
                legacy_stage_table_name='s'+source_dvpd['pipeline_name']
                stage_table_name_syntax_addition=f'"stage_table_name":"{legacy_stage_table_name}"'
    else:
        print("ERROR: No Stage Properties in the dvpd. File will be skipped " + source_file_path.name)

    # process every row and make adjustments
    with open(source_file_path, 'r') as source_file:
        with open(target_file_path,'w') as target_file:
            file_text=source_file.read()

            if stage_table_name_syntax_addition != None:
                search_regex = """stage_properties"\\s*:\\s*\\[\\{([^}]+)"""
                search_result=re.search(search_regex,file_text)
                source_stage_property=search_result.group(1)
                adapted_stage_property=source_stage_property+","+stage_table_name_syntax_addition
                file_text=file_text.replace(source_stage_property,adapted_stage_property)

            target_file.write(file_text)



########################   MAIN ################################


if __name__ == '__main__':
    description_for_terminal = "Refactor dpvd of version 0.6.1 into version 0.6.2"
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument('dvpd_file_name',  help='Name the file to process. File must be in the configured dvpd.Use @youngest to parse the youngest.')
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    args = parser.parse_args()

    # get config values
    params_dvpdc = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpd_default_directory'])
    dvpd_default_directory = Path(params_dvpdc['dvpd_default_directory'])

    params_migrate = configuration_load_ini(args.ini_file, 'migration', ['dvpd_migration_directory'])
    dvpd_migration_directory=Path(params_migrate['dvpd_migration_directory'])

    # create target directory
    if not os.path.isdir(dvpd_migration_directory):
        print(f"creating dir: migrated")
        dvpd_migration_directory.mkdir(parents=True)


    list_of_files=[]

    dvpd_file_name=args.dvpd_file_name
    if dvpd_file_name == '@youngest':
        list_of_files.append(get_name_of_youngest_dvpd_file(params_dvpdc['dvpd_default_directory']))
    elif  dvpd_file_name == '@all':
       list_of_files=get_list_of_dvpd_files(params_dvpdc['dvpd_default_directory'])
    else:
        list_of_files.append(dvpd_file_name)

    print("-- Migrate 0.6.1 to 0.6.2 --")
    for source_file_name in list_of_files:
        source_file_path = Path(source_file_name)
        target_file_path= dvpd_migration_directory/source_file_name

        if not source_file_path.exists():
           source_file_path = dvpd_default_directory.joinpath(source_file_name)
           if not source_file_path.exists():
                print(f"could not find file {args.source_file_name}")

        print("migrating dvpd file:" + source_file_name)

        migrate_dvpd(source_file_path,target_file_path)


    print("--- migration complete ---")

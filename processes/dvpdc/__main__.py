import argparse
import os
from pathlib import Path
from lib.configuration import configuration_load_ini
import json

table_dict=[]
field_dict=[]
def collect_essential_elements(dvpd_object):
    root_keys=['pipeline_name','dvpd_version','stage_properties','data_extraction','fields']
    error_count=0
    for key_name in root_keys:
        if dvpd_object.get(key_name)==None:
            print ("missing declaration of root property "+key_name)
            error_count +=1

    # Check essential keys of data model declaration
    table_keys=['table_name','table_stereotype']
    table_count = 0
    for schema_entry in dvpd_object['data_vault_model']:
        if schema_entry.get('schema_name') == None:
            print("\"schema_name\" is not dedclared")
            

        for table_entry in schema_entry['tables']:
            table_count+=1
            for key_name in table_keys:
                if table_entry.get(key_name) == None:
                    print("missing declaration of essential table property \"" + key_name + "\" for table "+ str(table_count))
                    error_count += 1


    if error_count>0:
        print ("Stop compoling due to errors")
        exit(5)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dvpd_filename", help="Name of the dvpd file to compile")
    parser.add_argument("--dvpi",  help="Name of the dvpi file to write (defaults to filename +  dvpi.json)")
    parser.add_argument("-l","--log filename", help="Name of the report file (defaults to filename + .dvpdc.log")
    args = parser.parse_args()

    params = configuration_load_ini('dvpdc.ini', 'dvpdc')

    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(args.dvpd_filename)
    if not os.path.exists(dvpd_file_path):
        raise Exception(f'could not find dvpd file: {dvpd_file_path}')

    print("Compiling "+ dvpd_file_path.as_posix())
    try:
        with open(dvpd_file_path, "r") as dvpd_file:
            dvpd_object=json.load(dvpd_file)
    except json.JSONDecodeError as e:
        print("ERROR: JSON Parsing error of file "+ dvpd_file_path.as_posix())
        print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        exit(5)

    collect_essential_elements(dvpd_object)

    print("json correct")


import argparse
import os
from pathlib import Path
from lib.configuration import configuration_load_ini
import json


g_error_count=0
g_table_dict={}
g_field_dict={}

def register_error(message):
    global g_error_count
    print(message)
    g_error_count += 1

def check_essential_element(dvpd_object):
    """Check for the essential keys, that are needed to identify the main objects"""

    root_keys=['pipeline_name','dvpd_version','stage_properties','data_extraction','fields']
    for key_name in root_keys:
        if dvpd_object.get(key_name)==None:
            register_error ("missing declaration of root property "+key_name)

    # Check essential keys of data model declaration
    table_keys=['table_name','table_stereotype']
    table_count = 0
    for schema_entry in dvpd_object['data_vault_model']:
        if schema_entry.get('schema_name') == None:
            register_error("\"schema_name\" is not dedclared")


        for table_entry in schema_entry['tables']:
            table_count+=1
            for key_name in table_keys:
                if table_entry.get(key_name) == None:
                    register_error("missing declaration of essential table property \"" + key_name + "\" for table "+ str(table_count))

    if table_count == 0:
        register_error("No table declared")

    # Check essential keys of field declaration
    field_keys = ['field_name', 'field_type','targets']
    field_count = 0
    for field_entry in dvpd_object['fields']:
        field_count += 1
        for key_name in field_keys:
            if field_entry.get(key_name) == None:
                register_error(f"missing declaration of essential field property \"{key_name}\" for field {field_count}")
            target_count=0
        if field_entry.get('targets') != None:
            for target_entry in field_entry.get('targets'):
                target_count += 1
                if target_entry.get('table_name') == None:
                    register_error(f"missing declaration of table_name: field {field_count}, target {target_count} ")


    if g_error_count>0:
        print ("*** Stopped compiling due to errors ***")
        exit(5)

def transform_hub_table(table_entry,schema_name,storage_component):
    """Cleanse check and add table declaration for a hub table"""
    global g_table_dict
    table_name = table_entry['table_name'].lower()
    table_properties={}
    table_properties['table_stereotype'] = 'hub'
    if 'hub_key_column_name' in table_entry:
        table_properties['hub_key_column_name'] = table_entry['hub_key_column_name'].upper()
    else:
        register_error(f'hub_key_column_name is not declared for hub table {table_name}')
    g_table_dict[table_name] = table_properties

def transform_lnk_table(table_entry,schema_name,storage_component):
    """Cleanse check and add table declaration for a lnk table"""
    global g_table_dict
    table_name = table_entry['table_name'].lower()
    table_properties={}
    table_properties['table_stereotype'] = 'lnk'
    if 'link_key_column_name' in table_entry:
        table_properties['link_key_column_name'] = table_entry['link_key_column_name'].upper()
    else:
        register_error(f'link_key_column_name is not declared for lnk table {table_name}')
    table_properties['is_link_without_sat'] = table_entry.get('is_link_without_sat', False)  # default is false

    if 'link_parent_tables' in table_entry:
        list_position=0
        table_properties['link_parent_tables']=[]
        for parent_entry in table_entry['link_parent_tables']:
            cleansed_parent_entry={}
            list_position += 1
            if isinstance(parent_entry,dict):
                if 'table_name' in parent_entry:
                    cleansed_parent_entry['table_name']=parent_entry['table_name' ].lower()
                    cleansed_parent_entry['relation_name']=parent_entry.get('relation_name','*')
                    cleansed_parent_entry['hub_key_column_name_in_link']=parent_entry.get('hub_key_column_name_in_link').upper()
                    cleansed_parent_entry['parent_list_position']=list_position
                else:
                    register_error(f'table_name is not declared in link_parent_tables for lnk table {table_name}')
            else:
                cleansed_parent_entry['table_name'] = parent_entry.lower()
                cleansed_parent_entry['relation_name'] = '*'
                cleansed_parent_entry['hub_key_column_name_in_link'] = None
                cleansed_parent_entry['parent_list_position'] = list_position
            #else:
            #    register_error(f'link_parent_tables has bad syntax for lnk table {table_name}')
            table_properties['link_parent_tables'].append(cleansed_parent_entry)
    else:
        register_error(f'link_parent_tables is not declared for lnk table {table_name}')


    # finally add this to the global table dictionary
    g_table_dict[table_name] = table_properties


def transform_sat_table(table_entry,schema_name,storage_component):
    """Cleanse check and add table declaration for a satellite table"""
    global g_table_dict
    table_name = table_entry['table_name'].lower()
    table_properties={}
    table_properties['table_stereotype'] = 'sat'
    if 'satellite_parent_table' in table_entry:
        table_properties['satellite_parent_table'] = table_entry['satellite_parent_table'].lower()
    else:
        register_error(f'satellite_parent_table is not declared for satellite table {table_name}')
    table_properties['is_multiactive']=table_entry.get('is_multiactive',False)  # default is false
    #todo Add model profile default logic ->
    table_properties['compare_criteria']=table_entry.get('compare_criteria','key+current').lower()  # default is profile
    #todo Add model profile default logic ->
    table_properties['is_enddated']=table_entry.get('is_enddated',True)  # default is profile
    #todo Add model profile default logic ->
    table_properties['uses_diff_hash']=table_entry.get('uses_diff_hash',True)  # default is profile
    if 'diff_hash_column_name' in table_entry:
        table_properties['diff_hash_column_name'] = table_entry['diff_hash_column_name'].upper()
    #todo Add model profile default logic ->
    table_properties['has_deletion_flag']=table_entry.get('has_deletion_flag',True)  # default is profile
    cleansed_driving_keys=[]
    if 'driving_keys' in table_entry:
        #todo check if driving keys is a list
        cleansed_driving_keys=[]
        for driving_key in table_entry['driving_keys']:
            cleansed_driving_keys.append(driving_key.upper())
    table_properties['driving_keys']=cleansed_driving_keys
    table_properties['tracked_relation_name'] = table_entry.get('tracked_relation_name')  # default is None

    # finally add the cleansed properties to the table dictionary
    g_table_dict[table_name] = table_properties

def transform_ref_table(table_entry,schema_name,storage_component):
    """Cleanse check and add table declaration for a satellite table"""
    global g_table_dict
    table_name = table_entry['table_name'].lower()
    table_properties={}
    table_properties['table_stereotype'] = 'ref'

    #todo Add model profile default logic ->
    table_properties['is_enddated']=table_entry.get('is_enddated',True)  # default is profile
    #todo Add model profile default logic ->
    table_properties['uses_diff_hash']=table_entry.get('uses_diff_hash',True)  # default is profile
    if 'diff_hash_column_name' in table_entry:
        table_properties['diff_hash_column_name'] = table_entry['diff_hash_column_name'].upper()

    # finally add the cleansed properties to the table dictionary
    g_table_dict[table_name] = table_properties

def collect_table_properties(dvpd_object):
    """collect and cleanse all necessary table properties"""
    for schema_entry in dvpd_object['data_vault_model']:
        schema_name=schema_entry['schema_name'].lower()
        storage_component=schema_entry.get('storage_component','').lower()
        for table_entry in schema_entry['tables']:
            if g_table_dict.get(table_entry['table_name'].lower()):
                register_error(f"table_name '{table_entry['table_name']}' has already been defined. table_name must be unique in the model")
                continue
            match table_entry['table_stereotype'].lower():
                case 'hub':
                    transform_hub_table(table_entry,schema_name,storage_component)
                case 'lnk':
                    transform_lnk_table(table_entry,schema_name,storage_component)
                case 'sat':
                    transform_sat_table(table_entry,schema_name,storage_component)
                case 'ref':
                    transform_ref_table(table_entry,schema_name,storage_component)
                case _:
                    register_error(f"Unknown table stereotype '{table_entry['table_stereotype']}' declared for table {table_entry['table_name']}")

    if g_error_count > 0:
        print("*** Stopped compiling due to errors ***")
        exit(5)

def collect_field_properties(dvpd_object):
    global g_field_dict

    field_position=0
    for field_entry in dvpd_object['fields']:
        field_name = field_entry['field_name'].upper()
        if g_field_dict.get(field_name) != None:
            register_error(f"Duplicate field_name declared: {field_name}")
        field_position += 1
        cleansed_field_entry=field_entry.copy()
        del cleansed_field_entry['targets']
        del cleansed_field_entry['field_name']
        cleansed_field_entry['field_position']=field_position
        cleansed_field_entry['needs_encryption'] = field_entry.get('needs_encryption',False)
        g_field_dict[field_name] = cleansed_field_entry
        map_field_to_tables(field_entry)

    if g_error_count > 0:
        print("*** Stopped compiling due to errors ***")
        exit(5)

def map_field_to_tables(field_entry):
    global g_table_dict

    field_name=field_entry['field_name'].upper()
    for table_mapping in field_entry['targets']:
        table_name=table_mapping['table_name'].lower()
        if not table_name in g_table_dict:
            register_error(f"Can't map field {field_name} to table {table_name}. Table is not declared in the model")
            continue
        table_map_entry={}
        table_map_entry['field_name']=field_name
        table_map_entry['column_name'] = table_mapping.get('column_name',field_name)  # defaults to field name
        table_map_entry['column_type'] = table_mapping.get('column_type',field_entry['field_type']).upper()  # defaults to field type
        table_map_entry['prio_for_column_position'] = table_mapping.get('prio_for_column_position',50000)  # defaults to 50000
        table_map_entry['prio_for_row_order'] = table_mapping.get('prio_for_row_order',50000)  # defaults to 50000
        table_map_entry['row_order_direction'] = table_mapping.get('row_order_direction','ASC')  # defaults to ASC
        table_map_entry['exclude_from_key_hash'] = table_mapping.get('exclude_from_key_hash',False)  # defaults to False
        table_map_entry['prio_in_key_hash'] = table_mapping.get('prio_in_key_hash',0)  # defaults to 0
        table_map_entry['exclude_from_change_detection'] = table_mapping.get('exclude_from_change_detection',False)  # defaults to False
        table_map_entry['prio_in_diff_hash'] = table_mapping.get('prio_in_diff_hash',0)  # defaults to 0
        table_map_entry['column_content_comment'] = table_mapping.get('column_content_comment',field_entry.get('field_comment'))
        table_map_entry['update_on_every_load'] = table_mapping.get('update_on_every_load',False)  # defaults to False
        relation_names_cleansed = []
        if 'relation_names' in table_mapping:
            for relation_name in  table_mapping['relation_names']:
                #todo test if relation_name is a string object
                relation_names_cleansed.append(relation_name.upper())
        table_map_entry['relation_names']=relation_names_cleansed
        # announced property: hash_cleansing_rules
        # announced property: hash_cleansing_rules

        # finally add this to the table
        table_entry=g_table_dict[table_name]
        if not 'field_assignment' in table_entry:
            table_entry['field_assignment']=[]
        table_entry['field_assignment'].append(table_map_entry)

def derive_content_dependent_table_properties():
    print("tbd")
    # iterate over all tables

    # for links
    #  add hub key column names to the references

    # for satellites

    # determine if it is an effectivity satellite

    #    if not effectitivity sat  table_properties['compare_criteria'] == 'key' or table_properties['compare_criteria'] != 'none'
    #     if table_properties['uses_diff_hash'] and diff hash is not declared:
    #           register_error(f'diff_hash_column_name is not declared but needed for satellite table {table_name}')

    # check if parent is link, when sat has driving keys

    # warn when parent is hub but sat is an esat

# ======================= Main =========================================== #

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

    check_essential_element(dvpd_object)
    collect_table_properties(dvpd_object)
    collect_field_properties(dvpd_object)

    print("compile successful")
    print("JSON of g_table_dict:")
    print(json.dumps(g_table_dict, indent=2))



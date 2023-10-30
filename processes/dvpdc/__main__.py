import argparse
import os
from pathlib import Path
from lib.configuration import configuration_load_ini
import json
from datetime import datetime



g_error_count=0
g_table_dict={}
g_field_dict={}
g_hash_dict={}
g_dvpi_document={}

def print_the_brain():
    print("compile successful")
    print("JSON of g_field_dict:")
    print(json.dumps(g_field_dict, indent=2,sort_keys=True))

    print("JSON of g_table_dict:")
    print(json.dumps(g_table_dict, indent=2,sort_keys=True))

    print("JSON of g_hash_dict:")
    print(json.dumps(g_hash_dict, indent=2,sort_keys=True))

def print_dvpi_document():
    print("DVPI :")
    print(json.dumps(g_dvpi_document, indent=2))


def register_error(message):
    global g_error_count
    print(message)
    g_error_count += 1

def remove_stereotype_suffix(table_name):
    """Removes cimt best practice stereotype suffixes from table names, so the name can be used for specific column name
    derivation """
    triggering_suffixes=['hub','lnk','sat','ref']
    words=table_name.split("_")
    reduced_table_name=table_name
    if len(words)>1:
        for suffix in triggering_suffixes:
            if words[-1].endswith(suffix):
                words.pop(-1)
                break
        reduced_table_name='_'.join(words)
    return reduced_table_name

def check_essential_element(dvpd_object):
    """Check for the essential keys, that are needed to identify the main objects"""

    root_keys=['pipeline_name','dvpd_version','stage_properties','data_extraction','fields']
    for key_name in root_keys:
        if dvpd_object.get(key_name) is None:
            register_error ("missing declaration of root property "+key_name)

    # Check essential keys of data model declaration
    table_keys=['table_name','table_stereotype']
    table_count = 0
    for schema_entry in dvpd_object['data_vault_model']:
        if schema_entry.get('schema_name') is None:
            register_error("\"schema_name\" is not dedclared")


        for table_entry in schema_entry['tables']:
            table_count+=1
            for key_name in table_keys:
                if table_entry.get(key_name) is None:
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
        if 'targets' in field_entry:
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
    table_properties= {'table_stereotype': 'hub'}
    if 'hub_key_column_name' in table_entry:
        table_properties['hub_key_column_name'] = table_entry['hub_key_column_name'].upper()
    else:
        table_properties['hub_key_column_name'] = "HK_"+remove_stereotype_suffix(table_name).upper()
        #register_error(f'hub_key_column_name is not declared for hub table {table_name}')
    g_table_dict[table_name] = table_properties

def transform_lnk_table(table_entry,schema_name,storage_component):
    """Cleanse check and add table declaration for a lnk table"""
    global g_table_dict
    table_name = table_entry['table_name'].lower()
    table_properties= {'table_stereotype': 'lnk'}
    if 'link_key_column_name' in table_entry:
        table_properties['link_key_column_name'] = table_entry['link_key_column_name'].upper()
    else:
        table_properties['link_key_column_name'] = "LK_" +remove_stereotype_suffix(table_name).upper()
        #register_error(f'link_key_column_name is not declared for lnk table {table_name}')
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
                    if 'hub_key_column_name_in_link' in parent_entry:
                        cleansed_parent_entry['hub_key_column_name_in_link']=parent_entry.get('hub_key_column_name_in_link').upper()
                    else:
                        cleansed_parent_entry['hub_key_column_name_in_link'] = None
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
    table_properties= {'table_stereotype': 'sat'}
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
    else:  # derive default for diff column hash name
        if table_properties['is_multiactive']:
            table_properties['diff_hash_column_name'] = 'GH_' + table_name.upper()
        else:
            table_properties['diff_hash_column_name'] = 'RH_' + table_name.upper()

    #todo Add model profile default logic ->
    table_properties['has_deletion_flag']=table_entry.get('has_deletion_flag',True)  # default is profile
    cleansed_driving_keys=[]
    if 'driving_keys' in table_entry:
        #todo check if driving keys is a list
        cleansed_driving_keys=[]
        for driving_key in table_entry['driving_keys']:
            cleansed_driving_keys.append(driving_key.upper())
    table_properties['driving_keys']=cleansed_driving_keys
    if 'tracked_relation_name' in table_entry:
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
    else:
        table_properties['diff_hash_column_name'] = 'RH_' + table_name.upper()

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
        create_columns_from_field_mapping(field_entry, field_position)

    if g_error_count > 0:
        print("*** Stopped compiling due to errors ***")
        exit(5)

def create_columns_from_field_mapping(field_entry, field_position):
    global g_table_dict

    field_name=field_entry['field_name'].upper()
    for table_mapping in field_entry['targets']:
        table_name=table_mapping['table_name'].lower()
        if not table_name in g_table_dict:
            register_error(f"Can't map field {field_name} to table {table_name}. Table is not declared in the model")
            continue
        column_map_entry={}
        column_name = table_mapping.get('column_name',field_name).upper()  # defaults to field name
        column_map_entry['field_name']=field_name
        column_map_entry['field_position']=field_position
        column_map_entry['column_type'] = table_mapping.get('column_type',field_entry['field_type']).upper()  # defaults to field type
        column_map_entry['prio_for_column_position'] = table_mapping.get('prio_for_column_position',50000)  # defaults to 50000
        column_map_entry['prio_for_row_order'] = table_mapping.get('prio_for_row_order',50000)  # defaults to 50000
        column_map_entry['row_order_direction'] = table_mapping.get('row_order_direction','ASC')  # defaults to ASC
        column_map_entry['exclude_from_key_hash'] = table_mapping.get('exclude_from_key_hash',False)  # defaults to False
        column_map_entry['prio_in_key_hash'] = table_mapping.get('prio_in_key_hash',0)  # defaults to 0
        column_map_entry['exclude_from_change_detection'] = table_mapping.get('exclude_from_change_detection',False)  # defaults to False
        column_map_entry['prio_in_diff_hash'] = table_mapping.get('prio_in_diff_hash',0)  # defaults to 0
        column_map_entry['column_content_comment'] = table_mapping.get('column_content_comment',field_entry.get('field_comment'))
        column_map_entry['update_on_every_load'] = table_mapping.get('update_on_every_load',False)  # defaults to False
        relation_names_cleansed = []
        if 'relation_names' in table_mapping:
            for relation_name in  table_mapping['relation_names']:
                #todo test if relation_name is a string object
                relation_names_cleansed.append(relation_name.upper())
        column_map_entry['relation_names']=relation_names_cleansed
        # announced property: hash_cleansing_rules

        # finally add this to the table
        table_entry=g_table_dict[table_name]
        if not 'data_columns' in table_entry:
            table_entry['data_columns']={}
        column_dict=table_entry['data_columns']
        if not column_name in column_dict:
            column_dict[column_name] = {}
        theColumn=column_dict[column_name]
        if not 'field_mappings' in theColumn:
            theColumn['field_mappings'] = []
        theColumn['field_mappings'].append(column_map_entry)


def check_multifield_mapping_consistency():
    global g_table_dict
    for table_name, table_entry in g_table_dict.items():
        if 'data_columns' in table_entry:
            for column_name,column_entry in table_entry['data_columns'].items():
                check_multifield_mapping_consistency_of_column(table_name, column_name, column_entry)

def check_multifield_mapping_consistency_of_column(table_name, column_name, column_entry):
    properties_to_align=['column_type','prio_for_column_position','prio_for_row_order','exclude_from_key_hash'
            ,'prio_in_key_hash','exclude_from_change_detection','prio_in_diff_hash']
    if not 'field_mappings' in column_entry:
        raise(f" no field mappings on data column {column_name} in table {table_name}")
    if len(column_entry['field_mappings']) <2:
        return      # there can be no conflict in single mappings
    #todo implement mapping comparison
    print("!!! WARNING !!!! Field mapping comparison is not implemented yet")

def derive_content_dependent_table_properties():
    global g_table_dict
    for table_name, table_entry in g_table_dict.items():
        match table_entry['table_stereotype']:
            case 'hub':
                derive_content_dependent_hub_properties(table_name,table_entry)
            case 'lnk':
                derive_content_dependent_lnk_properties(table_name,table_entry)
            case 'sat':
                derive_content_dependent_sat_properties(table_name,table_entry)
            case 'ref':
                derive_content_dependent_ref_properties(table_name,table_entry)
            case _:
                raise(
                    f"!!! Something bad happened !!! cleansed stereotype {table_entry['table_stereotype']} has no rule in derive_content_dependent_table_properties()")

    if g_error_count > 0:
        print("*** Stopped compiling due to errors ***")
        exit(5)

def derive_content_dependent_hub_properties(table_name,table_entry):
    if not 'data_columns' in table_entry:
        register_error(f"Hub table {table_name} has no field mapping. A hub without a business key makes no sense")
        return

    has_business_key=False
    for column_name,column_properties in table_entry['data_columns'].items():
        first_field=column_properties['field_mappings'][0]
        if first_field['exclude_from_key_hash']:
            column_properties['column_class'] = 'content_untracked'
        else:
            column_properties['column_class']='business_key'
            has_business_key=True
        column_properties['field_mapping_count']=len(column_properties['field_mappings'])
        for property_name in ['prio_for_column_position','field_position','prio_in_key_hash','exclude_from_key_hash','column_content_comment']:
            column_properties[property_name]=first_field[property_name]
        derive_implicit_relations(column_properties)

    if not has_business_key:
        register_error(f"Hub table {table_name} has no business key assigned")

def derive_content_dependent_lnk_properties(table_name, table_entry):
    global g_table_dict

    for link_parent in table_entry['link_parent_tables']:
        if link_parent['table_name'] not in g_table_dict:
            register_error(f"link parent table '{link_parent['table_name']}' of link '{table_name}' is not declared")
            return
        parent_table=g_table_dict[link_parent['table_name']]
        link_parent['parent_key_column_name']=parent_table['hub_key_column_name']

    if 'data_columns' in table_entry:
        for column_name, column_properties in table_entry['data_columns'].items():
            first_field = column_properties['field_mappings'][0]
            if first_field['exclude_from_key_hash']:
                column_properties['column_class'] = 'content_untracked'
            else:
                column_properties['column_class'] = 'dependent_child_key'
            column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
            for property_name in ['prio_for_column_position', 'field_position','prio_in_key_hash', 'exclude_from_key_hash','column_content_comment']:
                column_properties[property_name] = first_field[property_name]
            derive_implicit_relations(column_properties)


def derive_content_dependent_sat_properties(table_name, table_entry):
    if table_entry['satellite_parent_table'] not in g_table_dict:
        register_error(f"parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}' is not declared")
        return

    table_entry['is_effectivity_sat'] = not 'data_columns' in table_entry  # determine is_effectivity_sat

    parent_table = g_table_dict[table_entry['satellite_parent_table']]
    if parent_table['table_stereotype'] == 'hub':
        if table_entry['is_effectivity_sat']:
            register_error(f"Parent table '{table_entry['satellite_parent_table']}' of effectivity sat '{table_name}' is not a link")
    elif parent_table['table_stereotype'] != 'lnk':
        register_error(f"Parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}' is not a link or hub")

    if table_entry['is_effectivity_sat']:
        return  # without any columns, we are done here

    for column_name,column_properties in table_entry['data_columns'].items():
        first_field=column_properties['field_mappings'][0]
        if first_field['exclude_from_change_detection']:
            column_properties['column_class'] = 'content_untracked'
        else:
            column_properties['column_class']='content'
        column_properties['field_mapping_count']=len(column_properties['field_mappings'])
        for property_name in ['column_type','column_content_comment','prio_for_column_position','prio_for_row_order','row_order_direction','exclude_from_change_detection','prio_in_diff_hash']:
            column_properties[property_name]=first_field[property_name]
        derive_implicit_relations(column_properties)

def derive_content_dependent_ref_properties(table_name, table_entry):
    for column_name, column_properties in table_entry['data_columns'].items():
        first_field = column_properties['field_mappings'][0]
        if first_field['exclude_from_change_detection']:
            column_properties['column_class'] = 'content_untracked'
        else:
            column_properties['column_class'] = 'content'
        column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
        for property_name in ['column_type', 'column_content_comment','prio_for_column_position',
                              'exclude_from_change_detection', 'prio_in_diff_hash']:
            column_properties[property_name] = first_field[property_name]
        derive_implicit_relations(column_properties)

def derive_implicit_relations(column_properties):
    has_multiple_field_mappings= len(column_properties['field_mappings']) > 1
    for field_entry in  column_properties['field_mappings']:
        if len(field_entry['relation_names']) == 0:
            if has_multiple_field_mappings:
                field_entry['relation_names'].append('/')
            else:
                field_entry['relation_names'].append('*')



def derive_load_operations():
    global g_table_dict

    # collect declared relations
    for table_name,table_entry in g_table_dict.items():
        load_operations={}
        if 'data_columns' in table_entry:
            for data_column in table_entry['data_columns'].values():
                for field_mapping in data_column['field_mappings']:
                    for relation_name in field_mapping['relation_names']:
                        if relation_name != '*':
                            load_operations[relation_name]={"operation_origin":"explicit field mapping relation"}
        if 'tracked_relation_name' in table_entry:
            load_operations[table_entry['tracked_relation_name']] = {"operation_origin": "explicitly tracked relation"}
        if len(load_operations)>0:
            table_entry['load_operations']=load_operations
        link_relation_list=[]
        if 'link_parent_tables' in table_entry:
            for link_parent_entry in table_entry['link_parent_tables']:
                if link_parent_entry['relation_name'] != '*' and link_parent_entry['relation_name'] is not None :
                    link_relation_list.append(link_parent_entry['relation_name'])
        if len(link_relation_list)>0:
            table_entry['link_relations'] = link_relation_list
            if 'load_operations' not in table_entry:
                load_operations = {"/":{"operation_origin":"unnamed relation of link due to explict link relations"}}
                table_entry['load_operations'] = load_operations


    # hub tables, without explicit relations have the universal relation "*"
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == 'hub':
           if 'load_operations' not in table_entry:
                load_operations = {"*":{"operation_origin":"implicit universal relation of hub"}}
                table_entry['load_operations'] = load_operations


    # sat table without explicit relations, use the operations of their parent
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == 'sat':
            if 'load_operations' not in table_entry:
                parent_table=g_table_dict[table_entry['satellite_parent_table']]
                if 'load_operations' in parent_table:
                    load_operations = {}
                    for parent_operation in parent_table['load_operations']:
                        load_operations[parent_operation] = {"operation_origin":"following parent operation list"}
                else:
                    load_operations = {
                        "/": {"operation_origin": "implicit unnamed relation operation"}}
                table_entry['load_operations'] = load_operations

    # link without specific relation use relations of all their satellites (which at this point must have one)
    for link_table_name, link_table_entry in g_table_dict.items():
        if link_table_entry['table_stereotype'] == 'lnk':
            if 'load_operations' not in link_table_entry:
                load_operations = {}
                for sat_table_name,sat_table_entry in g_table_dict.items():
                    if sat_table_entry.get('satellite_parent_table') == link_table_name:
                        for sat_load_operation in sat_table_entry['load_operations']:
                            load_operations[sat_load_operation]={"operation_origin":f"induced from satellite {sat_table_name}"}
                if len(load_operations) > 0:
                    link_table_entry['load_operations'] = load_operations
                else:
                    load_operations = {"/": {"operation_origin": "implicit unnamed relation of link, that has no sat"}}
                    link_table_entry['load_operations'] = load_operations

    # ref tables alswys only have  "/" operation
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == 'ref':
           if 'load_operations' not in table_entry:
                load_operations = {"/":{"operation_origin":"ref table load operation"}}
                table_entry['load_operations'] = load_operations


def add_data_mapping_dict_to_load_operations():
    global g_table_dict
    for table_name,table_entry in g_table_dict.items():
        for relation_name,load_operation in table_entry['load_operations'].items():
            if 'data_columns' in table_entry:
                add_data_mapping_dict_for_one_load_operation(table_name, table_entry, relation_name, load_operation)

def add_hash_columns():
    # all hubs hashes first
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype']=="hub":
            add_hash_column_mappings_for_hub(table_name, table_entry)


    # then link hashes
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype']=="lnk":
            add_hash_column_mappings_for_lnk(table_name, table_entry)

    if g_error_count > 0:
        print_the_brain()
        print("*** Stopped compiling due to errors ***")
        exit(5)


    # finally sattelites
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype']=="sat":
            add_hash_column_mappings_for_sat(table_name, table_entry)

    if g_error_count > 0:
        print_the_brain()
        print("*** Stopped compiling due to errors ***")
        exit(5)

    # and reference tables
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype']=="ref":
             add_hash_column_mappings_for_ref(table_name, table_entry)

    if g_error_count > 0:
        print("*** Stopped compiling due to errors ***")
        exit(5)


def add_hash_column_mappings_for_hub(table_name,table_entry):
    global g_hash_dict

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']

    hash_base_name = "KEY_OF_"+table_name.upper()
    key_column_name = table_entry['hub_key_column_name']
    # create a hash for every operation
    load_operations=table_entry['load_operations']
    for relation_name, load_operation_entry in load_operations.items():
        if relation_name == "*" or relation_name == "/" or len(load_operations) == 1:
            hash_name = hash_base_name
            stage_column_name = key_column_name
        else:
            hash_name = hash_base_name + "__FOR__" + relation_name.upper()
            stage_column_name = key_column_name + "_" + relation_name.upper()

        hash_fields=[]
        for column_name,column_entry in load_operation_entry['data_mapping_dict'].items():
            if column_entry['exclude_from_key_hash'] :
                continue
            hash_field={'field_name':column_entry['field_name'],
                        'prio_in_key_hash':column_entry['prio_in_key_hash'],
                        'field_target_table':table_name,
                        'field_target_column':column_name}
            hash_fields.append(hash_field)

        # put hash definition into global list
        hash_description={   "stage_column_name": stage_column_name,
                        "hash_origin_table":table_name,
                         "column_class":"key",
                         "hash_fields":hash_fields}

        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name]=hash_description

        # add reference to global entry into load operation
        load_operation_entry['hash_mapping_dict']={'key':{     "hash_name":hash_name,
                                "hash_column_name":key_column_name,}}

        # put hash column in table hash list
        if key_column_name not in table_hash_columns:
            table_hash_columns[key_column_name]={"column_class":"key",
                                             "column_type":"#todo "} #todo integrate model profile



def add_hash_column_mappings_for_lnk(table_name,table_entry):
    link_hash_base_name = "KEY_OF_"+table_name.upper()
    link_key_column_name = table_entry['link_key_column_name']
    load_operations = table_entry['load_operations']

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']

    for relation_name, load_operation_entry in load_operations.items():
        hash_mapping_dict = {}
        load_operation_entry['hash_mapping_dict'] = hash_mapping_dict

        # render names according to relation
        if relation_name == "*" or relation_name == "/" or len(load_operations) == 1:
            link_hash_name = link_hash_base_name
            stage_column_name = link_key_column_name
        else:
            link_hash_name = link_hash_base_name + "_" + relation_name.upper()
            stage_column_name = link_key_column_name + "_" + relation_name

        link_hash_fields=[]

        # add parent hash key fields for this relation
        link_parent_count=0
        for link_parent_entry in table_entry['link_parent_tables']:
            link_parent_count+=1
            parent_table_entry=g_table_dict[link_parent_entry['table_name']]
            parent_load_operations=parent_table_entry['load_operations']
            if link_parent_entry['relation_name'] != '*':
                parent_relation= link_parent_entry['relation_name']  # the parent must provide operation of explicitly declared relation
            elif '*' in parent_load_operations:
                parent_relation = '*'  # the parent only has a universal relation
            else:
                parent_relation=relation_name  # the parent must provide the relation of the process of the link

            if not parent_relation in parent_load_operations:
                register_error(f"Hub '{link_parent_entry['table_name']}' has no business key mapping for relation '{parent_relation}' needed for link '{table_name}'"  )
                return
            parent_load_operation=parent_load_operations[parent_relation]
            parent_hash_reference_dict=parent_load_operation['hash_mapping_dict']
            parent_key_hash_reference=parent_hash_reference_dict['key']

            # assemble the column name for the hub key in the link
            if link_parent_entry['hub_key_column_name_in_link'] != None:
                hub_key_column_name_in_link=link_parent_entry['hub_key_column_name_in_link']
            elif parent_relation !="/" and parent_relation != '*':
                hub_key_column_name_in_link=parent_key_hash_reference['hash_column_name']+"_"+parent_relation.upper()
            else:
                hub_key_column_name_in_link = parent_key_hash_reference['hash_column_name']

            # add the hash field mappings of the hash parent to the hash fields of the link
            parent_hash_entry=g_hash_dict[parent_key_hash_reference['hash_name']]
            for parent_hash_field in parent_hash_entry['hash_fields']:
                link_hash_field=parent_hash_field.copy()
                link_hash_field['parent_declaration_position']=link_parent_count
                link_hash_fields.append(link_hash_field)

            # add reference to global entry of parent into load operation
            link_parent_key_hash_reference =  {"hash_name": parent_key_hash_reference['hash_name'],
                                       "hash_column_name": hub_key_column_name_in_link }

            hash_mapping_dict['parent_key_'+str(link_parent_count)] =link_parent_key_hash_reference

            # put hash column in table hash list
            if hub_key_column_name_in_link not in table_hash_columns:
                table_hash_columns[hub_key_column_name_in_link] = {"column_class": "parent_key",
                                                    "parent_table_name":link_parent_entry['table_name'],
                                                   "parent_key_column_name":parent_key_hash_reference['hash_column_name'],
                                                   "column_type": "#todo "}  # todo integrate model profile


        # add dependent child keys if exist
        if 'data_mapping_dict' in load_operation_entry:
            for column_name,column_entry in load_operation_entry['data_mapping_dict'].items():
                if column_entry['exclude_from_key_hash']:
                    continue
                hash_field={'field_name':column_entry['field_name'],
                            'prio_in_key_hash':column_entry['prio_in_key_hash'],
                            'field_target_table':table_name ,
                            'field_target_column':column_name}
                link_hash_fields.append(hash_field)

        # put hash definition into global list
        link_hash_description = {"stage_column_name": stage_column_name,
                      "hash_origin_table": table_name,
                      "column_class": "key",
                      "hash_fields": link_hash_fields}

        if link_hash_name not in g_hash_dict:
            g_hash_dict[link_hash_name] = link_hash_description

        # add reference for link key hash to load operation
        link_key_hash_reference = {"hash_name": link_hash_name,
                              "hash_column_name": link_key_column_name, }
        hash_mapping_dict['key']=link_key_hash_reference

        # put hash column in table hash list
        if link_key_column_name not in table_hash_columns:
            table_hash_columns[link_key_column_name] = {"column_class": "key",
                                                               "column_type": "#todo "}  # todo integrate model profile

def add_hash_column_mappings_for_sat(table_name,table_entry):

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']

    load_operations= table_entry['load_operations']
    for relation_name, load_operation_entry in load_operations.items():
        hash_mapping_dict = {}
        load_operation_entry['hash_mapping_dict'] = hash_mapping_dict
        # add parent key hash to hash reference list
        satellite_parent_table = g_table_dict[table_entry['satellite_parent_table']]
        parent_load_operations = satellite_parent_table['load_operations']

        if not relation_name in parent_load_operations:
            register_error(
                f"Parent table '{satellite_parent_table['table_name']}' has no load operation for relation '{relation_name}' requiered for satellite '{table_name}'")
            return

        parent_load_operation = parent_load_operations[relation_name]
        parent_hash_reference_dict = parent_load_operation['hash_mapping_dict']
        parent_key_hash_reference = parent_hash_reference_dict['key']

        sat_key_column_name=parent_key_hash_reference['hash_column_name']

        sat_key_hash_reference = {"hash_name": parent_key_hash_reference['hash_name'],
                                          "hash_column_name": sat_key_column_name}
        hash_mapping_dict['parent_key'] = sat_key_hash_reference

        # put hash column in table hash list
        if sat_key_column_name not in table_hash_columns:
            table_hash_columns[sat_key_column_name] = {"column_class": "parent_key",
                                                               "parent_table_name": table_entry['satellite_parent_table'],
                                                               "parent_key_column_name": parent_key_hash_reference[
                                                                   'hash_column_name'],
                                                               "column_type": "#todo "}  # todo integrate model profile

        # if not needed, skip diff hash
        if table_entry['is_effectivity_sat'] or table_entry['compare_criteria'] == 'key' or table_entry[
            'compare_criteria'] == 'none' or not  table_entry['uses_diff_hash']:
                continue

        # add diff hash

        diff_hash_base_name="DIFF_OF_"+table_name.upper()
        diff_hash_column_name = table_entry['diff_hash_column_name']
        if relation_name == "*" or relation_name == "/" or len(load_operations) == 1:
            hash_name = diff_hash_base_name
            stage_column_name = diff_hash_column_name
        else:
            hash_name = diff_hash_base_name + "__FOR__" + relation_name.upper()
            stage_column_name = diff_hash_column_name + "_" + relation_name.upper()

        hash_fields = []
        for column_name, column_entry in load_operation_entry['data_mapping_dict'].items():
            if column_entry['exclude_from_change_detection']:
                continue
            hash_field = {'field_name': column_entry['field_name'],
                          'prio_in_diff_hash': column_entry['prio_in_diff_hash'],
                          'prio_for_row_order':column_entry['prio_for_row_order'],
                          'field_target_table': table_name,
                          'field_target_column': column_name}
            hash_fields.append(hash_field)

        # put hash definition into global list
        hash_description = {"stage_column_name": stage_column_name,
                            "hash_origin_table": table_name,
                            "multi_row_content" : table_entry['is_multiactive'],
                            "related_key_hash" : parent_key_hash_reference['hash_name'],
                            "column_class": "diff_hash",
                            "hash_fields": hash_fields}

        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name] = hash_description

        # add reference to global entry into load operation
        hash_mapping_dict['diff_hash']={"hash_name": hash_name,
                                         "hash_column_name": diff_hash_column_name }

        # put hash column in table hash list
        if diff_hash_column_name not in table_hash_columns:
            table_hash_columns[diff_hash_column_name] = {"column_class": "diff_hash",
                                                               "column_type": "#todo "}  # todo integrate model profile


def add_hash_column_mappings_for_ref(table_name,table_entry):
    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']

    if not table_entry['uses_diff_hash']:
        return

    load_operations=table_entry['load_operations']
    diff_hash_base_name = "DIFF_OF_" + table_name.upper()
    diff_hash_column_name = table_entry['diff_hash_column_name']
    for relation_name, load_operation_entry in load_operations.items():
        hash_mapping_dict = {}
        load_operation_entry['hash_mapping_dict'] = hash_mapping_dict
        if relation_name == "*" or relation_name == "/" or len(load_operations) == 1:
            hash_name = diff_hash_base_name
            stage_column_name = diff_hash_column_name
        else:
            hash_name = diff_hash_base_name + "__FOR__" + relation_name.upper()
            stage_column_name = diff_hash_column_name + "_" + relation_name.upper()

        hash_fields = []
        for column_name, column_entry in load_operation_entry['data_mapping_dict'].items():
            if column_entry['exclude_from_change_detection']:
                continue
            hash_field = {'field_name': column_entry['field_name'],
                          'prio_in_diff_hash': column_entry['prio_in_diff_hash'],
                          'field_target_table': table_name,
                          'field_target_column': column_name}
            hash_fields.append(hash_field)

        # put hash definition into global list
        hash_description = {"stage_column_name": stage_column_name,
                            "hash_origin_table": table_name,
                            "column_class": "diff_hash",
                            "hash_fields": hash_fields}
        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name] = hash_description

        # add reference to global entry into load operation
        hash_mapping_dict['diff_hash']={"hash_name": hash_name,
                                         "hash_column_name": diff_hash_column_name }

        # put hash column in table hash list
        if diff_hash_column_name not in table_hash_columns:
            table_hash_columns[diff_hash_column_name] = {"column_class": "diff_hash",
                                                               "column_type": "#todo "}  # todo integrate model profile

def add_data_mapping_dict_for_one_load_operation(table_name, table_entry, relation_name, load_operation):
    data_mapping_dict={}
    for data_column_name, data_column in table_entry['data_columns'].items():
        for field_mapping in data_column['field_mappings']:
            field_name = field_mapping['field_name']
            use_field=False
            for mapping_relation_name in field_mapping['relation_names']:
                if mapping_relation_name == relation_name or mapping_relation_name=='*':
                    use_field=True
            if not use_field:
                continue
            if data_column_name not in data_mapping_dict:
                data_mapping_dict[data_column_name]={"field_name":field_name}
                copy_data_column_properties_to_operation_mapping(data_mapping_dict[data_column_name],data_column)
            else:
                register_error(f"Duplicate field mappings for column {data_column_name} in relation {relation_name} for table {table_name}")

    if len(data_mapping_dict)>0:
        load_operation['data_mapping_dict']=data_mapping_dict

    if g_error_count > 0:
        print("*** Stopped compiling due to errors ***")
        exit(5)

def copy_data_column_properties_to_operation_mapping(data_mapping_dict,data_column):
    operation_relevant_column_properties=['column_class','exclude_from_change_detection','prio_for_row_order','prio_in_diff_hash','exclude_from_key_hash','prio_in_key_hash','update_on_every_load']
    for relevant_key in operation_relevant_column_properties:
        if relevant_key in data_column:
            data_mapping_dict[relevant_key]=data_column[relevant_key]


def assemble_dvpi(dvpd_object, dvpd_filename):
    global g_dvpi_document

    # add meta declaration and dpvd meta data
    g_dvpi_document={'dvdp_compiler':'dvpdc reference compiler,  release 0.6.0',
                     'dvpi_version': '0.6.0',
                     'compile_timestamp':datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    'dvpd_version':dvpd_object['dvpd_version'],
                     'pipeline_name':dvpd_object['pipeline_name'],
                     'dvpd_filemame':dvpd_filename}

    # add tables
    dvpi_table_dict={}
    g_dvpi_document['table_dict']=dvpi_table_dict
    for table_name, table_entry in g_table_dict.items():
        dvpi_table_entry=assemble_dvpi_table_entry(table_name,table_entry)
        dvpi_table_dict[table_name]=dvpi_table_entry

    # copy data_extraction from dvpd
    g_dvpi_document['data_extraction']=dvpd_object['data_extraction']

    # add parse sets
    dvpi_parse_sets=[]
    g_dvpi_document['parse_sets']=dvpi_parse_sets
    dvpi_parse_sets.append(assemble_dvpi_parse_set(dvpd_object))

def assemble_dvpi_table_entry(table_name,table_entry):
    table_properties_to_copy=['table_stereotype','has_deletion_flag','is_effectivity_sat','is_enddated','is_multiactive','compare_criteria','uses_diff_hash']
    dvpi_table_entry={}
    for table_property in table_properties_to_copy:
        if table_property in table_entry:
            dvpi_table_entry[table_property]=table_entry[table_property]

    dvpi_column_dict={}
    dvpi_table_entry['column_dict']=dvpi_column_dict


    # add meta columns to column dict
    #todo use model profile for column names and types
    dvpi_column_dict['MD_INSERTED_AT'] = { 'column_class':'meta_load_date',
                                           'column_type':'#tdbd'}
    dvpi_column_dict['MD_RECORD_SOURCE'] = { 'column_class':'meta_record_source',
                                           'column_type':'#tdbd'}
    dvpi_column_dict['MD_LOAD_PROCESS_ID'] = { 'column_class':'meta_record_source',
                                           'column_type':'#tdbd'}
    if 'has_deletion_flag' in table_entry and table_entry['has_deletion_flag']:
        dvpi_column_dict['MD_IS_DELETED'] = {'column_class': 'meta_deletion_flag',
                                                  'column_type': '#tdbd'}

    if 'is_enddated' in table_entry and table_entry['is_enddated']:
        dvpi_column_dict['MD_VALID_BEFORE'] = {'column_class': 'meta_load_enddate',
                                                  'column_type': '#tdbd'}


    # add hash columns to column dict
    hash_column_properties_to_copy=['column_class','column_type','parent_key_column_name','parent_table_name']
    for column_name,column_entry in table_entry['hash_columns'].items():
        if column_name in dvpi_column_dict:
            register_error(
                f"Double column name '{column_name}' when adding hash to columns for table '{table_name}'. Check for conflicts between meta data colums and hashes ?")
        dvpi_column_entry = {}
        dvpi_column_dict[column_name] = dvpi_column_entry
        for column_property in hash_column_properties_to_copy:
            if column_property in column_entry:
                dvpi_column_entry[column_property] = column_entry[column_property]



    # add data columns to column dict
    data_column_properties_to_copy=['column_class','column_type','column_content_comment','exclude_from_change_detection','prio_for_column_position']
    if 'data_columns' in table_entry:
        for column_name,column_entry in table_entry['data_columns'].items():
            if column_name in dvpi_column_dict:
                register_error(f"Double column name '{column_name}' when adding data column for table '{table_name}'. Check for conflicts between data, meta data colums and hashes ?")
            dvpi_column_entry={}
            dvpi_column_dict[column_name] =dvpi_column_entry
            for column_property in data_column_properties_to_copy:
                if column_property in column_entry:
                    dvpi_column_entry[column_property] = column_entry[column_property]


    return dvpi_table_entry


def assemble_dvpi_parse_set(dvpd_object):
    parse_set={}

    #add meta data for parsing
    parse_set['stage_properties']=dvpd_object['stage_properties']
    parse_set['record_source_name_expression'] = dvpd_object['record_source_name_expression']

    #add field dictionary
    parse_set['field_dict']=g_field_dict

    #add hash dictionary
    parse_set['hash_dict']=g_hash_dict

    #add load operations
    dvpi_load_operations=[]
    parse_set['load_operations'] = dvpi_load_operations
    has_deletion_flag_in_a_table=False
    for table_name, table_entry in g_table_dict.items():
        if 'has_deletion_flag' in table_entry and table_entry['has_deletion_flag']:
            has_deletion_flag_in_a_table=True
        for relation_name,load_operation_entry in table_entry['load_operations'].items():
            dvpi_load_operation_entry= {'table_name': table_name,
                                        'relation_name': relation_name,
                                        'operation_origin': load_operation_entry['operation_origin'],
                                        'hash_mapping_dict': assemble_dvpi_hash_mapping_dict(load_operation_entry)}

            if 'data_mapping_dict' in  load_operation_entry:
                dvpi_load_operation_entry['data_mapping_dict']=assemble_dvpi_data_mapping_dict(load_operation_entry)
            dvpi_load_operations.append(dvpi_load_operation_entry)

    # add stage column dict
    parse_set['stage_column_dict']=assemble_dvpi_stage_column_dict(has_deletion_flag_in_a_table)

    if g_error_count > 0:
        print_the_brain()
        print("*** Stopped compiling due to errors ***")
        exit(5)

    return  parse_set

def assemble_dvpi_hash_mapping_dict(load_operation_entry):
    dvpi_hash_mapping_dict={}
    for hash_type_name,load_operation_hash_dict_entry in load_operation_entry['hash_mapping_dict'].items():
        dvpi_hash_mapping_dict[hash_type_name]={ 'hash_column_name':load_operation_hash_dict_entry['hash_column_name'],
                'hash_name':load_operation_hash_dict_entry['hash_name'],
                'stage_column_name':g_hash_dict[load_operation_hash_dict_entry['hash_name']]['stage_column_name']
                    }
    return dvpi_hash_mapping_dict

def assemble_dvpi_data_mapping_dict(load_operation_entry):
    dvpi_data_mapping_dict = {}
    for column_name, data_mapping_dict_entry in load_operation_entry['data_mapping_dict'].items():
        dvpi_data_mapping_dict[column_name] = {'field_name': data_mapping_dict_entry['field_name'],
                                                  'column_class': data_mapping_dict_entry['column_class'],
                                               'stage_column_name':data_mapping_dict_entry['field_name'] # currently it is 1:1 naming
                                                  }
    return dvpi_data_mapping_dict


def assemble_dvpi_stage_column_dict(has_deletion_flag_in_a_table):
    dvpi_stage_column_dict = {}


    # add meta columns to column stage dict
    # todo use model profile for column names and types
    dvpi_stage_column_dict['MD_INSERTED_AT'] = {'stage_column_class': 'meta_load_date',
                                          'column_type': '#tdbd'}
    dvpi_stage_column_dict['MD_RECORD_SOURCE'] = {'stage_column_class': 'meta_record_source',
                                            'column_type': '#tdbd'}
    dvpi_stage_column_dict['MD_LOAD_PROCESS_ID'] = {'stage_column_class': 'meta_record_source',
                                              'column_type': '#tdbd'}
    if has_deletion_flag_in_a_table:
        dvpi_stage_column_dict['MD_IS_DELETED'] = {'stage_column_class': 'meta_deletion_flag',
                                             'column_type': '#tdbd'}

    # add all hashes to
    for hash_name,hash_entry in g_hash_dict.items():
        stage_column_name=hash_entry['stage_column_name']
        if stage_column_name in dvpi_stage_column_dict:
            register_error(
                f"Double stage column name '{stage_column_name}' when adding hash to columns for stage table. Check for conflicts between meta data colums and hashes ?")
        dvpi_stage_column_entry = {'stage_column_class':'hash',
                             'hash_name':hash_name,
                             'column_type':'#tbd'} # todo use model profile for type
        dvpi_stage_column_dict[stage_column_name] = dvpi_stage_column_entry

    # add all fields to
    for field_name,field_entry in g_field_dict.items():
        stage_column_name=field_name
        if stage_column_name in dvpi_stage_column_dict:
            register_error(
                f"Double stage column name '{stage_column_name}' when adding hash to columns for stage table. Check for conflicts between meta data colums and hashes ?")
        dvpi_stage_column_entry = {'stage_column_class':'data',
                             'field_name':field_name,
                             'column_type':field_entry['field_type'],
                             'column_classes':['content'] } # later feature will collect list of classes
        dvpi_stage_column_dict[stage_column_name] = dvpi_stage_column_entry

    return dvpi_stage_column_dict

# ======================= Main =========================================== #

def dvpdc(dvpd_filename,dvpi_filename=None):

    global g_table_dict
    global g_dvpi_document
    global g_field_dict
    global g_error_count
    global g_hash_dict

    g_table_dict={}
    g_dvpi_document={}
    g_field_dict={}
    g_error_count=0
    g_hash_dict={}


    params = configuration_load_ini('dvpdc.ini', 'dvpdc')

    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)

    if dvpi_filename == None:
        dvpi_filename=dvpd_filename.replace('.json','').replace('.dvpd','')+".dvpi.json"

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
    check_multifield_mapping_consistency()
    derive_content_dependent_table_properties()
    derive_load_operations()
    add_data_mapping_dict_to_load_operations()
    add_hash_columns()

    #print_the_brain()

    assemble_dvpi(dvpd_object,dvpd_filename) # todo add option to omit stage_column_dict
    print_dvpi_document()

    # write DVPI to file
    dvpi_directory=Path(params['dvpi_default_directory'])
    dvpi_directory.mkdir(parents=True, exist_ok=True)
    dvpi_file_path = dvpi_directory.joinpath(dvpi_filename)

    print("Compile successfull. Writing DVPI to " + dvpi_file_path.as_posix())

    try:
        with open(dvpi_file_path, "w") as dvpi_file:
            json.dump(g_dvpi_document, dvpi_file, ensure_ascii=False, indent=2)
    except json.JSONDecodeError as e:
        print("ERROR: JSON writing to  of file "+ dvpi_file_path.as_posix())
        print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        exit(5)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("dvpd_filename", help="Name of the dvpd file to compile")
    parser.add_argument("--dvpi",  help="Name of the dvpi file to write (defaults to filename +  dvpi.json)")
    #parser.add_argument("-l","--log filename", help="Name of the report file (defaults to filename + .dvpdc.log")
    args = parser.parse_args()
    dvpdc(dvpd_filename=args.dvpd_filename, dvpi_filename=args.dvpi)



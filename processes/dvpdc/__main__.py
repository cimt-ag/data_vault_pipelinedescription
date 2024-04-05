#!/usr/bin/env python310
# =====================================================================
# Part of the Data Vault Pipeline Description Reference Implementation
#
#  Copyright 2023 Matthias Wegner mattywausb@gmail.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  =====================================================================

import argparse
import copy
import os
import sys


# Include data_vault_pipelinedescription folder into
project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

import re

from pathlib import Path
from lib.configuration import configuration_load_ini
from lib.exceptions import DvpdcError
import json
from datetime import datetime
from tkinter import filedialog



g_error_count=0
g_table_dict={}
g_field_dict={}
g_hash_dict={}
g_dvpi_document={}
g_model_profile_dict={}
g_pipeline_model_profile_name=""

g_logfile=None

def print_the_brain():
    print("JSON of g_model_profile_dict:")
    print(json.dumps(g_model_profile_dict, indent=2,sort_keys=True))

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
    g_logfile.write(message)
    g_logfile.write("\n")
    g_error_count += 1

def log_progress(message):
    print(message)
    g_logfile.write(message)
    g_logfile.write("\n")

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

def cast2Bool(boolCandidate):
    if isinstance(boolCandidate,bool):
        return boolCandidate
    if isinstance(boolCandidate,str):
        return boolCandidate.lower()=='true'
    if isinstance(boolCandidate,int):
        return boolCandidate != 0
    raise Exception(f"can't cast '{boolCandidate}' to bool")

def load_model_profiles(full_directory_name):
    """Runs through model profile files and tries to load them"""
    directory = Path(full_directory_name)

    name_pattern_matcher=re.compile(".+profile.json$")
    for file in directory.iterdir():
          if file.is_file() and os.path.getsize(file) != 0 and name_pattern_matcher.match(Path(file).name):
                add_model_profile_file(file)

def add_model_profile_file(file_to_process: Path):
    """Parses one model profile file, validates it and adds it to the internal dictionary"""
    global g_model_profile_dict

    file_name=file_to_process.name

    #todo add all mandatory keywords
    mandatory_keys=['model_profile_name','table_key_column_type','table_key_hash_function','table_key_hash_encoding','hash_concatenation_seperator']

    try:
        with open(file_to_process, "r") as dvpd_model_profile_file:
            model_profile_object=json.load(dvpd_model_profile_file)
    except json.JSONDecodeError as e:
        register_error("WARNING: JSON Parsing error of file "+ file_to_process.as_posix())
        log_progress(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        log_progress("Model profile will not be available")
        return

    for mandatory_keyword in mandatory_keys:
        if mandatory_keyword not in model_profile_object:
            register_error(f"'model profile is missing keyword '{mandatory_keyword}' in file '{file_name}'")


    model_profile_name=model_profile_object['model_profile_name']
    model_profile_object['model_profile_file_name']=file_name
    if model_profile_name not in g_model_profile_dict:
        g_model_profile_dict[model_profile_name]=model_profile_object
    else:
        if file_name != g_model_profile_dict[model_profile_name]['model_profile_file_name']:
            register_error("duplicate declaration of model profile '{0}' in '{1}'. Already read from '{2}'".format(model_profile_name,file_name,g_model_profile_dict[model_profile_name]['model_profile_file_name']))


def check_essential_element(dvpd_object):
    """Check for the essential keys, that are needed to identify the main objects"""

    global g_pipeline_model_profile

    root_keys=['pipeline_name','dvpd_version','stage_properties','data_extraction','fields']
    for key_name in root_keys:
        if dvpd_object.get(key_name) is None:
            register_error (f"missing declaration of root property '{key_name}'")


    # Check essential keys of data model declaration
    table_keys=['table_name','table_stereotype']
    table_count = 0
    for schema_index,schema_entry in enumerate(dvpd_object['data_vault_model'],start=1):
        if schema_entry.get('schema_name') is None:
            register_error(f"missing declaration of 'schema_name' for data_vault_model entry [{schema_index}]")


        for table_entry in schema_entry['tables']:
            table_count+=1
            for key_name in table_keys:
                if table_entry.get(key_name) is None:
                    register_error(f"missing declaration of essential table property '{key_name}' for table entry [{str(table_count)}]")

    if table_count == 0:
        register_error("No table declared")

    # Check essential keys of field declaration
    field_keys = ['field_name', 'field_type','targets']
    field_count = 0
    for field_entry in dvpd_object['fields']:
        field_count += 1
        for key_name in field_keys:
            if field_entry.get(key_name) == None:
                register_error(f"missing declaration of essential field property '{key_name}' for field [{field_count}]")
        target_count=0
        if 'targets' in field_entry:
            for target_entry in field_entry.get('targets'):
                target_count += 1
                if target_entry.get('table_name') == None:
                    register_error(f"missing declaration of 'table_name' for field [{field_count}], target [{target_count}] ")


def transform_hub_table(dvpd_table_entry, schema_name, storage_component):
    """Cleanse check and add table declaration for a hub table"""
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name=dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    table_properties= {'table_stereotype': 'hub', 'schema_name': schema_name, 'storage_component': storage_component,
                       'model_profile_name': model_profile_name}
    if model_profile_name not in g_model_profile_dict:
        register_error(f"model profile '{model_profile_name}' for table '{table_name}' is not defined")

    if 'hub_key_column_name' in dvpd_table_entry:
        table_properties['hub_key_column_name'] = dvpd_table_entry['hub_key_column_name'].upper()
    else:
        table_properties['hub_key_column_name'] = "HK_"+remove_stereotype_suffix(table_name).upper()
        #register_error(f'hub_key_column_name is not declared for hub table {table_name}')
    g_table_dict[table_name] = table_properties

def transform_lnk_table(dvpd_table_entry, schema_name, storage_component):
    """Cleanse check and add table declaration for a lnk table"""
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name=dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    table_properties= {'table_stereotype': 'lnk','schema_name':schema_name,'storage_component':storage_component,
                       'model_profile_name': model_profile_name}
    if model_profile_name not in g_model_profile_dict:
        register_error(f"model profile '{model_profile_name}' for table '{table_name}' is not defined")

    if 'link_key_column_name' in dvpd_table_entry:
        table_properties['link_key_column_name'] = dvpd_table_entry['link_key_column_name'].upper()
    else:
        table_properties['link_key_column_name'] = "LK_" +remove_stereotype_suffix(table_name).upper()
        #register_error(f'link_key_column_name is not declared for lnk table {table_name}')
    table_properties['is_link_without_sat'] = cast2Bool(dvpd_table_entry.get('is_link_without_sat', False))  # default is false

    if 'link_parent_tables' in dvpd_table_entry:
        list_position=0
        table_properties['link_parent_tables']=[]
        for parent_entry in dvpd_table_entry['link_parent_tables']:
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


def transform_sat_table(dvpd_table_entry, schema_name, storage_component):
    """Cleanse check and add table declaration for a satellite table"""
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name=dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name);
    table_properties= {'table_stereotype': 'sat','schema_name':schema_name,'storage_component':storage_component,
                       'model_profile_name': model_profile_name}

    if model_profile_name not in g_model_profile_dict:
        register_error(f"model profile '{model_profile_name}' for table '{table_name}' is not defined")
        return
    model_profile=g_model_profile_dict[model_profile_name]

    if 'satellite_parent_table' in dvpd_table_entry:
        table_properties['satellite_parent_table'] = dvpd_table_entry['satellite_parent_table'].lower()
    else:
        register_error(f'satellite_parent_table is not declared for satellite table {table_name}')
    table_properties['is_multiactive']=cast2Bool(dvpd_table_entry.get('is_multiactive', False))  # default is false
    table_properties['compare_criteria']=dvpd_table_entry.get('compare_criteria', model_profile['compare_criteria_default']).lower()  # default is profile
    table_properties['is_enddated']=cast2Bool(dvpd_table_entry.get('is_enddated', model_profile['is_enddated_default']))  # default is profile
    table_properties['uses_diff_hash']=cast2Bool(dvpd_table_entry.get('uses_diff_hash', model_profile['uses_diff_hash_default']))  # default is profile
    if 'diff_hash_column_name' in dvpd_table_entry:
        table_properties['diff_hash_column_name'] = dvpd_table_entry['diff_hash_column_name'].upper()
    else:  # derive default for diff column hash name
        if table_properties['is_multiactive']:
            table_properties['diff_hash_column_name'] = 'GH_' + table_name.upper()
        else:
            table_properties['diff_hash_column_name'] = 'RH_' + table_name.upper()

    table_properties['has_deletion_flag']=cast2Bool(dvpd_table_entry.get('has_deletion_flag', model_profile['has_deletion_flag_default']))  # default is profile
    if 'driving_keys' in dvpd_table_entry:
        #todo check if driving keys is a list
        cleansed_driving_keys=[]
        for driving_key in dvpd_table_entry['driving_keys']:
            cleansed_driving_keys.append(driving_key.upper())
        table_properties['driving_keys']=cleansed_driving_keys
    if 'tracked_relation_name' in dvpd_table_entry:
        table_properties['tracked_relation_name'] = dvpd_table_entry.get('tracked_relation_name')  # default is None

    # finally add the cleansed properties to the table dictionary
    g_table_dict[table_name] = table_properties

def transform_ref_table(dvpd_table_entry, schema_name, storage_component):
    """Cleanse check and add table declaration for a satellite table"""
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name=dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    table_properties={'table_stereotype': 'ref','schema_name':schema_name,'storage_component':storage_component,
                       'model_profile_name': model_profile_name}

    if model_profile_name not in g_model_profile_dict:
        register_error(f"model profile '{model_profile_name}' for table '{table_name}' is not defined")
        return

    model_profile=g_model_profile_dict[model_profile_name]

    table_properties['is_enddated']=cast2Bool(dvpd_table_entry.get('is_enddated', model_profile['is_enddated_default']) ) # default is profile
    table_properties['uses_diff_hash']=cast2Bool(dvpd_table_entry.get('uses_diff_hash', model_profile['uses_diff_hash_default']))  # default is profile
    if 'diff_hash_column_name' in dvpd_table_entry:
        table_properties['diff_hash_column_name'] = dvpd_table_entry['diff_hash_column_name'].upper()
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
        column_map_entry['row_order_direction'] = table_mapping.get('row_order_direction','ASC')  # defaults to ASC
        column_map_entry['exclude_from_key_hash'] = table_mapping.get('exclude_from_key_hash',False)  # defaults to False
        column_map_entry['exclude_from_change_detection'] = table_mapping.get('exclude_from_change_detection',False)  # defaults to False
        column_map_entry['column_content_comment'] = table_mapping.get('column_content_comment',field_entry.get('field_comment'))
        column_map_entry['update_on_every_load'] = table_mapping.get('update_on_every_load',False)  # defaults to False
        try:
            column_map_entry['prio_in_key_hash'] = int(table_mapping.get('prio_in_key_hash',0) ) # defaults to 0
            column_map_entry['prio_for_column_position'] = int(table_mapping.get('prio_for_column_position',50000))  # defaults to 50000
            column_map_entry['prio_for_row_order'] = int(table_mapping.get('prio_for_row_order',50000) ) # defaults to 50000
            column_map_entry['prio_in_diff_hash'] = int(table_mapping.get('prio_in_diff_hash',0))  # defaults to 0
        except ValueError as ve:
            register_error(f"Error when reading numerical properties from  mapping of field '{field_name}' to table '{table_name}':"+str(ve))

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
        for property_name in ['column_type','prio_for_column_position','field_position','prio_in_key_hash','exclude_from_key_hash','column_content_comment']:
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
        if parent_table['table_stereotype']!='hub':
            register_error(f"link parent table '{link_parent['table_name']}' of link '{table_name}' is not a hub")
            return
        link_parent['parent_key_column_name']=parent_table['hub_key_column_name']

    if 'data_columns' in table_entry:
        for column_name, column_properties in table_entry['data_columns'].items():
            first_field = column_properties['field_mappings'][0]
            if first_field['exclude_from_key_hash']:
                column_properties['column_class'] = 'content_untracked'
            else:
                column_properties['column_class'] = 'dependent_child_key'
            column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
            for property_name in ['column_type','prio_for_column_position', 'field_position','prio_in_key_hash', 'exclude_from_key_hash','column_content_comment']:
                column_properties[property_name] = first_field[property_name]
            derive_implicit_relations(column_properties)


def derive_content_dependent_sat_properties(table_name, table_entry):
    if table_entry['satellite_parent_table'] not in g_table_dict:
        register_error(f"parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}' is not declared")
        return

    table_entry['is_effectivity_sat'] = not 'data_columns' in table_entry  # determine is_effectivity_sat

    parent_table = g_table_dict[table_entry['satellite_parent_table']]
    parent_table_stereotype = 'lnk'
    if parent_table['table_stereotype'] == 'hub':
        parent_table_stereotype = 'hub'
        if table_entry['is_effectivity_sat']:
            register_error(f"Parent table '{table_entry['satellite_parent_table']}' of effectivity sat '{table_name}' is not a link")
    elif parent_table['table_stereotype'] != 'lnk':
        register_error(f"Parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}' is not a link or hub")

    # Driving Key Check
    if 'driving_keys' in table_entry:
        if parent_table_stereotype != 'lnk':
            register_error(f"Satellite '{table_name}' declares driving Key, but parent is not a link")
        

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
        raise DvpdcError


    # finally sattelites
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype']=="sat":
            add_hash_column_mappings_for_sat(table_name, table_entry)

    if g_error_count > 0:
        raise DvpdcError

    # and reference tables
    for table_name,table_entry in g_table_dict.items():
        if table_entry['table_stereotype']=="ref":
             add_hash_column_mappings_for_ref(table_name, table_entry)


def add_hash_column_mappings_for_hub(table_name,table_entry):
    global g_hash_dict

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']

    model_profile = g_model_profile_dict[table_entry['model_profile_name']]
    table_key_column_type = model_profile['table_key_column_type']


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
                         "hash_fields":hash_fields,
                         "column_type":table_key_column_type,
                         "hash_encoding":model_profile['table_key_hash_encoding'],
                         "hash_function":model_profile['table_key_hash_function'],
                         "hash_concatenation_seperator": model_profile['hash_concatenation_seperator'],
                         "hash_timestamp_format_sqlstyle": model_profile['hash_timestamp_format_sqlstyle'],
                         "hash_null_value_string": model_profile['hash_null_value_string'],
                         "model_profile_name":table_entry['model_profile_name']
                          }


        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name]=hash_description

        # add reference to global entry into load operation
        load_operation_entry['hash_mapping_dict']={'key':{     "hash_name":hash_name,
                                "hash_column_name":key_column_name,}}

        # put hash column in table hash list
        if key_column_name not in table_hash_columns:
            table_hash_columns[key_column_name]={"column_class":"key",
                                             "column_type":table_key_column_type}



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
            parent_model_profile=g_model_profile_dict[parent_table_entry['model_profile_name']]
            parent_table_key_column_type=parent_model_profile['table_key_column_type']
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
                link_parent_entry['hub_key_column_name_in_link']=hub_key_column_name_in_link
            else:
                hub_key_column_name_in_link = parent_key_hash_reference['hash_column_name']
                link_parent_entry['hub_key_column_name_in_link'] = hub_key_column_name_in_link

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
                                                   "column_type": parent_table_key_column_type}


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

        # put link hash definition into global list
        model_profile = g_model_profile_dict[table_entry['model_profile_name']]
        table_key_column_type = model_profile['table_key_column_type']


        link_hash_description = {"stage_column_name": stage_column_name,
                                 "hash_origin_table": table_name,
                                 "column_class": "key",
                                 "hash_fields": link_hash_fields,
                                 "column_type": table_key_column_type,
                                 "hash_encoding": model_profile['table_key_hash_encoding'],
                                 "hash_function": model_profile['table_key_hash_function'],
                                 "hash_concatenation_seperator": model_profile['hash_concatenation_seperator'],
                                 "hash_timestamp_format_sqlstyle": model_profile['hash_timestamp_format_sqlstyle'],
                                 "hash_null_value_string": model_profile['hash_null_value_string'],
                                 "model_profile_name": table_entry['model_profile_name']
                                 }

        if link_hash_name not in g_hash_dict:
            g_hash_dict[link_hash_name] = link_hash_description

        # add reference for link key hash to load operation
        link_key_hash_reference = {"hash_name": link_hash_name,
                              "hash_column_name": link_key_column_name, }
        hash_mapping_dict['key']=link_key_hash_reference

        # put hash column in table hash list

        if link_key_column_name not in table_hash_columns:
            table_hash_columns[link_key_column_name] = {"column_class": "key",
                                                               "column_type": table_key_column_type}

def add_hash_column_mappings_for_sat(table_name,table_entry):

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']
    satellite_parent_table = g_table_dict[table_entry['satellite_parent_table']]
    satellite_parent_model_profile = g_model_profile_dict[satellite_parent_table['model_profile_name']]
    satellite_parent_table_key_column_type = satellite_parent_model_profile['table_key_column_type']

    load_operations= table_entry['load_operations']

    for relation_name, load_operation_entry in load_operations.items():
        hash_mapping_dict = {}
        load_operation_entry['hash_mapping_dict'] = hash_mapping_dict
        # add parent key hash to hash reference list
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
                                                               "column_type":satellite_parent_table_key_column_type}

        # if not needed, skip diff hash
        if table_entry['is_effectivity_sat'] or table_entry['compare_criteria'] == 'key' or table_entry[
            'compare_criteria'] == 'none' or not  table_entry['uses_diff_hash']:
                continue

        # add diff hash

        diff_hash_base_name="DIFF_OF_"+table_name.upper()
        diff_hash_column_name = table_entry['diff_hash_column_name']
        model_profile = g_model_profile_dict[table_entry['model_profile_name']]
        diff_hash_column_type = model_profile['diff_hash_column_type']

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
                            "hash_fields": hash_fields,
                            "column_type": diff_hash_column_type,
                            "hash_encoding": model_profile['diff_hash_encoding'],
                            "hash_function": model_profile['diff_hash_function'],
                            "hash_concatenation_seperator": model_profile['hash_concatenation_seperator'],
                            "hash_timestamp_format_sqlstyle": model_profile['hash_timestamp_format_sqlstyle'],
                            "hash_null_value_string": model_profile['hash_null_value_string'],
                            "model_profile_name": table_entry['model_profile_name']
                            }

        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name] = hash_description

        # add reference to global entry into load operation
        hash_mapping_dict['diff_hash']={"hash_name": hash_name,
                                         "hash_column_name": diff_hash_column_name }

        # put hash column in table hash list
        if diff_hash_column_name not in table_hash_columns:
            table_hash_columns[diff_hash_column_name] = {"column_class": "diff_hash",
                                                               "column_type": diff_hash_column_type}


def add_hash_column_mappings_for_ref(table_name,table_entry):
    if 'hash_columns' not in table_entry:
        table_entry['hash_columns']={}
    table_hash_columns= table_entry['hash_columns']

    if not table_entry['uses_diff_hash']:
        return

    model_profile = g_model_profile_dict[table_entry['model_profile_name']]
    diff_hash_column_type = model_profile['table_key_column_type']

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
                            "hash_fields": hash_fields,
                            "column_type": diff_hash_column_type,
                            "hash_encoding": model_profile['diff_hash_encoding'],
                            "hash_function": model_profile['diff_hash_function'],
                            "hash_concatenation_seperator": model_profile['hash_concatenation_seperator'],
                            "hash_timestamp_format_sqlstyle": model_profile['hash_timestamp_format_sqlstyle'],
                            "hash_null_value_string": model_profile['hash_null_value_string'],
                            "model_profile_name": table_entry['model_profile_name']
                            }
        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name] = hash_description

        # add reference to global entry into load operation
        hash_mapping_dict['diff_hash']={"hash_name": hash_name,
                                         "hash_column_name": diff_hash_column_name }

        # put hash column in table hash list
        if diff_hash_column_name not in table_hash_columns:
            table_hash_columns[diff_hash_column_name] = {"column_class": "diff_hash",
                                                               "column_type": diff_hash_column_type}

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
                     'dvpd_filename':dvpd_filename}

    # add tables
    dvpi_tables=[]
    g_dvpi_document['tables']=dvpi_tables
    for table_name, table_entry in g_table_dict.items():
        dvpi_tables_entry=assemble_dvpi_table_entry(table_name,table_entry)
        dvpi_tables.append(dvpi_tables_entry)

    #todo check for double table objects in physical model(system, schema, name)

    # copy data_extraction from dvpd
    g_dvpi_document['data_extraction']=dvpd_object['data_extraction']

    # add parse sets
    dvpi_parse_sets=[]
    g_dvpi_document['parse_sets']=dvpi_parse_sets
    dvpi_parse_sets.append(assemble_dvpi_parse_set(dvpd_object))

def assemble_dvpi_table_entry(table_name,table_entry):
    table_properties_to_copy=['table_stereotype','schema_name','storage_component','has_deletion_flag','is_effectivity_sat','is_enddated','is_multiactive','compare_criteria','uses_diff_hash']
    dvpi_table_entry={'table_name':table_name}
    for table_property in table_properties_to_copy:
        if table_property in table_entry:
            dvpi_table_entry[table_property]=table_entry[table_property]
    
    # Driving Keys
    if 'driving_keys' in table_entry:
        if table_entry['table_stereotype'] != 'sat':
            register_error(f"Driving Keys defined for Table {table_name} even though Table is not a Satellite")
        parent = table_entry['satellite_parent_table']
        parent_hash_columns = g_table_dict[parent]['hash_columns']
        parent_data_columns = g_table_dict[parent]['data_columns']
        for driving_key in table_entry['driving_keys']:
            if driving_key not in parent_hash_columns and driving_key not in parent_data_columns:
                register_error(f"Driving Key {driving_key} not in parent {parent} columns")
        # if checks successfull -> add to dvpi
        dvpi_table_entry['driving_keys'] = table_entry['driving_keys']

    dvpi_columns=[]
    dvpi_table_entry['columns']=dvpi_columns

    model_profile = g_model_profile_dict[table_entry['model_profile_name']]


    # add meta columns to column dict

    dvpi_columns.append({'column_name':model_profile['load_date_column_name'], 'is_nullable':False,'column_class':'meta_load_date',
                                           'column_type':model_profile['load_date_column_type']})
    dvpi_columns.append({'column_name':model_profile['load_process_id_column_name'],'is_nullable':False,'column_class':'meta_load_process_id',
                                           'column_type':model_profile['load_process_id_column_type']})
    dvpi_columns.append({'column_name':model_profile['record_source_column_name'],'is_nullable':False,'column_class':'meta_record_source',
                                           'column_type':model_profile['record_source_column_type']})

    if 'has_deletion_flag' in table_entry and table_entry['has_deletion_flag']:
        dvpi_columns.append({'column_name':model_profile['deletion_flag_column_name'],'is_nullable':False,'column_class': 'meta_deletion_flag',
                                                  'column_type': model_profile['deletion_flag_column_type']})

    if 'is_enddated' in table_entry and table_entry['is_enddated']:
        dvpi_columns.append({'column_name':model_profile['load_enddate_column_name'],'is_nullable': False, 'column_class': 'meta_load_enddate',
                                                  'column_type': model_profile['load_enddate_column_type']})


    # add hash columns to columns
    hash_column_properties_to_copy=['column_class','column_type','parent_key_column_name','parent_table_name']
    for column_name,column_entry in table_entry['hash_columns'].items():
        dvpi_column_entry = {'column_name':column_name,'is_nullable':False}
        dvpi_columns.append(dvpi_column_entry)
        for column_property in hash_column_properties_to_copy:
            if column_property in column_entry:
                dvpi_column_entry[column_property] = column_entry[column_property]

    # add data columns to columns
    data_column_properties_to_copy=['column_class','column_type','column_content_comment','exclude_from_change_detection','prio_for_column_position']
    if 'data_columns' in table_entry:
        for column_name,column_entry in table_entry['data_columns'].items():
            dvpi_column_entry = {'column_name': column_name,'is_nullable':True,}
            dvpi_columns.append(dvpi_column_entry)
            for column_property in data_column_properties_to_copy:
                if column_property in column_entry and column_entry[column_property] != None:
                    dvpi_column_entry[column_property] = column_entry[column_property]

    # final check for double column names
    column_dict={}
    for column_entry in dvpi_columns:
        column_name=column_entry['column_name']
        if column_name not in column_dict:
            column_dict[column_name]=1
        else:
            register_error(
                f"Double column name '{column_name}' when assembling table '{table_name}'. Check for conflicts ")

    return dvpi_table_entry


def assemble_dvpi_parse_set(dvpd_object):
    parse_set={}

    #add meta data for parsing
    stage_properties=copy.deepcopy(dvpd_object['stage_properties'])
    for stage_property_entry in stage_properties:
        if 'stage_table_name' not in  stage_property_entry:
            stage_property_entry['stage_table_name']=f"s{g_dvpi_document['pipeline_name']}"
        if 'storage_component' not in  stage_property_entry:
            stage_property_entry['storage_component']=""
    parse_set['stage_properties']=stage_properties
    #todo check for duplicate stage table names on same system

    parse_set['record_source_name_expression'] = dvpd_object['record_source_name_expression']

    #add field dictionary
    dvpi_fields=[]
    parse_set['fields']=dvpi_fields
    for field_name,field_entry in g_field_dict.items():
        dvpi_field_entry=field_entry.copy()
        dvpi_field_entry['field_name']=field_name
        dvpi_fields.append(dvpi_field_entry)


    #add hash dictionary
    dvpi_hashes=[]
    parse_set['hashes']=dvpi_hashes
    for hash_name,hash_entry in g_hash_dict.items():
        dvpi_hash_entry=hash_entry.copy()
        dvpi_hash_entry['hash_name']=hash_name
        dvpi_hashes.append(dvpi_hash_entry)

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
                                        'hash_mappings': assemble_dvpi_hash_mappings(load_operation_entry)}

            if 'data_mapping_dict' in  load_operation_entry:
                dvpi_load_operation_entry['data_mapping']=assemble_dvpi_data_mappings(load_operation_entry)
            dvpi_load_operations.append(dvpi_load_operation_entry)

    # add stage column dict
    parse_set['stage_columns']=assemble_dvpi_stage_columns(has_deletion_flag_in_a_table)

    if g_error_count > 0:
        raise DvpdcError

    return  parse_set

def assemble_dvpi_hash_mappings(load_operation_entry):
    dvpi_hash_mappings=[]
    for hash_class,load_operation_hash_dict_entry in load_operation_entry['hash_mapping_dict'].items():
        dvpi_hash_mapping_entry={'hash_class':hash_class,
                                'column_name':load_operation_hash_dict_entry['hash_column_name'],
                                'hash_name':load_operation_hash_dict_entry['hash_name'],
                                'is_nullable':False,
                                'stage_column_name':g_hash_dict[load_operation_hash_dict_entry['hash_name']]['stage_column_name']
                    }
        dvpi_hash_mappings.append(dvpi_hash_mapping_entry)
    return dvpi_hash_mappings

def assemble_dvpi_data_mappings(load_operation_entry):
    dvpi_data_mappings = []
    for column_name, data_mapping_dict_entry in load_operation_entry['data_mapping_dict'].items():
        dvpi_data_mapping_entry = {'column_name':column_name,
                                   'field_name': data_mapping_dict_entry['field_name'],
                                   'column_class': data_mapping_dict_entry['column_class'],
                                   'is_nullable': True,
                                    'stage_column_name':data_mapping_dict_entry['field_name'] # currently it is 1:1 naming
                                    }
        dvpi_data_mappings.append(dvpi_data_mapping_entry)
    return dvpi_data_mappings


def assemble_dvpi_stage_columns(has_deletion_flag_in_a_table):
    dvpi_stage_columns = []

    model_profile = g_model_profile_dict[g_pipeline_model_profile_name]

    # add meta columns to column stage dict

    dvpi_stage_columns.append({'stage_column_name':model_profile['load_date_column_name'],'is_nullable':False,'stage_column_class': 'meta_load_date',
                                          'column_type': model_profile['load_date_column_type']})
    dvpi_stage_columns.append({'stage_column_name':model_profile['load_process_id_column_name'],'is_nullable':False,'stage_column_class': 'meta_load_process_id',
                                            'column_type':model_profile['load_process_id_column_type']})
    dvpi_stage_columns.append({'stage_column_name':model_profile['record_source_column_name'],'is_nullable':False,'stage_column_class': 'meta_record_source',
                                              'column_type': model_profile['record_source_column_type']})
    if has_deletion_flag_in_a_table:
        dvpi_stage_columns.append({'stage_column_name':model_profile['deletion_flag_column_name'],'is_nullable':False,'stage_column_class': 'meta_deletion_flag',
                                             'column_type': model_profile['deletion_flag_column_type']})

    # add all hashes to stage list
    for hash_name,hash_entry in g_hash_dict.items():
        dvpi_stage_column_entry = {'stage_column_name':hash_entry['stage_column_name'],
                                   'stage_column_class':'hash',
                                   'is_nullable': False,
                                   'hash_name':hash_name,
                                   'column_type':hash_entry['column_type']}
        dvpi_stage_columns.append(dvpi_stage_column_entry)

    # add all fields to
    for field_name,field_entry in g_field_dict.items():
        column_classes = collect_column_classes_for_field(field_name)
        dvpi_stage_column_entry = {'stage_column_name':field_name,
                                   'stage_column_class':'data',
                                   'field_name':field_name,
                                   'is_nullable': True,
                                   'column_type':field_entry['field_type'],
                                   'column_classes':column_classes } # later feature will collect list of classes
        dvpi_stage_columns.append(dvpi_stage_column_entry)

    # final check for double stage column names
    column_dict={}
    for stage_column_entry in dvpi_stage_columns:
        stage_column_name = stage_column_entry['stage_column_name']
        if stage_column_name not in column_dict:
            column_dict[stage_column_name]=1
        else:
            register_error(
                f"Double stage column name '{stage_column_name}' when adding hash to columns for stage table. Check for conflicts between meta data columns and hashes ?")

    return dvpi_stage_columns

def collect_column_classes_for_field(field_name):
    column_classes=[]
    for table_name,table_entry in g_table_dict.items():
        if 'data_columns' not in table_entry:
            continue
        for column_name,data_column_entry in table_entry['data_columns'].items():
            for field_mapping_entry in data_column_entry['field_mappings']:
                if field_mapping_entry['field_name']==field_name:
                    if data_column_entry['column_class'] not in column_classes:
                        column_classes.append(data_column_entry['column_class'])

    return column_classes

def writeDvpiSummary(dvpdc_report_path, dvpd_file_path):
    dvpdc_report_directory = Path(dvpdc_report_path)
    dvpdc_report_directory.mkdir(parents=True, exist_ok=True)

    dvpisum_filename = dvpd_file_path.name.replace('.json', '').replace('.dvpd', '') + ".dvpisum.txt"

    dvpisum_file_path = dvpdc_report_directory.joinpath(dvpisum_filename)

    try:
        with open(dvpisum_file_path, "w") as dvpisum_file:
            dvpisum_file.write("Data Vault Pipeline Instruction Summary (DVPISUM)\n")
            dvpisum_file.write("=================================================\n\n")
            dvpisum_file.write(f"Pipeline name: { g_dvpi_document['pipeline_name']}\n")
            dvpisum_file.write(f"DVPD file:     {dvpd_file_path.name}\n")
            dvpisum_file.write(f"dvpd version:  {g_dvpi_document['dvpd_version']}\n")
            dvpisum_file.write(f"compiled at:   {g_dvpi_document['compile_timestamp']}\n")

            dvpisum_file.write("\nTables\n")
            dvpisum_file.write("--------------------------------------------------\n")
            for table_entry in g_dvpi_document['tables']:
                dvpisum_file.write(f"{table_entry['table_name']}")
                if table_entry['table_stereotype'] == 'sat':
                    if table_entry['is_multiactive']:
                        dvpisum_file.write(' (multiactive sat)')
                    elif table_entry['is_effectivity_sat']:
                        dvpisum_file.write(' (effectivity sat)')
                    else:
                        dvpisum_file.write(' (sat)')
                else:
                    dvpisum_file.write(f" ({table_entry['table_stereotype']})")

                dvpisum_file.write(f" [{table_entry['storage_component']}.{table_entry['schema_name']}.{table_entry['table_name']}]\n")
                max_column_name_length=0
                for column_entry in table_entry['columns']:
                    if len(column_entry['column_name']) > max_column_name_length:
                        max_column_name_length=len(column_entry['column_name'])
                for column_entry in table_entry['columns']:
                    dvpisum_file.write(f"      {column_entry['column_class'].ljust(20)}| {column_entry['column_name'].ljust(max_column_name_length)}  {column_entry['column_type']}\n")
                dvpisum_file.write("\n")

            for parse_set_index,parse_set_entry in enumerate(g_dvpi_document['parse_sets'],start=1):
                dvpisum_file.write(f"\nParse set {parse_set_index}\n")
                dvpisum_file.write("--------------------------------------------------\n")
                for load_operation_entry in parse_set_entry['load_operations']:
                    dvpisum_file.write(f"\n{load_operation_entry['table_name']} [{load_operation_entry['relation_name']}] {load_operation_entry['operation_origin']} \n")
                    for hash_mapping_entry in load_operation_entry['hash_mappings']:
                        dvpisum_file.write(f"     {hash_mapping_entry['hash_class']}:  {hash_mapping_entry['stage_column_name']} >> {hash_mapping_entry['column_name']}  [")
                        dvpisum_file.write(renderHashFieldAssembly(parse_set_entry,hash_mapping_entry['hash_name']))
                        dvpisum_file.write("]\n")

                    if 'data_mapping' not in load_operation_entry:
                        continue

                    for data_mapping_entry in load_operation_entry['data_mapping']:
                        dvpisum_file.write(f"     {data_mapping_entry['column_class']}:  {data_mapping_entry['stage_column_name']} >> {data_mapping_entry['column_name']}\n")

                for stage_property_entry in parse_set_entry['stage_properties']:
                    dvpisum_file.write(f"\nStage table: {stage_property_entry['storage_component']}.{stage_property_entry['stage_schema']}.{stage_property_entry['stage_table_name']}\n")

                max_column_name_length=0
                for column_entry in parse_set_entry['stage_columns']:
                    if len(column_entry['stage_column_name']) > max_column_name_length:
                        max_column_name_length=len(column_entry['stage_column_name'])
                for column_entry in parse_set_entry['stage_columns']:
                    dvpisum_file.write(f"      {column_entry['stage_column_class'].ljust(20)}| {column_entry['stage_column_name'].ljust(max_column_name_length)}  {column_entry['column_type']}\n")
                dvpisum_file.write("\n")

            dvpisum_file.write("\nDVPD\n")
            dvpisum_file.write("--------------------------------------------------\n")

            with open(dvpd_file_path,"r") as dvdp_source_file:
                   for line in dvdp_source_file:
                            dvpisum_file.write(line)


    except:
        log_progress("ERROR: writing dvpi summary " + dvpisum_file_path.as_posix())
        raise

def renderHashFieldAssembly(parse_set_entry,hash_name):
    for hash_entry in parse_set_entry['hashes']:
        if hash_entry['hash_name'] == hash_name:
            fields = []
            for field_entry in hash_entry['hash_fields']:
                fields.append(field_entry['field_name'])
            return hash_entry['hash_concatenation_seperator'].join(fields)
    raise(f"There is a consistency error in the DVPI. Could not find hash '{hash_name}")


def dvpdc(dvpd_filename,dvpi_directory=None, dvpdc_report_directory=None, ini_file=None, model_profile_directory=None):
    """ this function is a wrapper around the real compiler to initialize the log file"""
    global g_logfile


    params = configuration_load_ini(ini_file, 'dvpdc', ['dvpd_model_profile_directory'])

    if dvpdc_report_directory == None:
        dvpdc_report_directory_path=Path(params['dvpdc_report_default_directory'])
    else:
        dvpdc_report_directory_path = Path(dvpdc_report_directory)

    dvpdc_report_directory_path.mkdir(parents=True, exist_ok=True)
    dvpdc_log_file_name= dvpd_filename.replace('.json','').replace('.dvpd','')+".dvpdc.log"
    dvpdc_log_file_path = dvpdc_report_directory_path.joinpath(dvpdc_log_file_name)


    with open(dvpdc_log_file_path,"w") as g_logfile:
        g_logfile.write(f"Data vault pipeline description compiler log \n")
        print("---")
        log_progress(f"Compiler Version 0.6.0")
        g_logfile.write(f"Compile time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_progress(f"Compiling {dvpd_filename}\n")
        try:
            dvpdc_worker(dvpd_filename, dvpi_directory, dvpdc_report_directory_path, ini_file, model_profile_directory)
        except DvpdcError:
            log_progress("*** Compilation ended with errors ***")
            raise

def dvpdc_worker(dvpd_filename,dvpi_directory=None, dvpdc_report_directory = None, ini_file = None, model_profile_directory=None):

    global g_table_dict
    global g_dvpi_document
    global g_field_dict
    global g_error_count
    global g_hash_dict
    global g_model_profile_dict
    global g_pipeline_model_profile_name

    g_table_dict={}
    g_dvpi_document={}
    g_field_dict={}
    g_error_count=0
    g_hash_dict={}
    g_model_profile_dict={}
    g_pipeline_model_profile_name=""


    params = configuration_load_ini(ini_file, 'dvpdc',['dvpd_model_profile_directory'])

    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)

    if not os.path.exists(dvpd_file_path):
        raise Exception(f'could not find dvpd file: {dvpd_file_path}')

    if model_profile_directory==None:
        load_model_profiles(params['dvpd_model_profile_directory'])
    else:
        load_model_profiles(model_profile_directory)

    try:
        with open(dvpd_file_path, "r") as dvpd_file:
            dvpd_object=json.load(dvpd_file)
    except json.JSONDecodeError as e:
        register_error("ERROR: JSON Parsing error of file "+ dvpd_file_path.as_posix())
        log_progress(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        raise DvpdcError

    g_pipeline_model_profile_name= dvpd_object.get('model_profile_name','_default')
    if g_pipeline_model_profile_name not in g_model_profile_dict:
        register_error(f"Model profile '{g_pipeline_model_profile_name}' declared in pipeline does not exist")
        raise DvpdcError



    check_essential_element(dvpd_object)
    if g_error_count > 0:
        raise DvpdcError

    collect_table_properties(dvpd_object)
    if g_error_count > 0:
        raise DvpdcError

    collect_field_properties(dvpd_object)
    if g_error_count > 0:
        raise DvpdcError

    check_multifield_mapping_consistency()
    if g_error_count > 0:
        raise DvpdcError

    derive_content_dependent_table_properties()
    if g_error_count > 0:
        raise DvpdcError

    derive_load_operations()
    if g_error_count > 0:
        raise DvpdcError

    add_data_mapping_dict_to_load_operations()
    if g_error_count > 0:
        raise DvpdcError

    add_hash_columns()
    if g_error_count > 0:
        raise DvpdcError

    assemble_dvpi(dvpd_object,dvpd_filename)
    #print_dvpi_document()

    # write DVPI to file
    if dvpi_directory == None:
        dvpi_directory = Path(params['dvpi_default_directory'])
    else:
        dvpi_directory = Path(dvpi_directory)
    dvpi_directory.mkdir(parents=True, exist_ok=True)
    dvpi_filename=dvpd_filename.replace('.json','').replace('.dvpd','')+".dvpi.json"
    dvpi_file_path = dvpi_directory.joinpath(dvpi_filename)

    log_progress("Writing DVPI to " + dvpi_file_path.as_posix())

    try:
        with open(dvpi_file_path, "w") as dvpi_file:
            json.dump(g_dvpi_document, dvpi_file, ensure_ascii=False, indent=2)
    except json.JSONDecodeError as e:
        register_error("ERROR: JSON writing to  of file "+ dvpi_file_path.as_posix())
        log_progress(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        raise DvpdcError

    log_progress("--- Compile successfull ---")

    writeDvpiSummary(dvpdc_report_directory,dvpd_file_path)

########################################################################################################################
if __name__ == "__main__":
    description_for_terminal = "Cimt AG reccommends to follow the instruction before starting the script. If you run your script from command line, it should look" \
                               " like this: python __main__.py inputFile"
    usage_for_terminal = "Type: python __main__.py --h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage= usage_for_terminal
    )
    # input Arguments
    parser.add_argument("dvpd_filename", help="Name of the dvpd file to compile")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--model_profile_directory",help="Name of the model profile directory")

    # output arguments
    parser.add_argument("--dvpi_directory",  help="Name of the dvpi file to write (defaults to filename +  dvpi.json)")
    parser.add_argument("--report_directory", help="Name of the report file (defaults to filename + .dvpdc.log")
    parser.add_argument("--print_brain", help="When set, the compiler will print its internal data structure to stdout", action='store_true')

    #parser.add_argument("-l","--log filename", help="Name of the report file (defaults to filename + .dvpdc.log")
    args = parser.parse_args()
    try:
        dvpdc(dvpd_filename=args.dvpd_filename,
              dvpi_directory=args.dvpi_directory,
              dvpdc_report_directory=args.report_directory,
              ini_file=args.ini_file,
              model_profile_directory=args.model_profile_directory
              )
        if args.print_brain:
            print_the_brain()
    except DvpdcError:
        if args.print_brain:
            print_the_brain()
        print("*** stopped compilation due to errors in input ***")
        exit(5)
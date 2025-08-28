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
sys.path.insert(0, project_directory)

import re

from pathlib import Path
from lib.configuration import configuration_load_ini
from lib.exceptions import DvpdcError
import json
from datetime import datetime

#  ----------- Global Variables ---------
# They are the "Blackboard" or "Brain" and contain the internal model of the dvpd, that is developed and read
# during the compilation and rendereing procedurre

g_error_count = 0
g_table_dict = {}
g_field_dict = {}
g_hash_dict = {}
g_dvpi_document = {}
g_model_profile_dict = {}
g_pipeline_model_profile_name = ""
g_verbose_logging = False

g_logfile = None

# ----------  Utiltity Functions  ---------------------

def print_the_brain():
    """
    Prints all global variablees of the "brain" to the console for debugging
    """
    print("JSON of g_model_profile_dict:")
    print(json.dumps(g_model_profile_dict, indent=2, sort_keys=True))

    print("JSON of g_field_dict:")
    print(json.dumps(g_field_dict, indent=2, sort_keys=True))

    print("JSON of g_table_dict:")
    print(json.dumps(g_table_dict, indent=2, sort_keys=True))

    print("JSON of g_hash_dict:")
    print(json.dumps(g_hash_dict, indent=2, sort_keys=True))

def dump_the_brain(dvpdc_report_path, dvpd_file_name):
    """
    Writes all global variables as json text to a file for debugging
    """
    dvpdc_report_directory = Path(dvpdc_report_path)
    dvpdc_report_directory.mkdir(parents=True, exist_ok=True)
    dvpd_file_path = Path(dvpd_file_name)


    braindump_filename = dvpd_file_path.name.replace('.json', '').replace('.dvpd', '') + ".braindump.json"

    braindump_file_path = dvpdc_report_directory.joinpath(braindump_filename)


    with open(braindump_file_path, "w") as braindump_file:
        braindump_file.write('{"==========DVPDC BRAIN DUMP ==========":{\n')

        braindump_file.write('"JSON of g_model_profile_dict":')
        braindump_file.write(json.dumps(g_model_profile_dict, indent=2, sort_keys=True))

        braindump_file.write(',\n"JSON of g_field_dict:":')
        braindump_file.write(json.dumps(g_field_dict, indent=2, sort_keys=True))

        braindump_file.write(',\n"JSON of g_table_dict:":')
        braindump_file.write(json.dumps(g_table_dict, indent=2, sort_keys=True))

        braindump_file.write(',\n"JSON of g_hash_dict:":')
        braindump_file.write(json.dumps(g_hash_dict, indent=2, sort_keys=True))

        braindump_file.write('\n}')



def print_dvpi_document():
    """
    Print the DVPI to the console
    """
    print("DVPI :")
    print(json.dumps(g_dvpi_document, indent=2))


def log_function_step(function_name, message):
    """
    Print a function specific message to the console and write it to the log file

    Args:
        function_name: Name of the function, that logs the message
        message: Sting with the message
    """
    if not g_verbose_logging:
        return
    log_text = f"{function_name}: {message}"
    print(log_text)
    g_logfile.write(log_text)
    g_logfile.write("\n")


def register_error(message):
    """
    Increase the global error count, print thea error message to the console and write it to the log file

    Args:
        message: Sting with the message
    """
    global g_error_count
    print("compile error:" + message)
    g_logfile.write(message)
    g_logfile.write("\n")
    g_error_count += 1


def log_progress(message):
    """
    Print a message to the console and write it to the log file
    Args:
        message: Sting with the message
    """
    print(message)
    g_logfile.write(message)
    g_logfile.write("\n")

def cast2Bool(boolCandidate):
    """
    Convert a variety of boolean data representation into a python boolean value
    """
    if isinstance(boolCandidate, bool):
        return boolCandidate
    if isinstance(boolCandidate, str):
        return boolCandidate.lower() == 'true'
    if isinstance(boolCandidate, int):
        return boolCandidate != 0
    raise Exception(f"can't cast '{boolCandidate}' to bool")

#  ----------------- Best Practice utility functions --------------------------------


def remove_stereotype_suffix(table_name):
    """
    Removes cimt best practice stereotype suffixes from table names, so the name can be used for specific column name
    derivation
    """
    triggering_suffixes = ['hub', 'lnk', 'sat', 'ref']
    words = table_name.split("_")
    reduced_table_name = table_name
    if len(words) > 1:
        for suffix in triggering_suffixes:
            if words[-1].endswith(suffix):
                words.pop(-1)
                break
        reduced_table_name = '_'.join(words)
    return reduced_table_name


# --------- model profile handling functions


def load_model_profiles(full_directory_name):
    """
    Runs through model profile files and tries to load them.

    Args:
        full_directory_name: Name of the directory to search for model profile files

    Registers errors by its sub function
    """
    directory = Path(full_directory_name)

    name_pattern_matcher = re.compile(".+profile.json$")
    for file in directory.iterdir():
        if file.is_file() and os.path.getsize(file) != 0 and name_pattern_matcher.match(Path(file).name):
            add_model_profile_file(file)


def add_model_profile_file(file_to_process: Path):
    """
    Parses one model profile file, validates it and adds it to the internal g_model_profile_dict


    Args: Path to the model profile

    Brain changes:
        g_model_profile_dict with the model profile name as key word

    Registers errors
    """
    global g_model_profile_dict

    file_name = file_to_process.name

    # todo add all mandatory keywords
    mandatory_keys = ['model_profile_name', 'table_key_column_type', 'table_key_hash_function',
                      'table_key_hash_encoding', 'hash_concatenation_seperator']

    try:
        with open(file_to_process, "r") as dvpd_model_profile_file:
            model_profile_object = json.load(dvpd_model_profile_file)
    except json.JSONDecodeError as e:
        register_error("WARNING: JSON Parsing error of file " + file_to_process.as_posix())
        log_progress(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        log_progress("Model profile will not be available")
        return

    for mandatory_keyword in mandatory_keys:
        if mandatory_keyword not in model_profile_object:
            register_error(f"'model profile is missing keyword '{mandatory_keyword}' in file '{file_name}'")

    model_profile_name = model_profile_object['model_profile_name']
    model_profile_object['model_profile_file_name'] = file_name
    if model_profile_name not in g_model_profile_dict:
        g_model_profile_dict[model_profile_name] = model_profile_object
    else:
        if file_name != g_model_profile_dict[model_profile_name]['model_profile_file_name']:
            register_error("duplicate declaration of model profile '{0}' in '{1}'. Already read from '{2}'".format(
                model_profile_name, file_name, g_model_profile_dict[model_profile_name]['model_profile_file_name']))

# -----------  functions, that transfer the data from the dvpd file into the brain structure ----------

def check_essential_structure(dvpd_object):
    """
    Check for the essential keys in the dvpd, that are needed to identify the main objects

    Args:
        dvpd_objet: The parsed (unmodified) dvpd json structure

    Registers errors
    """

    global g_pipeline_model_profile

    root_keys = ['pipeline_name', 'dvpd_version', 'stage_properties', 'data_extraction', 'fields',
                 'record_source_name_expression', 'data_vault_model']
    for key_name in root_keys:
        if dvpd_object.get(key_name) is None:
            register_error(f"CEE-S1: missing declaration of root property '{key_name}'")

    if g_error_count > 0:
        return

    # Check essential keys of data model declaration
    table_keys = ['table_name', 'table_stereotype']
    table_count = 0
    for schema_index, schema_entry in enumerate(dvpd_object['data_vault_model'], start=1):
        if schema_entry.get('schema_name') is None:
            register_error(f"CEE-S2: missing declaration of 'schema_name' for data_vault_model entry [{schema_index}]")
        if schema_entry.get('tables') is None:
            register_error(f"CEE-S3: missing declaration of 'tables' for data_vault_model entry [{schema_index}]")
        else:
            for table_entry in schema_entry['tables']:
                table_count += 1
                for key_name in table_keys:
                    if table_entry.get(key_name) is None:
                        register_error(
                            f"CEE-S4: missing declaration of essential table property '{key_name}' for table entry [{str(table_count)}]")

    if table_count == 0:
        register_error("CEE-S5: No table declared")

    # Check essential keys of field declaration
    field_keys = ['field_name', 'field_type', 'targets']
    field_count = 0
    for field_entry in dvpd_object['fields']:
        field_count += 1
        for key_name in field_keys:
            if field_entry.get(key_name) == None:
                register_error(
                    f"CEE-S6: missing declaration of essential field property '{key_name}' for field [{field_count}]")
        target_count = 0
        if 'targets' in field_entry:
            for target_entry in field_entry.get('targets'):
                target_count += 1
                if target_entry.get('table_name') == None:
                    register_error(
                        f"CEE-S7: missing declaration of 'table_name' for field [{field_count}], target [{target_count}] ")

def collect_table_properties(dvpd_object):
    """
    collect and cleanse all necessary table properties
    Args:
        dvpd_objet: The parsed (unmodified) dvpd json structure

    Brain changes:
        by subfunctions

    Registers errors by itself and subfunctions
    """
    for schema_entry in dvpd_object['data_vault_model']:
        schema_name = schema_entry['schema_name'].lower()
        storage_component = schema_entry.get('storage_component', '').lower()
        for table_entry in schema_entry['tables']:
            if g_table_dict.get(table_entry['table_name'].lower()):
                register_error(
                    f"table_name '{table_entry['table_name']}' has already been defined. table_name must be unique in the model")
                continue

            table_comment = table_entry['table_comment'] if 'table_comment' in table_entry else None

            match table_entry['table_stereotype'].lower():
                case 'hub':
                    collect_hub_properties(table_entry, schema_name, storage_component, table_comment)
                case 'lnk':
                    collect_lnk_properties(table_entry, schema_name, storage_component, table_comment)
                case 'sat':
                    collect_sat_properties(table_entry, schema_name, storage_component, table_comment)
                case 'ref':
                    collect_ref_properties(table_entry, schema_name, storage_component, table_comment)
                case _:
                    register_error(
                        f"Unknown table stereotype '{table_entry['table_stereotype']}' declared for table {table_entry['table_name']}")



def collect_hub_properties(dvpd_table_entry, schema_name, storage_component, table_comment):
    """
    Cleanse check and add table declaration for a hub table

    Args:
        dvpd_table_entry: the substructre in dvpd json structure for this table
        schema_name: Name of the schema, this table was declared in
        storage_component: storage component,this table was declaed in
        table_comment: comment for the table

    Brain changes:
        g_table_dict: New entry with Key=cleansed table name and the table properties
                cleansing: table_name is lower case
                           is_only_structural_element defaults to false
                           model_profile_name defaults to the globally declared profile name
                           hub_key_column_name is cleansed to upper case
                           hub_key_column_name defaults to cimt best practice naming convention
    """
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name = dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    is_only_structural_element = dvpd_table_entry.get('is_only_structural_element', False)
    table_properties = {'table_stereotype': 'hub', 'schema_name': schema_name, 'storage_component': storage_component,
                        'model_profile_name': model_profile_name, 'table_comment': table_comment
        , 'is_only_structural_element': is_only_structural_element}
    if model_profile_name not in g_model_profile_dict:
        register_error(f"CHP-S1: model profile '{model_profile_name}' for table '{table_name}' is not defined")

    if 'hub_key_column_name' in dvpd_table_entry:
        table_properties['hub_key_column_name'] = dvpd_table_entry['hub_key_column_name'].upper()
    else:
        table_properties['hub_key_column_name'] = "HK_" + remove_stereotype_suffix(table_name).upper()
        # register_error(f'CHP-S2: hub_key_column_name is not declared for hub table {table_name}')
    g_table_dict[table_name] = table_properties


def collect_lnk_properties(dvpd_table_entry, schema_name, storage_component, table_comment):
    """
    Cleanse check and add table declaration for a lnk table to g_table_dict/tables.
    This includes the expansion of
    the compressed parent table declaration syntax (single string with table_name) into the
    general declaration (object with "table_name" key)

    Args:
        dvpd_table_entry: the substructre in dvpd json structure for this table
        schema_name: Name of the schema, this table was declared in
        storage_component: storage component,this table was declaed in
        table_comment: comment for the table

    Brain changes:
        g_table_dict: New entry with Key=cleansed table name and the table properties
                cleansing:  table_name is lower case
                            is_only_structural_element defaults to false
                            model_profile_name defaults to the globally declared profile name
                            link_key_column_name is cleansed to upper case
                            link_key_column_name defaults to cimt best practice naming convention
                            is_link_without_sat defaults to false
                            remove link_parent_tables when is_only_structural_element=true
                            link_parent_tables/table_name cleansed to lower case
                            link_parent_tables/hub_key_column_name_in_link defaults to none
                            link_parent_tables/has_explicit_link_parent_relations defaults to false
                            link_parent_tables/relation_name defaults to ?
                generating: parent_list_position = positon of the  parent table entry in the array starting with 1

    Registers errors for link specific structural mistakes
    """
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name = dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    is_only_structural_element = dvpd_table_entry.get('is_only_structural_element', False)
    table_properties = {'table_stereotype': 'lnk', 'schema_name': schema_name, 'storage_component': storage_component,
                        'model_profile_name': model_profile_name, 'table_comment': table_comment
        , 'is_only_structural_element': is_only_structural_element}
    if model_profile_name not in g_model_profile_dict:
        register_error(f"CLP-S1: model profile '{model_profile_name}' for table '{table_name}' is not defined")

    if 'link_key_column_name' in dvpd_table_entry:
        table_properties['link_key_column_name'] = dvpd_table_entry['link_key_column_name'].upper()
    else:
        table_properties['link_key_column_name'] = "LK_" + remove_stereotype_suffix(table_name).upper()
        # register_error(f'CLP-S2: link_key_column_name is not declared for lnk table {table_name}')
    table_properties['is_link_without_sat'] = cast2Bool(
        dvpd_table_entry.get('is_link_without_sat', False))  # default is false

    table_properties['link_parent_tables'] = []

    if is_only_structural_element:
        table_properties['has_explicit_link_parent_relations'] = False
        g_table_dict[table_name] = table_properties
        if 'link_parent_tables'  in dvpd_table_entry:
            dvpd_table_entry.pop('link_parent_tables')
        return

    if 'link_parent_tables' not in dvpd_table_entry:
        register_error(f"CLP-S5:  Declaration of 'link_parent_tables' clause is missing for lnk table '{table_name}'")
        return

    list_position = 0
    has_explicit_link_parent_relations = False
    for parent_entry in dvpd_table_entry['link_parent_tables']:
        cleansed_parent_entry = {}
        list_position += 1
        if isinstance(parent_entry, dict):
            if 'table_name' in parent_entry:
                cleansed_parent_entry['table_name'] = parent_entry['table_name'].lower()
                if 'relation_name' in parent_entry:
                    cleansed_parent_entry['relation_name'] = parent_entry.get('relation_name').upper()
                    has_explicit_link_parent_relations = True
                else:
                    cleansed_parent_entry['relation_name'] = '?'
                if 'hub_key_column_name_in_link' in parent_entry:
                    cleansed_parent_entry['hub_key_column_name_in_link'] = parent_entry.get(
                        'hub_key_column_name_in_link').upper()
                else:
                    cleansed_parent_entry['hub_key_column_name_in_link'] = None
                cleansed_parent_entry['parent_list_position'] = list_position
            else:
                register_error(f"CLP-S3: property 'table_name' is not declared in link_parent_tables for lnk table '{table_name}'")
        else:
            cleansed_parent_entry['table_name'] = parent_entry.lower()
            cleansed_parent_entry['relation_name'] = '?'
            cleansed_parent_entry['hub_key_column_name_in_link'] = None
            cleansed_parent_entry['parent_list_position'] = list_position
        # else:
        #    register_error(f'CLP-S4:  link_parent_tables has bad syntax for lnk table {table_name}')
        table_properties['link_parent_tables'].append(cleansed_parent_entry)
        table_properties['has_explicit_link_parent_relations'] = has_explicit_link_parent_relations


    # finally add this to the global table dictionary
    g_table_dict[table_name] = table_properties


def collect_sat_properties(dvpd_table_entry, schema_name, storage_component, table_comment):
    """
    Cleanse check and add table declaration for a satellite table to g_table_dict/tables

    Args:
        dvpd_table_entry: the substructre in dvpd json structure for this table
        schema_name: Name of the schema, this table was declared in
        storage_component: storage component,this table was declaed in
        table_comment: comment for the table

    Brain changes:
        g_table_dict: New entry with Key=cleansed table name and the table properties
                cleansing: table_name is lower case
                           is_only_structural_element defaults to false
                           model_profile_name defaults to the globally declared profile name
                           satellite_parent_table cleansed to lower case
                           is_multiactive defatults to false
                           compare_criteria defaults to model profile setting
                           is_enddated defaults to model profile setting
                           uses_diff_hash defaults to model profile setting
                           diff_hash_column_name defaults to cimt best practice naming convention when needed
                           has_deletion_flag defaults to model profile setting
                           driving_keys defaults to empty list

    """
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name = dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    table_properties = {'table_stereotype': 'sat', 'schema_name': schema_name, 'storage_component': storage_component,
                        'model_profile_name': model_profile_name, 'table_comment': table_comment
        , 'is_only_structural_element': False}

    if model_profile_name not in g_model_profile_dict:
        register_error(f"CSP-S1:  model profile '{model_profile_name}' for table '{table_name}' is not defined")
        return
    model_profile = g_model_profile_dict[model_profile_name]

    if 'satellite_parent_table' in dvpd_table_entry:
        table_properties['satellite_parent_table'] = dvpd_table_entry['satellite_parent_table'].lower()
    else:
        register_error(f'CSP-S2: satellite_parent_table is not declared for satellite table {table_name}')
    table_properties['is_multiactive'] = cast2Bool(dvpd_table_entry.get('is_multiactive', False))  # default is false
    table_properties['compare_criteria'] = dvpd_table_entry.get('compare_criteria', model_profile[
        'compare_criteria_default']).lower()  # default is profile
    table_properties['is_enddated'] = cast2Bool(
        dvpd_table_entry.get('is_enddated', model_profile['is_enddated_default']))  # default is profile
    table_properties['uses_diff_hash'] = cast2Bool(
        dvpd_table_entry.get('uses_diff_hash', model_profile['uses_diff_hash_default']))  # default is profile
    if 'diff_hash_column_name' in dvpd_table_entry:
        table_properties['diff_hash_column_name'] = dvpd_table_entry['diff_hash_column_name'].upper()
    else:  # derive default for diff column hash name
        if table_properties['is_multiactive']:
            table_properties['diff_hash_column_name'] = 'GH_' + table_name.upper()
        else:
            table_properties['diff_hash_column_name'] = 'RH_' + table_name.upper()

    table_properties['has_deletion_flag'] = cast2Bool(
        dvpd_table_entry.get('has_deletion_flag', model_profile['has_deletion_flag_default']))  # default is profile
    if 'driving_keys' in dvpd_table_entry:
        # todo check if driving keys is a list
        cleansed_driving_keys = []
        for driving_key in dvpd_table_entry['driving_keys']:
            cleansed_driving_keys.append(driving_key.upper())
        table_properties['driving_keys'] = cleansed_driving_keys
    if 'tracked_relation_name' in dvpd_table_entry:
        table_properties['tracked_relation_name'] = dvpd_table_entry.get('tracked_relation_name').upper()

    # finally add the cleansed properties to the table dictionary
    g_table_dict[table_name] = table_properties


def collect_ref_properties(dvpd_table_entry, schema_name, storage_component, table_comment):
    """
    Cleanse check and add table declaration for a reference table to g_table_dict/tables

    Args:
        dvpd_table_entry: the substructre in dvpd json structure for this table
        schema_name: Name of the schema, this table was declared in
        storage_component: storage component,this table was declaed in
        table_comment: comment for the table

    Brain changes:
        g_table_dict: New entry with Key=cleansed table name and the table properties
                cleansing: table_name is lower case
                           is_only_structural_element defaults to false
                           model_profile_name defaults to the globally declared profile name
                           hub_key_column_name is cleansed to upper case
                           hub_key_column_name defaults to cimt best practice naming convention
                           is_enddated defaults to model profile setting
                           uses_diff_hash defaults to model profile setting
                           diff_hash_column_name defaults to cimt best practice naming convention when needed

    """
    global g_table_dict
    table_name = dvpd_table_entry['table_name'].lower()
    model_profile_name = dvpd_table_entry.get('model_profile_name', g_pipeline_model_profile_name)
    table_properties = {'table_stereotype': 'ref', 'schema_name': schema_name, 'storage_component': storage_component,
                        'model_profile_name': model_profile_name, 'table_comment': table_comment
        , 'is_only_structural_element': False}

    if model_profile_name not in g_model_profile_dict:
        register_error(f"CRP-S1: model profile '{model_profile_name}' for table '{table_name}' is not defined")
        return

    model_profile = g_model_profile_dict[model_profile_name]

    table_properties['is_enddated'] = cast2Bool(
        dvpd_table_entry.get('is_enddated', model_profile['is_enddated_default']))  # default is profile
    table_properties['uses_diff_hash'] = cast2Bool(
        dvpd_table_entry.get('uses_diff_hash', model_profile['uses_diff_hash_default']))  # default is profile
    if 'diff_hash_column_name' in dvpd_table_entry:
        table_properties['diff_hash_column_name'] = dvpd_table_entry['diff_hash_column_name'].upper()
    else:
        table_properties['diff_hash_column_name'] = 'RH_' + table_name.upper()

    # finally add the cleansed properties to the table dictionary
    g_table_dict[table_name] = table_properties


def collect_field_properties(dvpd_object):
    """
    Transfer and cleanse the field declarations to the g_fields struct and add the column mappings
    to all tables, the field is mapped to

    Args:
        dvpd_object: The parsed (unmodified) dvpd json structure

    Brain changes:
        g_field_dict: new entry for every field. Key= Fieldname
             cleansing: field_name is upper case
                        needs_encryption defaults to false

        more changes are done by subfunctions

    Registers errors by itself and subfunctions
    """
    global g_field_dict

    field_position = 0
    for field_entry in dvpd_object['fields']:
        field_name = field_entry['field_name'].upper()
        if g_field_dict.get(field_name) != None:
            register_error(f"Duplicate field_name declared: {field_name}")
        field_position += 1
        cleansed_field_entry = field_entry.copy()   # we use the dvdp delcaration as blueprint
        del cleansed_field_entry['targets']         # and remove elements that don't belong
        del cleansed_field_entry['field_name']      # in the g_fields objects
        cleansed_field_entry['field_position'] = field_position
        cleansed_field_entry['needs_encryption'] = field_entry.get('needs_encryption', False)
        g_field_dict[field_name] = cleansed_field_entry
        create_columns_from_field_mapping(field_entry, field_position)


def create_columns_from_field_mapping(field_entry, field_position):
    """
    Adds data column entries and direct key mappings to all tables the field is mapped to.

    Args:
        field_entry: the substructre in dvpd json structure for this field
        field_position: position of the field in the field list of the dvpd starting with 1

    Brain changes:
        g_table_dict/data_columns:  key entry for the target column with
                                    a new list 'field_mapping' entry for the
            cleansed:   field_name is cleansed to upper case
                        relation_names defaults to empty list
                        relation_names are cleansed to upper case
                        column_name defaults to field name in upper case
                        column_type default to field type
                        is_multi_active_key is only set when declared !!
                        row_order_direction default to ASC
                        exclude_from_key_hash defaults to false
                        exclude_from_change_detection devaults to false
                        column_content_comment defaults to field comment
                        update_on_every_load defaults to false
                        prio_in_key_hash defaults to 0
                        prio_for_column_position defaults to 50000
                        prio_for_row_order defaults to 50000
                        prio_in_diff_hash defaults to 0
        g_table_dict/direct_key_mappings: new list entry for every field with a direct key value
            cleansed:   field_name is cleansed to upper case
                        relation_names defaults to empty list
                        relation_names are cleansed to upper case


        more changes are done by subfunctions

    Registers errors
    """
    global g_table_dict

    field_name = field_entry['field_name'].upper()
    for table_mapping in field_entry['targets']:
        table_name = table_mapping['table_name'].lower()
        if not table_name in g_table_dict:
            register_error(f"CFM-2: Can't map field {field_name} to table {table_name}. Table is not declared in the model")
            continue
        table_entry = g_table_dict[table_name]

        # Assemble the basic mapping entry

        relation_names_cleansed = []  # of no relation is declared, at least an empty array will be attached as 'relation_names'
        if 'relation_names' in table_mapping:
            for relation_name in table_mapping['relation_names']:
                # todo test if relation_name is a string object
                relation_names_cleansed.append(relation_name.upper())

        column_map_entry = {'field_name':field_name,
                            'field_position':field_position,
                            'relation_names':relation_names_cleansed}

        # assemble direct key mapping, and store it as table property
        if table_mapping.get('use_as_key_hash', False):
            if table_entry['table_stereotype'] != 'hub' and table_entry['table_stereotype'] != 'lnk':
                #todo: create test for CFM-3
                register_error(
                    f"CFM-3: 'use_as_key_hash' only possible for mappings to hubs and links. Can't map field '{field_name}' to table '{table_name}'")
                continue
            if not 'direct_key_mappings' in table_entry:
                table_entry['direct_key_mappings'] = []
            table_entry['direct_key_mappings'].append(column_map_entry)
            continue

        # assemble data column mapping
        column_name = table_mapping.get('column_name', field_name).upper()  # defaults to field name
        column_map_entry['column_type'] = table_mapping.get('column_type',
                                                            field_entry['field_type']).upper()  # defaults to field type
        if 'is_multi_active_key' in table_mapping:
            if table_entry['table_stereotype'] == 'sat':
                column_map_entry['is_multi_active_key'] = table_mapping.get('is_multi_active_key')
            else:
                register_error(
                    "CFM-1: 'is_multi_avtive_key' property declared for non-sat entity. (property can only be declared if target is a multi-active satellite)")
        column_map_entry['row_order_direction'] = table_mapping.get('row_order_direction', 'ASC')  # defaults to ASC
        column_map_entry['exclude_from_key_hash'] = table_mapping.get('exclude_from_key_hash',
                                                                      False)  # defaults to False
        column_map_entry['exclude_from_change_detection'] = table_mapping.get('exclude_from_change_detection',
                                                                              False)  # defaults to False
        column_map_entry['column_content_comment'] = table_mapping.get('column_content_comment',
                                                                       field_entry.get('field_comment'))
        column_map_entry['update_on_every_load'] = table_mapping.get('update_on_every_load',
                                                                     False)  # defaults to False
        try:
            column_map_entry['prio_in_key_hash'] = int(table_mapping.get('prio_in_key_hash', 0))  # defaults to 0
            column_map_entry['prio_for_column_position'] = int(
                table_mapping.get('prio_for_column_position', 50000))  # defaults to 50000
            column_map_entry['prio_for_row_order'] = int(
                table_mapping.get('prio_for_row_order', 50000))  # defaults to 50000
            column_map_entry['prio_in_diff_hash'] = int(table_mapping.get('prio_in_diff_hash', 0))  # defaults to 0
        except ValueError as ve:
            register_error(
                f"Error when reading numerical properties from  mapping of field '{field_name}' to table '{table_name}':" + str(
                    ve))

        # add the data column mapping to the data columns dictionary of the table
        if not 'data_columns' in table_entry:
                table_entry['data_columns'] = {}
        column_dict = table_entry['data_columns']
        if not column_name in column_dict:
            column_dict[column_name] = {}
        theColumn = column_dict[column_name]
        if not 'field_mappings' in theColumn:
            theColumn['field_mappings'] = []
        theColumn['field_mappings'].append(column_map_entry)

# ------------------  Check function

def check_multifield_mapping_consistency():
    """
    Traverse for all data coluums in all tables and check the consistency for declaration, when
    multiple fields map to the same column

    Registers errors from subfunctions
    """
    global g_table_dict
    for table_name, table_entry in g_table_dict.items():
        if 'data_columns' in table_entry:
            for column_name, column_entry in table_entry['data_columns'].items():
                check_multifield_mapping_consistency_of_column(table_name, column_name, column_entry)


def check_multifield_mapping_consistency_of_column(table_name, column_name, column_entry):
    """
    Check the consistency of column declaration, when multiple fields map to the same column

    Registers errors
    """
    properties_to_align = ['column_type', 'prio_for_column_position', 'prio_for_row_order', 'exclude_from_key_hash'
        , 'prio_in_key_hash', 'exclude_from_change_detection', 'prio_in_diff_hash']
    if not 'field_mappings' in column_entry:
        raise (f" no field mappings on data column {column_name} in table {table_name}")
    if len(column_entry['field_mappings']) < 2:
        return  # there can be no conflict in single mappings
    # todo implement mapping comparison
    print("!!! WARNING !!!! Field mapping comparison is not implemented yet")


def derive_content_dependent_table_properties():
    """
    Iterates over all tables to determine
    stereotype specific properties from the table properies, set by the dvpd

    Registers errors from subfunctions
    """
    global g_table_dict
    for table_name, table_entry in g_table_dict.items():
        match table_entry['table_stereotype']:
            case 'hub':
                derive_content_dependent_hub_properties(table_name, table_entry)
            case 'lnk':
                derive_content_dependent_lnk_properties(table_name, table_entry)
            case 'sat':
                derive_content_dependent_sat_properties(table_name, table_entry)
            case 'ref':
                derive_content_dependent_ref_properties(table_name, table_entry)
            case _:
                raise (
                    f"!!! Something bad happened !!! cleansed stereotype {table_entry['table_stereotype']} has no rule in derive_content_dependent_table_properties()")


def derive_content_dependent_hub_properties(table_name, table_entry):
    """
    Determines hub specific properties from the hub declaration

    Args:
        table_name: String with the table name (needed to provide meaningful messages)
        table_entry: the g_table_dict/tables object that has to be processed

    Brain changes:
        g_table_dict/data_columns:  add column_class (determines business key columns)
                                    add field_mapping_Count
                                    copy type and all hash postition properties from first field in the list
                                    add_generic_relation_mappings()

         g_table_dict/direct_key_mappings:
                                    add_generic_releation_mappings()
    """

    has_business_key = False
    if 'data_columns' in table_entry:
        for column_name, column_properties in table_entry['data_columns'].items():
            first_field = column_properties['field_mappings'][0]
            if first_field['exclude_from_key_hash']:
                column_properties['column_class'] = 'content_untracked'
            else:
                column_properties['column_class'] = 'business_key'
                has_business_key = True
            column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
            for property_name in ['column_type', 'prio_for_column_position', 'field_position', 'prio_in_key_hash',
                                  'exclude_from_key_hash', 'column_content_comment']:
                column_properties[property_name] = first_field[property_name]
            add_generic_relation_mappings(column_properties)

    table_entry['has_business_key'] = has_business_key

    if 'direct_key_mappings' in table_entry:
        for direct_key_properties in table_entry['direct_key_mappings']:
            add_generic_relation_mappings_to_field_mapping_of_column(direct_key_properties)

    if not has_business_key and not table_entry['is_only_structural_element']:
        register_error(f"CDH-S1: Hub table {table_name} has no business key assigned")

    # checking the need of key declarations for structural elements need a full picture of all related
    # tables. So it is done later.





def derive_content_dependent_lnk_properties(table_name, table_entry):
    """
    Checks validity of link relations and determines link specific properties from the lnk declaration

    Args:
        table_name: String with the table name (needed to provide meaningful messages)
        table_entry: the g_table_dict/tables object that has to be processed


    Brain changes:
        g_table_dict: parent_key_column_name
        g_table_dict/data_columns:  add column_class (determines dependent child key columns)
                                    add field_mapping_Count
                                    copy type and all hash position properties from first field in the list
                                    add_generic_relation_mappings()

         g_table_dict/direct_key_mappings:
                                    add_generic_releation_mappings()
    """

    global g_table_dict

    for link_parent in table_entry['link_parent_tables']:
        if link_parent['table_name'] not in g_table_dict:
            register_error(f"CDL-S1: link parent table '{link_parent['table_name']}' of link '{table_name}' is not declared")
            return
        parent_table = g_table_dict[link_parent['table_name']]
        if parent_table['table_stereotype'] != 'hub':
            register_error(f"CDL-S2: link parent table '{link_parent['table_name']}' of link '{table_name}' is not a hub")
            return
        link_parent['parent_key_column_name'] = parent_table['hub_key_column_name']

    if 'data_columns' in table_entry:
        for column_name, column_properties in table_entry['data_columns'].items():
            first_field = column_properties['field_mappings'][0]
            if first_field['exclude_from_key_hash']:
                column_properties['column_class'] = 'content_untracked'
            else:
                column_properties['column_class'] = 'dependent_child_key'
            column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
            for property_name in ['column_type', 'prio_for_column_position', 'field_position', 'prio_in_key_hash',
                                  'exclude_from_key_hash', 'column_content_comment']:
                column_properties[property_name] = first_field[property_name]
            add_generic_relation_mappings(column_properties)

    if 'direct_key_mappings' in table_entry:
        for direct_key_properties in table_entry['direct_key_mappings']:
            add_generic_relation_mappings_to_field_mapping_of_column(direct_key_properties)

def derive_content_dependent_sat_properties(table_name, table_entry):
    """
    Checks validity of satellite relations including declarations that
    are only valid for a specific type of parent
    Determines satellite specific properties from the sat declaration

    Args:
        table_name: String with the table name (needed to provide meaningful messages)
        table_entry: the g_table_dict/tables object that has to be processed

    Brain changes:
        g_table_dict: add is_effectivity_sat
        g_table_dict/data_columns:  add column_class (determines tracked and untracked columns)
                                    add field_mapping_Count
                                    copy type and all hash position properties from first field in the list
                                    add_generic_relation_mappings()

    """
    if table_entry['satellite_parent_table'] not in g_table_dict:
        register_error(
            f"parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}' is not declared")
        return

    table_entry['is_effectivity_sat'] = not 'data_columns' in table_entry  # determine is_effectivity_sat

    parent_table = g_table_dict[table_entry['satellite_parent_table']]
    parent_table_stereotype = 'lnk'
    if parent_table['table_stereotype'] == 'hub':
        parent_table_stereotype = 'hub'
        if table_entry['is_effectivity_sat']:
            register_error(
                f"Parent table '{table_entry['satellite_parent_table']}' of effectivity sat '{table_name}' is not a link")
    elif parent_table['table_stereotype'] != 'lnk':
        register_error(
            f"Parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}' is not a link or hub")

    # Driving Key Check
    if 'driving_keys' in table_entry:
        if parent_table_stereotype != 'lnk':
            register_error(f"Satellite '{table_name}' declares driving Key, but parent is not a link")

    if table_entry['is_effectivity_sat']:
        return  # without any columns, we are done here

    for column_name, column_properties in table_entry['data_columns'].items():
        first_field = column_properties['field_mappings'][0]
        if first_field['exclude_from_change_detection']:
            column_properties['column_class'] = 'content_untracked'
        else:
            column_properties['column_class'] = 'content'
        if 'is_multi_active_key' in first_field:
            if 'is_multiactive' in table_entry and table_entry['is_multiactive'] == True:
                column_properties['is_multi_active_key'] = first_field['is_multi_active_key']
            else:
                register_error(
                    f"CDP-1: 'is_multi_active_key' property can only be used when target table is a multi-active satellite")
        column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
        for property_name in ['column_type', 'column_content_comment', 'prio_for_column_position', 'prio_for_row_order',
                              'row_order_direction', 'exclude_from_change_detection', 'prio_in_diff_hash']:
            column_properties[property_name] = first_field[property_name]
        add_generic_relation_mappings(column_properties)


def derive_content_dependent_ref_properties(table_name, table_entry):
    """
    Determines reference table specific properties from the reference table declaration

    Args:
        table_name: String with the table name (needed to provide meaningful messages)
        table_entry: the g_table_dict/tables object that has to be processed


    Brain changes:
        g_table_dict/data_columns:  add column_class (determines tracked and untracked columns)
                                    add field_mapping_Count
                                    copy type and all hash position properties from first field in the list
                                    add_generic_relation_mappings()
    """
    for column_name, column_properties in table_entry['data_columns'].items():
        first_field = column_properties['field_mappings'][0]
        if first_field['exclude_from_change_detection']:
            column_properties['column_class'] = 'content_untracked'
        else:
            column_properties['column_class'] = 'content'
        column_properties['field_mapping_count'] = len(column_properties['field_mappings'])
        for property_name in ['column_type', 'column_content_comment', 'prio_for_column_position',
                              'exclude_from_change_detection', 'prio_in_diff_hash']:
            column_properties[property_name] = first_field[property_name]
        add_generic_relation_mappings(column_properties)

def add_generic_relation_mappings(column_properties):
    """
    Determies the relation mapping defaults for every field mapping of a lolumn

    Args:
        column_properties: the g_table_dict/tables/column object that has to be processed

    """
    for field_entry in column_properties['field_mappings']:
        add_generic_relation_mappings_to_field_mapping_of_column(field_entry)

def add_generic_relation_mappings_to_field_mapping_of_column(field_entry):
    """
       This is STEP 1 of operation deduction procedure
       It determines the relation name for a field mapping, that has no relation name declaration in the dvpd

       Args:
           field_entry: the field to investigate g_table_dict/tables/data_columns/<name>/field_mappings[n]

       Brain changes:
            g_table_dict/tables/data_columns/<name>/field_mappings[n]:
                    when relation_names is an empty list:
                        place the "/" relation into the list
                        set implict_unnamed_relation to true
                    else
                        set implict_unnamed_relation to false

       Field mappings for every column, that have no relation names yet, will be placed in the "/" relation
       (the 'relation_names' list is created by create_columns_from_field_mapping but can be emtpy)"""
    if len(field_entry['relation_names']) == 0:
        field_entry['relation_names'].append('/')
        field_entry['implict_unnamed_relation'] = True
    else:
        field_entry['implict_unnamed_relation'] = False
    if '*' in field_entry['relation_names'] and len(field_entry['relation_names']) > 1:
        register_error(
            f"When using '*' as relation names, this must be the only relation in the 'relation_names' for a table mapping. This is violated by  '{field_entry['field_name']}'")
        # todo: add test to trigger the upper error

def derive_load_operations():
    """
    Orchestrate all steps, needed to determine the load operations for every table.
    This will be done regardless if the table was only declared for structural
    completness, since we need a full picture to determine the hash compositions.
    The final descision if an operation is need will be done later.
    The functions rely on the "black board principle": They only add information, where there is still none
    (gap filling pattern)  and they are responsible for

    Brain changes:
        tables[n]: adds empty array as load_operations
        more changes on g_table_dict from subfunctions

    Subfunctions will register errors
    """

    global g_table_dict

    # add load operations dict to every table, so we dont have to care about existence in the following code
    for table_name, table_entry in g_table_dict.items():
        load_operations = {}
        table_entry['load_operations'] = load_operations

    set_load_operations_for_reference_tables()
    determine_load_operations_from_relations_in_mappings()
    determine_load_operations_for_links_with_parent_relation_directives()
    determine_load_operations_from_tracking_directive()
    pull_satellite_load_operations_into_links()
    pull_hub_load_operations_into_links()
    pull_parent_operations_into_sat()

    # todo final_load_operation_crosscheck()


def set_load_operations_for_reference_tables():
    """
    Generate the "/" load operation for every reference table

    Brain changes:
        g_table_dict/tables[n]: adds '/' load_operations to load_operations

    """
    # ref tables always only have  "/" operation
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == 'ref':
            load_operations = table_entry['load_operations']
            load_operations['/'] = {"operation_origin": "ref table load operation", "mapping_set": "*"}


def determine_load_operations_from_relations_in_mappings():
    """
    Step 2 of load operation determination procedure
    Every table, with a field mapping will get a load operation for every distinct relation in the mappings
    This will include a "/" operation, for the mappings that defaulted to the  "/" relation
    Hubs with only "/" relation, will get a "is_hub_with_universal_load_operation" flag
    Tables with only a "*" relation, will not have an operation added.
    The name of the load operation will be the name of the keyset, to be used. (this is probably the keyset in the parent)
    the load operation will have a 'mapping_set' property.
    The name of the mapping_set is the name of the field collection, to be used in this table for this keyset.
    It differs from the load_operation name, since it will not


    Brain changes:
        g_table_dict/tables[n]/:  adds  is_hub_with_universal_load_operation
                                  adds data_is_mapped_to_generic_relation
        g_table_dict/tables[n]/load_operations: adds keys with the name or the load operation,
                                                derived from the relation_names that are not '*'
                                                    adds operation_origin
                                                    adds mapping_set with the relation_name

    """
    # collect declared relations
    for table_name, table_entry in g_table_dict.items():
        load_operations = table_entry['load_operations']

        if table_entry['table_stereotype'] == 'hub':
            table_entry['is_hub_with_universal_load_operation'] = False

        table_entry['data_is_mapped_to_generic_relation'] = False

        has_implicit_unnamed_mapping_for_all_columns = True
        if 'data_columns' in table_entry:
            has_generic_mapping_for_all_columns = True

            # add operations by scanning all columns and their mappings
            for data_column in table_entry['data_columns'].values():
                has_generic_mapping = False
                for field_mapping in data_column['field_mappings']:
                    for relation_name in field_mapping['relation_names']:
                        if relation_name != '*':
                            load_operations[relation_name] = {"operation_origin": "field mapping relation",
                                                              "mapping_set": relation_name}
                            if not field_mapping['implict_unnamed_relation']:
                                has_implicit_unnamed_mapping_for_all_columns = False
                        else:
                            has_generic_mapping = True
                if not has_generic_mapping:
                    has_generic_mapping_for_all_columns = False

        if 'direct_key_mappings' in table_entry:
                has_generic_mapping = False
                for direct_key_mapping in table_entry['direct_key_mappings']:
                    for relation_name in direct_key_mapping['relation_names']:
                        if relation_name != '*':
                            load_operations[relation_name] = {"operation_origin": "field mapping relation",
                                                              "mapping_set": relation_name}
                            if not direct_key_mapping['implict_unnamed_relation']:
                                has_implicit_unnamed_mapping_for_all_columns = False
                        else:
                            has_generic_mapping = True
                if not has_generic_mapping:
                    has_generic_mapping_for_all_columns = False

        if 'data_columns' in table_entry or 'direct_key_mappings' in table_entry:
            if len(load_operations) == 0:  # no mapping generated a load operation (all mappings are * mappings)
                table_entry['data_is_mapped_to_generic_relation'] = True

        # finally crosscheck completness of mappings for all determined load operations
        for load_operation_name, load_operation in load_operations.items():
            if 'data_columns' in table_entry:
                for data_column_name, data_column in table_entry['data_columns'].items():
                    count_matches = 0
                    universal_mapping_defined = False
                    for field_mapping in data_column['field_mappings']:
                        for relation_name in field_mapping['relation_names']:
                            if relation_name == load_operation_name:
                                count_matches += 1
                            if relation_name == '*':
                                universal_mapping_defined = True
                    if count_matches > 1:
                        register_error(
                            f"DLO-20:There are multiple explicit mappings for relation '{load_operation_name}' into column '{data_column_name}' of table '{table_name}'")
                    if count_matches == 0 and not universal_mapping_defined:
                        register_error(
                            f"DLO-21:There is no field mapping for relation '{load_operation_name}' into column '{data_column_name}' of table '{table_name}'")
                    if count_matches == 1 and universal_mapping_defined:
                        register_error(
                            f"DLO-22: There is a mix of universal (*) relation mapping with mapping for relation'{load_operation_name}' into column '{data_column_name}' of table '{table_name}'")

            # todo add crosscheck for direct key mapping completenes

        # Set universal flag for hub,s that have only a "/" operation
        if table_entry['table_stereotype'] == 'hub' and len(
                load_operations) == 1 and '/' in load_operations and has_implicit_unnamed_mapping_for_all_columns:
            table_entry['is_hub_with_universal_load_operation'] = True


def determine_load_operations_for_links_with_parent_relation_directives():
    """
    Step 3 of load operation determination procedure
        This only applies to links, that have at least one parent relation declaration
        The load operation is set to "/" and the mapping set also to "*"
        All other links will not get a load operation here

    Brain changes:
        g_table_dict/tables[n]/load_operations: add keys with a '/' the load operation,
    """
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] != 'lnk' \
                or not table_entry['has_explicit_link_parent_relations'] \
                or table_entry['is_only_structural_element']:
            continue  # we are only interested in links with explicitc parent relations that are  not only structural elemets

        load_operations = table_entry['load_operations']
        if len(load_operations) > 0:
            register_error(
                f"DLO-30:parent table relations can't be used, when expliciv field mapping relations are already defined. Table: '{table_name}'")

        load_operations['/'] = {"operation_origin": "fixed '/' operation due to explicit parent relation declaration",
                                "mapping_set": "*"}


def determine_load_operations_from_tracking_directive():
    """
    STEP 4 of load operation determination procedure
    Adds load operations for satellites with a tracked_relation declaration
    Will only work for satellites, that have no field mapping or only "*" field mappings

    Brain changes:
        g_table_dict/tables[n]/load_operations: add keys with the load operation, named like the tracked relation

    register errors
    """
    for table_name, table_entry in g_table_dict.items():
        load_operations = table_entry['load_operations']
        if 'tracked_relation_name' in table_entry:
            if len(load_operations) > 0:
                # todo add compiler test to trigger this error
                register_error(
                    f"DLO-40:You cannot define a tracked relation, when you declared relations in data mappings other then ['*']. Table: '{table_name}'")
            if table_entry['tracked_relation_name'] != '*':
                load_operations[table_entry['tracked_relation_name']] = {
                    "operation_origin": "explicitly tracked relation", "mapping_set": "*"}


def pull_satellite_load_operations_into_links():
    """
    STEP 5 of load operation determination procedure
    For all links, that have not load operation yet, scan all its satellites for load operations(=key sets)
    and add these to the the link as load operation (=key set of the links parents).
    The mapping set is * (this is only true until we reach  0.7.0)

    Brain changes:
        g_table_dict/tables[n]/load_operations: add keys with the load operation, named like the tracked relation

    register errors
    """
    for link_table_name, link_table in g_table_dict.items():
        link_load_operations = link_table['load_operations']
        if link_table['table_stereotype'] != 'lnk' \
                or len(link_load_operations) > 0 \
                or link_table['is_only_structural_element']:
            continue  # only links without load operation yet and no structural only elements

        for sat_table_name, sat_table in g_table_dict.items():
            if sat_table['table_stereotype'] != 'sat':
                continue  # satellites only

            sat_load_operations = sat_table['load_operations']
            if len(sat_load_operations) == 0 or link_table_name != sat_table['satellite_parent_table']:
                continue  # only links children satellites with load operations are of interest

            for sat_load_operation_name in sat_load_operations:
                # todo add testcase where multiple sats on the link induce the same load operation #issue #304
                if sat_load_operation_name != '*':
                    link_load_operations[sat_load_operation_name] = {
                        "operation_origin": f"induced from satellite {sat_table_name}", "mapping_set": "*"}
                if not is_operation_supported_by_link_hubs(link_table_name, sat_load_operation_name):
                    register_error(
                        f"DLO-50:operation '{sat_load_operation_name}' induced by satellite '{sat_table_name}' to link {sat_table['satellite_parent_table']} is not supported by the hubs of the link")


def is_operation_supported_by_link_hubs(link_table_name, load_operation_name):
    """
    Determines if  at least one hub of the link explicitly supports a given load operation
    and if all hubs if the lin are able to support the operation (also have it as explcit,
    operation or are universal supports)

    Args:
            link_table_name: Name of the link table
            load_operation_name: Name of the load operation to check

    Returns:
            True: Operation is supported
            False: Operation is not supported

    """
    link_table = g_table_dict[link_table_name]

    if link_table['has_explicit_link_parent_relations']:
        raise f"This function cant be called for links with explicit parent relations. Table: {link_table_name}"

    is_supported_by_all_hubs = True
    hubs_with_operation = 0
    for link_parent_table_entry in link_table['link_parent_tables']:
        hub_table = g_table_dict[link_parent_table_entry['table_name']]
        is_supported_by_hub = False
        for hub_load_operation_name in hub_table['load_operations'].keys():
            if hub_load_operation_name == load_operation_name:
                hubs_with_operation += 1
                is_supported_by_hub = True
        if hub_table['is_hub_with_universal_load_operation']:  # is supported but probably not explicitly
            is_supported_by_hub = True
        if not is_supported_by_hub:
            is_supported_by_all_hubs = False
            break

    return is_supported_by_all_hubs and hubs_with_operation > 0


def pull_hub_load_operations_into_links():
    """
    STEP 6 of load operation determination procedure
    If there are any links left, that have no load operation declaration yet, (neither driven
    by themself, nor dirven from their satellites). The link will have a load operation
    for every load operation, that is defined by every of its hubs.

    Brain changes:
        g_table_dict/tables[n]/load_operations: add keys for load operation, named like the relations
            common to all hubs

    register errors

    """
    for link_table_name, link_table in g_table_dict.items():
        link_load_operations = link_table['load_operations']

        # skip non links, links with operations, links that are only structural
        if link_table['table_stereotype'] != 'lnk'  \
                or len(link_load_operations) > 0    \
                or link_table['is_only_structural_element']:
            continue

        # collect the operations, all hubs have in common
        load_operation_collection = {}
        relevant_hub_count = 0
        first_relevant_hub = True
        dlo_61_triggered=False
        for link_parent_table in link_table['link_parent_tables']:
            hub_table = g_table_dict[link_parent_table['table_name']]
            if hub_table['is_hub_with_universal_load_operation']:
                continue
            relevant_hub_count += 1
            hub_load_operations = hub_table['load_operations']
            for hub_load_operation_name in hub_load_operations.keys():
                if first_relevant_hub:
                    load_operation_collection[hub_load_operation_name] = 1
                elif hub_load_operation_name in load_operation_collection:
                    load_operation_collection[hub_load_operation_name] += 1
            if len(hub_load_operations) == 0:
                register_error(
                    f"DLO-61: No load operations have been created for parent '{link_parent_table['table_name']}' of the link '{link_table_name}'")
                dlo_61_triggered=True
                if hub_table['is_only_structural_element'] and 'direct_key_mappings' not in hub_table:
                    register_error(
                        f"DLO-61a: Table '{link_parent_table['table_name']}' is_only_structural_element and might miss a 'use_as_key_hash' mapping or business key")
            first_relevant_hub = False

        if dlo_61_triggered:
            return

        if relevant_hub_count > 0:
            for collected_operation_name, collected_operation_count in load_operation_collection.items():
                if collected_operation_count == relevant_hub_count:
                    link_load_operations[collected_operation_name] = {
                        "operation_origin": "following parent hub common operation list", "mapping_set": "*"}
        else:
            link_load_operations['/'] = {
                "operation_origin": "implicit unnamed relation, since all parents are universal", "mapping_set": "*"}

        if len(link_load_operations) == 0:
            register_error(
                f"DLO-60: there is no commonly supported relation between all hubs of the link '{link_table_name}'")


def pull_parent_operations_into_sat():
    """
    STEP 7
    If there are any satellites left, that have no load operation declaration yet,
    the parent operations are copied for the sat.

    Brain changes:
        g_table_dict/tables[n]/load_operations: add keys for load operation, named like the relations
            of the parents

    register errors
    """
    for sat_table_name, sat_table in g_table_dict.items():
        sat_load_operations = sat_table['load_operations']
        if sat_table['table_stereotype'] != 'sat' or len(sat_load_operations) > 0:
            continue  # only sats without load operations yet

        # this satellite has no load operation yet.
        # that can be the result of leaving out the declaration or
        # by declaring the '*' relation in all field relations or as tracked relation

        parent_table = g_table_dict[sat_table['satellite_parent_table']]
        parent_load_operations = parent_table['load_operations']
        for parent_operation in parent_load_operations:
            sat_load_operations[parent_operation] = {"operation_origin": "following parent operation list",
                                                     "mapping_set": "*"}

        if len(sat_load_operations) > 1:
            tracked_relation_name = sat_table.get('tracked_relation_name', None)
            if tracked_relation_name != '*' and not sat_table['data_is_mapped_to_generic_relation']:
                sat_operation_list_string = "','".join(sat_load_operations)
                register_error(
                    f"DLO-70: Sat '{sat_table_name}' got multiple induced relations ('{sat_operation_list_string}') from parent,but have no '*' relation set. ")


#  --------------------- Functions that assemble the hash compositions ----------------


def add_hash_columns():
    """
    Orchestrate all steps, needed to assemble the hash compositions

    Brain changes:
        changes on g_table_dict, g_hash_dict from subfunctions

    Subfunctions will register errors
    """

    # all hubs hashes first
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == "hub":
            add_hash_column_mappings_for_hub(table_name, table_entry)

    # then link hashes
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == "lnk":
            add_hash_column_mappings_for_lnk(table_name, table_entry)

    if g_error_count > 0:
        raise DvpdcError

    # finally sattelites
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == "sat":
            add_hash_column_mappings_for_sat(table_name, table_entry)

    if g_error_count > 0:
        raise DvpdcError

    # and reference tables
    for table_name, table_entry in g_table_dict.items():
        if table_entry['table_stereotype'] == "ref":
            add_hash_column_mappings_for_ref(table_name, table_entry)


def add_hash_column_mappings_for_hub(table_name, table_entry):
    """
    Assemble the hash definitions for all load operations of a hub table.
    Hashes are identified by the "KEY_OF"+<name of the table>, extended by "__FOR__" +<operation name>
    when the operation is not '*' or '/'.
    also the Hash Column Name for the stage table is assembled from the tables key column name and
    the relation name
    All data columns mapped to the hub, that are not 'exlcuded from key hash' are used.

    Args:
            table_name: Name of the table, the hash is added (only used for messages)
            table_entry: g_table_dict/tables[<key>] entry of the table

    Brain changes:
        g_hash_dict: add entry with the internal Hash name and the properties declared as hash description below
                     this includes the list of hash_fields
        g_table_dict.tables<table>.load_operations<operation_name>:
                     add hash_mapping_dict with 'key' entry referring the internal hash name
                        and hash_column_name in the target table
        g_table_dict.tables<table>.hash_columns:
                     add entry with key column name


    will register errors
    """
    global g_hash_dict

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns'] = {}
    table_hash_columns = table_entry['hash_columns']

    model_profile = g_model_profile_dict[table_entry['model_profile_name']]
    table_key_column_type = model_profile['table_key_column_type']

    hash_base_name = "KEY_OF_" + table_name.upper()
    key_column_name = table_entry['hub_key_column_name']

    # create a hash for every load operation of the hub (which is a different key set by definition)
    load_operations = table_entry['load_operations']
    for load_operation_name, load_operation_entry in load_operations.items():
        # render internal hash name
        if load_operation_name == "*" or load_operation_name == "/" or len(load_operations) == 1:
            hash_name = hash_base_name
            stage_column_name = key_column_name
        else:
            hash_name = hash_base_name + "__FOR__" + load_operation_name.upper()
            stage_column_name = key_column_name + "_" + load_operation_name.upper()

        # assemble the columns and fields for this hash from the load operations data_mapping_dict
        hash_fields = []
        if 'data_mapping_dict' in load_operation_entry:
            for column_name, column_entry in load_operation_entry['data_mapping_dict'].items():
                if column_entry['exclude_from_key_hash']:
                    continue
                hash_field = {'field_name': column_entry['field_name'],
                              'prio_in_key_hash': column_entry['prio_in_key_hash'],
                              'field_target_table': table_name,
                              'field_target_column': column_name}
                hash_fields.append(hash_field)

        # put hash definition into global list
        hash_description = {"stage_column_name": stage_column_name,
                            "hash_origin_table": table_name,
                            "column_class": "key",
                            "column_type": table_key_column_type,
                            "hash_encoding": model_profile['table_key_hash_encoding'],
                            "hash_function": model_profile['table_key_hash_function'],
                            "hash_concatenation_seperator": model_profile['hash_concatenation_seperator'],
                            "hash_timestamp_format_sqlstyle": model_profile['hash_timestamp_format_sqlstyle'],
                            "hash_null_value_string": model_profile['hash_null_value_string'],
                            "model_profile_name": table_entry['model_profile_name']
                            }

        # add hash field list, when it has fields
        if len(hash_fields) >0:
            hash_description['hash_fields']= hash_fields

        # add direct key field mapping if it exists
        if 'direct_key_field' in load_operation_entry:
            hash_description['direct_key_field' ] = load_operation_entry ['direct_key_field']
            hash_description['stage_column_name'] = load_operation_entry['direct_key_field']


        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name] = hash_description

        # add reference to global entry into load operation
        load_operation_entry['hash_mapping_dict'] = {'key': {"hash_name": hash_name,
                                                             "hash_column_name": key_column_name, }}

        # put hash column in table hash list
        if key_column_name not in table_hash_columns:
            table_hash_columns[key_column_name] = {"column_class": "key",
                                                   "column_type": table_key_column_type}


def add_hash_column_mappings_for_lnk(link_table_name, link_table_entry):
    """
        Assemble the hash definitions for all load operations of a link table.
        Hashes are identified by the "KEY_OF"+<name of the table>, extended by "__FOR__" +<operation name>
        when the operation is not '*' or '/'.
        also the Hash Column name  for the stage table is assembled from the tables key
        column name and the relation name
        All data columns mapped to the link, that are not 'exlcuded from key hash' are used as
        dependent child keys.
        The link hash input is assembled by all business key columns from all parents supporting
        the load operation plus all dependent child keys.

        Args:
                table_name: Name of the table, the hash is added (only used for messages)
                table_entry: g_table_dict/tables[<key>] entry of the table

        Brain changes:
            g_hash_dict: add entry with the internal Hash name and the properties
                         declared as hash description below in link_hash_description
                         this includes the list of hash_fields

            g_table_dict.tables<table>.load_operations<operation_name>:
                         add hash_mapping_dict with 'key' entry referring the internal hash name
                            and hash_column_name in the target table
                         add hash_mapping_dict entries for all parent key columns (named parent_key_<n>)

            g_table_dict.tables<table>.hash_columns:
                         add entry with link key column
                         add entry with copies of parent key column
                                    and parent_declaration_position

            g_table_dict.tables<table>.link_parent_tables[n]:
                         generate the hub_key_column_name_in_link from the parent hub key name and
                         the relation


        will register errors
        """

    link_hash_base_name = "KEY_OF_" + link_table_name.upper()
    link_key_column_name = link_table_entry['link_key_column_name']
    load_operations = link_table_entry['load_operations']

    if 'hash_columns' not in link_table_entry:
        link_table_entry['hash_columns'] = {}
    table_hash_columns = link_table_entry['hash_columns']

    for link_load_operation_name, link_load_operation_entry in load_operations.items():
        hash_mapping_dict = {}
        log_function_step('add_hash_column_mappings_for_lnk', f"{link_table_name}:{link_load_operation_name}")
        link_load_operation_entry['hash_mapping_dict'] = hash_mapping_dict
        # link_mapping_set=link_load_operation_entry['mapping_set']

        # render link key names according to link_load_operation_name
        if link_load_operation_name == "*" or link_load_operation_name == "/" or len(load_operations) == 1:
            link_hash_name = link_hash_base_name
            stage_column_name = link_key_column_name
        else:
            link_hash_name = link_hash_base_name + "_" + link_load_operation_name.upper()
            stage_column_name = link_key_column_name + "_" + link_load_operation_name

        link_hash_fields = []

        # add parent hash key fields for this operation
        link_parent_count = 0
        hash_assembly_had_errors=False
        for link_parent_entry in link_table_entry['link_parent_tables']:
            link_parent_count += 1
            parent_table_entry = g_table_dict[link_parent_entry['table_name']]
            parent_model_profile = g_model_profile_dict[parent_table_entry['model_profile_name']]
            parent_table_key_column_type = parent_model_profile['table_key_column_type']
            parent_load_operations = parent_table_entry['load_operations']

            # determine the parent (hub) key set to use
            if link_parent_entry['relation_name'] != '?':  # explicitly declared parent relation
                needed_key_set = link_parent_entry[
                    'relation_name']  # the parent must provide keyset of explicitly declared relation
            elif link_table_entry[
                'has_explicit_link_parent_relations']:  # If relation name to parent is not decided, and part on explicit relation set
                needed_key_set = '/'
            elif parent_table_entry['is_hub_with_universal_load_operation']:  # the parent only has a universal relation
                needed_key_set = '/'
            else:
                needed_key_set = link_load_operation_name  # the parent must provide the relation of the process of the link

            if not needed_key_set in parent_load_operations:
                register_error(
                    f"AHS-L1: Hub '{link_parent_entry['table_name']}' has no key mapping for relation '{needed_key_set}' needed for link '{link_table_name}'")
                hash_assembly_had_errors=True
                continue
            parent_load_operation = parent_load_operations[needed_key_set]
            parent_hash_reference_dict = parent_load_operation['hash_mapping_dict']
            parent_key_hash_reference = parent_hash_reference_dict['key']

            # assemble the column name for the hub key in the link
            if link_parent_entry['hub_key_column_name_in_link'] != None:
                hub_key_column_name_in_link = link_parent_entry['hub_key_column_name_in_link']
            elif needed_key_set != "/" and needed_key_set != '*' and link_table_entry[
                'has_explicit_link_parent_relations']:
                hub_key_column_name_in_link = parent_key_hash_reference[
                                                  'hash_column_name'] + "_" + needed_key_set.upper()
                link_parent_entry['hub_key_column_name_in_link'] = hub_key_column_name_in_link
            else:
                hub_key_column_name_in_link = parent_key_hash_reference['hash_column_name']
                link_parent_entry['hub_key_column_name_in_link'] = hub_key_column_name_in_link

            # add the hash field mappings of the hash parent to the hash fields of the link if we dont have a direct key
            if 'direct_key_field' not in link_load_operation_entry:
                parent_hash_entry = g_hash_dict[parent_key_hash_reference['hash_name']]
                if 'hash_fields' not in parent_hash_entry:
                    register_error(
                        f"AHS-L2: Cant assemble link key fields for '{link_table_name}', since hub '{link_parent_entry['table_name']}' has no businiess keys mapped")
                    hash_assembly_had_errors = True
                    continue
                for parent_hash_field in parent_hash_entry['hash_fields']:
                    link_hash_field = parent_hash_field.copy()
                    link_hash_field['parent_declaration_position'] = link_parent_count
                    link_hash_fields.append(link_hash_field)

            # add reference to global entry of parent into load operation
            link_parent_key_hash_reference = {"hash_name": parent_key_hash_reference['hash_name'],
                                              "hash_column_name": hub_key_column_name_in_link}

            hash_mapping_dict['parent_key_' + str(link_parent_count)] = link_parent_key_hash_reference

            # put hash column in table hash list
            if hub_key_column_name_in_link not in table_hash_columns:
                table_hash_columns[hub_key_column_name_in_link] = {"column_class": "parent_key",
                                                                   "parent_table_name": link_parent_entry['table_name'],
                                                                   "parent_key_column_name": parent_key_hash_reference[
                                                                       'hash_column_name'],
                                                                   "column_type": parent_table_key_column_type}

        if hash_assembly_had_errors:
            return

        # add dependent child keys if exist
        if 'data_mapping_dict' in link_load_operation_entry:
            for column_name, column_entry in link_load_operation_entry['data_mapping_dict'].items():
                if column_entry['exclude_from_key_hash']:
                    continue
                hash_field = {'field_name': column_entry['field_name'],
                              'prio_in_key_hash': column_entry['prio_in_key_hash'],
                              'field_target_table': link_table_name,
                              'field_target_column': column_name}
                link_hash_fields.append(hash_field)

        # put link hash definition into global list
        model_profile = g_model_profile_dict[link_table_entry['model_profile_name']]
        table_key_column_type = model_profile['table_key_column_type']

        link_hash_description = {"stage_column_name": stage_column_name,
                                 "hash_origin_table": link_table_name,
                                 "column_class": "key",
                                 "hash_fields": link_hash_fields,
                                 "column_type": table_key_column_type,
                                 "hash_encoding": model_profile['table_key_hash_encoding'],
                                 "hash_function": model_profile['table_key_hash_function'],
                                 "hash_concatenation_seperator": model_profile['hash_concatenation_seperator'],
                                 "hash_timestamp_format_sqlstyle": model_profile['hash_timestamp_format_sqlstyle'],
                                 "hash_null_value_string": model_profile['hash_null_value_string'],
                                 "model_profile_name": link_table_entry['model_profile_name']
                                 }

        # add hash field list, when it has fields
        if len(link_hash_fields) >0:
            link_hash_description['hash_fields']= link_hash_fields

        # add direct key field, when it was declared, and change stage column name to field name
        if 'direct_key_field' in link_load_operation_entry:
            link_hash_description['direct_key_field' ] = link_load_operation_entry ['direct_key_field']
            link_hash_description['stage_column_name'] = link_load_operation_entry ['direct_key_field']

        if link_hash_name not in g_hash_dict:
            g_hash_dict[link_hash_name] = link_hash_description

        # add reference for link key hash to load operation
        link_key_hash_reference = {"hash_name": link_hash_name,
                                   "hash_column_name": link_key_column_name, }
        hash_mapping_dict['key'] = link_key_hash_reference

        # put hash column in table hash list

        if link_key_column_name not in table_hash_columns:
            table_hash_columns[link_key_column_name] = {"column_class": "key",
                                                        "column_type": table_key_column_type}


def add_hash_column_mappings_for_sat(table_name, table_entry):
    """
    Assemble the hash definitions for all load operations of a sat table.
    Key hashes looked up in the parent table.
    Diff hashes are only created when there are relevant columns and the general
    settings declare it.
    Diff hashes are identified by  "DIFF_OF"+<name of the table>, extended by "__FOR__" +<operation name>
        when the operation is not '*' or '/'.
    All data columns mapped to the sat, that are not 'exlcuded from diff hash' are used for the diff hash

    Args:
            table_name: Name of the table, the hashes are added (only used for messages)
            table_entry: g_table_dict/tables[<key>] entry of the table

    Brain changes:
        g_table_dict.tables<table>.hash_columns:
                     add entry with key column name
                     add entry with diff_hash column name

        g_hash_dict: only the diff hash needs to be added  with the internal Hash name and
                        the properties declared as hash description below
                        this includes the list of hash_fields

        g_table_dict.tables<table>.load_operations<operation_name>:
                     add hash_mapping_dict with 'parent_key' entry referring the internal hash name
                     of the proper parent key
                     add hash_mapping_dict with 'diff_hash' entry referring the internal hash name
                     of the proper parent key


    will register errors
    """
    log_function_step('add_hash_column_mappings_for_sat', str(table_name))

    if 'hash_columns' not in table_entry:
        table_entry['hash_columns'] = {}
    table_hash_columns = table_entry['hash_columns']
    satellite_parent_table = g_table_dict[table_entry['satellite_parent_table']]
    satellite_parent_model_profile = g_model_profile_dict[satellite_parent_table['model_profile_name']]
    satellite_parent_table_key_column_type = satellite_parent_model_profile['table_key_column_type']

    load_operations = table_entry['load_operations']

    # determine the distinct mapping sets over all load operations of the table
    mapping_set_dict = {}
    for load_operation_name, load_operation_entry in load_operations.items():
        mapping_set = load_operation_entry['mapping_set']
        if not mapping_set in mapping_set_dict:
            mapping_set_dict[mapping_set] = 1

    # add a key and diff hash for every load operation of the satellite
    for load_operation_name, load_operation_entry in load_operations.items():
        hash_mapping_dict = {}
        load_operation_entry['hash_mapping_dict'] = hash_mapping_dict

        # determine key hash from parent table

        parent_load_operations = satellite_parent_table['load_operations']

        if not load_operation_name in parent_load_operations: #todo test this to be omitted for structural element parents that declare a BK
            if satellite_parent_table['is_only_structural_element']:
                if  'direct_key_mappings' not in satellite_parent_table:
                    register_error(
                        f"AHS-S4: Missing a key declaration for parent table '{table_entry['satellite_parent_table']}' of satellite '{table_name}'. Even though the parent is only structural, 'use_as_key_hash' or business keys are needed")
                    return
            register_error(
                f"AHS-S5: Parent table '{table_entry['satellite_parent_table']}' has no load operation for relation '{load_operation_name}' requiered for satellite '{table_name}'")
            return


        parent_load_operation = parent_load_operations[load_operation_name]
        parent_hash_reference_dict = parent_load_operation['hash_mapping_dict']
        parent_key_hash_reference = parent_hash_reference_dict['key']
        satellite_parent_table_key_column_name = parent_key_hash_reference['hash_column_name']

        sat_key_column_name = parent_key_hash_reference[
            'hash_column_name']  # currently the same as parent. Might be overwritten by sat propetery later

        if 'hash_name' not in parent_key_hash_reference:
            # todo: create compiler check test case to trigger this message
            register_error(
                f"AHS-S6: Parent table '{table_entry['satellite_parent_table']}' for satellite '{table_name}' has no hash calculation for {satellite_parent_table_key_column_name}. You may need a 'use_as_key_hash' mapping to the satellite.")
            return

        # put reference to hash description in load operation hash list
        sat_key_hash_reference = {"hash_name": parent_key_hash_reference['hash_name'],
                                  "hash_column_name": sat_key_column_name}

        hash_mapping_dict['parent_key'] = sat_key_hash_reference

        # put hash column in table hash list
        if sat_key_column_name not in table_hash_columns:
            table_hash_columns[sat_key_column_name] = {"column_class": "parent_key",
                                                       "parent_table_name": table_entry['satellite_parent_table'],
                                                       "parent_key_column_name": satellite_parent_table_key_column_name,
                                                       "column_type": satellite_parent_table_key_column_type}

        # skip diff hash logic if not needed
        if table_entry['is_effectivity_sat'] or table_entry['compare_criteria'] == 'key' or table_entry[
            'compare_criteria'] == 'none' or not table_entry['uses_diff_hash']:
            table_entry['uses_diff_hash'] = False
            continue

        if not table_entry['uses_diff_hash']:
            continue  # without diff hash we are done here

        # add diff hash for the mapping set
        mapping_set = load_operation_entry['mapping_set']

        diff_hash_base_name = "DIFF_OF_" + table_name.upper()
        diff_hash_column_name = table_entry['diff_hash_column_name']
        model_profile = g_model_profile_dict[table_entry['model_profile_name']]
        diff_hash_column_type = model_profile['diff_hash_column_type']

        if mapping_set == "*" or mapping_set == "/" or len(mapping_set_dict) == 1:
            hash_name = diff_hash_base_name
            stage_column_name = diff_hash_column_name
        else:
            hash_name = diff_hash_base_name + "__FOR__" + mapping_set.upper()
            stage_column_name = diff_hash_column_name + "_" + mapping_set.upper()

        hash_fields = []
        for column_name, column_entry in load_operation_entry['data_mapping_dict'].items():
            if column_entry['exclude_from_change_detection']:
                continue
            hash_field = {'field_name': column_entry['field_name'],
                          'prio_in_diff_hash': column_entry['prio_in_diff_hash'],
                          'prio_for_row_order': column_entry['prio_for_row_order'],
                          'field_target_table': table_name,
                          'field_target_column': column_name}
            hash_fields.append(hash_field)

        # put hash definition into global list
        hash_description = {"stage_column_name": stage_column_name,
                            "hash_origin_table": table_name,
                            "multi_row_content": table_entry['is_multiactive'],
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
        if 'hash_name' in sat_key_hash_reference:  # hash value is defined by hash calculation of parent
            hash_description["related_key_hash"] = parent_key_hash_reference['hash_name']

        if hash_name not in g_hash_dict:
            g_hash_dict[hash_name] = hash_description

        # add reference to global entry into load operation
        hash_mapping_dict['diff_hash'] = {"hash_name": hash_name,
                                          "hash_column_name": diff_hash_column_name}

        # put diff hash column in table hash list
        if diff_hash_column_name not in table_hash_columns:
            table_hash_columns[diff_hash_column_name] = {"column_class": "diff_hash",
                                                         "column_type": diff_hash_column_type}


def add_hash_column_mappings_for_ref(table_name, table_entry):
    """
     Assemble the diff hash definitions for all load operations of a ref table.
     Diff hashes are identified by  "DIFF_OF"+<name of the table>, extended by "__FOR__" +<operation name>
         when the operation is not '*' or '/'.
     All data columns mapped to the reference, that are not 'exlcuded from diff hash' are used for the diff hash

     Args:
             table_name: Name of the table, the hashes are added (only used for messages)
             table_entry: g_table_dict/tables[<key>] entry of the table

     Brain changes:
         g_table_dict.tables<table>.hash_columns:
                      add entry with diff_hash column name

         g_hash_dict:  diff hash is  added  with the internal Hash name and
                         the properties declared as hash description below
                         this includes the list of hash_fields

         g_table_dict.tables<table>.load_operations<operation_name>:
                      add hash_mapping_dict with 'diff_hash' entry referring the internal hash name
                      of the proper parent key


     will register errors
     """
    if 'hash_columns' not in table_entry:
        table_entry['hash_columns'] = {}
    table_hash_columns = table_entry['hash_columns']

    if not table_entry['uses_diff_hash']:
        return

    model_profile = g_model_profile_dict[table_entry['model_profile_name']]
    diff_hash_column_type = model_profile['table_key_column_type']

    load_operations = table_entry['load_operations']
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
        hash_mapping_dict['diff_hash'] = {"hash_name": hash_name,
                                          "hash_column_name": diff_hash_column_name}

        # put hash column in table hash list
        if diff_hash_column_name not in table_hash_columns:
            table_hash_columns[diff_hash_column_name] = {"column_class": "diff_hash",
                                                         "column_type": diff_hash_column_type}

# ------------------ function to add the data mapping properties depending on the load operation

def add_data_mapping_dict_to_load_operations():
    """
    Walk through all tables and call the mapping dictionary functions

    Brain changes:
        subfunctions will change g_table_dict.tables<table>.load_operations<operation_name>

    subfunctions register errors
    """
    global g_table_dict
    for table_name, table_entry in g_table_dict.items():
        for load_operation_name, load_operation in table_entry['load_operations'].items():
            if 'data_columns' in table_entry:
                log_function_step('add_data_mapping_dict_to_load_operations', f"{table_name}:{load_operation_name}")
                add_data_mapping_dict_for_one_load_operation(table_name, table_entry, load_operation['mapping_set'],
                                                             load_operation)
            if 'direct_key_mappings' in table_entry:
                add_direct_key_mapping_for_one_load_operation(table_name, table_entry, load_operation['mapping_set'],
                                                             load_operation)

def add_data_mapping_dict_for_one_load_operation(table_name, table_entry, mapping_set_name, load_operation):
    """
    Determine the required mapping from field to target column for a
    specific load operation and mapping set by search
    (currently the separation of load operation and mapping set seem to be redundant, but
    this will change with upcoming featrures regarding the definition of releations)

    Args:
            table_name: Name of the table this is aone for (needed for messages)
            table_entry: g_table_dict/tables[<key>] entry of the table
            mapping_set_name: Name of the Mapping set to use
            load_operation: g_table_dict/tables[<key>]/load_operations[n] this should be done for

     Brain changes:
             g_table_dict.tables<table>.load_operations<operation_name>:
                add 'data_mapping_dict' with: <column_name> : <field_name>

    will register errors
    """
    data_mapping_dict = {}
    for data_column_name, data_column in table_entry['data_columns'].items():
        default_field_name = None
        explicit_mapped_field_name = None

        # search in all field mappings of the column for the specified mapping set
        for field_mapping in data_column['field_mappings']:
            for mapping_relation_name in field_mapping['relation_names']:

                if mapping_relation_name == mapping_set_name:
                    if explicit_mapped_field_name == None:
                        explicit_mapped_field_name = field_mapping['field_name']
                    else:
                        register_error(
                            f"Found more then one field mapping for column {data_column_name} in relation {mapping_set_name} for table {table_name}")

                if mapping_relation_name == "*":
                    if default_field_name == None:
                        default_field_name = field_mapping['field_name']
                    else:
                        register_error(
                            f"Duplicate default field mappings for column {data_column_name} for table {table_name}")

        # Add the identified field name
        if explicit_mapped_field_name != None:
            data_mapping_dict[data_column_name] = {"field_name": explicit_mapped_field_name}
            copy_data_column_properties_to_operation_mapping(data_mapping_dict[data_column_name], data_column)
            continue  # we prefer the explicit, so continue with next data column

        if default_field_name != None:
            data_mapping_dict[data_column_name] = {"field_name": default_field_name}
            copy_data_column_properties_to_operation_mapping(data_mapping_dict[data_column_name], data_column)
            continue  # we take the default and continue with next data column

        # when we reach this point, we have not found a valid mapping for the column
        register_error(
            f"No valid mapping found for Column {data_column_name} in relation {mapping_set_name} for table {table_name}")

    # finally add the data mapping dict to the load operation, when mappings have been found
    if len(data_mapping_dict) > 0:
        load_operation['data_mapping_dict'] = data_mapping_dict


def add_direct_key_mapping_for_one_load_operation(table_name, table_entry, mapping_set_name, load_operation):

    data_mapping_dict = {}
    default_field_name = None
    explicit_mapped_field_name = None

    # search in all direct key mappings for the specified mapping set
    for field_mapping in table_entry['direct_key_mappings']:
        for mapping_relation_name in field_mapping['relation_names']:

            if mapping_relation_name == mapping_set_name:
                if explicit_mapped_field_name == None:
                    explicit_mapped_field_name = field_mapping['field_name']
                else:
                    register_error(
                        f"DKL-1:Found more then one direct key mapping for relation '{mapping_set_name}' for table '{table_name}'")

            if mapping_relation_name == "*":
                if default_field_name == None:
                    default_field_name = field_mapping['field_name']
                else:
                    #todo: add test for DKL-2, this error might not be possible,since *
                    register_error(
                        f"DKL-2:Duplicate default field mappings for direct key for table {table_name}")

    # Add the identified field name
    if explicit_mapped_field_name != None:
        load_operation['direct_key_field']= explicit_mapped_field_name
        return   # we found the best solution

    if default_field_name != None:
        load_operation['direct_key_field']= default_field_name
        return   # we use the default  solution

    #no solution found
    #todo: add test for DKL-3
    register_error(
        f"DKL-3: Could not determine direct key mapping for relation '{mapping_set_name}' for table '{table_name}'")


def copy_data_column_properties_to_operation_mapping(data_mapping_dict, data_column):
    """
      Copies the hashing relevant properties of the data columns of a table to the data mappings
      of the load operation.

      Args:
              data_mapping_dict: g_table_dict.tables<table>.load_operations<operation_name>.data_mapping_dict
                                 to copy to
              data_column: g_table_dict/tables[<key>].data_column[<column_name>] to copy from

       Brain changes:
               g_table_dict.tables<table>.load_operations<operation_name>.data_mapping_dict
                  add all keys listed in the function below

      """
    operation_relevant_column_properties = ['column_class', 'exclude_from_change_detection', 'prio_for_row_order',
                                            'prio_in_diff_hash', 'exclude_from_key_hash', 'prio_in_key_hash',
                                            'update_on_every_load', 'is_multi_active_key']
    for relevant_key in operation_relevant_column_properties:
        if relevant_key in data_column:
            data_mapping_dict[relevant_key] = data_column[relevant_key]

# ------------------  Final intertable checks


def check_intertable_column_constraints():
    """
    Final checks, that can only be done after all colunms and load operations have
    been determined
        -check if declared driving key columns can be resolved

    will register errors

    """

    for table_name, table_entry in g_table_dict.items():
        # Driving Keys must be resolvable in the parent
        if 'driving_keys' in table_entry and table_entry['table_stereotype'] == 'sat':
            parent = table_entry['satellite_parent_table']
            parent_hash_columns = g_table_dict[parent]['hash_columns']
            parent_data_columns = []
            if 'data_columns' in g_table_dict[parent]:
                parent_data_columns = g_table_dict[parent]['data_columns']
            for driving_key in table_entry['driving_keys']:
                if driving_key not in parent_hash_columns and driving_key not in parent_data_columns:
                    register_error(
                        f"Driving Key '{driving_key}' is not a key hash or dependent child key in parent '{parent}'")


    #todo: check if fields are only mapped to tables, that will not be rendered. Throw error if so.


# ------------------ Functions to render the dvpi from the brain content -------------------

def assemble_dvpi(dvpd_object, dvpd_filename):
    """
    Create the dvpi structure and populate it with data from the brain.

    Args:
            dvpd_object: The source dvpd (used to copy some static properties, taht are not in he brain
            dvpd_filename: Name of the final file, to write to (used to write it as property into the dvpi)

    Changes: g_dvpi_document will contain a full dvpi when done

    """
    global g_dvpi_document

    pipeline_revision_tag = dvpd_object.get('pipeline_revision_tag', '--none--')

    # add meta declaration and dpvd meta data
    g_dvpi_document = {'dvdp_compiler': 'dvpdc reference compiler,  release 0.6.2',
                       'dvpi_version': '0.6.2',
                       'compile_timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                       'dvpd_version': dvpd_object['dvpd_version'],
                       'pipeline_name': dvpd_object['pipeline_name'],
                       'pipeline_revision_tag': pipeline_revision_tag,
                       'dvpd_filename': dvpd_filename}

    # add tables
    dvpi_tables = []
    g_dvpi_document['tables'] = dvpi_tables
    for table_name, table_entry in g_table_dict.items():
        if table_entry['is_only_structural_element']:  # we dont care about structural elements
            continue
        dvpi_tables_entry = assemble_dvpi_table_entry(table_name, table_entry)
        dvpi_tables.append(dvpi_tables_entry)

    # todo check for double table objects in physical model(system, schema, name)

    # copy data_extraction from dvpd
    g_dvpi_document['data_extraction'] = dvpd_object['data_extraction']

    # add parse sets (currently only one, will be more in later releases)
    dvpi_parse_sets = []
    g_dvpi_document['parse_sets'] = dvpi_parse_sets
    dvpi_parse_sets.append(assemble_dvpi_parse_set(dvpd_object))


def assemble_dvpi_table_entry(table_name, table_entry):
    """
    Assembles a dvpi table entry from the brain

    Args:
            table_name: name of the table
            table_entry: g_tables[<table_name>] entry to transform

    returns: the final dvpi tables entry

    will register errors
    """

    table_properties_to_copy = ['table_stereotype', 'table_comment', 'schema_name', 'storage_component',
                                'has_deletion_flag', 'is_effectivity_sat', 'is_enddated', 'is_multiactive',
                                'compare_criteria', 'uses_diff_hash']
    dvpi_table_entry = {'table_name': table_name}
    for table_property in table_properties_to_copy:
        if table_property in table_entry and table_entry[table_property] != None:
            dvpi_table_entry[table_property] = table_entry[table_property]

    # Driving Keys
    if 'driving_keys' in table_entry and table_entry['table_stereotype'] == 'sat':
        dvpi_table_entry['driving_keys'] = table_entry['driving_keys']

    dvpi_columns = []
    dvpi_table_entry['columns'] = dvpi_columns

    model_profile = g_model_profile_dict[table_entry['model_profile_name']]

    # add meta columns to column dict

    dvpi_columns.append(
        {'column_name': model_profile['load_date_column_name'], 'is_nullable': False, 'column_class': 'meta_load_date',
         'column_type': model_profile['load_date_column_type']})
    dvpi_columns.append({'column_name': model_profile['load_process_id_column_name'], 'is_nullable': False,
                         'column_class': 'meta_load_process_id',
                         'column_type': model_profile['load_process_id_column_type']})
    dvpi_columns.append({'column_name': model_profile['record_source_column_name'], 'is_nullable': False,
                         'column_class': 'meta_record_source',
                         'column_type': model_profile['record_source_column_type']})

    if 'has_deletion_flag' in table_entry and table_entry['has_deletion_flag']:
        dvpi_columns.append({'column_name': model_profile['deletion_flag_column_name'], 'is_nullable': False,
                             'column_class': 'meta_deletion_flag',
                             'column_type': model_profile['deletion_flag_column_type']})

    if 'is_enddated' in table_entry and table_entry['is_enddated']:
        dvpi_columns.append({'column_name': model_profile['load_enddate_column_name'], 'is_nullable': False,
                             'column_class': 'meta_load_enddate',
                             'column_type': model_profile['load_enddate_column_type']})

    # add hash columns to columns
    hash_column_properties_to_copy = ['column_class', 'column_type', 'parent_key_column_name', 'parent_table_name']
    for column_name, column_entry in table_entry['hash_columns'].items():
        dvpi_column_entry = {'column_name': column_name, 'is_nullable': False}
        dvpi_columns.append(dvpi_column_entry)
        for column_property in hash_column_properties_to_copy:
            if column_property in column_entry:
                dvpi_column_entry[column_property] = column_entry[column_property]

    # add data columns to columns
    data_column_properties_to_copy = ['column_class', 'column_type', 'column_content_comment',
                                      'exclude_from_change_detection', 'prio_for_column_position']
    if 'data_columns' in table_entry:
        for column_name, column_entry in table_entry['data_columns'].items():
            dvpi_column_entry = {'column_name': column_name, 'is_nullable': True, }
            dvpi_columns.append(dvpi_column_entry)
            for column_property in data_column_properties_to_copy:
                if column_property in column_entry and column_entry[column_property] != None:
                    dvpi_column_entry[column_property] = column_entry[column_property]

    # final check for double column names
    column_dict = {}
    for column_entry in dvpi_columns:
        column_name = column_entry['column_name']
        if column_name not in column_dict:
            column_dict[column_name] = 1
        else:
            register_error(
                f"AD-TE1: Double column name '{column_name}' when assembling table '{table_name}'. Please check for name collisions between meta columns, data columns and hash columns!")

    return dvpi_table_entry


def assemble_dvpi_parse_set(dvpd_object):
    """
    Assembles a dvpi parse set entry from the brain

    Args:
            dvpd_object: the dvpd (needed, since some properties will be copied directly)

    returns: the final dvpi parse set entry

    will register errors
    """

    parse_set = {}

    # add meta data for parsing
    stage_properties = copy.deepcopy(dvpd_object['stage_properties'])
    for stage_property_entry in stage_properties:
        if 'stage_table_name' not in stage_property_entry:
            stage_property_entry['stage_table_name'] = f"{g_dvpi_document['pipeline_name']}_stage"
        if 'storage_component' not in stage_property_entry:
            stage_property_entry['storage_component'] = ""
    parse_set['stage_properties'] = stage_properties
    # todo check for duplicate stage table names on same system

    parse_set['record_source_name_expression'] = dvpd_object['record_source_name_expression']

    # add field dictionary
    dvpi_fields = []
    parse_set['fields'] = dvpi_fields
    for field_name, field_entry in g_field_dict.items():
        dvpi_field_entry = field_entry.copy()
        dvpi_field_entry['field_name'] = field_name
        dvpi_fields.append(dvpi_field_entry)

    # add hash dictionary
    dvpi_hashes = []
    parse_set['hashes'] = dvpi_hashes
    for hash_name, hash_entry in g_hash_dict.items():
        dvpi_hash_entry = hash_entry.copy()
        dvpi_hash_entry['hash_name'] = hash_name
        dvpi_hashes.append(dvpi_hash_entry)

    # add load operations
    dvpi_load_operations = []
    parse_set['load_operations'] = dvpi_load_operations
    has_deletion_flag_in_a_table = False
    for table_name, table_entry in g_table_dict.items():
        if 'has_deletion_flag' in table_entry and table_entry['has_deletion_flag']:
            has_deletion_flag_in_a_table = True
        for relation_name, load_operation_entry in table_entry['load_operations'].items():
            dvpi_load_operation_entry = {'table_name': table_name,
                                         'relation_name': relation_name,
                                         'operation_origin': load_operation_entry['operation_origin'],
                                         'hash_mappings': assemble_dvpi_hash_mappings(load_operation_entry)}

            if 'data_mapping_dict' in load_operation_entry:
                dvpi_load_operation_entry['data_mapping'] = assemble_dvpi_data_mappings(load_operation_entry)
            dvpi_load_operations.append(dvpi_load_operation_entry)

    # add stage column dict
    parse_set['stage_columns'] = assemble_dvpi_stage_columns(has_deletion_flag_in_a_table)

    if g_error_count > 0:
        raise DvpdcError

    return parse_set


def assemble_dvpi_hash_mappings(load_operation_entry):
    """
    Assembles a dvpi hash mapping entry for a specific load operation

    Args:
            load_operation_entry: g_table_dict/tables[<key>]/load_operations[n] this should be done for

    returns: the dvpi hash_mappings properties for this load operation

    """
    global g_hash_dict

    dvpi_hash_mappings = []
    if not 'hash_mapping_dict' in load_operation_entry:
        return dvpi_hash_mappings
    for hash_class, load_operation_hash_dict_entry in load_operation_entry['hash_mapping_dict'].items():
        hash_definition = g_hash_dict[load_operation_hash_dict_entry['hash_name']]
        dvpi_hash_mapping_entry = {'hash_class': hash_class,
                                   'column_name': load_operation_hash_dict_entry['hash_column_name'],
                                   'hash_name':  load_operation_hash_dict_entry['hash_name'],
                                   'stage_column_name': hash_definition['stage_column_name']
                                   }
        if 'direct_key_field' in hash_definition:
            dvpi_hash_mapping_entry['direct_key_field'] = hash_definition['direct_key_field']

        dvpi_hash_mappings.append(dvpi_hash_mapping_entry)
    return dvpi_hash_mappings


def assemble_dvpi_data_mappings(load_operation_entry):
    """
    Assembles a dvpi data_mapping entry for a specific load operation

    Args:
            load_operation_entry: g_table_dict/tables[<key>]/load_operations[n] this should be done for

    returns: the dvpi data_mapping properties for this load operation

    """
    dvpi_data_mappings = []
    for column_name, data_mapping_dict_entry in load_operation_entry['data_mapping_dict'].items():
        dvpi_data_mapping_entry = {'column_name': column_name,
                                   'field_name': data_mapping_dict_entry['field_name'],
                                   'column_class': data_mapping_dict_entry['column_class'],
                                   'stage_column_name': data_mapping_dict_entry['field_name']
                                   # currently it is 1:1 naming
                                   }
        if 'is_multi_active_key' in data_mapping_dict_entry:
            dvpi_data_mapping_entry['is_multi_active_key'] = data_mapping_dict_entry['is_multi_active_key']
        dvpi_data_mappings.append(dvpi_data_mapping_entry)
    return dvpi_data_mappings


def assemble_dvpi_stage_columns(has_deletion_flag_in_a_table):
    """
    Assembles a dvpi stage_columns entry for the current brain
    (This will change, when multiple parse sets and stage tables are supported)

    Args:
            has_deletion_flag_in_a_table: must be set to true, if a deletion flag is needed in the stage table

    returns: the dvpi stage_columns properties for this load operation
    """

    stage_column_dict={}

    dvpi_stage_columns = []

    model_profile = g_model_profile_dict[g_pipeline_model_profile_name]

    # add meta columns to column stage dict (assuming, we will not have a conflict in between meta column names

    stage_column_dict[model_profile['load_date_column_name']]={'stage_column_name': model_profile['load_date_column_name'], 'is_nullable': False,
                               'stage_column_class': 'meta_load_date',
                               'column_type': model_profile['load_date_column_type']}
    stage_column_dict[model_profile['load_process_id_column_name']]={'stage_column_name': model_profile['load_process_id_column_name'], 'is_nullable': False,
                               'stage_column_class': 'meta_load_process_id',
                               'column_type': model_profile['load_process_id_column_type']}
    stage_column_dict[model_profile['record_source_column_name']] ={'stage_column_name': model_profile['record_source_column_name'], 'is_nullable': False,
                               'stage_column_class': 'meta_record_source',
                               'column_type': model_profile['record_source_column_type']}

    if has_deletion_flag_in_a_table:
        stage_column_dict[model_profile['deletion_flag_column_name']] =  {'stage_column_name': model_profile['deletion_flag_column_name'], 'is_nullable': False,
                                'stage_column_class': 'meta_deletion_flag',
                                'column_type': model_profile['deletion_flag_column_type']}

    # add all hashes that have not direct key column to stage dict

    direct_key_hashes={}
    for hash_name, hash_entry in g_hash_dict.items():
        if 'direct_key_field' in hash_entry:
            if hash_entry['direct_key_field'] not in direct_key_hashes:
                direct_key_hashes[ hash_entry['direct_key_field']]=1
            else:
                continue  # direct keys will only be added once
        if hash_entry['stage_column_name'] in stage_column_dict:
            register_error(
                f"AD-SC0: Double stage column name '{hash_entry['stage_column_name']}' when assembling columns for stage table. Please check for name collisions between meta columns, fields and hash columns!")
            continue

        dvpi_stage_column_entry = {'stage_column_name': hash_entry['stage_column_name'],
                                   'stage_column_class': 'hash',
                                   'is_nullable': False,
                                   'hash_name': hash_name,
                                   'column_type': hash_entry['column_type']}
        if 'direct_key_field' in hash_entry:
            field_name = hash_entry['direct_key_field']
            dvpi_stage_column_entry['field_name'] = field_name
            dvpi_stage_column_entry['stage_column_class']='direct_key'
            targets = collect_target_column_data_for_direct_key(field_name)
            dvpi_stage_column_entry['targets'] = targets
            dvpi_stage_column_entry['column_classes']= collect_column_classes_from_targets(targets)

        stage_column_dict[hash_entry['stage_column_name']]=dvpi_stage_column_entry

        # add all fields to the stage list
    for field_name, field_entry in g_field_dict.items():
        if field_name in direct_key_hashes:
            continue # direct key fields have been managed above

        if field_name in stage_column_dict:
            register_error(
                f"AD-SC0b: Double stage column name '{field_name}' when assembling columns for stage table. Please check for name collisions between meta columns, fields and hash columns!")

        targets=collect_target_column_data_for_field(field_name)
        stage_column_dict[field_name] = {'stage_column_name': field_name,
                                         'stage_column_class': 'data',
                                         'field_name': field_name,
                                         'is_nullable': True,
                                         'column_type': field_entry['field_type'],
                                         'column_classes': collect_column_classes_from_targets(targets),
                                         'targets': targets  # Add the targets array
                                         }

    # finally convert the dict into the stage column array
    for stage_column_entry in stage_column_dict.values():
        dvpi_stage_columns.append(stage_column_entry)

    return dvpi_stage_columns

def collect_target_column_data_for_direct_key(field_name):
    targets = []

    # collect hashes, that use the field as direct key
    hashes_using_field=[]
    for hash_name, hash_entry in g_hash_dict.items():
        if 'direct_key_field' in hash_entry:
            if hash_entry['direct_key_field'] == field_name:
                hashes_using_field.append(hash_name)

    # search for uses of the hash in load operations
    for table_name, table_entry in g_table_dict.items():
        if 'load_operations' in table_entry:
            for load_operation_entry in table_entry['load_operations'].values():
                if 'hash_mapping_dict' in load_operation_entry:
                    for load_operation_hash_entry in load_operation_entry ['hash_mapping_dict'].values():
                        if load_operation_hash_entry['hash_name'] in hashes_using_field:
                            hash_column_name_in_table=load_operation_hash_entry['hash_column_name']
                            table_hash_column=table_entry['hash_columns'][hash_column_name_in_table]
                            targets.append({
                                'table_name': table_name,
                                'column_name': hash_column_name_in_table,
                                'column_type': table_hash_column['column_type'],
                                'column_class': table_hash_column['column_class']
                            })
    return targets

def collect_column_classes_from_targets(targets):
    column_classes=[]
    if len(targets)==0:
        column_classes.append('unmapped')
    for target_entry in targets:
        if target_entry['column_class'] not in column_classes:
            column_classes.append(target_entry['column_class'] )
    return column_classes
def collect_target_column_data_for_field(field_name):
    targets=[]
    for table_name, table_entry in g_table_dict.items():
        if table_entry['is_only_structural_element']:
            continue    #skip tables that are not created, therefor will not be a target
        if 'data_columns' in table_entry:
            for column_name, column_entry in table_entry['data_columns'].items():
                for mapping in column_entry['field_mappings']:
                    if mapping['field_name'] == field_name:
                        targets.append({
                            'table_name': table_name,
                            'column_name': column_name,
                            'column_type': column_entry['column_type'],
                            'column_class': column_entry['column_class']
                        })
    return targets

def collect_column_classes_for_field(field_name):
    """
    Assistence for the staging assembly,
    Collects for a specific field all column classes, this field is mapped to

    Args:
            field_name: name of the field of interest

    returns: list of column classes
    """
    column_classes = []

    # collect from data column mappings
    for table_name, table_entry in g_table_dict.items():
        if 'data_columns' in table_entry:
            for column_name, data_column_entry in table_entry['data_columns'].items():
                for field_mapping_entry in data_column_entry['field_mappings']:
                    if field_mapping_entry['field_name'] == field_name:
                        if data_column_entry['column_class'] not in column_classes:
                            column_classes.append(data_column_entry['column_class'])


    # collect from usage as direct key value
    for hash_name, hash_entry in g_hash_dict.items():
        if  hash_entry.get('direct_key_field','') == field_name:
            # search for table load operations, using this hash
            for table_name, table_entry in g_table_dict.items():
                if 'load_operations' in table_entry:
                    for load_operation_name, load_operation_entry in table_entry['load_operations'].items():
                        if 'hash_column_dict' in load_operation_entry:
                            for hash_column_class, hash_mapping_entry in load_operation_entry['hash_column_dict']:
                                if hash_mapping_entry['hash_name']== hash_name:
                                    if hash_column_class not in column_classes:
                                        column_classes.append(hash_column_class)

    return column_classes



# ------------------ Functions to write the dvpi Summary

def writeDvpiSummary(dvpdc_report_path, dvpd_file_path):
    """
    Render the dvpi summary report to a file in the dvpdc report. The file is named
    like the dvpd soure file wihtout any dvpd or json postfix but instaed with the
    postfix ".dvpidum.txt"

    Args:
            dvpdc_report_path: relative or absolute directory path for the report file
            dvpd_file_path: file path of the source dvpd file
    """

    dvpdc_report_directory = Path(dvpdc_report_path)
    dvpdc_report_directory.mkdir(parents=True, exist_ok=True)

    dvpisum_filename = dvpd_file_path.name.replace('.json', '').replace('.dvpd', '') + ".dvpisum.txt"

    dvpisum_file_path = dvpdc_report_directory.joinpath(dvpisum_filename)

    try:
        with open(dvpisum_file_path, "w") as dvpisum_file:
            dvpisum_file.write("Data Vault Pipeline Instruction Summary (DVPISUM)\n")
            dvpisum_file.write("=================================================\n\n")
            dvpisum_file.write(f"Pipeline name: {g_dvpi_document['pipeline_name']}\n")
            dvpisum_file.write(f"DVPD file:     {dvpd_file_path.name}\n")
            dvpisum_file.write(f"dvpd version:  {g_dvpi_document['dvpd_version']}\n")
            dvpisum_file.write(f"compiled at:   {g_dvpi_document['compile_timestamp']}\n")

            ## ------------------- Tables
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

                dvpisum_file.write(
                    f" [{table_entry['storage_component']}.{table_entry['schema_name']}.{table_entry['table_name']}]\n")
                max_column_name_length = 0
                for column_entry in table_entry['columns']:
                    if len(column_entry['column_name']) > max_column_name_length:
                        max_column_name_length = len(column_entry['column_name'])
                for column_entry in table_entry['columns']:
                    dvpisum_file.write(
                        f"      {column_entry['column_class'].ljust(20)}| {column_entry['column_name'].ljust(max_column_name_length)}  {column_entry['column_type']}\n")
                dvpisum_file.write("\n")

            ## ------------------- Parse sets
            for parse_set_index, parse_set_entry in enumerate(g_dvpi_document['parse_sets'], start=1):
                dvpisum_file.write(f"\nParse set {parse_set_index}\n")
                dvpisum_file.write("--------------------------------------------------\n")
                for load_operation_entry in parse_set_entry['load_operations']:
                    dvpisum_file.write(
                        f"\n{load_operation_entry['table_name']} [{load_operation_entry['relation_name']}] {load_operation_entry['operation_origin']} \n")
                    for hash_mapping_entry in load_operation_entry['hash_mappings']:
                        dvpisum_file.write(
                            f"     {hash_mapping_entry['hash_class'].ljust(10)}: {hash_mapping_entry['stage_column_name']} >> {hash_mapping_entry['column_name']}")
                        dvpisum_file.write(
                                "\n                 " + renderHashFieldAssembly(parse_set_entry, hash_mapping_entry) )
                        dvpisum_file.write("\n")

                    if 'data_mapping' not in load_operation_entry:
                        continue

                    for data_mapping_entry in load_operation_entry['data_mapping']:
                        dvpisum_file.write(
                            f"     {data_mapping_entry['column_class'].ljust(10)}: {data_mapping_entry['stage_column_name']} >> {data_mapping_entry['column_name']}\n")

                for stage_property_entry in parse_set_entry['stage_properties']:
                    dvpisum_file.write(
                        f"\nStage table: {stage_property_entry['storage_component']}.{stage_property_entry['stage_schema']}.{stage_property_entry['stage_table_name']}\n")

                max_column_name_length = 0
                for column_entry in parse_set_entry['stage_columns']:
                    if len(column_entry['stage_column_name']) > max_column_name_length:
                        max_column_name_length = len(column_entry['stage_column_name'])
                for column_entry in parse_set_entry['stage_columns']:
                    dvpisum_file.write(
                        f"      {column_entry['stage_column_class'].ljust(20)}| {column_entry['stage_column_name'].ljust(max_column_name_length)}  {column_entry['column_type']}\n")
                dvpisum_file.write("\n")

            dvpisum_file.write("\nDVPD\n")
            dvpisum_file.write("--------------------------------------------------\n")

            with open(dvpd_file_path, "r") as dvdp_source_file:
                for line in dvdp_source_file:
                    dvpisum_file.write(line)


    except:
        log_progress("ERROR: writing dvpi summary " + dvpisum_file_path.as_posix())
        raise


def renderHashFieldAssembly(parse_set_entry, hash_mapping_entry):
    """
     Render the text snippet of the hash field collection for a specific hash

     Args:
             parse_set_entry: dvpi.parse_set[n]
             hash_mapping_entry: dvpi.parse_set[n].load_operation[n].hash_mapping[n]

     Returns: String with the formatted and sorted field list of the hash

     """

    hash_name = hash_mapping_entry['hash_name']
    for hash_entry in parse_set_entry['hashes']:  # look up the hash definition in the pase set
        if hash_entry['hash_name'] == hash_name:

            # format key hash
            if hash_entry['column_class'] == 'key':
                if 'direct_key_field' in hash_entry:
                    return ">direct<"
                if 'hash_fields' in hash_entry:
                    hash_fields_sorted = sorted(hash_entry['hash_fields'], key=lambda d: "{:03d}".format(
                        d.get('parent_declaration_position', 0)) + '_/_' + d['field_target_table'] + '_/_' + str(
                        d['prio_in_key_hash']) + '_/_' + d['field_target_column'])
                else:
                    raise (f"There is a consistency error in the DVPI. Hash '{hash_name} has neither hash_fields nor a direct_key_field")
            # format diff hash
            else:
                hash_fields_sorted = sorted(hash_entry['hash_fields'],
                                            key=lambda d: '_' + str(d['prio_in_diff_hash']) + '_/_' + d[
                                                'field_target_column'])
            fields = []
            for field_entry in hash_fields_sorted:
                fields.append(field_entry['field_name'])
            return "["+hash_entry['hash_concatenation_seperator'].join(fields)+"]"
    raise (f"There is a consistency error in the DVPI. Could not find hash '{hash_name}")



# --------------------  Extention key word transfer ------------------

def apply_syntax_extensions(dvpd_object, dvpi_document):
    """
     Search the dvpf for extention keywords (starting with 'x') an transfer them
     to the proper position in the dpvi document. (Expects the dvpi document to be complete)

     Args:
             dvpd_object: the source dvpd document
             dvpi_document: the already rendered dvpi document

     """
    import re

    def is_ext_key(key):
        return re.match(r"x.+_.+", key)

    def copy_extensions(source, target):
        for key, value in source.items():
            if is_ext_key(key):
                target[key] = value

    # --- 1. Root level ---
    copy_extensions(dvpd_object, dvpi_document)

    # --- 2. Stage properties ---
    for src, dst in zip(dvpd_object.get("stage_properties", []),
                        dvpi_document.get("parse_sets", [{}])[0].get("stage_properties", [])):
        copy_extensions(src, dst)

    # --- 3. Data extraction ---
    copy_extensions(dvpd_object.get("data_extraction", {}), dvpi_document.get("data_extraction", {}))

    # --- 4. Fields ---
    dvpd_fields = dvpd_object.get("fields", [])
    dvpi_fields = dvpi_document.get("parse_sets", [{}])[0].get("fields", [])
    dvpi_field_lookup = {f["field_name"]: f for f in dvpi_fields}
    for field in dvpd_fields:
        dst_field = dvpi_field_lookup.get(field["field_name"])
        if dst_field:
            copy_extensions(field, dst_field)

    # --- 5. Tables ---
    dvpd_table_lookup = {}
    for schema in dvpd_object.get("data_vault_model", []):
        schema_name = schema.get("schema_name")
        for table in schema.get("tables", []):
            table_name = table["table_name"]
            dvpd_table_lookup[table_name.lower()] = (table, schema)

    dvpi_table_lookup = {t["table_name"].lower(): t for t in dvpi_document.get("tables", [])}
    for table_name, (dvpd_table, dvpd_schema) in dvpd_table_lookup.items():
        dvpi_table = dvpi_table_lookup.get(table_name)
        if dvpi_table:
            copy_extensions(dvpd_table, dvpi_table)     # data_vaullt_model[].tables[0] -> tables[0]
            copy_extensions(dvpd_schema, dvpi_table)

            for load_op in dvpi_document.get("parse_sets", [{}])[0].get("load_operations", []):
                if load_op.get("table_name", "").lower() == table_name:
                    copy_extensions(dvpd_table, load_op)    # data_vaullt_model[].tables[0] -> parse_sets.load_operations[0]

    # --- 6. Link parent keywords ---
    for table in dvpd_table_lookup.values():
        dvpd_table = table[0]
        if dvpd_table.get("table_stereotype", "").lower() == "lnk" and "link_parent_tables" in dvpd_table:
            for parent in dvpd_table["link_parent_tables"]:
                if isinstance(parent, str):
                    parent_table = parent.lower()
                    parent_exts = {}
                elif isinstance(parent, dict):
                    parent_table = parent.get("table_name", "").lower()
                    parent_exts = {k: v for k, v in parent.items() if is_ext_key(k)}    # data_vaullt_model[].tables[0].link_parent_tabes -> tables[0].columns[0]
                else:
                    continue

                if not parent_exts:
                    continue
                target_table = dvpi_table_lookup.get(dvpd_table["table_name"].lower())
                if not target_table:
                    continue
                for col in target_table.get("columns", []):
                    if col.get("parent_table_name", "").lower() == parent_table:
                        col.update(parent_exts)

    # --- 7. Field Targets ---
    dvpi_hash_lookup = {}
    for h in dvpi_document.get("parse_sets", [{}])[0].get("hashes", []):
        for f in h.get("hash_fields", []):
            dvpi_hash_lookup[(f["field_name"], f["field_target_table"], f["field_target_column"])] = f
    # load keyword
    for load_op in dvpi_document.get("parse_sets", [{}])[0].get("load_operations", []):
        table_name = load_op.get("table_name", "")
        for dm in load_op.get("data_mapping", []):
            key = (dm["field_name"], table_name, dm["column_name"])
            for field in dvpd_fields:
                if field["field_name"] != dm["field_name"]:
                    continue
                for target in field.get("targets", []):
                    if any(is_ext_key(k) and "load" in k for k in target):
                        dm.update({k: v for k, v in target.items() if is_ext_key(k) and "load" in k})   # fields[0].targets[0]. with "load" in name -> parse_sets.load_operations[0].data_mappings[0]

    for field in dvpd_fields:
        for target in field.get("targets", []):
            table = target.get("table_name")
            column = target.get("column_name", field["field_name"])

            # column keyword
            if any(is_ext_key(k) and "column" in k for k in target):    # fields[0].targets[0]. with "column" in name -> tables[0].columns[0]
                for tbl in dvpi_document.get("tables", []):
                    if tbl["table_name"].lower() == table.lower():
                        for col in tbl.get("columns", []):
                            if col["column_name"] == column:
                                copy_extensions(target, col)

            # hash keyword
            if any(is_ext_key(k) and "hash" in k for k in target):  # fields[0].targets[0]. with "hash" in name -> parse_sets.hashes[0].hash_fields[0]
                hf = dvpi_hash_lookup.get((field["field_name"], table.lower(), column))
                if hf:
                    copy_extensions(target, hf)


# --------------- The main compiler functions ------------------------
def dvpdc(dvpd_filename, dvpi_directory=None, dvpdc_report_directory=None, ini_file=None, model_profile_directory=None,
          verbose_logging=False):
    """
     Wrapper for the compiler function, needed to read the configuration file
     and initialize the log files.
     This function can be called as included function (e.g. from the automated test)

     Args:
            dvpd_filename
            dvpi_directory
            dvpdc_report_directory
            ini_file
            model_profile_directory
            verbose_logging

     """
    global g_logfile
    global g_verbose_logging

    g_verbose_logging = verbose_logging

    params = configuration_load_ini(ini_file, 'dvpdc', ['dvpd_model_profile_directory'])

    if dvpdc_report_directory == None:
        dvpdc_report_directory_path = Path(params['dvpdc_report_default_directory'])
    else:
        dvpdc_report_directory_path = Path(dvpdc_report_directory)

    dvpdc_report_directory_path.mkdir(parents=True, exist_ok=True)
    dvpdc_log_file_name = dvpd_filename.replace('.json', '').replace('.dvpd', '') + ".dvpdc.log"
    dvpdc_log_file_path = dvpdc_report_directory_path.joinpath(dvpdc_log_file_name)

    with open(dvpdc_log_file_path, "w") as g_logfile:
        g_logfile.write(f"Data vault pipeline description compiler log \n")
        log_progress(f"=== DVPD Compiler Version 0.6.3 ===")
        g_logfile.write(f"Compile time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        log_progress(f"Compiling {dvpd_filename}\n")
        try:
            dvpdc_worker(dvpd_filename, dvpi_directory, dvpdc_report_directory_path, ini_file, model_profile_directory)
        except DvpdcError:
            log_progress("*** Compilation ended with errors ***")
            raise


def dvpdc_worker(dvpd_filename, dvpi_directory=None, dvpdc_report_directory=None, ini_file=None,
                 model_profile_directory=None):
    """
     Orchestrates the whole compiler exection: Initialize the brain, call all functions
     to populate the brain, call functions to generate dvpi, write the dvpi and generate
     the dvpisudm.
     Will rais an DvpdError as soon as a step finishes with a registerd error. This allows the step
     to declare as many errors as possible an prevent further processing until all requirements
     for the step have been met.

     Args:
            dvpd_filename
            dvpi_directory
            dvpdc_report_directory
            ini_file
            model_profile_directory

     Brain change:
            full reset before running

    Exceptions:
        DvpcdError after any step that registered an error

     """

    global g_table_dict
    global g_dvpi_document
    global g_field_dict
    global g_error_count
    global g_hash_dict
    global g_model_profile_dict
    global g_pipeline_model_profile_name

    g_table_dict = {}
    g_dvpi_document = {}
    g_field_dict = {}
    g_error_count = 0
    g_hash_dict = {}
    g_model_profile_dict = {}
    g_pipeline_model_profile_name = ""

    params = configuration_load_ini(ini_file, 'dvpdc', ['dvpd_model_profile_directory'])

    dvpd_file_path = Path(params['dvpd_default_directory']).joinpath(dvpd_filename)

    if not os.path.exists(dvpd_file_path):
        raise Exception(f'could not find dvpd file: {dvpd_file_path}')

    # load the model profiles, that are available
    if model_profile_directory == None:
        load_model_profiles(params['dvpd_model_profile_directory'])
    else:
        load_model_profiles(model_profile_directory)

    # parse the json dvpd file into dpvd_object
    try:
        with open(dvpd_file_path, "r") as dvpd_file:
            dvpd_object = json.load(dvpd_file)
    except json.JSONDecodeError as e:
        register_error("ERROR: JSON Parsing error of file " + dvpd_file_path.name)
        log_progress(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        raise DvpdcError

    # check, if the model profile declared is available
    g_pipeline_model_profile_name = dvpd_object.get('model_profile_name', '_default')
    if g_pipeline_model_profile_name not in g_model_profile_dict:
        register_error(f"Model profile '{g_pipeline_model_profile_name}' declared in pipeline does not exist")
        raise DvpdcError

    check_essential_structure(dvpd_object)
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

    check_intertable_column_constraints()
    if g_error_count > 0:
        raise DvpdcError

    # remove any load operations from "is_only_structural_element" tables
    for table_name, table_entry in g_table_dict.items():
        if table_entry['is_only_structural_element']:
            table_entry['load_operations'] = {}

    assemble_dvpi(dvpd_object, dvpd_filename)
    apply_syntax_extensions(dvpd_object, g_dvpi_document)
    # print_dvpi_document()

    # write DVPI to file
    if dvpi_directory == None:
        dvpi_directory = Path(params['dvpi_default_directory'])
    else:
        dvpi_directory = Path(dvpi_directory)
    dvpi_directory.mkdir(parents=True, exist_ok=True)
    dvpi_filename = dvpd_filename.replace('.json', '').replace('.dvpd', '') + ".dvpi.json"
    dvpi_file_path = dvpi_directory.joinpath(dvpi_filename)

    log_progress("Writing DVPI to " + dvpi_file_path.as_posix())

    try:
        with open(dvpi_file_path, "w") as dvpi_file:
            json.dump(g_dvpi_document, dvpi_file, ensure_ascii=False, indent=2)
    except json.JSONDecodeError as e:
        register_error("ERROR: JSON writing to  of file " + dvpi_file_path.as_posix())
        log_progress(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno))
        raise DvpdcError

    log_progress("--- Compile successfull ---")
    print("")

    writeDvpiSummary(dvpdc_report_directory, dvpd_file_path)


def get_name_of_youngest_dvpd_file(ini_file):
    """
    Search the dvpd directory for the youngest dvpd file

    Args:
            ini_file: name of configuration file with the declatation of the dvpd_default_directory

    Returns:
            Name of the youngest file

     """


    params = configuration_load_ini(ini_file, 'dvpdc', ['dvpd_default_directory'])

    max_mtime = 0
    youngest_file = ''

    for file_name in os.listdir(params['dvpd_default_directory']):
        if not os.path.isfile(params['dvpd_default_directory'] + '/' + file_name):
            continue
        file_mtime = os.path.getmtime(params['dvpd_default_directory'] + '/' + file_name)
        if file_mtime > max_mtime:
            youngest_file = file_name
            max_mtime = file_mtime

    return youngest_file


############################################# MAIN ##################################################
"""
The main block reads and prepares all call arguments calls the dvpc
and adds some optinal debugging output afterwards 
"""

if __name__ == "__main__":
    description_for_terminal = "DVPD compiler. Parses a data vault pipeline description (dvpd) file and translates it into a data vault pipeline instruction (dvpi)." \
                               "\nPlease read the dvpd concept documentation for better understanding of the ." \
                               "\nThe filename of the dvpi file will be the filename of the dvpd file, without any '.dpvd' or '.json' segments and with '.dvpi.json' appended" \
                               "\n Examples: myname.dvpd.json -> myname.dvpi.json, myname.txt->myname.txt.dvpi.json, dvpd_myname.json -> dpvd_myname.dvpi.json"
    usage_for_terminal = "dvpdc <file to compile> [options] \n Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage=usage_for_terminal
    )
    # input Arguments
    parser.add_argument("dvpd_filename",
                        help="Name of the dvpd file to compile. Set this to '@youngest' to compile the youngest file in your dvpd directory")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    parser.add_argument("--model_profile_directory", help="Name of the model profile directory")

    # output arguments
    parser.add_argument("--dvpi_directory", help="Name of the director, the dvpi file will be written to")
    parser.add_argument("--report_directory", help="Name of the report file (defaults to filename + .dvpdc.log")
    parser.add_argument("--print_brain", help="When set, the compiler will print its internal data structure to stdout",
                        action='store_true')
    parser.add_argument("--dump_brain", help="When set, the compiler will print its internal data structure to stdout",
                        action='store_true')
    parser.add_argument("--verbose", help="Log more information about progress", action='store_true')

    # parser.add_argument("-l","--log filename", help="Name of the report file (defaults to filename + .dvpdc.log")
    args = parser.parse_args()

    dvpd_filename = args.dvpd_filename

    if dvpd_filename == '@youngest':
        dvpd_filename = get_name_of_youngest_dvpd_file(ini_file=args.ini_file)

    #determine report path also here for print brain (will be done again in dvpcd for encapsulation)
    report_directory_name=args.report_directory
    if report_directory_name==None:
        params = configuration_load_ini(args.ini_file, 'dvpdc')
        report_directory_name=params['dvpdc_report_default_directory']

    try:
        dvpdc(dvpd_filename=dvpd_filename,
              dvpi_directory=args.dvpi_directory,
              dvpdc_report_directory=args.report_directory,
              ini_file=args.ini_file,
              model_profile_directory=args.model_profile_directory,
              verbose_logging=args.verbose
              )


        if args.print_brain:
            print_the_brain()
        if args.dump_brain:
                dump_the_brain(report_directory_name,dvpd_filename)
    except DvpdcError:
        if args.print_brain:
            print_the_brain()
        if args.dump_brain:
                dump_the_brain(report_directory_name,dvpd_filename)
        print("*** DVPD compiler stopped compilation due to errors DVPD input ***\n")
        exit(5)

    except Exception:
        if args.print_brain:
            print_the_brain()
        if args.dump_brain:
                dump_the_brain(report_directory_name,dvpd_filename)
        raise
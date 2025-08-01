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
import base64
import hashlib
import re
import sys
import os

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from Levenshtein import distance
from processes.dvpdc.__main__ import dvpdc
from pathlib import Path
from lib.configuration import configuration_load_ini
from lib.exceptions import DvpdcError
import json


g_difference_count=0
g_test_id=""

def report_missing(keyword, path):
    global g_difference_count
    print(f"ATST--EI:[{g_test_id}] /{path}:Keyword '{keyword}' is missing !")
    g_difference_count += 1

def report_unexpected(keyword, path):
    global g_difference_count
    print(f"ATST--EI:[{g_test_id}] /{path}:Keyword '{keyword}' is not in reference !")
    g_difference_count += 1

def report_type_missmatch(expected_value, found_value, path):
    global g_difference_count
    print(f"ATST--EI:[{g_test_id}] /{path}:Wrong type '{type(found_value)}' ! Expected '{type(expected_value)}'  (ls-diff:{distance(found_value,expected_value)}) ")
    g_difference_count += 1

def report_list_length_missmatch(expected_list, found_list, path):
    global g_difference_count
    print(f"ATST--EI:[{g_test_id}] /{path}:Wrong count of list elements '{len(found_list)}' ! Expected '{len(expected_list)}' ")
    g_difference_count += 1
    #todo implement comparison based on identifiing element (approach: path pattern->keyword list to find identifing )
def report_value_difference(expected_value, found_value, path):
    global g_difference_count
    g_difference_count += 1
    ls_diff_message=""
    if isinstance(expected_value,str) and isinstance(found_value,str):
        ls_diff_message=f", ls-diff:{distance(found_value,expected_value)}"
    print(f"ATST--EI:[{g_test_id}] /{path}: Wrong value '{found_value}' ! Expected '{expected_value}'{ls_diff_message}")


def run_test_for_file(dvpd_filename, raise_on_crash=False):
    global g_difference_count
    global g_test_id
    try:
        matches=re.search("^([^_.]+)",dvpd_filename)  # get first part of the filename
        g_test_id=matches.group()
        dvpdc(dvpd_filename, ini_file=args.ini_file)
        if dvpd_filename[5] == "c":
            print(f"ATST---I:[{g_test_id}] *** test failed: Compiling successfull, but should not ***")
            #return "fail"
            return "incorrect"

    except DvpdcError:
        if dvpd_filename[5] != "c":
            print(f"ATST---I:[{g_test_id}] *** test failed: Compiling failed, but should not ***")
            return "fail"

    except Exception as e:
        print(f"ATST---I:[{g_test_id}] *** test failed: Compiler Crashed ***")
        if raise_on_crash:
            raise
        return "crash"

    print(f"\nATST-LEI:[{g_test_id}]--- Comparing result with reference ---")
    g_difference_count=0

    try:
        compare_dvpdc_log_with_reference(dvpd_filename)
        if dvpd_filename[5]!="c":
            compare_dvpi_with_reference(dvpd_filename)

    except FileNotFoundError:
        print(f"ATST---I:[{g_test_id}] *** test failed: Missing reference data. There is no reference data available for the test case ***")
        return "no_reference"

    if g_difference_count == 0:
            print(f"\nATST---I:[{g_test_id}] --- Test OK ---")
            return "success"

    print(f"\nATST---I:[{g_test_id}] *** test failed:Result differs {g_difference_count} times from reference ***")
    return "differ"


def compare_dvpdc_log_with_reference(dvpd_filename):
    global g_difference_count


    dvpdc_params = configuration_load_ini(args.ini_file, 'dvpdc')
    dvpdc_test_params = configuration_load_ini(args.ini_file, 'dvpdc_test')

    dvpdc_report_directory = Path(dvpdc_params['dvpdc_report_default_directory'])

    dvpdc_log_filename = dvpd_filename.replace('.json', '').replace('.dvpd', '') + ".dvpdc.log"
    dvpdc_log_file_path = dvpdc_report_directory.joinpath(dvpdc_log_filename)
    dvpdc_log_file_reference_file_path = Path(dvpdc_test_params['dvpdc_test_reference_data_directory']).joinpath(dvpdc_log_filename)


    try:
        with open(dvpdc_log_file_path, "r") as dvpdc_log_file:
            log_file_lines=dvpdc_log_file.read().splitlines()
    except Exception:
        print(f"ATST--EI:[{g_test_id}] ERROR reading "+ dvpdc_log_file_path.as_posix())
        raise

    try:
        with open(dvpdc_log_file_reference_file_path, "r") as dvpdc_log_file_reference:
            reference_log_file_lines=dvpdc_log_file_reference.read().splitlines()
    except FileNotFoundError:
        print(f"ATST--EI:[{g_test_id}] Reference file not found " + dvpdc_log_file_reference_file_path.as_posix())
        g_difference_count+=1
        raise

    print(f"ATST-LEI:[{g_test_id}] Comparing Compiler log")
    HEADER_LOG_LINES=3
    for index, reference_line in enumerate(reference_log_file_lines):
        if index < HEADER_LOG_LINES or reference_line.startswith("Writing DVPI to"): # skip first lines, they can change without impact
            continue
        message_found=False
        for log_line in log_file_lines:
            if log_line==reference_line:
                message_found=True
                break
        if not message_found:
            print(f"ATST--EI:[{g_test_id}] missing in compiler log >>{reference_line}")
            g_difference_count+=1

    for index, log_line in enumerate(log_file_lines):
        if index < HEADER_LOG_LINES or log_line.startswith("Writing DVPI to"): # skip first lines, they can change without impact
            continue
        message_found=False
        for reference_line in  reference_log_file_lines:
            if log_line==reference_line:
                message_found=True
                break
        if not message_found:
            print(f"ATST--EI:[{g_test_id}] unexpected in compiler log >>{log_line}")
            g_difference_count+=1



def compare_dvpi_with_reference(dvpd_filename):
    global g_difference_count

    dvpdc_params = configuration_load_ini(args.ini_file, 'dvpdc')
    dvpdc_test_params = configuration_load_ini(args.ini_file, 'dvpdc_test')

    dvpi_filename = dvpd_filename.replace('.json', '').replace('.dvpd', '') + ".dvpi.json"
    dvpi_file_path = Path(dvpdc_params['dvpi_default_directory']).joinpath(dvpi_filename)
    dvpi_reference_file_path = Path(dvpdc_test_params['dvpdc_test_reference_data_directory']).joinpath(dvpi_filename)

    try:
        with open(dvpi_file_path, "r") as dvpi_file:
            dvpi_object=json.load(dvpi_file)
    except json.JSONDecodeError as e:
        print(f"ATST--EI:[{g_test_id}] JSON Parsing error of file "+ dvpi_file_path.as_posix())
        print(print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno)))
        raise

    try:
        with open(dvpi_reference_file_path, "r") as dvpi_reference_file:
            dvpi_reference_object=json.load(dvpi_reference_file)
    except json.JSONDecodeError as e:
        print(f"ATST--EI:[{g_test_id}] JSON Parsing error of file "+ dvpi_reference_file_path.as_posix())
        print(print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno)))
        g_difference_count+=1
        return
    except FileNotFoundError:
        print(f"ATST--EI:[{g_test_id}] Reference file is missing " + dvpi_reference_file_path.as_posix())
        g_difference_count+=1
        raise

    elements_to_ignore=['dvdp_compiler','dvpi_version','compile_timestamp']
    for ignorable in elements_to_ignore:
        dvpi_reference_object.pop(ignorable, None)
        if ignorable in dvpi_object:
            dvpi_object.pop(ignorable, None)

    print(f"ATST-LEI:[{g_test_id}] Comparing DVPI")
    check_reference_values(dvpi_reference_object, dvpi_object)
    if g_difference_count > 0:
        print(f"ATST-LEI:[{g_test_id}]  Identified {g_difference_count} differences ")
    return g_difference_count

def check_reference_values(reference_object,test_object,path=""):

        if type(reference_object)!= type(test_object):
            report_type_missmatch(reference_object,test_object,path)
            return
        if isinstance(reference_object,list):
            if len(reference_object) != len(test_object):
                report_list_length_missmatch(reference_object,test_object,path)
                return
            for list_index,list_entry in enumerate(reference_object):
                child_path=f"{path}[{list_index}]"
                check_reference_values(list_entry,test_object[list_index],child_path)
            return
        if isinstance(reference_object,dict):
            for keyword, sub_object in reference_object.items():
                if keyword not in test_object:
                    report_missing(keyword, path)
                    continue
                child_path = f"{path}/{keyword}"
                check_reference_values(sub_object, test_object[keyword], child_path)
            for keyword, sub_object in test_object.items():
                if keyword not in reference_object:
                    report_unexpected(keyword, path)
                    continue
            return
        if reference_object != test_object:
            report_value_difference(reference_object, test_object, path)
            return

def search_for_testfile(testnumber):
    params = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpd_model_profile_directory'])
    dvpd_directory = Path(params['dvpd_default_directory'])

    fileprefix="t{:04d}".format(testnumber)

    for file in sorted(dvpd_directory.iterdir()):
        if (file.is_file()
            and file.stem.startswith(fileprefix)):
            return file.name

    return None



def find_dvpd_files(ini_file):
    params = configuration_load_ini(ini_file, 'dvpdc', ['dvpd_model_profile_directory'])
    directory = Path(params['dvpd_default_directory'])
    dvpd_files = []
    for file in sorted(directory.iterdir()):
        if file.is_file() and file.suffix == '.json':
            dvpd_files.append(file.name)
    return dvpd_files

def assemble_file_list_fingerprint(file_list):
    """Calculates an 8 character fingerprint hash value  from all attributes in the list
      Order of attributes is essential"""
    separator='|'
    stringified=separator.join(file_list)
    md5_hash=hashlib.md5(stringified.encode('utf-8')).digest()
    file_listfp_b32=base64.b32encode(md5_hash).decode('utf-8')
    return file_listfp_b32[:8]

################################  Main ########################################
if __name__ == "__main__":

    print("=== Automated test of DVPDC ===")

    successful_file_list=[]
    difference_file_list = []
    failing_file_list=[]
    reference_missing_list=[]
    crashed_file_list=[]
    incorrect_file_list=[]

    parser = argparse.ArgumentParser()
    parser.add_argument("--dvpd_filename","-f", required=False, help="Name of the dvpd file to test")
    parser.add_argument("--testnumber","-t", required=False, type=int, help="Number of the test")
    parser.add_argument("--ini_file", help="Name of the ini file",default='./dvpdc.ini')
    args = parser.parse_args()


    explicit_file = None
    if args.testnumber is not None:
        explicit_file=search_for_testfile(args.testnumber)
        if explicit_file is None:
            raise Exception(f"Could not find test file for testnumber {args.testnumber}")
    elif args.dvpd_filename!=None:
        explicit_file=args.dvpd_filename

    raise_on_crash=False
    if  explicit_file is not None:
        dvpd_file_list=[]
        dvpd_file_list.append(explicit_file)
        raise_on_crash=True
    else:
        dvpd_file_list = find_dvpd_files(ini_file=args.ini_file)

    for filename in dvpd_file_list:
        print(f"\nATST---I: ------------------ Testing:{filename} ---------------------------")
        result = run_test_for_file(filename,raise_on_crash)

        if result == "success":
            successful_file_list.append(filename)
        elif result == "differ":
            difference_file_list.append(filename)
        elif result == "fail":
            failing_file_list.append(filename)
        elif result == "no_reference":
            reference_missing_list.append(filename)
        elif result == "crash":
            crashed_file_list.append(filename)
        elif result == "incorrect":
            incorrect_file_list.append(filename)
        else:
            print(f"!!! Unhandled test result: {result} !!!")

    print("\n==================== Test Summary ================================")
    print("\nvvv---Passed tests---vvv")
    for filename in successful_file_list:
        print(filename)

    if len(difference_file_list)>0:
        print("\nvvv---Result differs---vvv")
        for filename in difference_file_list:
            print(filename)

    if len(reference_missing_list) > 0:
        print("\nvvv---Tests with missing reference---vvv")
        for filename in reference_missing_list:
            print(filename)

    if len(failing_file_list)>0:
        print("\nvvv---Compile Failed---vvv")
        for filename in failing_file_list:
            print(filename)

    if len(incorrect_file_list) > 0:
        print("\nvvv---Incorrectly successful compiles---vvv")
        for filename in incorrect_file_list:
            print(filename)

    if len(crashed_file_list) > 0:
        print("\nvvv---Tests that crashed---vvv")
        for filename in crashed_file_list:
            print(filename)







    print('\nTest log search hint:')
    print ('find "ATST---" for main results only,  "ATST--" to also include details, "ATST--EI" for details only')
    print ('find "ATST-" for all log output of automated test')

    print("\n==================== Test Statistics ================================")


    print(f"\nNumber of tests: {len(dvpd_file_list)} ")

    report_line=f"{len(dvpd_file_list)} = "
    file_list_fp=assemble_file_list_fingerprint(successful_file_list)
    report_line+=f"success {len(successful_file_list)} ({file_list_fp})"

    print(f"  {len(successful_file_list)} tests passed ({file_list_fp})")

    if len(difference_file_list)>0:
        file_list_fp=assemble_file_list_fingerprint(difference_file_list)
        report_line += f"+ difference {len(difference_file_list)} ({file_list_fp})"
        print(f"* {len(difference_file_list)} tests with differences ({file_list_fp})")
    if len(reference_missing_list) > 0:
        file_list_fp = assemble_file_list_fingerprint(reference_missing_list)
        report_line += f"+ no ref {len(reference_missing_list)} ({file_list_fp})"
        print(f"* {len(reference_missing_list)} tests have no reference data ({file_list_fp})")
    if len(failing_file_list)>0:
        file_list_fp=assemble_file_list_fingerprint(failing_file_list)
        report_line += f"+ fail {len(failing_file_list)} ({file_list_fp})"
        print(f"* {len(failing_file_list)} tests with failed compile ({file_list_fp})")
    if len(incorrect_file_list) > 0:  # Add incorrect to report
        file_list_fp = assemble_file_list_fingerprint(incorrect_file_list)
        report_line += f"+ incorrectly successfull {len(incorrect_file_list)} ({file_list_fp})"
        print(f"* {len(incorrect_file_list)} incorrectly successful compiles ({file_list_fp})")
    if len(crashed_file_list) > 0:
        file_list_fp = assemble_file_list_fingerprint(crashed_file_list)
        report_line += f"+ crash {len(crashed_file_list)} ({file_list_fp})"
        print(f"* {len(crashed_file_list)} tests crashed ({file_list_fp}) **** ")

    print("\nTest state: "+report_line)  

    print("--- Automated test of DVPDC complete ---")

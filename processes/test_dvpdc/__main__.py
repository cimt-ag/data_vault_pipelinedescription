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

from processes.dvpdc.__main__ import dvpdc
from pathlib import Path
from lib.configuration import configuration_load_ini
from lib.exceptions import DvpdcError
import json


g_difference_count=0

def report_missing(keyword, path):
    global g_difference_count
    print(f"Keyword '{keyword}' is missing at /{path}")
    g_difference_count += 1

def report_type_missmatch(expected_value, found_value, path):
    global g_difference_count
    print(f"Different type. Found '{type(found_value)}' Expected '{type(expected_value)}' at /{path}")
    g_difference_count += 1

def report_list_length_missmatch(expected_list, found_list, path):
    global g_difference_count
    print(f"Different count of list elements. Found '{len(found_list)}' Expected '{len(expected_list)}' at /{path}")
    g_difference_count += 1
    #todo implement comparison based on identifiing element (approach: path pattern->keyword list to find identifing )
def report_value_difference(expected_value, found_value, path):
    global g_difference_count
    print(f"Different value. Found '{found_value}' Expected '{expected_value}' at /{path}")
    g_difference_count += 1

def run_test_for_file(dvpd_filename):
    global g_difference_count
    g_difference_count=0

    try:
        dvpdc(dvpd_filename, ini_file=args.ini_file)
        print("\n--- Comparing result with reference ---")
        print(args.ini_file)
        compare_dvpdc_log_with_reference(dvpd_filename)
        if dvpd_filename[5]!="c":
            compare_dvpi_with_reference(dvpd_filename)

        #Successfully tested cases
        if g_difference_count == 0:
            print("****Successfully tested cases****")
            return "success"

    except DvpdcError:
        #print("****Execution of dvpdc resulted in a crash****")
        print("****Failing****")
        g_difference_count +=1
        return "fail"

    except FileNotFoundError:
        print("****Missing reference data. There is no reference data available for the test case****")
        g_difference_count +=1
        return "no_reference"

    except Exception as e:
        #print("****Failed test cases. Comparison with reference data revealed differences****")
        print("****Crashed****")
        g_difference_count +=1
        return "crash"


    return g_difference_count

"""      
    except DvpdcError:
        compare_dvpdc_log_with_reference(dvpd_filename)
        if dvpd_filename[5] == "c":
            print("Compile failed, but should not")
            g_difference_count += 1
        return g_difference_count
    except FileNotFoundError:
        print("**** Could not confirm correctness. Some reference files are missing ****")
        return g_difference_count
    except :
        print("**** DVPDC crashed ****")
        g_difference_count += 1
        return g_difference_count
"""



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
        print("ERROR: reading "+ dvpdc_log_file_path.as_posix())
        raise

    try:
        with open(dvpdc_log_file_reference_file_path, "r") as dvpdc_log_file_reference:
            reference_log_file_lines=dvpdc_log_file_reference.read().splitlines()
    except FileNotFoundError:
        print("Reference file not found " + dvpdc_log_file_reference_file_path.as_posix())
        g_difference_count+=1
        raise

    print("Comparing Compiler log")
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
            print(f"missing in log >>{reference_line}")
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
            print(f"not in reference >>{log_line}")
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
        print("ERROR: JSON Parsing error of file "+ dvpi_file_path.as_posix())
        print(print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno)))
        raise

    try:
        with open(dvpi_reference_file_path, "r") as dvpi_reference_file:
            dvpi_reference_object=json.load(dvpi_reference_file)
    except json.JSONDecodeError as e:
        print("ERROR: JSON Parsing error of file "+ dvpi_reference_file_path.as_posix())
        print(print(e.msg + " in line " + str(e.lineno) + " column " + str(e.colno)))
        g_difference_count+=1
        return
    except FileNotFoundError:
        print("Reference file is missing " + dvpi_reference_file_path.as_posix())
        g_difference_count+=1
        raise

    elements_to_ignore=['dvdp_compiler','dvpi_version','compile_timestamp']
    for ignorable in elements_to_ignore:
        dvpi_reference_object.pop(ignorable, None)

    print("Comparing DVPI")
    check_reference_values(dvpi_reference_object, dvpi_object)
    if g_difference_count > 0:
        print(f"*** Identified {g_difference_count} differences *** ")
    else:
        print("---- result acceptable ----")
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
            return
        if reference_object != test_object:
            report_value_difference(reference_object, test_object, path)
            return


############ My MAIN ############
def search_for_testfile(testnumber):
    params = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpd_model_profile_directory'])
    dvpd_directory = Path(params['dvpd_default_directory'])

    fileprefix="t{:04d}".format(testnumber)

    for file in sorted(dvpd_directory.iterdir()):
        if (file.is_file()
            and file.stem.startswith(fileprefix)):
            return file.name

    return None

"""
if __name__ == "__main__":

    #todo scan reference data directory and call compio

    dvpd_file_list= [#'test00_check_essential_elements.dvpd.json',
                     #'test01_check_model_relations.dvpd.json',
                     't0020_simple_hub_sat.dvpd.json',
                     't0022_one_link_one_esat.dvpd.json',
                     't0023_one_link_with_one_satellite.dvpd.json',
                     't0024_one_satellite_on_linked_hub.dvpd.json',
                     't0025_one_link_one_esat_three_hubs.dvpd.json',
                     't0055_broad_relation_feature_cover.dvpd.json'
                     ]


def search_for_testfile(testnumber, directory):
        fileprefix = "t{}".format(testnumber)

        for file in sorted(directory.iterdir()):
            if file.is_file() and file.stem.startswith(fileprefix):
                index_of_t = file.stem.index("t")

                test_num_from_filename = file.stem[index_of_t + 1:index_of_t + 5]
                if test_num_from_filename == str(testnumber):
                    return file.name

        return None
"""

def find_dvpd_files(ini_file):
    params = configuration_load_ini(ini_file, 'dvpdc', ['dvpd_model_profile_directory'])
    directory = Path(params['dvpd_default_directory'])
    dvpd_files = []
    for file in sorted(directory.iterdir()):
        if file.is_file() and file.suffix == '.json':
            dvpd_files.append(file.name)
    return dvpd_files


if __name__ == "__main__":

    successful_file_list=[]
    failing_file_list=[]
    reference_missing_list=[]
    crashed_file_list=[]

    parser = argparse.ArgumentParser()
    parser.add_argument("--dvpd_filename","-f", required=False, help="Name of the dvpd file to test")
    parser.add_argument("--testnumber","-t", required=False, type=int, help="Number of the test")
    parser.add_argument("--ini_file", help="Name of the ini file")
    args = parser.parse_args()

    dvpd_file_list = find_dvpd_files(ini_file=args.ini_file)

    explicit_file = None
    if args.testnumber is not None:
        explicit_file=search_for_testfile(args.testnumber)
        if explicit_file is None:
            raise Exception(f"Could not find test file for testnumber {args.testnumber}")
    elif args.dvpd_filename!=None:
        explicit_file=args.dvpd_filename

    if  explicit_file is not None:
        dvpd_file_list=[]
        dvpd_file_list.append(explicit_file)
        result = run_test_for_file(explicit_file) #zwischenvariable
        #if run_test_for_file(explicit_file) == 0:
        #    successful_file_list.append(explicit_file)
        #else:
        #    failing_file_list.append(explicit_file)

        if result == "success":
            successful_file_list.append(explicit_file)
        elif result == "fail":
            failing_file_list.append(explicit_file)
        elif result == "no_reference":
            reference_missing_list.append(explicit_file)
        elif result == "crash":
            crashed_file_list.append(explicit_file)
    else:               # no filename given, process the internal list
        for filename in dvpd_file_list:
            print(f"\n------------------ Testing:{filename} ---------------------------")
            result = run_test_for_file(filename)
            #if run_test_for_file(filename) == 0:
            #    successful_file_list.append(filename)
            #else:
            #    failing_file_list.append(filename)
            if result == "success":
                successful_file_list.append(filename)
            elif result == "fail":
                failing_file_list.append(filename)
            elif result == "no_reference":
                reference_missing_list.append(filename)
            elif result == "crash":
                crashed_file_list.append(filename)

    print("\n==================== Test Summary ================================")
    print("\nvvv---Passed tests---vvv")
    for filename in successful_file_list:
        print(filename)

    if len(failing_file_list)==0:
        print(f"\n---- All {len(successful_file_list)} tests completed sucessfully ----")
        #exit(0)
    else:
        print("\nvvv---Failed test---vvv")
        for filename in failing_file_list:
            print(filename)

    if len(reference_missing_list) > 0:
        print("\nvvv---Tests with missing reference---vvv")
        for filename in reference_missing_list:
            print(filename)

    if len(crashed_file_list) > 0:
        print("\nvvv---Tests that crashed---vvv")
        for filename in crashed_file_list:
            print(filename)

    print(f"\n**** {len(successful_file_list)} of {len(dvpd_file_list)} tests passed ****")
    print(f"\n**** {len(failing_file_list)} of {len(dvpd_file_list)} tests failed ****")
    print(f"\n**** {len(reference_missing_list)} of {len(dvpd_file_list)} are reference missing tests ****")
    print(f"\n**** {len(crashed_file_list)} of {len(dvpd_file_list)} tests crashed ****")
    exit(5)

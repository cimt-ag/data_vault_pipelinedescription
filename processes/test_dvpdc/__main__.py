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
    try:
        dvpdc(dvpd_filename)
        compare_dvpi_with_reference(dvpd_filename)
    except DvpdcError:
        print("Compile failed. but this might be on purpose")

def compare_dvpi_with_reference(dvpd_filename):
    dvpdc_params = configuration_load_ini('dvpdc.ini', 'dvpdc')
    dvpdc_test_params = configuration_load_ini('dvpdc.ini', 'dvpdc_test')

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
        raise

    elements_to_ignore=['dvdp_compiler','dvpi_version','compile_timestamp']
    for ignorable in elements_to_ignore:
        dvpi_reference_object.pop(ignorable, None)

    print("Comparing")
    check_reference_values(dvpi_reference_object, dvpi_object)
    if g_difference_count > 0:
        print("!!!! we had some differences !!!!")
    else:
        print("---- result acceptable ----")

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
if __name__ == "__main__":
    run_test_for_file("test20_simple_hub_sat.dvpd.json")
    run_test_for_file("test22_one_link_one_esat.dvpd.json")
    run_test_for_file("test55_large_feature_cover.dvpd.json")
    #todo scan reference data dorectory and call compio

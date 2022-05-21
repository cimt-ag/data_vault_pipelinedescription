"""
deploy view
deploy function
"""
import os
import csv
import codecs

from lib.config_pg_data_warehouse import pg_data_warehouse_get_connection, DwhConnectionType
from lib.datamodeldeploymentmanagerPG import DataModelDeploymentManager
from lib.configuration import configuration_load_ini
from pathlib import Path

global DEPLOY_SEVERITY
DEPLOY_SEVERITY = 1

OBJECTS_DEPLOY_FAILED = []

def deploy_process(file_path, type, schema_name, name, mandantory):
    file_name = os.path.split(file_path)[1]

    try:
        deployment_manager = DataModelDeploymentManager(pg_data_warehouse_get_connection(DwhConnectionType.owner))
        # print("^^^^^^ trying deploy of", file_name, type, schema_name, name)
        if type == 'table':
            deployment_manager.deploy_table(schema_name=schema_name, table_name=name)
        if type == 'view':
            deployment_manager.deploy_view(schema_name=schema_name, view_name=name)
        if type == 'function':
            deployment_manager.deploy_function(schema_name=schema_name, function_name=name)
        if type == 'data':
            deployment_manager.execute_data_insert(schema_name=schema_name, data_name=name)
        if type == 'testdata':
            deployment_manager.execute_testdata_insert(schema_name=schema_name, test_name=name)

    except Exception as err:
        print("^^^^^^ ERROR while deploying: ", type, schema_name, name, " from ", file_name)
        print(err)
        if mandantory == '0':
            VAR = 0
        global OBJECTS_DEPLOY_FAILED
        OBJECTS_DEPLOY_FAILED.append( type, schema_name, name, " from ", file_name)
        print("OBJECTS_DEPLOY_FAILED ================== ", OBJECTS_DEPLOY_FAILED)

        raise


def read_file(file_to_process):
    print(60 * "#", " file to process ", 60 * "#")
    print("*** vvvvvv", file_to_process, "vvvvvv ***")
    try:
        with codecs.open(file_to_process, "rb", "utf-8") as data:
            csvread = csv.reader(data, delimiter=',', quotechar='"')
            for row in csvread:
                if len(row) == 4:
                    mandantory = row[0]
                    type = row[1]
                    schema_name = row[2]
                    object = row[3]
                    if mandantory != '2':
                        deploy_process(file_to_process, type, schema_name, object, mandantory)
                else:
                    if len(row) > 0:
                        raise Exception("Malformed row :", row)

    except Exception as err:
        print('#### Error when reading object list file', err)
        raise


def main(file_to_deploy="#all#"):
    """Check the unprocessed directory and load any present files into stage."""

    in_preparation=True

    try:
        params = configuration_load_ini('basics.ini', 'ddl_deployment')
        ddl_root_path = params['ddl_root_path']
        string_base_path = f"{ddl_root_path}/jobless_deployment"
        base_path = Path(string_base_path)
        files_succesfully_full_deployed = []
        files_not_deployed = []
        count_files_with_error = 0
        for file in sorted(base_path.iterdir()):
            try:
                in_preparation=False
                if os.stat(file).st_size != 0 and (file_to_deploy=="#all#" or file.stem == file_to_deploy):
                    read_file(file)
                    files_succesfully_full_deployed.append(file)
            except Exception:
                count_files_with_error += 1
                files_not_deployed.append(file)
                print(" #### ^^^^ ERROR while installing file: ", file)
                print("")

        print("\n", 5 * "-", "files OK: ", 5 * "-")
        for f in files_succesfully_full_deployed:
            print("\t\t", os.path.split(f)[1])
        print( 25 * "-")

        if count_files_with_error > 0:
            print(5 * "#", "files FAILED: ", 5 * "#")
            for f in files_not_deployed:
                print("\t\t>>>>>", os.path.split(f)[1])
            print("\n")
            print("\n", 5 * "-", 'number of files with error: ', count_files_with_error, 30 * "-")
            raise NameError('at least one file has error')

    except Exception as e:
        print(20*"#","some processing failed, check the messages above",20*"#",'\n')
        if in_preparation:
            raise
        if DEPLOY_SEVERITY == 0:
            print('\n',10*"=-*","some mandantory deployment failed ", 10*"=-*",)
            raise
        print (str(e))



if __name__ == '__main__':
    #main("10_deploy_dvpd_base")
    #main("11_deploy_xenc_base")
    #main("91_testcases_xenc")
    main("80_deploy_processing")
    #main()


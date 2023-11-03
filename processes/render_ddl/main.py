from dvpi.models import DVPI
from dvpi.ddl_generator import generate_create_table_statement
from dvpi.case_sensitive_config_parser import CaseSensitiveConfigParser
import json
import argparse
import configparser
import os


def main(dvpi_path, config):

    with open(dvpi_path, "r") as file:
        data = json.load(file)
        dvpi = DVPI(**data)

        print(dvpi)

        for table_name, table in dvpi.tables:
            print(f"table_name: {table_name}")
            print(generate_create_table_statement(table_name, table.columns))

if __name__ == "__main__":
    # Reading the configuration file
    config = CaseSensitiveConfigParser()
    config.read('config/dvpdc.ini')

    parser = argparse.ArgumentParser(description='Process a DVPI JSON file to generate DDL statements.')
    parser.add_argument('dvpi_path', type=str, default='/home/joscha/data_vault_pipelinedescription/processes/render_ddl/resources/test55.dvpi.json', help='Path to the DVPI JSON file.')

    args = parser.parse_args()
    main(args.dvpi_path, config)

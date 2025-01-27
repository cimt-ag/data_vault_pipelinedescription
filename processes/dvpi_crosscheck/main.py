#!/usr/bin/env python310
# =====================================================================
# Part of the Data Vault Pipeline Description Reference Implementation
#
#  Copyright 2025 Albin Cekaj
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
import json
import os
import sys
from pathlib import Path

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0,project_directory)

from lib.configuration import configuration_load_ini

from Levenshtein import distance
class DVPIcrosscheck:
    def __init__(self, dvpi_directory):
        self.dvpi_directory = dvpi_directory
        self.dvpi_files = []
        self.pipeline_data = {}
        self.conflict_report = {}
        self.pipeline_names = {}
        self.total_differences = 0

    def load_dvpi_files(self,tests_only):
        for file_name in os.listdir(self.dvpi_directory):

            if file_name.startswith("t") and file_name.endswith(".json"):
                self.dvpi_files.append(file_name)

            if file_name.endswith(".json"):
                if (not tests_only and not file_name.startswith("t120")) or (tests_only and file_name.startswith("t120")):
                    self.dvpi_files.append(file_name)


    def load_pipeline_data(self):
        """Collect and organize tables, columns, and properties from each DVPI file."""
        for file_name in self.dvpi_files:
            file_path = os.path.join(self.dvpi_directory, file_name)
            with open(file_path, 'r') as f:
                dvpi_data = json.load(f)
                pipeline_name = dvpi_data.get("pipeline_name", file_name)
                self.pipeline_names[file_name] = pipeline_name

                tables = dvpi_data.get("tables", [])
                for table in tables:
                    table_name = table["table_name"]
                    if table_name not in self.pipeline_data:
                        self.pipeline_data[table_name] = {}

                    columns = table.get("columns", [])
                    for column in columns:
                        column_name = column["column_name"]
                        if column_name not in self.pipeline_data[table_name]:
                            self.pipeline_data[table_name][column_name] = {}

                        for key, value in column.items():
                            if key not in self.pipeline_data[table_name][column_name]:
                                self.pipeline_data[table_name][column_name][key] = {}
                            self.pipeline_data[table_name][column_name][key][pipeline_name] = value

    def check_table_name_similarity(self):
        """Check for table names that are too similar to each other."""
        print("\nChecking for similar table names...")
        table_names = list(self.pipeline_data.keys())
        similar_tables = []

        for i, table1 in enumerate(table_names):
            for table2 in table_names[i + 1:]:
                # Calculate Levenshtein distance
                similarity_distance = distance(table1, table2)
                if similarity_distance <= 2:
                    similar_tables.append((table1, table2, similarity_distance))

        # Print results
        if similar_tables:
            print("Warning: Found nearly similar table names:")
            for table1, table2, similarity_distance in similar_tables:
                print(f"  '{table1}' and '{table2}' (Distance: {similarity_distance})")
        else:
            print("No similar table names found.")

    def analyze_conflicts(self):
        """Identify conflicts in properties and presence of tables and columns across pipelines."""
        for table_name, columns in self.pipeline_data.items():
            # Identify pipelines where the table exists
            pipelines_with_table = {
                pipeline for pipeline in self.pipeline_names.values()
                if any(pipeline in col.get(prop, {}).keys() for col in columns.values() for prop in col.keys())
            }

            if len(pipelines_with_table) < 2:
                continue

            # Analyze column-level conflicts
            for column_name, properties in columns.items():
                # Analyze property conflicts
                for prop, values in properties.items():
                    unique_values = set(values.values())
                    if len(unique_values) > 1:  # If multiple unique values exist, we have a conflict
                        if table_name not in self.conflict_report:
                            self.conflict_report[table_name] = {}
                        if column_name not in self.conflict_report[table_name]:
                            self.conflict_report[table_name][column_name] = {}
                        self.conflict_report[table_name][column_name][prop] = {
                            pipeline: value for pipeline, value in values.items() if pipeline in pipelines_with_table
                        }
                        self.total_differences += 1

                # Analyze column presence across pipelines
                pipelines_with_column = set()
                for prop, pipelines in properties.items():
                    pipelines_with_column.update(pipelines.keys())

                # Filter only relevant pipelines
                pipelines_with_column.intersection_update(pipelines_with_table)

                if len(pipelines_with_column) < len(pipelines_with_table):
                    if pipelines_with_column != pipelines_with_table:  # Check if all declared or all missing
                        if table_name not in self.conflict_report:
                            self.conflict_report[table_name] = {}
                        if column_name not in self.conflict_report[table_name]:
                            self.conflict_report[table_name][column_name] = {}
                        self.conflict_report[table_name][column_name]["presence"] = {
                            pipeline: "declared" if pipeline in pipelines_with_column else "missing"
                            for pipeline in pipelines_with_table
                        }
                        self.total_differences += 1

    def print_conflicts(self):
        """Print out the report of conflicts for all tables and columns with conflict counts."""
        print("\nConflicts across pipelines:")

        total_tables = len(self.conflict_report)  # Total number of tables
        unique_dvpi = set()  # To track unique DVPI
        multi_dvpi_tables = 0  # Tables with conflicts across various DVPI
        total_conflicts = 0  # Track total conflicts globally

        for table_name, columns in self.conflict_report.items():
            # Count total conflicts for this table
            conflict_count = sum(
                len(properties) for column_name, properties in columns.items() if column_name != "table_presence"
            )
            total_conflicts += conflict_count

            # Track unique DVPI and multi-DVPI involvement
            table_dvpi = set()
            for column_name, properties in columns.items():
                if "presence" in properties:
                    for pipeline in properties["presence"]:
                        table_dvpi.add(pipeline)
                for prop, pipelines in properties.items():
                    if prop != "presence":
                        for pipeline in pipelines.keys():
                            table_dvpi.add(pipeline)

            unique_dvpi.update(table_dvpi)
            if len(table_dvpi) > 1:
                multi_dvpi_tables += 1

            print(f"\nTable '{table_name}' has {conflict_count} differences across pipelines:")
            for column_name, properties in columns.items():
                if "presence" in properties:
                    print(f"  Column '{column_name}' is in:")

                    # Group pipelines by status ("declared" or "missing")
                    grouped_status = {}
                    for pipeline, status in properties["presence"].items():
                        grouped_status.setdefault(status, []).append(pipeline)

                    # Sort by the number of pipelines in each group
                    sorted_status = sorted(grouped_status.items(), key=lambda x: len(x[1]))

                    # Print each group in the sorted order
                    for status, pipelines in sorted_status:
                        print(f'    "{status}"   : {pipelines[0]}')
                        for pipeline in pipelines[1:]:
                            print(f"                 : {pipeline}")
                for prop, pipelines in properties.items():
                    if prop != "presence":
                        print(f"  Column '{column_name}' has conflicts:")
                        print(f"    '{prop}' is:")

                        # Group pipelines by value
                        grouped_values = {}
                        for pipeline, value in pipelines.items():
                            grouped_values.setdefault(value, []).append(pipeline)

                        # Sort grouped values by the number of pipelines in each group
                        sorted_values = sorted(grouped_values.items(), key=lambda x: len(x[1]))

                        for value, pipelines in sorted_values:
                            print(f"      \"{value}\" : {pipelines[0]}")
                            for pipeline in pipelines[1:]:
                                print(f"                : {pipeline}")

        print(f"\nTotal number of tables analyzed: {total_tables}")
        print(f"Total number of DVPI analyzed: {len(unique_dvpi)}")
        print(f"Number of tables where various DVPI are involved: {multi_dvpi_tables}")
        print(f"Total number of conflicts: {total_conflicts}")

    def run_analysis(self,tests_only):
        """Run the analysis from loading data to generating the report."""
        self.load_dvpi_files(tests_only)
        self.load_pipeline_data()
        self.check_table_name_similarity()
        self.analyze_conflicts()
        self.print_conflicts()

        if self.total_differences > 0:
            sys.exit(8)
        else:
            sys.exit(0)

if __name__ == "__main__":
    description_for_terminal = "Cimt AG reccommends to follow the instruction before starting the script. If you run your script from command line, it should look" \
                               " like this: python __main__.py inputFile"
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage=usage_for_terminal
    )
    # input Arguments
    #todo add file focussed check
    #parser.add_argument("dvpi_filename",
    #                   help="Name of the dvpi file to check. Set this to '@youngest' to check the youngest file in your dvpi directory")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    # output arguments
    parser.add_argument("--dvpi_directory", help="Path of the directory with dvpi files to check")
    parser.add_argument("--tests_only", help="Restricts the list of dvpi files to the crosschek test files",action='store_true')

    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpd_model_profile_directory'])

    if args.dvpi_directory == None:
        dvpi_directory = Path(params['dvpi_default_directory'])
    else:
        dvpi_directory = Path(args.dvpi_directory)


    #if dvpd_filename == '@youngest':
    #    dvpd_filename = get_name_of_youngest_dvpd_file(ini_file=args.ini_file)


    crosscheck = DVPIcrosscheck(dvpi_directory)
    crosscheck.run_analysis(args.tests_only)
#!/usr/bin/env python310
# =====================================================================
# Part of the Data Vault Pipeline Description Reference Implementation
#
#  Copyright 2025 Albin Cekaj, Matthias Wegner, cimt ag
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

class CrosscheckError(Exception):
    """Raised when Crosscheck must stop due to severe errors  """
    pass
class DVPIcrosscheck:
    def __init__(self, dvpi_directory, dvpi_focus_file):
        self.dvpi_directory = dvpi_directory
        self.dvpi_files = []
        self.pipeline_data = {}
        self.conflict_report = {}
        self.pipeline_names = {}
        self.total_differences = 0
        self.multi_dvpi_table_count = 0
        self.dvpi_focus_file = dvpi_focus_file
        self.dvpi_count = 0
        self.similar_tables_of_unknown=[]

    def collect_dvpi_file_names(self, tests_only):
        for file_name in os.listdir(self.dvpi_directory):
            if file_name.endswith(".json"):
                if (not tests_only and not file_name.startswith("t120")) or (tests_only and file_name.startswith("t120")):
                    self.dvpi_files.append(file_name)


    def load_all_relevant_pipeline_data(self):
        """Collect and organize tables, columns, and properties from each DVPI file."""

        focus_on_file=False

        if self.dvpi_focus_file != "@all":  #load focus file first
            focus_on_file = True
            file_path = os.path.join(self.dvpi_directory, self.dvpi_focus_file )
            with open(file_path, 'r') as f:
                dvpi_data = json.load(f)
                pipeline_name = dvpi_data.get("pipeline_name")
                self.pipeline_names[pipeline_name] = self.dvpi_focus_file
                self.add_dvpi_to_repositories(dvpi_data,add_only_known_tables=False)
                self.dvpi_count += 1

        for file_name in self.dvpi_files:
            file_path = os.path.join(self.dvpi_directory, file_name)
            if file_name == self.dvpi_focus_file:
                continue
            with open(file_path, 'r') as f:
                dvpi_data = json.load(f)
                pipeline_name = dvpi_data.get("pipeline_name")
                if pipeline_name in self.pipeline_names:
                    raise CrosscheckError(f"Duplicate pipeline name {pipeline_name} declared by files  '{file_name}' and '{self.pipeline_names[pipeline_name]}'")
                self.pipeline_names[pipeline_name] = file_name
                if self.add_dvpi_to_repositories(dvpi_data, add_only_known_tables=focus_on_file):
                   self.dvpi_count +=1

    def add_dvpi_to_repositories(self,dvpi_data,add_only_known_tables=False):
        pipeline_name = dvpi_data.get("pipeline_name")
        tables = dvpi_data.get("tables", [])
        added_data=False
        for table in tables:
            table_name = table["table_name"]
            if table_name not in self.pipeline_data:
               if add_only_known_tables :
                 self.check_similarity_with_unknown(table_name)
                 continue
               else:
                 self.pipeline_data[table_name] = {}
            added_data = True

            columns = table.get("columns", [])
            for column in columns:
                column_name = column["column_name"]
                if column_name not in self.pipeline_data[table_name]:
                    self.pipeline_data[table_name][column_name] = {}

                for key, value in column.items():
                    if key not in self.pipeline_data[table_name][column_name]:
                        self.pipeline_data[table_name][column_name][key] = {}
                    self.pipeline_data[table_name][column_name][key][pipeline_name] = value
        return added_data
        #todo: evaluate coneptually, if we need more data to ensure compatibility of hash composition

    def check_table_name_similarity(self):
        """Check for table names that are too similar to each other."""
        print("\nChecking for similar table names...")
        table_names = list(self.pipeline_data.keys())
        similar_tables = []

        for i, table1 in enumerate(table_names):
            for table2 in table_names[i + 1:]:
                # Calculate Levenshtein distance
                similarity_distance = distance(table1, table2)
                if similarity_distance <= 1:
                    similar_tables.append((table1, table2, similarity_distance))
            for table2 in self.similar_tables_of_unknown:
                similarity_distance = distance(table1, table2)
                if similarity_distance <= 1:
                    similar_tables.append((table1, table2, similarity_distance))

        # Print results
        if similar_tables:
            print("! Warning: Found table name similarities:")
            for table1, table2, similarity_distance in similar_tables:
                print(f"  '{table1}' and '{table2}' (Distance: {similarity_distance})")
        else:
            print("Table name similarities: None")

        return len(similar_tables)

    def check_similarity_with_unknown(self, table_name_of_unknown):
        '''Checks if a given table name is similar to the relevant model and puts it in the list, if so.'''
        if table_name_of_unknown in self.similar_tables_of_unknown:
            return

        for table_name_of_focus in  self.pipeline_data:
            similarity_distance = distance(table_name_of_focus, table_name_of_unknown)
            if similarity_distance <= 1:
                self.similar_tables_of_unknown.append(table_name_of_unknown)
            return  # we can stop here, since at least one relevant table is already similar

    def analyze_conflicts(self):
        """Identify conflicts in properties and presence of tables and columns across pipelines."""
        for table_name, columns in self.pipeline_data.items():
            # Identify pipelines where the table exists
            pipelines_with_table = {
                pipeline for pipeline in self.pipeline_names.keys()
                if any(pipeline in col.get(prop, {}).keys() for col in columns.values() for prop in col.keys())
            }

            if len(pipelines_with_table) < 2:
                continue

            self.multi_dvpi_table_count +=1;

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

        if len(self.conflict_report) == 0:
            print ("\n- no conflicts -")
            return

        print("\nList of conflicts:")
        print("=========================================================")

        total_tables = len(self.conflict_report)  # Total number of tables



        for table_name, columns in self.conflict_report.items():
            # Count total conflicts for this table
            conflict_count = sum(
                len(properties) for column_name, properties in columns.items() if column_name != "table_presence"
            )

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


            if conflict_count == 1:
                print(f"\nTable '{table_name}' has {conflict_count} conflict across pipelines:")
            else:
                print(f"\nTable '{table_name}' has {conflict_count} conflicts across pipelines:")
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

        print("=========================================================")



    def run_analysis(self,tests_only):
        """Run the analysis from loading data to generating the report."""
        self.collect_dvpi_file_names(tests_only)
        self.load_all_relevant_pipeline_data()
        number_of_similar_tables=self.check_table_name_similarity()
        self.analyze_conflicts()
        self.print_conflicts()

        print(f"\nDVPI analyzed: {self.dvpi_count}")
        print(f"Tables analyzed: {len(self.pipeline_data)}")
        print(f"Tables created by multiple DVPI: {self.multi_dvpi_table_count}")
        print(f"Tables with conflicts: {len(self.conflict_report)}")
        print(f"Number of conflicts: {self.total_differences}")

        print(
            f"\ncrosscheck for {self.dvpi_count} DVPI files=>Tables:{len(self.pipeline_data)}, Conflict Tables: {len(self.conflict_report)}/{self.multi_dvpi_table_count}, Conflicts: {self.total_differences}")

        if self.total_differences>0:
            return "conflicts"

        if number_of_similar_tables>0:
            return "warnings"

        return "fine"



def get_name_of_youngest_dvpi_file(dvpi_default_directory):

    max_mtime=0
    youngest_file=''

    for file_name in os.listdir( dvpi_default_directory):
        if not os.path. isfile( dvpi_default_directory+'/'+file_name):
            continue
        file_mtime=os.path.getmtime( dvpi_default_directory+'/'+file_name)
        if file_mtime>max_mtime:
            youngest_file=file_name
            max_mtime=file_mtime

    return youngest_file

if __name__ == "__main__":
    print ("=== dvpi crosscheck ===")
    description_for_terminal = "Checks the structural compatibility from the pipeline description of a set of dvpi"
    usage_for_terminal = "Add option -h for further instruction"

    parser = argparse.ArgumentParser(
        description=description_for_terminal,
        usage=usage_for_terminal
    )
    # input Arguments

    parser.add_argument("dvpi_filename",
                       help="Name of the dvpi file to check. Set this to '@youngest' to check the youngest file in your dvpi directory")
    parser.add_argument("--ini_file", help="Name of the ini file", default='./dvpdc.ini')
    # output arguments
    parser.add_argument("--dvpi_directory", help="Path of the directory with dvpi files to check")
    parser.add_argument("--tests_only", help="Restricts the list of dvpi files to the crosschek test files",action='store_true')

    args = parser.parse_args()

    params = configuration_load_ini(args.ini_file, 'dvpdc', ['dvpi_default_directory'])

    if args.dvpi_directory == None:
        dvpi_directory = Path(params['dvpi_default_directory'])
    else:
        dvpi_directory = Path(args.dvpi_directory)


    dvpi_file_name=args.dvpi_filename
    if dvpi_file_name == '@youngest':
        dvpi_file_name = get_name_of_youngest_dvpi_file(params['dvpi_default_directory'])

    if dvpi_file_name != '@all':
        print(f"Crosscheck with focus on objects in '{dvpi_file_name}'")
    else:
        print(f"Crosscheck complete set of dvpi")

    crosscheck = DVPIcrosscheck(dvpi_directory, dvpi_file_name)
    try:
        check_result=crosscheck.run_analysis(args.tests_only)
    except CrosscheckError as ce:
        print(ce)
        print("*** dvpi crosscheck ended with error ***\n")
        sys.exit(9)

    if check_result == 'fine':
        print("--- dvpi crosscheck successfull ---\n")
        sys.exit(0)
    elif check_result == 'conflicts':
        print("*** dvpi crosscheck ended with conflicts ***\n")
        sys.exit(8)
    elif check_result == 'warnings':
            print("--! dvpi crosscheck ended with warnings !--\n")
            sys.exit(5)
    else:
        raise f"unknow check result type {check_result}"
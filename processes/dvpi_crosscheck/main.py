import json
#import configparser
import os
import sys
import argparse
from pathlib import Path
import re

project_directory = os.path.dirname(os.path.dirname(sys.path[0]))
sys.path.insert(0, project_directory)

class DVPIcrosscheck:
    def __init__(self, dvpi_directory):
        self.dvpi_directory = dvpi_directory
        self.dvpi_files = []
        self.tables_dict = {}
        self.table_occurrences = {}
        self.pipeline_names = {}
        self.table_differences = {}
        self.total_differences = 0
    def load_dvpi_files(self):
        for file_name in os.listdir(self.dvpi_directory):
            if file_name.startswith("t120") and file_name.endswith(".json"):
                self.dvpi_files.append(file_name)

    def load_tables_from_dvpi(self, file_name):
        """
        Load the tables from a single DVPI file.
        """
        file_path = os.path.join(self.dvpi_directory, file_name)
        with open(file_path, 'r') as f:
            dvpi_data = json.load(f)
            tables = {table['table_name']: table for table in dvpi_data.get("tables", [])}
            pipeline_name = dvpi_data.get("pipeline_name", file_name)
            self.pipeline_names[file_name] = pipeline_name
            return tables

    def load_table_occurrences(self, file_name, tables):
        """
        Track which tables appear in each DVPI.
        """
        pipeline_name = self.pipeline_names[file_name]
        for table_name in tables.keys():
            if table_name not in self.table_occurrences:
                self.table_occurrences[table_name] = []
            self.table_occurrences[table_name].append((pipeline_name, tables[table_name]))

    def run_comparison(self):
        """
        Load DVPI files, check properties, and generate the table occurrence report.
        """
        self.load_dvpi_files()

        # Load tables, check properties, and track occurrences for each test case
        for file_name in self.dvpi_files:
            tables = self.load_tables_from_dvpi(file_name)
            self.tables_dict[file_name] = tables
            for table in tables.values():
                self.check_table_properties(table)  # Run checks for each table
            self.load_table_occurrences(file_name, tables)

        # Generate the list of tables that appear in more than one test case
        self.generate_table_occurrence_report()

    def generate_table_occurrence_report(self):
        """
        Print tables that appear in more than one DVPI and the DVPI where they appear.
        """
        print("\nTables that appear in more than one test case:")
        for table_name, occurrences in self.table_occurrences.items():
            if len(occurrences) > 1:
                pipeline_names = [occurrence[0] for occurrence in occurrences]
                print(f"Table '{table_name}' appears in: {', '.join(pipeline_names)}")

                self.compare_columns_detailed_for_all_pipelines(table_name, occurrences)

    def compare_table_across_test_cases(self, table_name, occurrences):
        """
        Compare the tables with the same name across multiple DVPI.
        """
        # Use the first occurrence as the reference
        reference_pipeline, reference_table = occurrences[0]
        reference_properties = {
            "table_stereotype": reference_table["table_stereotype"],
            "schema_name": reference_table.get("schema_name", ""),
            "storage_component": reference_table.get("storage_component", ""),
            "columns": reference_table["columns"]
        }

        for pipeline_name, table in occurrences[1:]:
            for prop, ref_value in reference_properties.items():
                # Compare columns in a separate way
                if prop == "columns":
                    self.compare_columns_detailed(ref_value, table[prop], table_name, reference_pipeline, pipeline_name)
                elif table.get(prop) != ref_value:
                    if table_name not in self.table_differences:
                        self.table_differences[table_name] = []
                    self.table_differences[table_name].append({
                        "reference_pipeline": reference_pipeline,
                        "pipeline_name": pipeline_name,
                        "property": prop,
                        "reference_value": ref_value,
                        "comparison_value": table.get(prop)
                    })

    def compare_columns_detailed_for_all_pipelines(self, table_name, occurrences):
        """
        Compare columns for all pipelines where the table appears.
        """
        pipeline_tables = {pipeline: table["columns"] for pipeline, table in occurrences}

        # Generate all pairwise combinations of pipelines
        pipelines = list(pipeline_tables.keys())
        for i in range(len(pipelines)):
            for j in range(i + 1, len(pipelines)):
                ref_pipeline = pipelines[i]
                compare_pipeline = pipelines[j]
                ref_columns = pipeline_tables[ref_pipeline]
                compare_columns = pipeline_tables[compare_pipeline]

                self.compare_columns_detailed(
                    ref_columns, compare_columns, table_name, ref_pipeline, compare_pipeline
                )

    def compare_columns_detailed(self, ref_columns, compare_columns, table_name, reference_pipeline, pipeline_name):
        ref_columns_dict = {col["column_name"]: col for col in ref_columns}
        compare_columns_dict = {col["column_name"]: col for col in compare_columns}

        all_column_names = set(ref_columns_dict.keys()).union(compare_columns_dict.keys())
        differences_found = False
        table_differences = []

        for column_name in all_column_names:
            ref_col = ref_columns_dict.get(column_name)
            comp_col = compare_columns_dict.get(column_name)
            column_differences = {"column_name": column_name, "status": []}

            if ref_col and not comp_col:
                column_differences["status"].append({
                    "pipeline": reference_pipeline,
                    "status": "declared"
                })
                column_differences["status"].append({
                    "pipeline": pipeline_name,
                    "status": "missing"
                })
                differences_found = True
            elif not ref_col and comp_col:
                column_differences["status"].append({
                    "pipeline": reference_pipeline,
                    "status": "missing"
                })
                column_differences["status"].append({
                    "pipeline": pipeline_name,
                    "status": "declared"
                })
                differences_found = True
            else:
                # Check for attribute differences in matching columns
                for key in ref_col.keys():
                    if ref_col.get(key) != comp_col.get(key):
                        column_differences["status"].append({
                            "pipeline": reference_pipeline,
                            "attribute": key,
                            "value": ref_col.get(key),
                            "status": "declared"
                        })
                        column_differences["status"].append({
                            "pipeline": pipeline_name,
                            "attribute": key,
                            "value": comp_col.get(key),
                            "status": "declared"
                        })
                        differences_found = True

            # Add differences for this column if there are any
            if column_differences["status"]:
                table_differences.append(column_differences)

        # Store the differences for this table if any were found
        if differences_found:
            if table_name not in self.table_differences:
                self.table_differences[table_name] = []
            self.table_differences[table_name].append({
                "reference_pipeline": reference_pipeline,
                "pipeline_name": pipeline_name,
                "column_differences": table_differences
            })

            self.total_differences += len(table_differences)
        return not differences_found

    def print_differences(self):
        for table_name, differences in self.table_differences.items():
            print(f"\nTable '{table_name}' has differences across test cases:")
            for diff in differences:
                print(f"  Between {diff['reference_pipeline']} and {diff['pipeline_name']}:")
                for column_diff in diff["column_differences"]:
                    print(f"    Column '{column_diff['column_name']}' is in:")

                    max_pipeline_length = max(len(status['pipeline']) for status in column_diff["status"])

                    for status in column_diff["status"]:
                        pipeline = status["pipeline"].ljust(max_pipeline_length)  # Align pipeline names
                        if "attribute" in status:
                            attribute = status["attribute"]
                            value = status["value"]
                            print(f"      {pipeline} -> {attribute}: {value}")
                        else:
                            print(f"      {pipeline} {status['status']}")

        #  total conflicts
        print(f"\nTotal number of conflicts is: {self.total_differences}")

    def check_table_properties(self, table):
        pass

if __name__ == "__main__":
    dvpi_directory = r"C:\git_ordner\dvpd\var\dvpi"
    comparison = DVPIcrosscheck(dvpi_directory)
    comparison.run_comparison()
    comparison.print_differences()
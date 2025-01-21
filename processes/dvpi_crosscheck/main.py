import json
import os
import sys
from Levenshtein import distance
class DVPIcrosscheck:
    def __init__(self, dvpi_directory):
        self.dvpi_directory = dvpi_directory
        self.dvpi_files = []
        self.pipeline_data = {}
        self.conflict_report = {}
        self.pipeline_names = {}  # Store pipeline names from DVPI files
        self.total_differences = 0

    def load_dvpi_files(self):
        for file_name in os.listdir(self.dvpi_directory):
            if file_name.startswith("t120") and file_name.endswith(".json"):
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

            # Skip if the table exists in fewer than two pipelines
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
        for table_name, columns in self.conflict_report.items():
            # Count total conflicts for the table
            conflict_count = sum(
                len(properties) for column_name, properties in columns.items() if column_name != "table_presence"
            )

            print(f"\nTable '{table_name}' has {conflict_count} differences across pipelines:")
            if "table_presence" in columns:
                print(f"  Table presence is:")
                for pipeline, status in columns["table_presence"].items():
                    print(f"      {status} : {pipeline}")
            for column_name, properties in columns.items():
                if column_name == "table_presence":
                    continue
                if "presence" in properties:
                    print(f"  Column '{column_name}' is in:")
                    sorted_presence = sorted(properties["presence"].items(), key=lambda x: x[0])

                    # Group pipelines by their status
                    grouped_status = {}
                    for pipeline, status in sorted_presence:
                        grouped_status.setdefault(status, []).append(pipeline)

                    for status, pipelines in grouped_status.items():
                        print(f'    "{status}"   : {pipelines[0]}')
                        for pipeline in pipelines[1:]:
                            print(f"                 : {pipeline}")
                for prop, pipelines in properties.items():
                    if prop != "presence":
                        print(f"  Column '{column_name}' has conflicts:")
                        print(f"    '{prop}' is:")

                        # Group pipelines by value and calculate alignment
                        grouped_values = {}
                        for pipeline, value in pipelines.items():
                            grouped_values.setdefault(value, []).append(pipeline)

                        max_value_length = max(len(str(value)) for value in grouped_values.keys())

                        for value, pipelines in grouped_values.items():
                            quoted_value = f'"{value}"'
                            print(f"      {quoted_value:<{max_value_length + 2}} : {pipelines[0]}")
                            for pipeline in pipelines[1:]:
                                print(f"      {' ' * (max_value_length + 2)} : {pipeline}")
        print(f"\nTotal number of conflicts: {self.total_differences}")

    def run_analysis(self):
        """Run the analysis from loading data to generating the report."""
        self.load_dvpi_files()
        self.load_pipeline_data()
        self.check_table_name_similarity()
        self.analyze_conflicts()
        self.print_conflicts()

if __name__ == "__main__":
    dvpi_directory = r"C:\\git_ordner\\dvpd\\var\\dvpi"
    crosscheck = DVPIcrosscheck(dvpi_directory)
    crosscheck.run_analysis()
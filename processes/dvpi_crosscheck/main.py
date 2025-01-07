import json
import os
import sys

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

    def analyze_conflicts(self):
        """Identify conflicts in properties and presence of tables and columns across pipelines."""
        pipelines_total = set(self.pipeline_names.values())  # Set of all pipeline names

        for table_name, columns in self.pipeline_data.items():
            # Calculate the presence of the table in pipelines
            table_presence = {
                pipeline: "declared in" if table_name in self.pipeline_data and any(
                    pipeline in col.get(prop, {}).keys()
                    for col in columns.values()
                    for prop in col.keys()
                ) else "missing in"
                for pipeline in pipelines_total
            }
            declared_count = list(table_presence.values()).count("declared in")

            # Skip the table if it's not in at least two pipelines
            if declared_count < 2:
                continue

            # Analyze column-level conflicts if the table is available in two or more pipelines
            for column_name, properties in columns.items():
                # Analyze property conflicts
                for prop, values in properties.items():
                    unique_values = set(values.values())
                    if len(unique_values) > 1:  # If multiple unique values exist, we have a conflict
                        if table_name not in self.conflict_report:
                            self.conflict_report[table_name] = {}
                        if column_name not in self.conflict_report[table_name]:
                            self.conflict_report[table_name][column_name] = {}
                        self.conflict_report[table_name][column_name][prop] = values
                        self.total_differences += 1

                # Analyze column presence across pipelines
                pipelines_with_column = set()
                for prop, pipelines in properties.items():
                    pipelines_with_column.update(pipelines.keys())

                if len(pipelines_with_column) < len(pipelines_total):
                    if pipelines_with_column != pipelines_total:  # Check if all declared or all missing
                        if table_name not in self.conflict_report:
                            self.conflict_report[table_name] = {}
                        if column_name not in self.conflict_report[table_name]:
                            self.conflict_report[table_name][column_name] = {}
                        self.conflict_report[table_name][column_name]["presence"] = {
                            pipeline: "declared in" if pipeline in pipelines_with_column else "missing in"
                            for pipeline in pipelines_total
                        }
                        self.total_differences += 1

    def print_conflicts(self):
        """Print out the report of conflicts for all tables and columns."""
        print("\nConflicts across pipelines:")
        for table_name, columns in self.conflict_report.items():
            print(f"\nTable '{table_name}' has differences across pipelines:")
            if "table_presence" in columns:
                print(f"  Table presence is:")
                for pipeline, status in columns["table_presence"].items():
                    print(f"      {status} : {pipeline}")
            for column_name, properties in columns.items():
                if column_name == "table_presence":
                    continue
                if "presence" in properties:
                    presence_values = list(properties["presence"].values())
                    most_common_value = max(set(presence_values), key=presence_values.count)
                    print(f"  Column '{column_name}' is in:")
                    sorted_presence = sorted(properties["presence"].items(), key=lambda x: x[1] != most_common_value)

                    # Group pipelines by their status
                    grouped_status = {}
                    for pipeline, status in sorted_presence:
                        grouped_status.setdefault(status, []).append(pipeline)

                    for status, pipelines in grouped_status.items():
                        # Print the first pipeline with the status
                        print(f"      {status}  : {pipelines[0]}")
                        # Align subsequent pipelines under the same status
                        for pipeline in pipelines[1:]:
                            print(f"                  : {pipeline}")
                for prop, pipelines in properties.items():
                    if prop != "presence":
                        print(f"  Column '{column_name}' has conflicts:")
                        print(f"    '{prop}' is:")
                        values = list(pipelines.values())
                        most_common_value = max(set(values), key=values.count)
                        sorted_pipelines = sorted(pipelines.items(), key=lambda x: x[1] != most_common_value)
                        for pipeline, value in sorted_pipelines:
                            print(f"      {value} : {pipeline}")
        print(f"\nTotal number of conflicts: {self.total_differences}")

    def run_analysis(self):
        """Run the analysis from loading data to generating the report."""
        self.load_dvpi_files()
        self.load_pipeline_data()
        self.analyze_conflicts()
        self.print_conflicts()

if __name__ == "__main__":
    dvpi_directory = r"C:\\git_ordner\\dvpd\\var\\dvpi"
    crosscheck = DVPIcrosscheck(dvpi_directory)
    crosscheck.run_analysis()
import os
import json

class ExtendStageDefinition:
    """Class to extend stage definitions in a DVPI file with target column information."""

    def __init__(self, dvpi_file):
        self.dvpi_file = dvpi_file
        self.dvpi_data = None

    def load_dvpi(self):
        """Load the existing DVPI JSON file safely."""
        if not os.path.exists(self.dvpi_file):
            print(f"ERROR: File not found: {self.dvpi_file}")
            return False

        with open(self.dvpi_file, "r", encoding="utf-8") as file:
            self.dvpi_data = json.load(file)

        print(f"Successfully loaded: {self.dvpi_file}")
        return True

    def extract_table_column_mappings(self):
        table_column_map = {}

        for table in self.dvpi_data.get("tables", []):
            table_name = table["table_name"]
            for column in table.get("columns", []):
                column_name = column["column_name"]
                table_column_map[column_name] = {
                    "table_name": table_name,
                    "column_type": column["column_type"],
                    "column_class": column.get("column_class", "unknown")
                }

        return table_column_map

    def extend_stage_columns(self):
        """Extend stage column definitions with target column information."""
        if not self.dvpi_data or "parse_sets" not in self.dvpi_data:
            print("No parse_sets found in the DVPI file.")
            return

        table_column_map = self.extract_table_column_mappings()

        for parse_set in self.dvpi_data.get("parse_sets", []):
            if "stage_columns" in parse_set:
                for column in parse_set["stage_columns"]:
                    stage_column_name = column["stage_column_name"]

                    targets = [
                        {
                            "table_name": table_column_map[stage_column_name]["table_name"],
                            "column_name": stage_column_name,
                            "column_type": table_column_map[stage_column_name]["column_type"],
                            "column_class": table_column_map[stage_column_name]["column_class"]
                        }
                    ] if stage_column_name in table_column_map else []

                    column["targets"] = targets


    def save_extended_dvpi(self, output_file):
        """Save the modified DVPI file."""
        with open(output_file, "w", encoding="utf-8") as file:
            json.dump(self.dvpi_data, file, indent=4)

    def run(self, output_file):
        """Main method to run the extension process."""
        if self.load_dvpi():
            self.extend_stage_columns()
            self.save_extended_dvpi(output_file)


if __name__ == "__main__":
    BASE_DIR = os.path.abspath(os.path.dirname(__file__))

    input_dvpi = os.path.join(BASE_DIR, "../../var/dvpi/t0111.dvpi.json")
    output_dvpi = os.path.join(BASE_DIR, "../../var/dvpi/t0111_extended.dvpi.json")

    print(f"Base Directory: {BASE_DIR}")
    print(f"Input File: {os.path.abspath(input_dvpi)}")
    print(f"Output File: {os.path.abspath(output_dvpi)}")

    extender = ExtendStageDefinition(input_dvpi)
    extender.run(output_dvpi)
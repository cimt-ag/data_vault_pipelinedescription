import json

class MissingFieldError(Exception):
    def __init__(self, message):
        super().__init__(message)

def parse_json_to_ddl(filepath):
    with open(filepath, 'r') as file:
        data = json.load(file)

    # Check for missing fields
    if 'tables' not in data:
        raise MissingFieldError("The field 'tables' is missing from the JSON.")
    
    if 'parse_sets' not in data:
        raise MissingFieldError("The field 'parse_sets' is missing from the JSON.")

    # Extract tables and stage tables
    tables = data.get('tables', [])
    parse_sets = data.get('parse_sets', [])

    ddl_statements = []

    # Generate DDL for tables
    for table in tables:
        # Check for missing fields 
        if 'schema_name' not in table:
            raise MissingFieldError("The field 'schema_name' is missing from the JSON.")
        
        if 'table_name' not in table:
            raise MissingFieldError("The field 'table_name' is missing from the JSON.")

        table_name = "{}.{}".format(table['schema_name'], table['table_name'])
        columns = table['columns']
        # print(f"columns:\n{columns}")
        column_statements = []
        for column in columns:
            col_name = column['column_name']
            col_type = column['column_type']
            # Handle the #todo placeholder
            if col_type == "#todo ":
                col_type = "VARCHAR(255)"  # Default data type if not provided
            column_statements.append("{} {}".format(col_name, col_type))
        ddl = "CREATE TABLE {} (\n{}\n);".format(table_name, ',\n'.join(column_statements))
        ddl_statements.append(ddl)

    # Generate DDL for stage tables
    for parse_set in parse_sets:
        stage_properties = parse_set['stage_properties']
        table_name = "{}.{}".format(stage_properties['stage_schema_name'], stage_properties['stage_table_name'])
        columns = parse_set['stage_columns']
        column_statements = []
        for column in columns:
            col_name = column['column_name']
            col_type = column['column_type']
            column_statements.append("{} {}".format(col_name, col_type))
        ddl = "CREATE TABLE {} (\n{}\n);".format(table_name, ',\n'.join(column_statements))
        ddl_statements.append(ddl)

    return "\n\n".join(ddl_statements)


if __name__ == '__main__':
    filepath = "processes/render_ddl/resources/new_style.dvpi.json"
    ddl_output = parse_json_to_ddl(filepath)
    print(ddl_output)

def generate_column_definition(column):
    """
    Generate the column definition for a given column.
    """
    return f"{column.column_name} {column.column_type}"

def generate_create_table_statement(table):
    """
    Generate a SQL CREATE TABLE statement for a given table.
    """
    column_definitions = [generate_column_definition(column) for column in table.columns.values()]
    return "CREATE TABLE {} (\n\t{}\n);".format(table.table_name, ',\n\t'.join(column_definitions))
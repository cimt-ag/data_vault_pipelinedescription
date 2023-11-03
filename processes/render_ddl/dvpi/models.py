class Column:
    def __init__(self, column_name, column_type="ToDo", column_class=None, parent_key_column_name=None, parent_table_name=None, column_content_comment=None, **kwargs): # **kwargs to handle additional fields which are ignored
        self.column_name = column_name
        self.column_class = column_class
        self.column_type = column_type
        self.parent_key_column_name = parent_key_column_name
        self.parent_table_name = parent_table_name

    def __str__(self):
        return f"Column(type={self.column_type}, class={self.column_class}, parent_key_column={self.parent_key_column_name}, parent_table={self.parent_table_name})"


class Table:
    def __init__(self, table_name, column_dict, schema="todo", table_stereotype="todo", **kwargs): # **kwargs to handle additional fields
        # print(f"column_dict: {column_dict}\n\n")
        self.table_name = table_name
        self.columns = {key: Column(column_name=key**value) for key, value in column_dict.items()}

    def __str__(self):
        return "Table(columns={" + ", ".join([f"{name}: {column}" for name, column in self.columns.items()]) + "})"


class StageTable:
    def __init(self, stage_column_dict):
        None

class DVPI:
    def __init__(self, table_dict, **kwargs):  # **kwargs to handle additional fields
        self.tables = {key: Table(table_name=key, **value) for key, value in table_dict.items()}

    def __str__(self):
        return "DVPI(tables={" + ", ".join([f"{name}: {table}" for name, table in self.tables.items()]) + "})"
        

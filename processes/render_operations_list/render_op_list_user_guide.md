# Render Operations List User Guide
The render operations list module exists, to create a a list of load-operations needed for a pipeline in a format we used at cimt.

# Explanation of list format
For DWH-Projects at CIMT-AG, we use a list of tables to be processed from a DataVault-Pipeline as input in our ETL-Jobs.
Each line in the list has the following structure: 
>{table|stage_table}.{schema_name}.{table_name}.[{relation_name}]

The first part is, to differentiate between stage_tables and 'normal' tables.
The schema_name denotes the schema the table belongs to.
For stage_tables, the schema_name equals the schema most associated with the pipeline and denotes the folder where the stage_table resides in.
The relation_name is is only rendered, if the table has to be loaded more than once (thus making the relation distinction necessary).


# Python Script
In order to be able to use the python script, the config 'dvpdc.ini' file needs to contain the 'rendering' section, including the properties 'dvpi_default_directory' & 'operations_list_directory'.
The script takes one parameter, namely the dvpi-file-name.
Example:
~~~
$ python processes/render_operations_list/__main__.py rsap_bseg_belegsegment_buchhaltung_p1.dvpi.json
~~~

The script prints the operations list to standard output and writes them to a file in the operations_list_directory.
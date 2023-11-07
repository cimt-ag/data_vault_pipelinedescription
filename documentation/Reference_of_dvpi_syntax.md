# DVPI Syntax Reference
DVPI is the resulset, created by the compiler by transforming the a dvpd. It is mainly designed to be read by generators for loading code and DDL.

A DVPI is expressed with JSON syntax and contains the following attributes (Keys):

# Root 

**dvdp_compiler**
<br> Textinformation about the compiler and its version

**dvpi_version**
<br> Version of the dvpi format. In general it is in sync with dvpd version .

**compile_timestamp**
<br> Compile time. Just for auditibilty

**dvpd_version**
<br>

**pipeline_name**
<br> Name of the pipeline, as declared in the dvpd. Could/should be used to identify the loading process artifact(s)

**dvpd_filemame**
<br>Name of the compiled DVPD file. Just for auditibilty

**tables[]**
<br>→ see "tables[]"

**data_extraction**
<br>→ see "data_extraction"

**parse_sets[]**
<br>List of parsing sets. Currently there will be only one entry. This structure element is already in the syntax to allow multiple parse sets, when supported by dvpd.
<br>→ see "parse_sets[]"

##tables[]
Json Path: /

The main purpose of the tables section, is to provide all structural information, needed to create the model tables, determine the loading procedure and document the relational structure

**table_name**
<br>Identification of the table in the DVPD Data Model. Is currently also used as Name of the Database Table. This will be separated in later releases.

**table_stereotype**
<br>Data Vault table stereotype "hub","lnk","sat","ref".  Should be useed to document the data vault model structure and determine the loading procedure.

**schema_name**
<br>Database schema of the table. (or database name, when the DB Engine does not support schemas, but uses "Databases" as structuring element)

**storage_component**
<br>Identification of the storage component. Valid Values depend on the system architecture and may control retrieval of connection parameters and use of platform technology specific  SQL Dialect, and loading procedures.

**has_deletion_flag**
<br>Triggers a loading procedure to manage a deletion flag, when processing deletion data

**is_effectivity_sat**
<br>Indicates to the loading procedure, that there are not data columns to be compared

**is_enddated**
<br>Indicated to the loading procedure, that an enddate has to be managed

**is_multiactive**
<br>Indicated to the loading procedure to follow the multiactive satellite loading pattern

**compare_criteria**
<br>Defines the elements, that have to be compared, when loading a satellite, as there are:
- key = the key (hub key, link key) is not already in the satellite
- data = the value combination of the relevant compare columns or the diff hash are not already in the satellite
- current = the value combination of the relevant compare columns or the diff hash are not equal to a current row in the satellite
- key+data = comparison is reduced to all rows which share the same key
- key+current = comparison of current values is reduced to the key (this is the main mode of data vault satellites)
- none = data will always be inserted (preventing duplication by repeated loads must be solved by load orchestration)

**uses_diff_hash**
<br>Indicates the existence and usage of a diff hash, for comparison of satellite data during the loading


**columns[]**
<br>→ see "columns[]"

###columns[]
Json Path: /tables[]

**column_name**
<br>Name of the column in the table. Should be used in DDL generation.

**column_type**
<br>Datatype of the column in the table. Should be used in DDL generation.

**column_content_comment**
<br>Comment provided for the column. Should be used in DDL generation.

**is_nullable**
<br>Declares if the column should be nullable. Is set to true for all hashes and metadata, since these should never be null.

**prio_for_column_position**
<br>Criteria to arrange column in a defined order in the DDL statement.


**column_class**
<br>Information about the kind of data from perspective of the data vault method. It should be used during DDL generation, when indexes or primary key contrainst are generated, to identify the columns of interest.

Possible values:
* **key** - the column is the hub key or link key of a hub or link
* **parent_key**- the column is the key of the parent table of a satellite or link
* **business_key** - the column is part of the business key of a hub
* **content** - the column contains data of a satellite
* **content_untracked** - the column contains data, that does not participate in keys or comparison
* **dependent_child_key** - the column is a dependent child key in a link
* **diff_hash** - the column contains a hash over all relevant columns/rows for comparison during the loading of satellites or reference tables
* **meta**_...
    * meta_load_date
	* meta_load_process_id
	* meta_record_source
	* meta_deletion_flag
	* meta_load_enddate

**parent_key_column_name**
<br>Name of the key column in the parent table, this column can be joined with. Provided to document the model structure or generate join SQL snippets.

**parent_table_name**
<br>table_name of the parent table, this column is used to join with. Provided to document the model structure or generate join SQL snippets.

**exclude_from_change_detection**
<br>Defines, if the column should be used in the change detection for loading satellites or reference tables. (#the meaning needs more clarification, since column_class and uses_diff_hash also control the elements involved#)


**xxxxx**
<br>

**xxxxx**
<br>

**xxxxx**
<br>


# License and Credits

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)
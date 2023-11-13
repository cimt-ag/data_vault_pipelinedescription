# DVPI Syntax Reference and usage guide
DVPI is the resulset, created by the compiler by transforming the a dvpd. It is mainly designed to be read by generators for loading code and DDL.

In this document you find a brief guideline how to use the content in your loading processes and a full syntax referenct

A DVPI is expressed with JSON syntax and contains the following attributes (Keys):

# Usage guideline
DVPI is designed to support the multiple steps of loading a source object into a data vault model. The follwong steps are normally needed for the loading:
- deploy the target database tables (might be done by the first run of the job or in sync with the deployment of the job artifact)
- contact the source and determine the increment
- fetch the data increment from the source
- parse the fetched data into rows and fields (This might involve identfication and translation of deletion events)
- calculate the needed hash values from the fetched data (might be part of every load operation or done in advance by creating a stage table)
- load the parsed data and hashes into the data vault tables in all necessary combinations (this might involve detection of missing source data and its translation in deletion flagging)

The listed steps can be implemented in different approaches as there are
- stage + target : Incoming data and calculated hashes are stored in a stage table first, then loaded to the target tables
- OSD + target: Incoming data is parsed into an "operational data store" (might be in memory only), hashes are calculated on the fly during the load into a target table
- target only: Incoming data is parsed and hashed for every target table on the fly

Please keep in mind, that the guideline describes, what should be used from the DVPI and how to get it.
It is by no means a recepie for the finally executed loading code but for a code generator, wich then create the specialized code from the DVPI content.  


### deploy target database tables
To deploy the target database tables, a ddl sql with the create statement must be generated somehow. The necessary information, to generate the ddl can be found in the DVPI as follows:
- iterate over the tables[] list
- inside a table list entry you find
    - you find schema and table name
    - table stereotype
	- iterate over the columns[] list
	- inside the columns list entry you find
	    - column name, type
		- indication of not null contratins
		- column class, can be used to identify specific columns (e.g. Business keys) that are interesting for indexes or primary key constrainst depending on the table stereotype

Should your loading pattern involve **stage tables** you also need to retreive the stage table structures as follows
- iterate over the "parse_sets[]" list
- insinde a parse set entry you find
	- stage_properties [] list, containg stage table schema and name for every storage component involved
	- stage_columns [] list with
	    - stage column name and type
		- flag to determin if column is nullable
		
		
### contact the source and determine the increment
This should be clarified by all properies in the "data_extraction" section. It depends heavily on your implementation architecture 
and module flexibility, how far the behavior of the fetching process can be configured.
Therefore this guide can only forerward you to the documentation of your modules.
		
### fetch the data increment from the source
This also is mostly defined by the properties in the "data_extraction" section. 

### iterate over parse sets
Depending on the data source there will be one or more parse sets for the fetched data. 
Tabularized (DB, CSV) sources have only one set, where hiearchical data (JSON,XML) structures with multiple loops will have more. (upcoming feature in 0.7.0).
Every parse set needs have its own definitions for parsing, hashing/staging and loading. This is why all declarations for this and the following steps are 
subelements in the list of parse_sets.

### parse the fetched data into rows and fields
To parse the data for a single parse set get the field names and the parameters to identify the data from the **fields[]** list. 
The kind of available properties depend on the needs for the parsed format and the capabilities of the parsing module. The only constantly available properties of the field are:
    - field name and type
	- field position
The field name is essential, since it is used as the identifier in the mappings.

The parsed data row might be directly stored in the ODS with the field_name as column name or kept in memory for staging. (It is not recommended to use the stage column name in the ods. This prevents confusion about the pattern)

### load data into stage table
This is only needed, when using the stage+target approach.

- interate over hashes[] list 
    - if there is a hash with "mult_row_content" = true execute necessary steps to provide multi row hashes (diff hash of multi active satellite)
	
To stage a single row 	
- iterate over stage_columns[] list and depending on the stage_column_class...
	- **"meta..."** put in the approproate value (e.g. record_source_name_expression, deletion flag)
	- **hash** calculate the hash value according the the recepie provided by the  "hashes[]" list entry with  the same "hash_name" and its "hash_fields[] list
	- **data** put in the value of the field, probably with transformation of the data type

### load data from stage to the target tables in all possible combinations
This only applies, when using the stage+target approach.
- in the current parse set iterate over load_operations[] list
    - retrieve table stereotype and properties by looking up the table name in the tables[] list.
	- execute the loading steps for the table stereotype
	- the data mapping must be read from the "hash_mappings[]" and "data_mappings[]" lists
	    - copy data from the stage column  "stage_column_name" to the target column "column_name"
	    - use the column_class to identify columns, that have special meanings in the loading (busniess keys, diff hash, etc)
	- iterate over all meta fields from the tables columns[] list and provide necessary data accordingly


### load data from Ods to the target tables in all possible combinations
This only applies, when using the ods+target approach.
- in the current parse set iterate over load_operations[] list
    - retrieve table stereotype and properties by looking up the table name in the tables[] list.
	- execute the loading steps for the table stereotype
	- the mapping of data columns must be read from "data_mappings[]" lists
	    - copy data from the ods column  "field_name" to the target column "column_name"
	- the mapping of hash columns must be read from the "hash_mappings[]" lists
	    - calculate the hash value according the the recepie provided by the  "hashes[]" list entry with  the same "hash_name" and its "hash_fields[] list
		- store the value in the column "column_name"
    - use the column_class to identify columns, that have special meanings in the loading (busniess keys, untracked)
	- iterate over all meta fields from the tables columns[] list and provide necessary data accordingly

### load data directly from source to the target table
- in the current parse set iterate over load_operations[] list
    - retrieve table stereotype and properties by looking up the table name in the tables[] list.
	- execute the loading steps for the table stereotype and the declared deletion detection procedure
	- the mapping of data columns must be read from "data_mappings[]" lists
	    - lookup the fields[] entry for the "field_name"
		- parse the field content from the source, by following the declaration of parsing properties
		- store the value in the column "column_name"
	- the mapping of hash columns must be read from the "hash_mappings[]" lists
	    - calculate the hash value according the the recepie provided by the  "hashes[]" list entry with  the same "hash_name" and its "hash_fields[] list
		- store the value in the column "column_name"
    - use the column_class to identify columns, that have special meanings in the loading (busniess keys, untracked)
	- iterate over all meta fields from the tables columns[] list and provide necessary data accordingly


# Syntax Reference

## Root 

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

###tables[]
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

### data_extraction
Json path: /

Contains all declarations needed to define the methods, how to retrieve the data. This might be just a module name, since it depends highly on the source technologiy and format and the flexibilty of the fetch and parse module.

**fetch_module_name**
<br>The name of the module to be used for fetching

**parse_module_name**
<br>The name of the module to be used for parsing

**...**
<br>

### parse_sets[]
Json path: /

Contains a list of parse sets. Until DVPD version 0.7.0 this will be only one element.

**stage_properties**
<br>List of stage properties, for different storage comnponents.
<br>→ see "stage_properties[]"

**record_source_name_expression**
<br>The record source name expression for the current parse set. Might contain placeholders, when the
processing module is capable of adding runtime specific information.

**fields[]**
<br>List of fields and their parsing properties.
<br>→ see "fields[]"

**hashes[]**
<br>List of hash "reciepies" needed.
<br>→ see "hashes[]"

**load_operations[]**
<br>List of load operations needed.
<br>→ see "load_operations[]"

**stage_columns[]**
<br>List of stage columns and their field / hash mapping.
<br>→ see "stage_columns[]"

### stage_properties[]
Json Path: /pares_sets[]

List of stage properties, for different storage comnponents. Mostly there will be only one entry, since having only one storage component for the data vault is the most common setup. Nevertheless, in case the data model is distributed over multiple storage components and technologies, this provides the opportunity to declare different names for every storage component.

**stage_schema**
<br>Name of the schema, the stage table will be placed in.

**stage_table_name**
<br>Name of the stage table.

### fields[]
Json Path: /pares_sets[]

Provides all necessary declarations how to parse every field from the source data.

**field_name**
<br>Name of the field. This will be used to identify the field in the mappings.

**field_type**
<br>Datatype of the field. Depeding on the parsing module, this must be the type of the incoming data and a type deviation to the target column will result in a type converion.

**field_position**
<br>This is the position of the field in the DVDP field list. It might be relevant for the parsing.

**<more properties to come>***


### hashes[]
Json Path: /pares_sets[]

Provides all necessary declaration, how to assemble and calculate the hash value.

**hash_name**
<br>Identfication of the hash. This is used to identify the hash in the mappings.

**stage_column_name**
<br>Name of the stage column, containing the hash value.

**hash_origin_table**
<br>Name of the data vault table, that is the cause of the hash (hash is the key of the table or a diff hash in the table)

**column_class**
<br>Column class of the hash: key / diff_hash

**multi_row_content**(diff hash only)
<br>Boolean, declaring if the hash has to be assembled from multiple rows. (e.g. a diff hash for multiactive satellites)

**related_key_hash**(diff hash only)
<br>Name of the hash, that defines the the key, the diff hash is referring to. This can be used to
identify all rows for the same multi row diff hash

**hash_fields[]**
<br>List of the fields, that need to be concatenated for the hash.
<br>→ see "hash_fields[]"

**column_type**
<br>Column type of the hash value in the target table.
(This is depends on the model profile, that has to be used for the hash containing table)

**hash_encoding**
<br>Type of enconding of the hash value. (Binary/BASE64/HEX)
(This is depends on the model profile, that has to be used for the hash containing table)

**hash_function**
<br>Hash function, that has to be applied.
(This is depends on the model profile, that has to be used for the hash containing table)

**hash_concatenation_seperator**
<br>Single character or string, that must be used as seperator between the concatinated fields
(This is depends on the model profile, that has to be used for the hash containing table)

**hash_timestamp_format_sqlstyle**
<br>Format string (using SQL syntax) to convert timestamps into a string representation for concatentation.
(This is depends on the model profile, that has to be used for the hash containing table)

**hash_null_value_string**
<br>String to be used for the data value NULL (Unknown) when concatenating the field data.
(This is depends on the model profile, that has to be used for the hash containing table)

**model_profile_name**
<br>This is just for documentation and tracing of the DVPD result and should not be used in any kind of processing of the DVPI.



### hash_fields[]
Json Path: /pares_sets[]/hashes[]/

The list of fields, to be concatenated for a hash. Be aware of the different properties to
organize the order of the fields for the concantination. The final interpretation lies in the
executing module and must be well documented by it.

**field_name**
<br>Name of the field, containing the data.

**prio_in_key_hash**(key hash only)
<br>Priority to be used, for ordering the fields in the concatination. This can be a direct declaration from the DVPD and should have more impact then other field attributes like name or field position. 

**prio_in_diff_hash**(diff hash only)
<br>Priority to be used, for ordering the fields in the concatination. This can be a direct declaration from the DVPD and should have more impact then other field attributes like name or field position. 

**prio_for_row_order**(diff hash only)
<br>Priority to be used, to define the order the rows, when assembling multi_row_content into a single hash (diff hash for multiactive satellites)

**field_target_table**
<br>Name of the table,  this field the field is mapped to and causes the participation of the field in the hash. (name of the hub table, for the hash of the hub key). 
This should be used to organize a table name specific order when assembling link keys.

**field_target_column**
<br>Name of the column,  this field the field is mapped to in the target table. 
This should be used to organize a column name specific order when assembling link keys.

**parent_declaration_position**
<br>Only for link hash keys, this is the position of the parten table in the link_parent_tables[] list i n the DVPD. 
This might be used to organize a link parent  declaration specific order, when assembling link keys.



### load_operations[]
Json Path: /pares_sets[]


### stage_columns[]
Json Path: /pares_sets[]




# License and Credits

(C) Matthias Wegner, cimt ag

Creative Commons License [CC BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)
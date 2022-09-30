DVPD core elements describe here must be supported by any implementation in the same way. If an implementation leaves out elements for simplicity, it should implement a check and warning message, to prevent false assumptions.

The syntax must and can be extended by properties, needed for project specific solutions (e.g. data_extraction modules, data encryption frameworks). Documentation for these properties must be provided for every module in a separate document.

A DVPD is expressed with JSON syntax and contains the following Attributes(Keys):

# Root 

**dvpd_Version**
(mandatory)<br>
Used to allow checking of compatibility. Must be set to the first version, that supports the used core elements
<br>*"1.0"*

**pipeline_name**
(mandatory)<br>
String to identify the pipeline. Must be unique over all pipelines managed by the system. Best practice for pipeline naming: Name of main the satellite/link, loaded by the pipeline.
<br>*"rgopd_clicks_p1"*

**pipeline_revision_tag**
(optional) <br>
String to identify the revision of the pipeline description. Content depends on process and toolset for development and deployment. Might be a version number or a revision / build tag.
<br> *"1.1" | "x129sa8"*

**pipeline_comment**
(optional)
<br>String with human understandable information about the pipeline purpose.

**record_source_name_expression**
(mandantory)<br>
String used to build the record source name. Might contain placeholders in syntax {<name of placeholder}>, that will be replaced by specific string. Valid placeholders depend on the data_extraction and staging engine
<br>*"sap.hr.depratments"*

**data_extraction**
(mandatory)<br>
Object, describing all necessary properties to access the data source<br>
→ see “data_extraction”

**model_profile_name**
(optional, default is “_default”)
<br>Name of the model profile to be used. The model profile defines the names and types of data vault specific columns, declares the ruleset for hashing and more.

**fields[]**(mandatory)
<br>Array, describing every source field, its properties how to extract it from the source data format and how to map the data to the data vault model
<br>→ see “fields”

**data_vault_modell[]**
(mandatory)
<br>Array with objects, describing the data vault tables and relations
<br>→ see “data_vault_modell”

**deletion_detection**
(optional)
<br>Object for declaring all necessary paramenter for deletion detection processes
<br>→ see “deletion_detection”


## data_extraction 
subelement of root 

**fetch_module_name**
(mandatory)
<br>name of the module, that is responsible to get the data from the source.This property would be used by a “master” process to determine, which module has to be chosen for loading the data.  Available modules depend on the implementation and the variety of data transport procedures an source formats. 
<br>*"csv_file_ftp" | "xml_file_azure" | "json_stream_over_kafka"

***>fetch module specific keys<***
<br>Depending on the used fetch module, there will be additional keys necessary to control the
genereal fetching process. Valid keys must be documented in the module documentation. Please note, that field specific paramterers for fetching and parsing have to be placed
as keys in the ***fields*** array

## fields[]
subelement of root 

**field_name**
(mandatory)
<br>Name of the field. Must be unique in the DVPD. Is normally used als the column name in the target table
<br>*"customer_id" | "article _name"*

**field_type**
(mandatory)
<br>Expected type of the field. Delivered data must be compliant to this type, or will be rejected by the loading process. (Rejection method depends on the fetch module). Valid types depend on the fetch module, but should be chosen from SQL Syntax, so this technical type can be directly used in the definition of the data model.
<br>*"VARCHAR(200)" | "INT8" | "TIMESTAMP"*

**needs_encryption**
(optional boolean with default false)
<br>When set to true, the data will be encrypted, according to the underlying concept for data protection
(This is the only standardized core element regarding encryption. All other properties are defined by the specific method of encryption)

**targets[]**
(mandatory)
<br>Array, defining all taret tables, this field will be mapped to
<br>→ targets

**field_comment**
(optional)
<br>Text that will be added as comment of the column in the stage data table

**>fetch module specific keys<**
<br> Depending of the data format and transport, there will be some more declarations necessary to identify the field in the source data. These properties can be added here. They must be documented in the fetch module documentation.

The order of elements in the array should be used for parsing positional data (csv, excel etc)..

### targets[]
subelement of fields[]

This array must contain at least one target description. Fields, that are mapped to multiple tables, must have one entry for each target table

**table_name**
(mandatory)
<br>Name of the target table.(Must be defined in the data_vault_model section
<br>*"rexmp_customer_hub" | "rgopd_ad_click_sat"

**target_column_name**
(optional)
<br>Name of the column in the target table. If not defined, the field_name will be used
<br>*"customer_number"

**target_column_type**
(optional)
<br>Datatype of the target column in the database. Must be a valid Database type. If not defined, the technical_type of the field will be used
<br>*"VARCHAR(200)"*

**recursion_name**
(optional, only useful for business key fields, must be defined on a link, that is referring its hub as recursive_parent)
<br>Declares this mapping to be used in a recursive reference.
The name must be defined in a ***recursive_parent*** relation of a the link table.

**field_groups[]**
(optional)
<br>List of field groups this field mapping will be restricted to. If not defined, the mapping will be used in every field group.
<br>*"[“Cust1”]"*

**exclude_from_key_hash**
(optional,default=false,only useful for hub and link table mappings)
<br>true = exclude the field from the calculation of the hub/link key. Used to define pure content column in the hub / link (this 
is rare but possible).

**prio_in_key_hash**
(optional, default=0)
<br>This property provides explicit control over the order of concatination of fields for the key hash calculation. It will overrule the implicit ordering, that is defeinde by the implementation. Implicit ordering will still be applied to columns of same prio. 

**exclude_from_diff_hash**
(optional, default=false, only useful on mappings to historized satellites)
<br>true = exclude the field from the calculation of the diff hash an therefore from the historization change detection

**prio_in_diff_hash**

optional, default=0

depending on the implementation the order of concatination of fields for the diff hash calculation is determined by the target_column name. This property provides more explicit control. Implicit ordering will still be applied to columns of same prio.  When columns are added to productive satellites it should allow to place new columns behind existing one during concatination.

 


 

hash_cleansing_rules

optional

contains different properties to describe a cleansing of the data before it is used in the hash. 

→ hash_cleansing_rules

column_content_comment

optional

comment, that will be added to the column in the data vault model. Default it the comment of the field

 

data_vault_model[]
json key

rules

function / description

example

storage_component

optional

Identification of the storage, this part of the model is placed. If not defined, there is on ly one storage component

main_dwh_db

big_data_storage

schema_name

mandatory

Name of the database schema, the tables are located. (this may also be the “database name”, since different database engines, adress this differently)

Especially for situations, where the schema name must also be used to provide dev/test/prod stages, it is recommended to declare parsable placeholders in the schema name. Those will be filled an runtime by the process, depending on the stage it runs in.

rvlt_accounting

tables[]

mandatory

list of all tables, located in the declared schema

->tables

tables[]
json key

rules

function / description

example

table_name

mandatory

name of the database table. 

raccn_account_hub

stereotype

mandatory

Data Vault Stereotype of the table:

hub,lnk,sat,msat,esat

 

table_content_comment

optional

Comment to add to the table in the database

 

storage_component

optional

If the data vault tables are distributed over different storage engines (e.g. for keeping big data out of expensive database storage), this property can be used to identify the location.  Valid values are depending on the implementation

fast_bi_db

big_data_storage_gcp

bis_data_storage_hadoop

model_profile_name

optional, default is model_profile_name declared on pipeline level

Name of the model profile to be used. The model profile defines the names and types of data vault specific columns, declares the ruleset for hashing and more.

postgres_main

<stereotype specific properties>

 

for details see next chapters

 

Stereotype “Hub”
json key

rules

function / description

example

hub_key_column_name

mandatory

Name of the hub key in the table

hk_raccn_account

Stereotype “lnk”
Depending on mapped fields and the properties this can be a 

normal link

dlink (Link with dependend child key): Is defined by mapping  a field to the link table (without excluding it from the key). Depending on the mapped field, this can be a non historized link

hierarchical link: is defined by link_hierarchical_parents declaration

json key

rules

function / description

example

link_key_column_name

mandatory

Name of the link key in the table

lk_raccn_account_department

link_parent_tables[]

mandatory

List of the table_names of all hubs, this link is referring to. The order of the tables in the list can be relevant to the hashing order of the link key.  In case, the processing engine enforces its own order, it muss issue a warning, when the order final order differs from the declarated.

[“raccn_account_hub”, “raccn_department_hub”]

recursive_parents[]

optional

List of recursive parent table declarations (e.g. for hierarchical links or “same as” links). Only tables that are link_parent_tables can be addressed here. The order of the tables in the list is relevant to the hashing order of the link key.  In case, the processing engine enforces its own order, it muss issue a warning, when the order final order differs from the declarated. How recursive parent businesskeys are ordered in relation to link parent businesskey is a decision of the engine

→ recursive_parents

is_link_without_sat

optional

must be set to true, to avoid warnings for links without an esat or sat

 

tracked_field_groups[]

optional, 

only valid for is_link_without_sat=true

list of field groups, this link will be processed for. The field groups must align with mappings of field that are used as businesskey in the hubs, the link is referring

 

Release 0-6-0

link_key_assemble_rule

 

optional

default: “p/p-r/p-d/ea”

Defines the rule, how to order the businesskeys for the link key concatenatenation. See section below for detailed specification 

 

 

Release 0-6-0

link_key_explicit_content_order[]

optional

must contain all relevant columns of parents and link

Specifies directly the order of businesskeys and dependent child key columns for hashing. Disables a link_key_assemble_rule

 

recursive_parents[]
json key

rules

function / description

example

table_name

mandatory

name of the link_parent_table, that is referenced again 

raccn_department_hub

recursion_name

mandatory

Name of the recursion (=.

The name should be usable to extend the hub key column names, since in general the additional hub key columns in the the link will be generated

master

field_group

mandatory

:warning: Might not be necessay :warning: field group defining fields for the business key columns of the hub, that have to be used for this relation

fg1,fg2

Stereotype “Satellite”
json key

rules

function / description

example

satellite_parent_table

mandatory

Name of the hub/link table, this satellite is connected to

raccn_account_hub

is_multiactive

optional, default=false

when set to true, the declaration and processing for multiactive satellites will be applied (no primary key, awarenes of multiple active rows for change detection)

 

is_historized

optional, default = true

whent set to true (default) meta data columns for historization will be added to the table and loading mechanism may process enddating functions

 

diff_hash_column_name

mandatory (normally)

Colum that contains the diff_hash (might be ommitted, when the implementation is not using a diff hash)

rh_account_p1_sat

driving_keys[]

optional

must refer to a parent_key or dependent_child_key in the parent table of the satellite

List of column names of the parent link, that are used as driving keys, to end former relations

In general, the name must match the final name of the key column in the link. Especially in case of recursive relation, the method of creating the key name must be taken into account.

[“hk_raccn_account”]

[“hk_rerps_artice”,”year”,”month”]

deletion_detection_rules[]

optional

Defines rulsets for a full data or partial data deletetion detection

→ deletion_detection_rules

very special features

content_enddate_columns[]

optional

List of column  pairs, where an addtional enddate processing should be applied (might be interesting, when modification dates of the source are relevant for queries)

 

max_history_depth

optional

depending on the implementation this will define a maximum depth of history in the satellite. Recommended thresholdtypes are: max_versions, max_valid_before_age

 

Stereotype Esat
json key

rules

function / description

example

satellite_parent_table

mandatory

Name of the link table, this satellite is connected to

raccn_account_department_lnk

tracked_field_groups

optional

list of field groups, this link will be processed for. The field groups must align with mappings of field that are used as businesskey in the hubs, the link of the esat is referring

 

driving_keys[]

optional

 

List of column names of the parent link, that are used as driving keys, to end former relations

[“hk_raccn_account”]

[“hk_rerps_artice”,”year”,”month”]

deletion_detection_rules[]

optional

Defines rulsets for a full data or partial data deletetion detection

→ deletion_detection_rules

max_history_depth

optional

depending on the implementation this will define a maximum depth of history in the satellite. Recommended thresholdtypes are: max_versions, max_valid_before_age

 

Stereotype ref
json key

rules

function / description

example

is_historized

optional, default= true

Defines, if the table will be historized by providing an enddate and using a diff hash

 

diff_hash_column_name

nearly mandatory when historized

Colum that contains the diff_hash (might be ommitted, when the implementation uses other methods, then a hash)

rh_country_iso_ref

deletion_detection
json key

rules

function / description

example

phase

mandatory

Declares the pipeline phase, the deletion detection will be applied. All other attributes depend on the phase (check out “phase definition for pipelines”)
“fetch” for the fetch phase
 “load” for the load phase 

load

<stereotype specific properties>

depend on phase

for details see next chapters

 

Phase “Fetch”
Properties for the deletion detection in the fetch phase highly depend on the source interface and implementation of the fetching module. The following properties are only suggestions

json key

rules

function / description

example

satellite_tables[]

must be declared in the model

Name of the satellite table

 

key_fields[]

must be declared in fields[]. The fields must be mapped to businesskeys of a parent of the satellite

Names of the fields, used to retrieve the list of still available keys in the source.  The modell mapping provides the necessary join relation to the satellite tables for determening the currently valid values in the vault.

load

Phase “load”
When the deletion detection is applied during the load phase, the followin properies must/may be set 

json key

rules

function / description

example

deletion_rules[]

mandatory

List of deletion rules, in case different satellites need different approaches

→ “load” deletion_rules[] 

“load” deletion_rules[]
json key

rules

function / description

example

rule_comment

optional

Name or short description of the rule. Enables more readable logging of exection progress and errors.

“All satellites of customer”

tables[]

mandatory

only declared satellite table names allowed

List of satellite table names, on wich to apply the deletion detection

“rsfdl_cusmomer_p1_sat”,”rsfdl_customer_p2_sat”

partitioning_fields[]

optional

only declared field names are allowed

List of fields (and therefore vault columns), that restrict the range of data. Only vault rows that are related to the available values in theses fields in the stage, will be checked and deleted, should they are missing in the stage.

“market_id”

join_path[]

optional

must begin with table containing at least one partitioning field

must contain all tables of the rule

Describes the join path in the model to get from the partitioning key to the direct parent of the tables, where deletion detection should be applied. Links will be represented by their Esat/Sat. Only in case of non historized links, the link itself can be declared here.

 

To detect deletion of all contract conditions of the delivered customers

“customer_hub”,”customer_contract_esat”,”contract_condition_esat”

Hash concat order rule declaration
For hub keys  and diff hashes
The order of the fields for concantenation during hashing can completly be controlled by using the prio_in_hash_key and prio_in_diff hash declaration in the target section.

Whithout declaration the order will be alphabetical with the target column name.

The priority attrbutes have a higher siginificanc then the column name. So defining a priority on every mapping gives full control.

For Link keys
Participation of fields in link keys is derived from the data model relations. An explicit declaration of the order is not yet possible, but will be added for edge cases later.

Until then, the main control over the order of hashing in the link key is by applying ordering rules.

There are various possibilities how to order the businesskeys of the multiple hubs / hub relations before concantenating them for hashing. Even though, not all execution engines might support the whole bandwidth, it should be defined in a standardizes way. Engines should reject unsupported patterns.

Since the hash rules are an essential part of the interface, the following declaration standard is defined
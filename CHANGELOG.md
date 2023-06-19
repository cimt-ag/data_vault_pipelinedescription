# release 0.6.0

### features
- stage schema must be declared now im stage_properties clause
- stage table name can be declared now in stage_properties clause, default is the name of the pipeline
- schema name and table are used in the DDL Generator utility script
- if the change detection uses a diff hash can not be switched with **uses_diff_hash** at the table and uses_diff_hash_default in the model profile
- #insert_criteria#

ATTENTION: You need to declare stage_properties with a stage_schema or will get a check error 

### DVPD syntax changes
- renamed "is_historized" to "is_enddated", since this reflects the behaviour much more precise. Providing diff hashes is another aspect an not bound to enddating
- renamed "target_column_name" to "column_name", following the naming concept, addressing the data vault objects as tables and columns 
- renamed "target_column_type" to "column_type", following the naming concept, addressing the data vault objects as tables and columns 
- renamed "stereotype" to "table_stereotype", for more clearance
- removed "esat" stereotype. Effectivity satellites are declared as sat having 0 mappings. They are only allowed on link parents.
- removed "msat" stereotype. Multiactive satellites are declared as sat with "is_multiactive":true 


### refactoring in compiler and resultset  
- renamed "target_table" to "table_name" (only relevant in compiler implementation and result tables)
- renamed "dv_column_class" to "column_class" (only relevant in compiler implementation and result tables)

# Release 0.5.4

### features
- table comments are now added to DDL Scripts
- Ordering of the stage table columns in the ddl, can now be adapted via configuration and more sorting
- job instance framework added for deployment

### bugfixes
- existence of field_type declaration is checked now
- existence of link parents is checked now
- process step generator corrected (no more unecessary steps)

### documentation
- apache license added
- documentation about the core syntax added

# Release 0.5.3

### bugfixes
- process plan for recursive link setting with field grouped esats is now correct

### code refactoring
- aligend deployment manager and jobless deployment to other project for better update compatibility
- added job instance framework to jobless for better compatibility to other projects
- renaming of jobless csv files list to allow copy paste into other projects 

# Release 0.5.2
- added "is_nullable" column to column result views (used for DDL Rendering)
- added utility Script to render Create table statements (not yet for xenc staging)
- jobless deployment can now be stopped explicitly when reaching a specific list file (usefull to leave out all automated tests)

# Release 0.5.1
- added "model profile" concept. 
You can now configure all basic definitions by changeing the "model profile" or add new profiles and chose the model per pipline. Check out the documentation and the "data_MODEL_PROFILE_DEFAULT.sql" script for a start.
The provided "default" model profile will generate the same content as the old "hard coded" version

## Known issues

- Due to introduction of the model profile, the amount of joins and lookups increased heavily. Querying some views at the "end of the foodchain" might take up to 30 seconds and more when 
all test are loaded into the database. 
__Workaround__: Don't load the tests. If already loaded you can remove it by deleting them from the dictionary table and run the load functions  

## Announcement

* multiactive satellite declaration will be changed in next version from explicit stereotype definition to simple properties of satellite (is_multiactive)

# Release 0.5.0
- added check about consistency of declaration from multiple fields to same target column
- essential support of cimt encryption concept, implemented as extention "xenc" (encryption of reference tables is missing)
- provide ordering information of tables and fields for consistent hash calculation
- added installation guide to the readme.md

## Encryption extention
The encryption extention provides the following features
* declaration of encryption key tables and mapping to the table with the encrypted data 
* derivation of necessary columns for the key tables depending on stereotype and partner
* derivation of processing steps and stage table structure to store the encryption keys
* addition of columns to the partner table (encryption key index for satellites) 
* addition of stage columns for the content in case of distribution of encrypted fields
over multiple target tables
* lots of checks about consistency of the declaration for encryption
* detailed information is provided in the [module documentation](https://cimtag.atlassian.net/wiki/spaces/CW/pages/3337879553/DVPD+-+cimt+encryption+extention+xenc)

# Release 0.4.1

- first elements  of extention to support cimt encryption added: Declaration of tables, adding columns to model. Currently missing: stage table for encryption tables, full test for fg processing and recursion processing
- driving key information is now available

# Release 0.4.0

## concept changes
- Attribute "technical_type" was renamed to "field_type"
- attribute "recursion_suffix" was renamed to "recursion_name"
- View "dvpd_dv_model_column" is replaced by "dpvd_pipeline_dv_column", providing also the pipeline name for filtering
- View "dvdp_pipeline_target_table" has been renamed to "dvpd_pipeline_dv_table"
- The unified model of all pipelines is now provided in "dvpd_dv_table" "dvpd_dv_column" and "dvpd_dv_link_parent"

### Parsing the json is now seperated from transformation logic
This concept is added to achieve portability of the transformation views to other database platforms.  The complex transformations now use only standard sql and rely on a relational model of the dvpd.  Loading the json to this relational model is implemented in the reference by using postgreSQL json functions but can easily be implemented with any other tool, capable of parsing json and writing to  tables.

Loading a dvpd json requires now 2 steps. 
- 1st insert the dvpd json to the dictionary table as usual
- 2nd trigger the parsing from json to the relational model by calling the function "dvpd_load_pipeline_to_raw(<name of the pipeline in dictionary)". Check out the examples in the testdata inserts.
To remove a pipeline from the system, the entiries for the pipeline must be deleted in all ..._raw tables. Currently this will happen automatically, since the load procedure removes and reloads all entries. This will be optimzed later.

## other enhancements
- jobless deployment csv lists are now provided in a seperate directory 
- jobless deployment is now tested against a database without the schema
- jobless deployment python code is now part of the project. (Deployment manager is extended to deploy tables and testcases)

## bugfixes
- Added missing Hash column views in 10_dvpd_deploy.csv



# Release 0.3.0
## new features
- automated tests for hash content mapping
- provide process list (changes some naming in HK)
- handling of recursion declaration and field groups is ok so far (needs more testing)

## refactoring
better naming for some elements

| old | better |
| -------------- | ------------------ |
| is_encrypted | needs_encryption |
| hierarchical | recursive |
| prio_in_hashkey | prio_in_key_hash |  

## bugfixes
- incompatbles usage of json_array_elements_text in a case clause in DVPD_PIPELINE_FIELD_TARGET_EXPANSION
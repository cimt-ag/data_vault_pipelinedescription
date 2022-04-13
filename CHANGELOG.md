
# Release 0.4.0

## concept changes
- Attribute "technical_type" was renamed to "field_type"
- attribute "recusion_suffix" was renamed to "recusion_name"
- dvpd json is now preparsed into a relational model. Loading a json requiers now 2 steps. 
1st Load json to dictionary table as usual, 2nd trigger the preparsing by calling function "dvpd_load_pipeline_to_raw(<name of the pipeline in dictionary)
- View "dvpd_dv_model_column" is replaced by "dpvd_pipeline_dv_column",providing also the pipeline name. The unified model of all pipeleins is now provided in"dvpd_dv_column"
- View "dvdp_pipeline_target_table" has been renamed to "dvpd_dv_table"

## bugfixes
- Added missing Hash column views in deployment.csv

## Annotation
The preparsed layer was added to make the reference implementation more portable. All complex transformations now is written on pure SQL Syntax without any json extention.  Parsing the json into the relational model is the only PostgreSQL specific code and can be replaced by any other method without any deep knowledge about the transformation


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
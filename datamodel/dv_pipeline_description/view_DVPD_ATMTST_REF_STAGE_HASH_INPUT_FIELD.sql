--drop view if exists dv_pipeline_description.DVPD_ATMTST_REF_STAGE_HASH_INPUT_FIELD;
create or replace view dv_pipeline_description.DVPD_ATMTST_REF_STAGE_HASH_INPUT_FIELD as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'stage_hash_input_field') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 process_block
	,table_row->>1 stage_column_name
	,table_row->>2 field_name
	,(table_row->>3)::int prio_in_hashkey
	,(table_row->>4)::int prio_in_diff_hash
from parsed_dvmodel_column 

);
 
 

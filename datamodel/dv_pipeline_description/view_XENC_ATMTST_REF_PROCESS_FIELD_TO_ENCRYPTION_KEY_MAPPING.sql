--drop view if exists dv_pipeline_description.XENC_ATMTST_REF_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING;
create or replace view dv_pipeline_description.XENC_ATMTST_REF_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'xenc_process_field_to_encryption_key_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 process_block
	,table_row->>1 field_name
	,table_row->>2 content_stage_column_name
	,table_row->>3 encryption_key_stage_column_name
	,cast(table_row->>4 as integer)  stage_map_rank
from parsed_dvmodel_column 

);
 
 

--drop view if exists dv_pipeline_description.XENC_ATMTST_REF_PROCESS_COLUMN_MAPPING;
create or replace view dv_pipeline_description.XENC_ATMTST_REF_PROCESS_COLUMN_MAPPING as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'xenc_process_column_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 table_name
	,table_row->>1 process_block
	,table_row->>2 column_name
	,table_row->>3 column_type
	,table_row->>4 dv_column_class
	,table_row->>5 stage_column_name
	,table_row->>6 content_stage_hash_column
	,table_row->>7 content_table_name
from parsed_dvmodel_column 

);
 
 

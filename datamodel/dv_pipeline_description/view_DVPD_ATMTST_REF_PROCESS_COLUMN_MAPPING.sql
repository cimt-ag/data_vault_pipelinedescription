--drop view if exists dv_pipeline_description.DVPD_ATMTST_REF_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_REF_STAGE_TABLE_COLUMN as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'process_column_mapping') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 table_name
	,table_row->>1 process_block
	,table_row->>2 column_name
	,table_row->>3 stage_column_name
	,table_row->>4 field_name
from parsed_dvmodel_column 

);
 
 

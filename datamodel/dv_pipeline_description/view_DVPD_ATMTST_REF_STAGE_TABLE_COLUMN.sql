--drop view if exists dv_pipeline_description.DVPD_ATMTST_REF_STAGE_TABLE_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_REF_STAGE_TABLE_COLUMN as (

with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'stage_table_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 stage_column_name
	,table_row->>1 column_type
	,(table_row->>2) :: int column_block
	,table_row->>3 field_name
	,table_row->>4 field_type
	,(table_row->>5) :: boolean encrypt 
from parsed_dvmodel_column 

);
 
 

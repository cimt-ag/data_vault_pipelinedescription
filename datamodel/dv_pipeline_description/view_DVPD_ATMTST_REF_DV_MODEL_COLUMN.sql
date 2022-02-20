--drop view if exists dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN;
create or replace view dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN as (
with parsed_dvmodel_column as (
select 
	pipeline_name 
	, json_array_elements(reference_data_json->'dv_model_column') table_row
from dv_pipeline_description.DVPD_ATMTST_REFERENCE
)
select 
	pipeline_name 
	,table_row->>0 table_name
	,(table_row->>1) :: int column_block
	,table_row->>2 dv_column_class
	,table_row->>3 column_name
	,table_row->>4 column_type
from parsed_dvmodel_column 
);
 
 
-- select * from dv_pipeline_description.DVPD_ATMTST_REF_DV_MODEL_COLUMN ddmc  order by 1,2,3,4,5;

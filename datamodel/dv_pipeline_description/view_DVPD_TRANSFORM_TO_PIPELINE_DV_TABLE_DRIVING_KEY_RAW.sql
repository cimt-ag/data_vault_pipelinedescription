--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_DRIVING_KEY_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_DRIVING_KEY_RAW as 

with data_vault_schema_basics as (
select 
dvpd_json ->>'pipeline_name' as pipeline_name
, json_array_elements(dvpd_json->'data_vault_model')->'tables' as tables
from dv_pipeline_description.dvpd_dictionary dt 
)
, table_expansion as (
	select
	pipeline_name
	, json_array_elements(tables)->>'table_name'  as table_name
	, json_array_elements(tables)->'driving_keys' as driving_keys
	from data_vault_schema_basics
	)
select 
 pipeline_name 
, table_name
, json_array_elements_text(driving_keys) driving_key
from table_expansion;

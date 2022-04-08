--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_TARGET_TABLE_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_TARGET_TABLE_RAW as 

with data_vault_schema_basics as (
	select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	, json_array_elements(dvpd_json->'data_vault_model')->>'schema_name' as schema_name
	, json_array_elements(dvpd_json->'data_vault_model')->'tables' as tables
	from dv_pipeline_description.dvpd_dictionary dt 
)
select
pipeline_name
, schema_name
, json_array_elements(tables)->>'table_name'  as table_name
, json_array_elements(tables)->>'stereotype' as stereotype
, json_array_elements(tables)->>'hub_key_column_name' as hub_key_column_name
, json_array_elements(tables)->>'link_key_column_name' as link_key_column_name
, json_array_elements(tables)->>'diff_hash_column_name' as diff_hash_column_name
, json_array_elements(tables)->>'satellite_parent_table' as satellite_parent_table
, json_array_elements(tables)->>'is_link_without_sat' as is_link_without_sat
, json_array_elements(tables)->>'is_historized' as is_historized 
from data_vault_schema_basics
;


drop view if exists dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE as 

with data_vault_schema_basics as (
select 
dvpd_json ->>'pipeline_name' as pipeline
, json_array_elements(dvpd_json->'data_vault_model')->>'schema_name' as schema_name
, json_array_elements(dvpd_json->'data_vault_model')->'tables' as tables
from dv_pipeline_description.dvpd_dictionary dt 
)
select 
 lower(pipeline) as pipeline
, lower(schema_name) as schema_name
, lower(table_name) as table_name
, lower(stereotype) as stereotype
, upper(hub_key_column_name)  as hub_key_column_name
, upper(link_key_column_name) as link_key_column_name
, upper(diff_hash_column_name) as diff_hash_column_name
, lower(satellite_parent_table) as satellite_parent_table
, link_parent_tables
, hierarchical_parents
, driving_keys
, tracked_field_groups
, coalesce(is_link_without_sat::bool,false) as is_link_without_sat
, coalesce(is_historized ::bool,true) as is_historized 
from (
	select
	pipeline
	, schema_name
	, json_array_elements(tables)->>'table_name'  as table_name
	, json_array_elements(tables)->>'stereotype' as stereotype
	, json_array_elements(tables)->>'hub_key_column_name' as hub_key_column_name
	, json_array_elements(tables)->>'link_key_column_name' as link_key_column_name
	, json_array_elements(tables)->>'diff_hash_column_name' as diff_hash_column_name
	, json_array_elements(tables)->>'satellite_parent_table' as satellite_parent_table
	, json_array_elements(tables)->'link_parent_tables' as link_parent_tables
	, json_array_elements(tables)->'hierarchical_parents' as hierarchical_parents
	, json_array_elements(tables)->'driving_keys' as driving_keys
	, json_array_elements(tables)->'tracked_field_groups' as tracked_field_groups
	, json_array_elements(tables)->>'is_link_without_sat' as is_link_without_sat
	, json_array_elements(tables)->>'is_historized' as is_historized 
	from data_vault_schema_basics
) json_parsed
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE ;
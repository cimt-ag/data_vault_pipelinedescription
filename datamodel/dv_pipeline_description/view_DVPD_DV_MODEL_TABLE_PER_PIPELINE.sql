drop view dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE cascade;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE as 
with data_vault_schema_basics as (
select 
dvpd_json ->>'pipeline_name' as pipeline
, json_array_elements(dvpd_json->'data_vault_modell')->>'schema_name' as schema_name
, json_array_elements(dvpd_json->'data_vault_modell')->'tables' as tables
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
, driving_hub_keys
, tracked_field_groups
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
	, json_array_elements(tables)->'driving_hub_keys' as driving_hub_keys
	, json_array_elements(tables)->'tracked_field_groups' as tracked_field_groups
	from data_vault_schema_basics
) json_parsed
;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE ;
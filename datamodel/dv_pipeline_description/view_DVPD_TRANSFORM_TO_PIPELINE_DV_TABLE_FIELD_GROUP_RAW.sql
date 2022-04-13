--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_FIELD_GROUP_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_FIELD_GROUP_RAW as 

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
	, json_array_elements(tables)->'tracked_field_groups' as tracked_field_groups
	from data_vault_schema_basics
	)
select 
 pipeline_name 
, table_name
, json_array_elements_text(tracked_field_groups) field_group
from table_expansion;

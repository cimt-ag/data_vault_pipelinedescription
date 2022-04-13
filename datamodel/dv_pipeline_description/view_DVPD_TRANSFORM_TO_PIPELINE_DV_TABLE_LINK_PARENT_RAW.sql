--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_FIELD_GROUP_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_LINK_PARENT_RAW as 

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
	, json_array_elements(tables)->'link_parent_tables' as link_parent_tables
	, json_array_elements(tables)->'recursive_parents' as recursive_parents
	from data_vault_schema_basics
	)
,  link_parent_tables as (
	select
	pipeline_name
	,  table_name
	, json_array_elements_text(link_parent_tables) as parent_table_name
	, false is_recursive_relation
	, null::text recursion_name
	from table_expansion
	)	
,  recursive_parent_tables as (
	select
	pipeline_name
	,  table_name
	, json_array_elements(recursive_parents)->>'table_name' as parent_table_name
	, true is_recursive_relation
	, json_array_elements(recursive_parents)->>'recursion_suffix' as recursion_name
	from table_expansion
	)	
select * from  link_parent_tables
union
select * from  recursive_parent_tables;

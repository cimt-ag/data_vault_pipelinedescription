-- drop view if exists dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT as 

with normalized_link_parents as (
	select 
		table_name
		,json_array_elements_text(link_parent_tables) link_parent_table
	from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE
) 
, normalized_recursive_parents as (
	select 
		table_name
		,json_array_elements(recursive_parents)->>'table_name'::text as link_parent_table
		,upper(json_array_elements(recursive_parents)->>'recursion_suffix')::text as recursion_suffix
	from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE
)
select distinct 
	nlp.table_name
	,link_parent_table parent_table_name
	,hub_key_column_name as hub_key_column_name
	,hub_key_column_name as parent_hub_key_column_name
	,false as is_recursive_relation
	,'' as recursion_suffix
from normalized_link_parents nlp 
join dv_pipeline_description.DVPD_DV_MODEL_TABLE mt on mt.table_name=link_parent_table
union 
select distinct 
	nlp.table_name
	,link_parent_table parent_table_name
	,hub_key_column_name || '_'||upper(recursion_suffix) as hub_key_column_name
	,hub_key_column_name as parent_hub_key_column_name
	,true as is_recursive_relation
	,coalesce(recursion_suffix,'') recursion_suffix
from normalized_recursive_parents nlp 
join dv_pipeline_description.DVPD_DV_MODEL_TABLE mt on mt.table_name=link_parent_table
;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT;
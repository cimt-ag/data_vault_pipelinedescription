-- drop view if exists dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT as 

with normalized_link_parents as (
	select 
		table_name
		,parent_table_name  link_parent_table
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
	where not is_recursive_relation 
) 
, normalized_recursive_parents as (
	select 
		table_name
		,parent_table_name  link_parent_table
		,recursion_name  as recursion_suffix
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
	where is_recursive_relation 
)
select distinct 
	lower(nlp.table_name) table_name
	,lower(link_parent_table) parent_table_name
	,hub_key_column_name as hub_key_column_name
	,hub_key_column_name as parent_hub_key_column_name
	,false as is_recursive_relation
	,'' as recursion_suffix
from normalized_link_parents nlp 
join dv_pipeline_description.DVPD_DV_MODEL_TABLE mt on mt.table_name=link_parent_table
union 
select distinct 
	lower(nlp.table_name) table_name
	,lower(link_parent_table) parent_table_name
	,hub_key_column_name || '_'||upper(recursion_suffix) as hub_key_column_name
	,hub_key_column_name as parent_hub_key_column_name
	,true as is_recursive_relation
	,coalesce(upper(recursion_suffix),'') recursion_suffix
from normalized_recursive_parents nlp 
join dv_pipeline_description.DVPD_DV_MODEL_TABLE mt on mt.table_name=link_parent_table
;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT;
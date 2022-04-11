-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT as 

with normalized_link_parents as (
	select 
		lower(pipeline_name ) pipeline_name
		,lower(table_name)  table_name
		,lower(parent_table_name)  link_parent_table
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
	where not is_recursive_relation 
) 
, normalized_recursive_parents as (
	select 
		lower(pipeline_name )  pipeline_name
		,lower(table_name) table_name
		,lower(parent_table_name)  link_parent_table
		,upper(recursion_name)  as recursion_suffix
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
	where is_recursive_relation 
)
select distinct 
	lower(nlp.pipeline_name ) pipeline_name
	,lower(nlp.table_name) table_name
	,lower(nlp.link_parent_table) parent_table_name
	,pdmt.hub_key_column_name as hub_key_column_name
	,pdmt.hub_key_column_name as parent_hub_key_column_name
	,false as is_recursive_relation
	,'' as recursion_suffix
from normalized_link_parents nlp 
join dv_pipeline_description.DVPD_PIPELINE_DV_TABLE pdmt on pdmt.table_name=nlp.link_parent_table
														and pdmt.pipeline_name = nlp.pipeline_name 
union 
select distinct 
	lower(nrp.pipeline_name ) pipeline_name
	,lower(nrp.table_name) table_name
	,lower(nrp.link_parent_table) parent_table_name
	,pdmt.hub_key_column_name || '_'||upper(recursion_suffix) as hub_key_column_name
	,pdmt.hub_key_column_name as parent_hub_key_column_name
	,true as is_recursive_relation
	,coalesce(upper(nrp.recursion_suffix),'') recursion_suffix
from normalized_recursive_parents nrp 
join dv_pipeline_description.DVPD_PIPELINE_DV_TABLE pdmt on pdmt.table_name=nrp.link_parent_table
														and pdmt.pipeline_name = nrp.pipeline_name 
;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT;
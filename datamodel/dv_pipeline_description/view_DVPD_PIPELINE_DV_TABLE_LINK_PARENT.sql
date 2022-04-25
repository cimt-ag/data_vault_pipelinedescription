-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT as 

with cleansed_link_parents as (
	select 
		lower(pipeline_name ) pipeline_name
		,lower(table_name)  table_name
		,lower(parent_table_name)  link_parent_table
		,is_recursive_relation 
		,coalesce(upper(recursion_name),'') recursion_name
		,link_parent_order 
		,recursive_parent_order 
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
) 
select distinct 
	clp.pipeline_name 
	,clp.table_name
	,clp.link_parent_table
	,pdmt.hub_key_column_name as hub_key_column_name
	,is_recursive_relation
	,recursion_name
	,link_parent_order 
	,recursive_parent_order 
from cleansed_link_parents clp 
join dv_pipeline_description.DVPD_PIPELINE_DV_TABLE pdmt on pdmt.table_name=clp.link_parent_table
														and pdmt.pipeline_name = clp.pipeline_name ;

-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_LINK_PARENT;
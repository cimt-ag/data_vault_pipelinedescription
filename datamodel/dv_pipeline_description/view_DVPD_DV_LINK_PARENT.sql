--drop view if exists dv_pipeline_description.DVPD_DV_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_DV_LINK_PARENT as 

SELECT
	DISTINCT 
 	table_name,
	link_parent_table,
	case when is_recursive_relation then hub_key_column_name||'_'||recursion_name 
			else hub_key_column_name end hub_key_column_name_in_link,
	parent_hub_key_column_name,
	is_recursive_relation,
	recursion_name
FROM
	dv_pipeline_description.dvpd_pipeline_dv_table_link_parent;


-- select * From dv_pipeline_description.DVPD_DV_LINK_PARENT;



drop view if exists dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT cascade;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT as 

with normalized_link_parents as (
	select 
		table_name
		,json_array_elements_text(link_parent_tables) link_parent_table
	from dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE
) 
select distinct 
	nlp.table_name
	,link_parent_table parent_table_name
	,hub_key_column_name as parent_hub_key_column_name
from normalized_link_parents nlp 
join dv_pipeline_description.DVPD_DV_MODEL_TABLE mt on mt.table_name=link_parent_table;

-- select * from dv_pipeline_description.DVPD_DV_MODEL_LINK_PARENT;
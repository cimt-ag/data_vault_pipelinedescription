drop view if exists dv_pipeline_description.DVPD_DV_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_DV_TABLE as 

select distinct 
	schema_name
	,table_name
	,stereotype
	,hub_key_column_name
	,link_key_column_name
	,diff_hash_column_name
	,satellite_parent_table 
	,is_link_without_sat
	,is_historized
from dv_pipeline_description.dvpd_pipeline_dv_table;

-- select * From dv_pipeline_description.DVPD_DV_MODEL_TABLE;


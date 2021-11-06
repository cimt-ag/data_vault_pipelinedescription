drop view dv_pipeline_description.DVPD_DV_MODEL_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_DV_MODEL_TABLE as 
select distinct 
schema_name
,table_name
,stereotype
,hub_key_column_name
,link_key_column_name
,diff_hash_column_name
,satellite_parent_table from dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE ;



--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_TABLE as 

select 
 lower(pipeline_name) as pipeline_name 
, lower(schema_name) as schema_name
, lower(table_name) as table_name
, lower(stereotype) as stereotype
, upper(hub_key_column_name)  as hub_key_column_name
, upper(link_key_column_name) as link_key_column_name
, upper(diff_hash_column_name) as diff_hash_column_name
, lower(satellite_parent_table) as satellite_parent_table
, coalesce(is_link_without_sat::bool,false) as is_link_without_sat
, coalesce(is_historized ::bool,true) as is_historized 
, '_default'::text as data_vault_model_profile_name -- will be configurable later
from dv_pipeline_description.dvpd_pipeline_dv_table_raw
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_TABLE ;
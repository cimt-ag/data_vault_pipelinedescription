drop view if exists dv_pipeline_description.DVPD_DV_MODEL_PARENT_BUSINESS_KEY_COLUMN cascade;

create or replace view dv_pipeline_description.DVPD_DV_MODEL_PARENT_BUSINESS_KEY_COLUMN as 

with leaf_targets as (
	select table_name , satellite_parent_table 
	from dv_pipeline_description.dvpd_dv_model_table_per_pipeline 
	where stereotype in('sat','msat','esat') or is_link_without_sat
	)
select lt.table_name leaf_table_name, lt.satellite_parent_table businesskey_table_name,mc.vault_column_name 
from leaf_targets lt
join dv_pipeline_description.dvpd_dv_model_column mc on mc.table_name=lt.satellite_parent_table
													and mc.dv_column_class ='business_key'
union 
select lt.table_name leaf_table_name, mc.table_name businesskey_table_name,mc.vault_column_name 
from leaf_targets lt
join dv_pipeline_description.dvpd_dv_model_link_parent mlp on mlp.table_name =lt.satellite_parent_table
join dv_pipeline_description.dvpd_dv_model_column mc on mc.table_name=mlp.parent_table_name
													and mc.dv_column_class ='business_key';
												
-- select * from dv_pipeline_description.DVPD_DV_MODEL_PARENT_BUSINESS_KEY_COLUMN order by 1,2,3;										

drop view if exists dv_pipeline_description.DVPD_PIPELINE_TO_DV_COLUMN_MAPPING cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_TO_DV_COLUMN_MAPPING as 

with dv_key_columns as (
select table_name ,vault_column_name ,dv_column_class,column_block 
from dv_pipeline_description.dvpd_dv_model_column ddmc 
where ddmc.dv_column_class not in ('meta')
)
select distinct pipeline 
	,field_group 
	,target_table 
	,case when field_group = '##all##' OR dv_column_class not in ('key','parent_key','diff_hash')   then dkl.vault_column_name
	else dkl.vault_column_name||'___'||UPPER(field_group) END stage_column_name
	,dkl.vault_column_name 
	,dv_column_class
	,column_block 
from dv_pipeline_description.dvpd_source_field_mapping dsfm 
join dv_key_columns dkl on dkl.table_name = dsfm.target_table 
order by pipeline ,field_group,target_table ,column_block ,dv_column_class ;





												
-- select * from ;										

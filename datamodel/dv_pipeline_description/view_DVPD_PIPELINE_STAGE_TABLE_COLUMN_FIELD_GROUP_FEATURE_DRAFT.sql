--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN_FIELD_GROUP_FEATURE_DRAFT cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN_FIELD_GROUP_FEATURE_DRAFT as

#not working

select distinct 
	plap.pipeline 
	,case when mc.column_type  in('key','hash_diff') and  sfm.field_group<>'_A_'  then 
			 mc.column_name||'__'||sfm.field_group
			 else coalesce (sfm.field_name,mc.column_name ) end  stage_column_name
	,mc.column_type 
	,min(mc.column_block)
	,sfm.field_name 
	,sfm.field_type 
	,coalesce(sfm.is_encrypted ,false) encrypt
from dv_pipeline_description.dvpd_pipeline_leaf_and_process_table plap 
join dv_pipeline_description.dvpd_dv_model_column mc on mc.table_name = plap.table_to_process 
													 and mc.dv_column_class not in ('meta')
left join dv_pipeline_description.dvpd_source_field_mapping sfm on sfm.target_table = plap.table_to_process 	
														  and sfm.target_column_name =mc.column_name 
group by 1,2,3,5,6,7;

														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN_FIELD_GROUP_FEATURE_DRAFT order by pipeline,column_block ,stage_column_name 										
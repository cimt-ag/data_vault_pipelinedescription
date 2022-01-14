--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN as 

select distinct 
	plap.pipeline 
	,coalesce (sfm.field_name,mc.vault_column_name ) stage_column_name
	,mc.column_type 
	,mc.column_block 
	,sfm.field_name 
	,sfm.field_type 
	,sfm.is_encrypted encrypt
from dv_pipeline_description.dvpd_pipeline_leaf_and_process_table plap 
join dv_pipeline_description.dvpd_dv_model_column mc on mc.table_name = plap.table_to_process 
													 and mc.dv_column_class not in ('meta')
left join dv_pipeline_description.dvpd_source_field_mapping sfm on sfm.target_table = plap.table_to_process 	
														  and sfm.target_column_name =mc.vault_column_name ;

														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_TABLE_COLUMN order by pipeline,column_block ,stage_column_name 										
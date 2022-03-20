--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD cascade;


create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD as

with target_hash_columns as (
	select  pipeline
		,process_block 
		,stage_column_name 
		,table_name 
		,column_name 
		,hierarchy_key_suffix 
	from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm_key
	where dv_column_class in ('key','diff_hash')
)
select distinct
 thc.pipeline 
 ,thc.process_block 
 ,thc.stage_column_name 
 ,ppstdmm.field_name
 ,ppstdmm.prio_in_hashkey 
 ,ppstdmm.prio_in_diff_hash  
from target_hash_columns  thc
join dv_pipeline_description.dvpd_dv_model_hash_input_column dmhic on dmhic.table_name =thc.table_name 
																  and dmhic.key_column =thc.column_name 
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline =thc.pipeline 
					and (ppstdmm.process_block = thc.process_block 	
					or (ppstdmm.hierarchy_key_suffix =dmhic.hierarchy_key_suffix 
					and thc.process_block = '_A_'))
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
; 

														 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD order by pipeline,process_block ,stage_column_name,field_name 										
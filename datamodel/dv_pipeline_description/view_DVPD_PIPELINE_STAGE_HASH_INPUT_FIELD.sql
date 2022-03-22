--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD cascade;


create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD as

with target_hash_columns as (
	select  pipeline
		,process_block 
		,field_group 
		,recursion_suffix 
		,stage_column_name 
		,table_name 
		,stereotype
		,column_name 
		,dv_column_class 
	from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm_key
	where dv_column_class in ('key','diff_hash')
)
, fields_for_link_key_hashes as (
select distinct
 thc.pipeline 
 ,thc.process_block 
 ,thc.stage_column_name 
 ,ppstdmm.field_name
 ,ppstdmm.field_group 
 ,ppstdmm.prio_in_hashkey 
 ,ppstdmm.prio_in_diff_hash  
 ,ppstdmm.recursion_suffix 
 ,dmhic.content_column 
 ,dmhic.content_recursion_suffix 
from target_hash_columns  thc
join dv_pipeline_description.dvpd_dv_model_hash_input_column dmhic on dmhic.table_name =thc.table_name 
																  and dmhic.key_column =thc.column_name 
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline =thc.pipeline 
					and ppstdmm.field_group = thc.field_group 	
					and ppstdmm.recursion_suffix =dmhic.content_recursion_suffix 
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
where thc.stereotype  ='lnk' 
)
, fields_for_not_link_key_hashes as (
select distinct
 thc.pipeline 
 ,thc.process_block 
 ,ppstdmm.process_block field_pb
 ,thc.field_group 
 ,ppstdmm.field_group  field_fg
 ,thc.stage_column_name 
 ,ppstdmm.field_name
 ,ppstdmm.prio_in_hashkey 
 ,ppstdmm.prio_in_diff_hash  
 ,ppstdmm.recursion_suffix 
 ,dmhic.content_column 
 ,dmhic.content_recursion_suffix 
from target_hash_columns  thc
join dv_pipeline_description.dvpd_dv_model_hash_input_column dmhic on dmhic.table_name =thc.table_name 
																  and dmhic.key_column =thc.column_name 
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline =thc.pipeline 
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
					and ppstdmm.process_block = thc.process_block     
where thc.stereotype  !='lnk' 
)
select 
 pipeline 
 ,process_block 
 ,stage_column_name 
 ,field_name
 ,field_group 
 ,prio_in_hashkey 
 ,prio_in_diff_hash  
 ,recursion_suffix 
 ,content_column 
 ,content_recursion_suffix
 from fields_for_link_key_hashes
 union 
select 
 pipeline 
 ,process_block 
 ,stage_column_name 
 ,field_name
 ,field_group 
 ,prio_in_hashkey 
 ,prio_in_diff_hash  
 ,recursion_suffix 
 ,content_column 
 ,content_recursion_suffix
 from fields_for_not_link_key_hashes
; 


													 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD order by pipeline,process_block ,stage_column_name,field_name 										
--drop view if exists dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD as


select distinct 
	eppstemm.pipeline_name,
	eppstemm.process_block,
	eppstemm.stage_column_name,
	eppstemm.dv_column_class ,
	field_name,
	field_group,
	prio_in_key_hash,
	prio_in_diff_hash,
	recursion_name,
	content_column,
	content_recursion_name,
	link_parent_order,
	recursive_parent_order
from  dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping eppstemm
join dv_pipeline_description.dvpd_pipeline_stage_hash_input_field pshif on pshif.pipeline_name = eppstemm.pipeline_name 
																		and pshif.stage_column_name = eppstemm .content_stage_hash_column  
														 
-- select * from dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD order by pipeline
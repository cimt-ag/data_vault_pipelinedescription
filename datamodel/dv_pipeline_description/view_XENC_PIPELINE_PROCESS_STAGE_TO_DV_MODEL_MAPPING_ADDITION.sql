--drop view if exists dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION as 

-- EKI columns for satellites
select 	base .pipeline_name,
	base .process_block,
	base .table_name,
	base .stereotype,
	base .column_name,
	base .dv_column_class,
	base .stage_column_name,
	base .column_type,
	base .column_block,
	base .field_group,
	base .recursion_name,
	base .field_name,
	base .field_type,
	base .needs_encryption,
	base .prio_in_key_hash,
	base .prio_in_diff_hash
from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE	base																	
where dv_column_class like 'xenc_%'	and stereotype in ('sat','msat')
union
-- additional stage columns for encrypted fields, that are distributed to more then one table
select
	base .pipeline_name,
	base .process_block,
	base .table_name,
	base .stereotype,
	base .column_name,
	base .dv_column_class,
	xenc .content_stage_column_name  stage_column_name,
	base .column_type,
	base .column_block,
	base .field_group,
	base .recursion_name,
	base .field_name,
	base .field_type,
	base .needs_encryption,
	base .prio_in_key_hash,
	base .prio_in_diff_hash
from dv_pipeline_description.xenc_pipeline_process_field_to_encryption_key_mapping xenc
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_base base 
												on base .pipeline_name = xenc .pipeline_name 
												and base .process_block  = xenc .process_block 
												and base.table_name = xenc.content_table_name 
												and base .field_name = xenc.field_name 
												and base.stage_column_name = xenc.origin_content_stage_column_name 
where xenc.stage_map_rank >1			
;


-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION order by pipeline,table_name,process_block;										

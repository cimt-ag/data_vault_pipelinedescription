--drop view if exists dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION as 

select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE																		
where dv_column_class like 'xenc_%'	and stereotype in ('sat','msat');

-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION order by pipeline,table_name,process_block;										

--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING as 

select * from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_core
union
select * from dv_pipeline_description.xenc_pipeline_process_stage_to_dv_model_mapping_addition
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING order by pipeline,table_name,process_block;										

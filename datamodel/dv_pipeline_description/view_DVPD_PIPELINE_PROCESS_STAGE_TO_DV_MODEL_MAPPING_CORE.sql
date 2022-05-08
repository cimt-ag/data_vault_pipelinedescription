--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_CORE cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_CORE as 

select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE																		
where (dv_column_class in ('meta','key','parent_key','diff_hash') or field_name is not null	)
and stereotype not like 'x%'; -- exclude table stereotypes from extentions

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE order by pipeline,table_name,process_block;										

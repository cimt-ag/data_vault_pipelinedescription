--drop view if exists dv_pipeline_description.XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING as 

with field_to_key_derivation as (
select ppstdmmb.pipeline_name 
	,ppstdmmb.process_block 
	,ppstdmmb.field_name 
	,ppstdmmb.stage_column_name content_stage_column_name
	,ppstdmmb.table_name 
	,ppstdmmb.column_name
	,pdtp.table_name encryption_key_table_name
	,pstemm.stage_column_name   encryption_key_stage_column_name
	,rank() over (partition by  ppstdmmb .pipeline_name ,ppstdmmb .stage_column_name  order by ppstdmmb .table_name  ) stage_map_rank
from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE ppstdmmb 
join dv_pipeline_description.dvpd_pipeline_field_properties pfp on pfp.pipeline = ppstdmmb .pipeline_name 
																and pfp.field_name = ppstdmmb.field_name 
																and pfp.needs_encryption
join dv_pipeline_description.xenc_pipeline_dv_table_properties	pdtp on pdtp.pipeline_name = ppstdmmb .pipeline_name 
																	and pdtp.xenc_content_table_name = ppstdmmb .table_name 
join dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping pstemm 
															on pstemm.pipeline_name =ppstdmmb.pipeline_name 
															and pstemm.table_name = pdtp .table_name 
															and pstemm.process_block = ppstdmmb.process_block 
															and pstemm.dv_column_class ='xenc_encryption_key'													
)
Select -- final view with extended stage column name
	pipeline_name 
	,process_block 
	,field_name 
	,case when stage_map_rank>1 then  content_stage_column_name||'_XENC'||stage_map_rank 
			else content_stage_column_name end content_stage_column_name
	,table_name content_table_name 
	,column_name content_column_name
	,encryption_key_table_name
	,encryption_key_stage_column_name
	,stage_map_rank
from field_to_key_derivation

-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION order by pipeline,table_name,process_block;										

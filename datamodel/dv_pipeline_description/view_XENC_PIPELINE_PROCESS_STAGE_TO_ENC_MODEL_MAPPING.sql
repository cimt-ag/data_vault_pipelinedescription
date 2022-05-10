--drop view if exists dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING as 

with expanded_xenc_table_properties as (
select epdtp.pipeline_name
	,epdtp.table_name
	,pdt.stereotype
	,ppp.process_block 
	,epdtp.xenc_content_hash_column_name
	,epdtp.xenc_content_salted_hash_column_name
	,epdtp.xenc_content_table_name
	,epdtp.xenc_encryption_key_column_name
	,epdtp.xenc_encryption_key_index_column_name
	,epdtp.xenc_diff_hash_column_name
	,epdtp.xenc_table_key_column_name
	,ppp.field_group 
	,ppp.recursion_name 
from dv_pipeline_description.xenc_pipeline_dv_table_properties epdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name 
														and pdt.table_name = epdtp .table_name
join dv_pipeline_description.dvpd_pipeline_process_plan ppp on ppp.pipeline_name =epdtp.pipeline_name 
														    and ppp.table_name = epdtp.xenc_content_table_name 
where pdt.stereotype like 'xenc%'
)
select 
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.process_block 
 ,pdc.column_name 
 ,pdc.column_type 
 ,pdc.column_block 
 ,dv_column_class
 ,related_dv_column
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name 
union 
select 
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.process_block 
 ,pdc.column_name 
 ,pdc.column_block 
 ,dv_column_class
 ,related_column
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name 
										
										
									


-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION order by pipeline,table_name,process_block;										

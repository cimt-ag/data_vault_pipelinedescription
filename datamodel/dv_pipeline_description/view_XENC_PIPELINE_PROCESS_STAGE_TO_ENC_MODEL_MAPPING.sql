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
select -- columns with same name in every process block
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.process_block 
 ,pdc.column_name 
 ,pdc.column_type 
 ,pdc.column_block 
 ,dv_column_class
 ,null related_stage_hash_column
 ,null related_hash_column
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name 
where dv_column_class  in ('meta','xenc_encryption_key_index')
union 
select -- encryption table columns referring to hash columns
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.process_block 
 ,case when extp.process_block ='_A_' then pdc.column_name 
 	  else pdc.column_name||extp.process_block  end column_name
  ,pdc.column_type 
 ,pdc.column_block 
 ,pdc.dv_column_class
 ,pstdmmb.stage_column_name  related_stage_hash_column
 ,pstdmmb.column_name  related_hash_column
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name 
left join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_base pstdmmb								
										on pstdmmb.pipeline_name = pdc.pipeline_name 
										and pstdmmb.table_name = extp.xenc_content_table_name 
										and pstdmmb.process_block = extp.process_block 
where (pdc.dv_column_class in ('key','xenc_bk_hash','xenc_bk_salted_hash', 'xenc_dc_hash','xenc_dc_salted_hash')
		and pstdmmb.dv_column_class in ('key','parent_key'))
		or 
		(pdc.dv_column_class in ('diff_hash')
		and pstdmmb.dv_column_class = 'diff_hash')
;

-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING order by pipeline,table_name,process_block;										

-- =====================================================================
-- Part of the Data Vault Pipeline Description Reference Implementation
--
-- Copyright 2023 Matthias Wegner mattywausb@gmail.com
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =====================================================================


--drop view if exists dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING as 

with expanded_xenc_table_properties as (
select epdtp.pipeline_name
	,epdtp.table_name
	,pdt.table_stereotype
	,ppp.relation_to_process 
	,epdtp.xenc_content_hash_column_name
	,epdtp.xenc_content_salted_hash_column_name
	,epdtp.xenc_content_table_name
	,epdtp.xenc_encryption_key_column_name
	,epdtp.xenc_encryption_key_index_column_name
	,epdtp.xenc_diff_hash_column_name
	,epdtp.xenc_table_key_column_name
from dv_pipeline_description.xenc_pipeline_dv_table_properties epdtp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = epdtp.pipeline_name 
														and pdt.table_name = epdtp .table_name
join dv_pipeline_description.dvpd_pipeline_process_plan ppp on ppp.pipeline_name =epdtp.pipeline_name 
														    and ppp.table_name = epdtp.xenc_content_table_name 
where pdt.table_stereotype like 'xenc%'
--and epdtp.pipeline_name like 'xenc%22%' -- for debugging
)
select -- columns with same name in every process block
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.relation_to_process 
 ,pdc.column_name  
 ,pdc.column_name stage_column_name 
 ,pdc.column_type 
 ,pdc.column_block 
 ,column_class
 ,null content_stage_hash_column
 ,null content_table_name
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name 
where column_class  in ('meta','xenc_encryption_key_index')
union
select -- encryption key columns for every relation_to_process 
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.relation_to_process 
 ,pdc.column_name  
 ,case when extp.relation_to_process ='/' then pdc.column_name 
 	  else pdc.column_name||extp.relation_to_process  
 	  end  as stage_column_name
  ,pdc.column_type 
 ,pdc.column_block 
 ,pdc.column_class
 ,null  content_stage_hash_column
 ,null content_table_name
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name
where (pdc.column_class in ('xenc_encryption_key'))										
union 
select -- encryption table columns referring to process block specific hash columns
 pdc.pipeline_name 
 ,pdc.table_name 
 ,extp.relation_to_process 
 ,pdc.column_name  
 ,case when extp.relation_to_process ='/' then pdc.column_name 
 	  else pdc.column_name||extp.relation_to_process  
 	  end  as stage_column_name
  ,pdc.column_type 
 ,pdc.column_block 
 ,pdc.column_class
 ,pstdmmb.stage_column_name  content_stage_hash_column
 ,extp.xenc_content_table_name content_table_name
from dv_pipeline_description.dvpd_pipeline_dv_column pdc
join expanded_xenc_table_properties extp on extp.pipeline_name = pdc.pipeline_name  
										and extp.table_name = pdc.table_name 
left join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_base pstdmmb								
										on pstdmmb.pipeline_name = pdc.pipeline_name 
										and pstdmmb.table_name = extp.xenc_content_table_name 
										and pstdmmb.relation_to_process = extp.relation_to_process 
where (pdc.column_class in ('key','xenc_bk_hash','xenc_bk_salted_hash', 'xenc_dc_hash','xenc_dc_salted_hash')
		and ((pstdmmb.table_stereotype in ('hub','lnk') and  pstdmmb.column_class = 'key') 
				or (pstdmmb.table_stereotype not in ('hub','lnk') and  pstdmmb.column_class = 'parent_key')))
		or 
		(pdc.column_class in ('diff_hash')
		and pstdmmb.column_class = 'diff_hash')
--order by table_name ,column_block,column_name -- for debugging
;

comment on view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING is
 '[Encryption Extention] Derived mapping of columns, that will be loaded to the encryption key store (ENC_MODEL)';

-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_ENC_MODEL_MAPPING order by pipeline,table_name,process_block;										

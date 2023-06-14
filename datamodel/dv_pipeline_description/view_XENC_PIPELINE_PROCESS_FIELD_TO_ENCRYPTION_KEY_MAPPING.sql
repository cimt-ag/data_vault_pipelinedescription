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
															and pstemm.column_class ='xenc_encryption_key'													
)
Select -- final view with extended stage column name
	pipeline_name 
	,process_block 
	,field_name 
	,case when stage_map_rank>1 then  content_stage_column_name||'_XENC'||stage_map_rank 
			else content_stage_column_name end content_stage_column_name
	,content_stage_column_name origin_content_stage_column_name
	,table_name content_table_name 
	,column_name content_column_name
	,encryption_key_table_name
	,encryption_key_stage_column_name
	,stage_map_rank
from field_to_key_derivation
;

comment on view dv_pipeline_description.XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING is
 '[Encryption Extention] Derivation of column combination for encryption depending on the process block';

-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_FIELD_TO_ENCRYPTION_KEY_MAPPING order by pipeline_name,process_block,field_name;										

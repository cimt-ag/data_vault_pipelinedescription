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


--drop view if exists dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD as


select distinct 
	eppstemm.pipeline_name,
	eppstemm.relation_to_process ,
	eppstemm.stage_column_name,
	eppstemm.column_class ,
	field_name,
	prio_in_key_hash,
	prio_in_diff_hash,
	content_column,
	link_parent_order
from  dv_pipeline_description.xenc_pipeline_process_stage_to_enc_model_mapping eppstemm
join dv_pipeline_description.dvpd_pipeline_stage_hash_input_field pshif on pshif.pipeline_name = eppstemm.pipeline_name 
																		and pshif.stage_column_name = eppstemm .content_stage_hash_column  
;																		

comment on view dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD is
 '[Encryption Extention] list of fields (and their order properties) to be used for every hash for staging to the encryption key store ';

-- select * from dv_pipeline_description.XENC_PIPELINE_STAGE_HASH_INPUT_FIELD order by pipeline
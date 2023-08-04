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


--drop view if exists dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION cascade;

create or replace view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION as 

-- EKI columns for satellites
select 	base .pipeline_name,
	base .relation_to_process,
	base .table_name,
	base .table_stereotype,
	base .column_name,
	base .column_class,
	base .stage_column_name,
	base .column_type,
	base .column_block,
	base .field_name,
	base .field_type,
	base .field_relation_name,
	base .needs_encryption,
	base .prio_in_key_hash,
	base .prio_in_diff_hash
from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE	base																	
where column_class like 'xenc_%'	and table_stereotype in ('sat')
union
-- additional stage columns for encrypted fields, that are distributed to more then one table
select
	base .pipeline_name,
	base .relation_to_process,
	base .table_name,
	base .table_stereotype,
	base .column_name,
	base .column_class,
	xenc .content_stage_column_name  stage_column_name,
	base .column_type,
	base .column_block,
	base .field_name,
	base .field_type,
	base .field_relation_name,
	base .needs_encryption,
	base .prio_in_key_hash,
	base .prio_in_diff_hash
from dv_pipeline_description.xenc_pipeline_process_field_to_encryption_key_mapping xenc
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_base base 
												on base .pipeline_name = xenc .pipeline_name 
												and base .relation_to_process  = xenc .relation_to_process 
												and base.table_name = xenc.content_table_name 
												and base .field_name = xenc.field_name 
												and base.stage_column_name = xenc.origin_content_stage_column_name 
where xenc.stage_map_rank >1			
;

comment on view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION is
 '[Encryption Extention] Additional mapping of field to stage to target column for every process block, table, pipeline ';


-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION order by pipeline,table_name,relation_to_process;										

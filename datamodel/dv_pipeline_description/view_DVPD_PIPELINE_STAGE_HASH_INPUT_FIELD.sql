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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD cascade;


create or replace view dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD as

with target_hash_columns as (
	select  pipeline_name
		,process_block 
		,field_group 
		,recursion_name 
		,stage_column_name 
		,table_name 
		,stereotype
		,column_name 
		,dv_column_class 
	from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm_key
	where dv_column_class in ('key','diff_hash')
)
, fields_for_link_key_hashes as (
select distinct
 thc.pipeline_name 
 ,thc.process_block 
 ,thc.stage_column_name 
 ,ppstdmm.field_name
 ,ppstdmm.field_group 
 ,ppstdmm.prio_in_key_hash 
 ,ppstdmm.prio_in_diff_hash  
 ,ppstdmm.recursion_name 
 ,dmhic.content_column 
 ,dmhic.content_recursion_name 
 ,dmhic.link_parent_order 
 ,dmhic.recursive_parent_order 
from target_hash_columns  thc
join dv_pipeline_description.dvpd_pipeline_dv_hash_input_column dmhic on dmhic.pipeline_name = thc.pipeline_name 
																  and dmhic.table_name =thc.table_name 
																  and dmhic.key_column =thc.column_name 
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline_name =thc.pipeline_name 
					and (ppstdmm.field_group = thc.field_group 	or ppstdmm.field_group = '_A_')
					and ppstdmm.recursion_name =dmhic.content_recursion_name 
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
where thc.stereotype  ='lnk' 
)
, fields_for_not_link_key_hashes as (
select distinct
 thc.pipeline_name 
 ,thc.process_block 
 ,ppstdmm.process_block field_pb
 ,thc.field_group 
 ,ppstdmm.field_group  field_fg
 ,thc.stage_column_name 
 ,ppstdmm.field_name
 ,ppstdmm.prio_in_key_hash 
 ,ppstdmm.prio_in_diff_hash  
 ,ppstdmm.recursion_name
 ,dmhic.content_column 
 ,dmhic.content_recursion_name 
 ,dmhic.link_parent_order 
 ,dmhic.recursive_parent_order 
from target_hash_columns  thc
join dv_pipeline_description.dvpd_pipeline_dv_hash_input_column dmhic on dmhic.pipeline_name = thc.pipeline_name
																	and  dmhic.table_name =thc.table_name 
																  and dmhic.key_column =thc.column_name 
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline_name =thc.pipeline_name 
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
					and ppstdmm.process_block = thc.process_block     
where thc.stereotype  !='lnk' 
)
select 
 pipeline_name 
 ,process_block 
 ,stage_column_name 
 ,field_name
 ,field_group 
 ,prio_in_key_hash 
 ,prio_in_diff_hash  
 ,recursion_name 
 ,content_column 
 ,content_recursion_name
 ,link_parent_order 
 ,recursive_parent_order 
 from fields_for_link_key_hashes
 union 
select 
 pipeline_name 
 ,process_block 
 ,stage_column_name 
 ,field_name
 ,field_group 
 ,prio_in_key_hash 
 ,prio_in_diff_hash  
 ,recursion_name 
 ,content_column 
 ,content_recursion_name
 ,link_parent_order 
 ,recursive_parent_order 
 from fields_for_not_link_key_hashes
; 

comment on view dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD is
 'list of fields (and their order properties) to be used for every hash in the stage table of the pipeline depending on processing_block';
													 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD order by pipeline,process_block ,stage_column_name,field_name 										
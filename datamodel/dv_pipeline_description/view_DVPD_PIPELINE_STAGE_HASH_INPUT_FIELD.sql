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

with stage_hash_columns as (
	select  pipeline_name
		,relation_to_process 
		,stage_column_name 
		,table_name 
		,table_stereotype
		,column_name 
		,column_class 
	from dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm_key
	where column_class in ('key','diff_hash')
)
, fields_for_link_key_hashes as (
select distinct
 shc.pipeline_name 
 ,shc.relation_to_process as relation_of_hash 
 ,shc.stage_column_name 
-- ,dmhic.content_table   -- debug
 ,dmhic.content_column 
 ,dmhic.link_parent_order 
-- ,pdlrkcm.link_parent_relation_name --debug
 ,ppstdmm.field_name
-- ,ppstdmm.field_relation_name  -- debug
 ,ppstdmm.prio_in_key_hash 
 ,ppstdmm.prio_in_diff_hash  
,ppstdmm.relation_to_process as relation_of_content_to_process 
 ,pdlrkcm.hub_key_column_name_in_link
 ,pdlrkcm.hub_key_column_name
from stage_hash_columns  shc
join dv_pipeline_description.dvpd_pipeline_dv_link_relation_key_column_mapping	pdlrkcm on pdlrkcm.pipeline_name = shc.pipeline_name
																			and pdlrkcm.table_name=shc.table_name
																			and pdlrkcm.link_key_column_name=shc.column_name
																			and pdlrkcm.relation_to_process = shc.relation_to_process
join dv_pipeline_description.dvpd_pipeline_dv_hash_input_column dmhic on dmhic.pipeline_name = shc.pipeline_name 
																  and dmhic.table_name =pdlrkcm.link_parent_table
																  and dmhic.key_column =pdlrkcm.hub_key_column_name 								   
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline_name =shc.pipeline_name 
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
					and (ppstdmm.field_relation_name =pdlrkcm.link_parent_relation_name 
						or (pdlrkcm.link_parent_relation_name = '*' and ppstdmm.field_relation_name =shc.relation_to_process)
						or ppstdmm.field_relation_name='*')
where shc.table_stereotype  ='lnk' 
)
, fields_for_not_link_key_hashes as (
select distinct
 shc.pipeline_name 
 ,shc.relation_to_process as relation_of_hash  
 ,shc.stage_column_name 
 ,dmhic.content_column 
 ,dmhic.link_parent_order 
 ,ppstdmm.field_name
 ,ppstdmm.field_relation_name
 ,ppstdmm.prio_in_key_hash 
 ,ppstdmm.prio_in_diff_hash  
 ,ppstdmm.relation_to_process as relation_of_content_to_process
from stage_hash_columns  shc
join dv_pipeline_description.dvpd_pipeline_dv_hash_input_column dmhic on dmhic.pipeline_name = shc.pipeline_name
																	and  dmhic.table_name =shc.table_name 
																  and dmhic.key_column =shc.column_name 
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping ppstdmm on ppstdmm.pipeline_name =shc.pipeline_name 
					and ppstdmm.table_name = dmhic.content_table 
					and ppstdmm.column_name = dmhic.content_column 
					and ppstdmm.relation_to_process = shc.relation_to_process     
where shc.table_stereotype  !='lnk' 
)
select 
 pipeline_name 
 ,relation_of_hash 
 ,stage_column_name 
 ,field_name
 ,prio_in_key_hash 
 ,prio_in_diff_hash  
 ,content_column 
 ,link_parent_order 
 ,hub_key_column_name_in_link
 ,hub_key_column_name
 from fields_for_link_key_hashes
 union 
select 
 pipeline_name 
 ,relation_of_hash 
 ,stage_column_name 
 ,field_name
 ,prio_in_key_hash 
 ,prio_in_diff_hash  
 ,content_column 
 ,link_parent_order 
 ,null as hub_key_column_name_in_link
 ,null as hub_key_column_name 
 from fields_for_not_link_key_hashes
 order by 1,3,4
; 

comment on view dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD is
 'list of fields (and their order properties) to be used for every hash in the stage table of the pipeline depending on processing_block';
													 
-- select * from dv_pipeline_description.DVPD_PIPELINE_STAGE_HASH_INPUT_FIELD order by pipeline,process_block ,stage_column_name,field_name 										
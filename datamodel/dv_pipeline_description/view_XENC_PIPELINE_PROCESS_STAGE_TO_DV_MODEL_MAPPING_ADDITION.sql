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


with table_relation_to_process_count as (
select pipeline_name,table_name,count(distinct relation_to_process) relation_to_process_count
from dv_pipeline_description.dvpd_pipeline_process_plan
group by 1,2
)
,link_key_stage_columns as (
select distinct 
 pipeline_name
 ,table_name
 ,relation_to_process
 ,link_key_stage_column_name
from  dv_pipeline_description.dvpd_pipeline_dv_link_relation_key_column_mapping	
)
,hub_keys as (
    select distinct -- hub keys
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
	,case when  relation_to_process ='/'  or trtpc.relation_to_process_count=1 then pdc.column_name 
	  		 else pdc.column_name||'_'||relation_to_process  
	 end stage_column_name
	,pdc.column_type 
	,pdc.column_block 
	,null as field_name 
	,null as field_type 
	,null as field_relation_name        
	,null::boolean as needs_encryption
	,null::int as prio_in_key_hash 
	,null::int  as prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name 
												and pdc.column_class = 'key'
												and ppp.table_stereotype = 'hub'
join table_relation_to_process_count trtpc on trtpc.pipeline_name = ppp.pipeline_name
												and trtpc.table_name = ppp.table_name
)
,sat_of_hub_eki as (
  select distinct 
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
	,case when  pdc.column_class = 'parent_key' and hk.stage_column_name is not null then hk.stage_column_name
		   when  pdc.column_class = 'diff_hash' and not has_explicit_relation_names then  pdc.column_name   
			when  ppp.relation_to_process in ('/','*')  then pdc.column_name 
	  		 else pdc.column_name||'_'||ppp.relation_to_process  
	 end stage_column_name
	,pdc.column_type 
	,pdc.column_block 
	,null as field_name 
	,null as field_type 
	,null as field_relation_name         
	,null::boolean as needs_encryption
	,null::int as prio_in_key_hash 
	,null::int  as prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name=ppp.pipeline_name
													and pdt.table_name = ppp.table_name
left join hub_keys hk on hk.pipeline_name = pdt.pipeline_name
					and hk.table_name = pdt.satellite_parent_table
					and hk.relation_to_process=ppp.relation_to_process
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name 
												and pdc.column_class  like 'xenc_%'
												and ppp.table_stereotype in ('sat')
where (pdt.pipeline_name,pdt.satellite_parent_table) in (select pipeline_name,table_name from hub_keys)	
)												
, sat_of_link_eki as (
  select distinct 
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
	,case when  pdc.column_class = 'parent_key' and lksc.link_key_stage_column_name is not null then lksc.link_key_stage_column_name
			when  pdc.column_class = 'diff_hash' and not has_explicit_relation_names then  pdc.column_name 
			when  ppp.relation_to_process in ('/','*')  then pdc.column_name 
	  		 else pdc.column_name||'_'||ppp.relation_to_process  
	 end stage_column_name
	,pdc.column_type 
	,pdc.column_block 
	,null as field_name 
	,null as field_type 
	,null as field_relation_name         
	,null::boolean as needs_encryption
	,null::int as prio_in_key_hash 
	,null::int  as prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name=ppp.pipeline_name
													and pdt.table_name = ppp.table_name
left join link_key_stage_columns lksc on lksc.pipeline_name = pdt.pipeline_name
					and lksc.table_name = pdt.satellite_parent_table
					and lksc.relation_to_process=ppp.relation_to_process
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name 
												and pdc.column_class  like 'xenc_%'
												and ppp.table_stereotype = 'sat'
where (pdt.pipeline_name,pdt.satellite_parent_table) in (select pipeline_name,table_name from link_key_stage_columns)	
)
, fields_used_in_multiple_tables as (
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
	base .prio_in_diff_hash,
	xenc .content_stage_column_name as stage_column_name_target_based
from dv_pipeline_description.xenc_pipeline_process_field_to_encryption_key_mapping xenc
join dv_pipeline_description.dvpd_pipeline_process_stage_to_dv_model_mapping_base base 
												on base .pipeline_name = xenc .pipeline_name 
												and base .relation_to_process  = xenc .relation_to_process 
												and base.table_name = xenc.content_table_name 
												and base .field_name = xenc.field_name 
												and base.stage_column_name = xenc.origin_content_stage_column_name 
where xenc.stage_map_rank >1	
)
select *, stage_column_name as stage_column_name_target_based from sat_of_hub_eki
union
select *, stage_column_name as stage_column_name_target_base from sat_of_link_eki
union
select * from fields_used_in_multiple_tables

	
;

comment on view dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION is
 '[Encryption Extention] Additional mapping of field to stage to target column for every process block, table, pipeline ';


-- select * from dv_pipeline_description.XENC_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_ADDITION order by pipeline,table_name,relation_to_process;										

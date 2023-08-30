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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE as 

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
,fields as (
select distinct -- content fields
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
    ,case when pfte.field_name is not null and relation_to_process in ('/','*')  then pdc.column_name  -- legacy generator compatible  (Stage = Target, will fail on multiple mappings to same target)
     else pfte.field_name end as stage_column_name
	--,pfte.field_name as stage_column_name  -- normal behaviuour
	,pdc.column_type 
	,pdc.column_block 
	,pfte.field_name 
	,pfte.field_type 
	,pfte.relation_name as field_relation_name 
	,pfte.needs_encryption
	,pfte.prio_in_key_hash 
	,pfte.prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name 
												and pdc.column_class not in ('meta')
join dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte on  pfte.pipeline_name =ppp.pipeline_name 
																		and pfte.table_name =pdc.table_name 
																		and pfte.column_name =pdc.column_name
																		and (pfte.relation_name = ppp.relation_to_process or pfte.relation_name ='*')
where pfte.field_name is not null 
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
,sat_of_hub_keys_and_diff as (
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
												and pdc.column_class in ('parent_key','diff_hash')
												and ppp.table_stereotype = 'sat'
where (pdt.pipeline_name,pdt.satellite_parent_table) in (select pipeline_name,table_name from hub_keys)	
)
, link_keys as (
select distinct -- link keys
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
	--,ptpc.parent_process_count  -- for debug purposes
    -- case when pfte.field_name is not null and process_block ='_A_'  then pdc.column_name  -- legacy generator compatible  (Stage = Target, will fail on multiple mappings to same target)
	,lksc.link_key_stage_column_name as stage_column_name
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
												and ppp.table_stereotype = 'lnk'
join link_key_stage_columns lksc  on lksc.pipeline_name = ppp.pipeline_name
								 and lksc.table_name=ppp.table_name
								 and lksc.relation_to_process = ppp.relation_to_process
)								 
, link_hub_keys as (
select distinct 
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,lrkcm.hub_key_column_name_in_link   as column_name 
	,'parent_key' as column_class  
	--,ptpc.parent_process_count  -- for debug purposes
	,hub_key_stage_column_name as stage_column_name
	,pdc.column_type 
	,pdc.column_block 
	,null as field_name 
	,null as field_type 
	,null as field_relation_name  
	,null::boolean as needs_encryption
	,null::int as prio_in_key_hash 
	,null::int  as prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_link_relation_key_column_mapping lrkcm  on lrkcm.pipeline_name = ppp.pipeline_name
								 and lrkcm.table_name=ppp.table_name
								 and lrkcm.relation_to_process = ppp.relation_to_process
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name
												and pdc.column_name = lrkcm.hub_key_column_name_in_link
)				
,sat_of_link_keys as (
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
												and pdc.column_class in ('parent_key','diff_hash')
												and ppp.table_stereotype = 'sat'
where (pdt.pipeline_name,pdt.satellite_parent_table) in (select pipeline_name,table_name from link_key_stage_columns)	
)
,ref_key_and_diff as (
  select distinct 
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
	,column_name as  stage_column_name
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
												and pdc.column_class in ('key','diff_hash')
   												and ppp.table_stereotype = 'ref'
)
-- >>>>>>>>> Final union <<<<<<<<<<<<<<<
Select * from fields
union
Select * from hub_keys
union
Select * from sat_of_hub_keys_and_diff
union
Select * from link_keys
union
Select * from link_hub_keys
union
Select * from sat_of_link_keys
union
Select * from ref_key_and_diff
;




comment on view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE is
 'processes specific mapping of fields to stage and target columns for every target table of a pipeline. (no meta elements) ';

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE order by pipeline_name,table_name,column_block,column_name,relation_to_process;										

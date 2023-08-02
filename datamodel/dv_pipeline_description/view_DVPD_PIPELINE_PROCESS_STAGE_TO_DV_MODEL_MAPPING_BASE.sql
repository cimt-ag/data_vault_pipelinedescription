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

with parent_table_process_count as (
select 
	parent_plan.pipeline_name 
	,pdtlp.table_name 
	,pdtlp.link_parent_table as parent_table_name 
	,coalesce (parent_pdt.hub_key_column_name ,parent_pdt.link_key_column_name ) parent_key_column_name
	,count(distinct parent_plan.relation_to_process) as parent_process_count
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
join dv_pipeline_description.dvpd_pipeline_process_plan parent_plan on parent_plan.table_name =pdtlp.link_parent_table 
																	and parent_plan.pipeline_name = pdtlp.pipeline_name 
join dv_pipeline_description.dvpd_pipeline_dv_table parent_pdt on parent_pdt.pipeline_name = parent_plan.pipeline_name 
															 and parent_pdt.table_name = pdtlp.link_parent_table 	
group by 1,2,3,4															 
union
select 
	parent_plan.pipeline_name 
	,pdt.table_name 
	,pdt.satellite_parent_table as parent_table_name 
	,coalesce (parent_pdt.hub_key_column_name ,parent_pdt.link_key_column_name ) parent_key_column_name
	,count(distinct parent_plan.relation_to_process) as parent_process_count
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
join dv_pipeline_description.dvpd_pipeline_process_plan parent_plan on parent_plan.pipeline_name = pdt.pipeline_name 
																	and parent_plan.table_name =pdt.satellite_parent_table 
join dv_pipeline_description.dvpd_pipeline_dv_table parent_pdt on parent_pdt.pipeline_name = parent_plan.pipeline_name 
															 and parent_pdt.table_name = pdt.satellite_parent_table 	
group by 1,2,3,4															 
order by pipeline_name
)
select distinct 
	ppp.pipeline_name
	,ppp.relation_to_process 
	,ppp.table_name
	,ppp.table_stereotype 
	,pdc.column_name 
	,pdc.column_class  
	--,ptpc.parent_process_count  -- for debug purposes
	--,pfte.relation_name         -- for debug purposes
    -- case when pfte.field_name is not null and process_block ='_A_'  then pdc.column_name  -- legacy generator compatible  (Stage = Target, will fail on multiple mappings to same target)
	,case when pfte.field_name is not null then pfte.field_name 
		  when relation_to_process ='/' then pdc.column_name 
		  when relation_name in('/','*') or ptpc.parent_process_count=1 then pdc.column_name 
	  		 else pdc.column_name||'_'||relation_to_process  
	 end stage_column_name
	,pdc.column_type 
	,pdc.column_block 
	,pfte.field_name 
	,pfte.field_type 
	,pfte.needs_encryption
	,pfte.prio_in_key_hash 
	,pfte.prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name 
												and pdc.column_class not in ('meta')
left join 	dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte on  pfte.pipeline_name =ppp.pipeline_name 
																		and pfte.table_name =pdc.table_name 
																		and pfte.column_name =pdc.column_name
																		and (pfte.relation_name = ppp.relation_to_process or pfte.relation_name ='*')
left join parent_table_process_count ptpc	 on ptpc.pipeline_name = ppp.pipeline_name 
														and ptpc.table_name = ppp.table_name 
														and ptpc.parent_key_column_name = pdc.column_name 
--and ppp.pipeline like 'test50%'
--order by table_name,process_block ,column_name 
;

comment on view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE is
 'processes specific mapping of fields to stage and target columns for every target table of a pipeline. (no meta elements) ';

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE order by pipeline,table_name,process_block;										

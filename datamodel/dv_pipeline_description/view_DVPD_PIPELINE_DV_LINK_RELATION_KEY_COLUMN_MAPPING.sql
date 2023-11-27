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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_DV_LINK_RELATION_KEY_COLUMN_MAPPING cascade;


create or replace view dv_pipeline_description.DVPD_PIPELINE_DV_LINK_RELATION_KEY_COLUMN_MAPPING as


with links_with_direct_parent_relation_declaration as (
select distinct pipeline_name ,table_name
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent
where relation_name<>'*'
--order by pipeline_name ,table_name 
)
, link_parent_count as (
select distinct pipeline_name ,table_name
	,link_parent_table
	,count(1) parent_reference_count
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent
group by 1,2,3
--order by pipeline_name ,table_name 
)
, assignment_for_direct_parent_relations as (
select 
	lwdprd.pipeline_name
	,lwdprd.table_name
	,ppp.relation_to_process
	,pdt.link_key_column_name
	,pdt.link_key_column_name as link_key_stage_column_name
	,pdtlp.link_parent_table
	,case when pdtlp.relation_name<>'*' then pdtlp.relation_name 
		  when 	lpc.parent_reference_count>1 then '/'
		  else '*' 
			end as link_parent_relation_name
	,pdt_parent.hub_key_column_name
	,case when hub_key_column_name_in_link is not null then hub_key_column_name_in_link
		  when pdtlp.relation_name not in('*','/')  then  pdt_parent.hub_key_column_name||'_'||pdtlp.relation_name
 		else pdt_parent.hub_key_column_name end as hub_key_column_name_in_link
	,case when pdtlp.relation_name not in('*','/')   then  pdt_parent.hub_key_column_name||'_'||pdtlp.relation_name
 		else pdt_parent.hub_key_column_name end as hub_key_stage_column_name		
from links_with_direct_parent_relation_declaration lwdprd
join dv_pipeline_description.dvpd_pipeline_process_plan ppp on ppp.pipeline_name = lwdprd.pipeline_name
																	and ppp.table_name = lwdprd.table_name
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name =lwdprd.pipeline_name
 														and pdt.table_name = lwdprd.table_name 		
join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp on pdtlp.pipeline_name = lwdprd.pipeline_name
																	and pdtlp.table_name = lwdprd.table_name
join link_parent_count lpc on lpc.pipeline_name =pdtlp.pipeline_name
						    and lpc.table_name=pdtlp.table_name
 							and lpc.link_parent_table = pdtlp.link_parent_table 	
join dv_pipeline_description.dvpd_pipeline_dv_table pdt_parent on pdt_parent.pipeline_name =pdtlp.pipeline_name
 														and pdt_parent.table_name = pdtlp.link_parent_table
)
,links_with_indirect_parent_relation_declaration as (
select distinct pipeline_name ,table_name
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent
except
select distinct pipeline_name ,table_name
from links_with_direct_parent_relation_declaration
)
,table_relation_to_process_count as (
select pipeline_name,table_name,count(distinct relation_to_process) relation_to_process_count
from dv_pipeline_description.dvpd_pipeline_process_plan
group by 1,2
)
,assignment_for_indirect_parent_relations as (
select 
	lwiprd.pipeline_name
	,lwiprd.table_name
	,ppp.relation_to_process
    ,pdt.link_key_column_name
	,case when trtpc.relation_to_process_count>1 and ppp.relation_to_process not in ('*','/') then pdt.link_key_column_name||'_'|| ppp.relation_to_process
									else pdt.link_key_column_name end as link_key_stage_column_name
	,pdtlp.link_parent_table
	,case when pdtlp.relation_name<>'*' then ppp.relation_to_process 
									 	else '*' end as link_parent_relation_name
    ,pdt_parent.hub_key_column_name									 	
	,case when pdtlp.relation_name<>'*'  then  pdt_parent.hub_key_column_name||'_'||pdtlp.relation_name
 		else pdt_parent.hub_key_column_name end as hub_key_column_name_in_link									 	
	,case when trtpc_parent.relation_to_process_count>1 and ppp.relation_to_process<>'/' then  pdt_parent.hub_key_column_name||'_'|| ppp.relation_to_process 
 										  else pdt_parent.hub_key_column_name end as hub_key_stage_column_name
from links_with_indirect_parent_relation_declaration lwiprd
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name =lwiprd.pipeline_name
 														and pdt.table_name = lwiprd.table_name 		
join table_relation_to_process_count trtpc on trtpc.pipeline_name = lwiprd.pipeline_name
											and trtpc.table_name = lwiprd.table_name
join dv_pipeline_description.dvpd_pipeline_process_plan ppp on ppp.pipeline_name = lwiprd.pipeline_name
																	and ppp.table_name = lwiprd.table_name
join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp on pdtlp.pipeline_name = lwiprd.pipeline_name
																	and pdtlp.table_name = lwiprd.table_name
join dv_pipeline_description.dvpd_pipeline_dv_table pdt_parent on pdt_parent.pipeline_name =pdtlp.pipeline_name
 														and pdt_parent.table_name = pdtlp.link_parent_table 	
join table_relation_to_process_count trtpc_parent on trtpc_parent.pipeline_name = pdt_parent.pipeline_name
											and trtpc_parent.table_name = pdt_parent.table_name
--order by 1,2,3
)
select * from assignment_for_direct_parent_relations
union
select * from assignment_for_indirect_parent_relations
order by pipeline_name ,table_name,link_parent_table,relation_to_process 																	
;																	

-- select * from dv_pipeline_description.DVPD_PIPELINE_DV_LINK_RELATION_KEY_COLUMN_MAPPING order by  pipeline_name ,table_name,link_parent_table,relation_to_process;
															   
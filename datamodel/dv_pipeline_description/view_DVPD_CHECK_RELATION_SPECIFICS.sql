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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_RELATION_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_RELATION_SPECIFICS as

with declared_relations as (  
	select 							-- declared on field mapping to table
	  pdt.pipeline_name 
	 ,pdt.table_name
	 ,pdt.table_stereotype
	 ,replace(pfte.relation_name,'*','/') relation_name  -- tables with only * fields are in the unnamed relation
	 ,count(1) count_field
	from dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte
	join dv_pipeline_description.dvpd_pipeline_dv_table  pdt on pdt.pipeline_name = pfte.pipeline_name 
	 													and pdt.table_name = pfte.table_name 
	group by 1,2,3,4
	union
	select 							-- declared in link to hub mapping
	  pipeline_name 
	 ,table_name
	 ,'lnk' as table_stereotype
	 ,relation_name 
	 ,count(1) count_field
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent
	where relation_Name <>'*'
	group by 1,2,3,4
	union
	select  						-- declared as tracking property
	  pipeline_name 
	 ,table_name
	 ,'sat' as table_stereotype
	 ,tracked_relation_name as relation_name 
	 ,count(1) count_field
	from dv_pipeline_description.dvpd_pipeline_dv_table
	where tracked_relation_name is not null
	group by 1,2,3,4
)
,link_relation_count as (
	select 
	  pdtlp.pipeline_name 
	 ,pdtlp.table_name
	 ,sum(case when relation_name<>'*' then 1 else 0 end ) count_of_declared_relation_names
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent  pdtlp 
	group by 1,2
)
,processes_of_link_parent as (
	select 
	  pdtlp.pipeline_name 
	 ,pdtlp.table_name
	 ,ppp_p.relation_to_process as  processable_relation 
	 ,pdtlp.link_parent_table 
	from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent  pdtlp 
	join dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN ppp_p on ppp_p.pipeline_name = pdtlp.pipeline_name 
																and ppp_p.table_name = pdtlp.link_parent_table 
	order by 1,2,4															
)
,collection_of_problems as (
select -- satellites with processes that are not supported by parent 
  ppp_s.pipeline_name 
 ,ppp_s.table_name
 ,ppp_s.relation_to_process 
 ,pdt_s.satellite_parent_table 
-- ,ppp_p.relation_to_process parent_relation_to_process
from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN ppp_s
join dv_pipeline_description.dvpd_pipeline_dv_table  pdt_s on pdt_s.pipeline_name = ppp_s.pipeline_name 
															and pdt_s.table_name =ppp_s.table_name  
															and pdt_s.table_stereotype ='sat'
left join dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN ppp_p on ppp_p.pipeline_name = ppp_s.pipeline_name 
															and ppp_p.table_name = pdt_s.satellite_parent_table  
															and ppp_p.relation_to_process = ppp_s.relation_to_process 
where ppp_p.table_name is null	and pdt_s.satellite_parent_table is not null
--order by 1,2,4			
union
select distinct-- links with declared relation names that are not supported by their hubs
  ppp_l.pipeline_name 
 ,ppp_l.table_name
 ,pdtlp.relation_name
 ,pdtlp.link_parent_table 
-- ,polp.processable_relation -- for DEBUG
from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN ppp_l
join link_relation_count lrc on lrc.pipeline_name = ppp_l.pipeline_name
							    and lrc.table_name = ppp_l.table_name
							     and lrc.count_of_declared_relation_names>0 
join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent  pdtlp on pdtlp.pipeline_name = ppp_l.pipeline_name 
															and pdtlp.table_name =ppp_l.table_name  
left join processes_of_link_parent polp on polp.pipeline_name = ppp_l.pipeline_name
								and polp.table_name = ppp_l.table_name
								and (polp.processable_relation = pdtlp.relation_name )
where polp.table_name is null and  pdtlp.relation_name<>'*'
union
select -- links driven by satellites that are not supported by their hubs
  ppp_l.pipeline_name 
 ,ppp_l.table_name
 ,ppp_l.relation_to_process 
 ,polp.table_name parent_table_name
from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN ppp_l
join link_relation_count lrc on lrc.pipeline_name = ppp_l.pipeline_name
							    and lrc.table_name = ppp_l.table_name
							     and lrc.count_of_declared_relation_names=0 
join dv_pipeline_description.dvpd_pipeline_dv_table  pdt_l on pdt_l.pipeline_name = ppp_l.pipeline_name 
															and pdt_l.table_name =ppp_l.table_name  
															and pdt_l.table_stereotype ='lnk'
left join processes_of_link_parent polp on polp.pipeline_name = ppp_l.pipeline_name
								and polp.table_name = ppp_l.table_name
								and polp.processable_relation = ppp_l.relation_to_process
where  polp.table_name is null
 -- and ppp_l.relation_to_process	<>'/'  
order by 1,2,3								
)								
-- >>>> Final presentation as check entry <<<<<	
select
  pipeline_name
  ,'Relation Name'::TEXT  	as object_type 
  ,relation_to_process 	as object_name
  ,'DVPD_CHECK_RELATION_SPECIFICS'::text  check_ruleset
  ,'Relation in table "'|| table_name   ||'" does not match any parent hub relation'   message
from collection_of_problems
;

comment on view dv_pipeline_description.DVPD_CHECK_RELATION_SPECIFICS IS
	'Checks consistency of all relation names used';

-- select * from dv_pipeline_description.DVPD_CHECK_FIELD_SPECIFICS order by 1,2,3




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


-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN as 

with tables_with_explicit_processes as (
-- relations declared on field mappings
select distinct 
	pdt.pipeline_name
	,pdt.table_name
	,pdt.table_stereotype 
	,relation_name as relation_to_process
	,'explicit field mapping' relation_origin
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte
join dv_pipeline_description.dvpd_pipeline_dv_table pdt  on pdt.table_name =pfte.table_name 
														and pdt.pipeline_name = pfte.pipeline_name 
where relation_name is not null and relation_name not in ('*')  
--
union
-- tracked relations of effectivity satellites
select distinct
	pdt.pipeline_name 
	,pdt.table_name 
	,pdt.table_stereotype 
	,tracked_relation_name as relation_to_process
	,'tracked_relation_name' relation_origin
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
where tracked_relation_name is not null
--
union
-- links, that have named relations can only have one process
select distinct
	pdtlp.pipeline_name 
	,pdtlp.table_name 
	,'lnk' 
	,'/' as relation_to_process
	,'link with explicit parent mapping' relation_origin
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
where relation_name <> '/'
)
,tables_without_explicit_processes as(
select distinct 
	pdt.pipeline_name 
	,pdt.table_name
	,pdt.table_stereotype
	,pdt.satellite_parent_table
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join tables_with_explicit_processes twepb on twepb.pipeline_name  =pdt.pipeline_name 
												   and twepb.table_name = pdt.table_name 
where twepb.table_name is null												   
)
,link_processes_derived_from_satellite as (
select 
	twoep.pipeline_name 
	,twoep.table_name
	,twoep.table_stereotype 
	,twep.relation_to_process 
	,'driven by sat'::text relation_origin
from tables_without_explicit_processes  twoep
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = twoep.pipeline_name 
																and pdt.satellite_parent_table = twoep.table_name 
join tables_with_explicit_processes twep on twep.pipeline_name = twoep.pipeline_name 
											 and twep.table_name = pdt.table_name 
											 and twep.table_stereotype in ('sat')
where twoep.table_stereotype = 'lnk'
)
,links_not_driven_by_satellite as (
select 	pipeline_name
	,table_name
	,table_stereotype  
from tables_without_explicit_processes
where table_stereotype = 'lnk'
except 
select pipeline_name 
	,table_name
	,table_stereotype
from link_processes_derived_from_satellite 
)
,link_processes_driven_by_hub as (
select 	lndbs.pipeline_name
	,lndbs.table_name
	,lndbs.table_stereotype
	,twep.relation_to_process
	,'driven by hub'::text relation_origin
from links_not_driven_by_satellite lndbs
join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp on pdtlp.table_name = lndbs.table_name 
													and pdtlp.pipeline_name = lndbs .pipeline_name 
join tables_with_explicit_processes twep on twep.pipeline_name =lndbs.pipeline_name 
										     and twep.table_name  = pdtlp.link_parent_table
)										
, sat_processes_driven_by_parent as (
-- parents with explicit processes
select 
	twoep.pipeline_name 
	,twoep.table_name 
	,twoep.table_stereotype 
	,twep.relation_to_process
    ,'driven by explicit parent'::text relation_origin
from tables_without_explicit_processes  twoep
join tables_with_explicit_processes twep  on twep.pipeline_name = twoep.pipeline_name 
																and twep.table_name  = twoep.satellite_parent_table
union 
-- links , driven by their parents
select 
	twoep.pipeline_name 
	,twoep.table_name 
	,twoep.table_stereotype 
	,lpdbh.relation_to_process
    ,'driven by explicit parent'::text relation_origin
from tables_without_explicit_processes  twoep
join link_processes_driven_by_hub lpdbh  on lpdbh.pipeline_name = twoep.pipeline_name 
																and lpdbh.table_name  = twoep.satellite_parent_table
)
, all_special_processes AS (
select * from tables_with_explicit_processes
union
select * from link_processes_derived_from_satellite
union 
select * from link_processes_driven_by_hub
union
select * from sat_processes_driven_by_parent
--order by pipeline_name, table_name,relation_to_process
)
, all_simple_processes as (
select
	twoep.pipeline_name 
	,twoep.table_name 
	,twoep.table_stereotype 
	,'/' :: varchar as relation_to_process
    ,'simple'::varchar relation_origin
from tables_without_explicit_processes twoep
left join all_special_processes asp on asp.pipeline_name = twoep.pipeline_name
								and asp.table_name = twoep.table_name
where asp.pipeline_name is null
)
-- >>>>>>> final result >>>>>>>>>
select * from all_special_processes
union
select * from all_simple_processes;


comment on view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN is
 'List of necessary processes (identified by  relation_to_process) for every target table of a pipeline. ';		

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN order by pipeline_name,table_name,relation_to_process;										

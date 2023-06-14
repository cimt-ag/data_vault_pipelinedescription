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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS as

with bk_count_for_tables as (
select 
	pdt.pipeline_name 
	,pdt.table_name  
	,count (sfm.field_name ) bk_count
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm ON pdt.table_name = lower(sfm.table_name  )
			and sfm.pipeline_name = pdt.pipeline_name 
			and not sfm.exclude_from_key_hash
where pdt.table_stereotype ='hub'   
group by 1,2
)
select 
	pipeline_name 
 	,'Table'::TEXT  object_type 
 	, table_name  object_name 
 	,'DVPD_CHECK_HUB_SPECIFICS'::text  check_ruleset
	, case when bk_count = 0 THEN 'No business key defined for the hub'
		else 'ok' end :: text message
from bk_count_for_tables
union
(with hk_count as (
select 
	pipeline_name 
	,hub_key_column_name 
	,count(1) hk_count
	,string_agg(table_name ,', ') table_list 
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
where table_stereotype = 'hub' and hub_key_column_name is not null
group by 1,2
)
select 
	pipeline_name 
 	,'Hub Key'::TEXT  object_type 
 	, hub_key_column_name object_name 
 	,'DVPD_CHECK_HUB_SPECIFICS'::text  check_ruleset
	, case when hk_count > 1 THEN 'Hub key name used for multiple hubs: '||table_list
		else 'ok' end :: text message
FROM hk_count);

comment on view dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS IS
	'Checks for hub specific rules (busniess key declared, Hash key name collision)';



-- select * from dv_pipeline_description.DVPD_CHECK_HUB_SPECIFICS order by 1,2,3




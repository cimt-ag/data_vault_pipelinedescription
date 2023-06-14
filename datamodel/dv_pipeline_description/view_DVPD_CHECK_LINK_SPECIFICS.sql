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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS as


with lk_count as (
select 
	pipeline_name 
	,link_key_column_name 
	,count(1) lk_count
	,string_agg(table_name ,', ') table_list 
from  dv_pipeline_description.dvpd_pipeline_dv_table pdt
where table_stereotype = 'lnk' and link_key_column_name is not null 
group by 1,2
)
select 
	pipeline_name 
 	,'Link Key'::TEXT  object_type 
 	, link_key_column_name object_name 
 	,'DVPD_CHECK_LINK_SPECIFICS'::text  check_ruleset
	, case when lk_count > 1 THEN 'Link key name used for multiple links: '||table_list
		else 'ok' end :: text message
FROM lk_count;

comment on view dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS IS
	'Checks for  for link specific rules (Link key collisions)';

-- select * from dv_pipeline_description.DVPD_CHECK_LINK_SPECIFICS order by 1,2,3




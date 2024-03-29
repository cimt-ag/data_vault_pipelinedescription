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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_SAT_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_SAT_SPECIFICS as


with esat_must_have_link_parent as (
	select 
		pdt.pipeline_name 
	 	,'Table'::TEXT  object_type 
	 	, pdt.table_name  object_name 
	 	,'DVPD_CHECK_SAT_SPECIFICS'::text  check_ruleset
		, 'an effectivity satellite (Sat without any mapped fields) must have a link as parent':: text message
	from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
	join dv_pipeline_description.dvpd_pipeline_dv_table parent ON parent.table_name = pdt.satellite_parent_table 
				and parent.pipeline_name = pdt.pipeline_name 
	where pdt.is_effectivity_sat and parent.table_stereotype  <> 'lnk'
)
,driving_key_per_pipeline_and_sat_table as (
	select 
		pdt.pipeline_name 
		,pdt.table_name 
		,satellite_parent_table 
		,driving_key
	from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
	join dv_pipeline_description.dvpd_pipeline_dv_table_driving_key pdtdk on pdtdk.pipeline_name =pdt.pipeline_name 
																		 and pdtdk.table_name =pdt.table_name 
	where table_stereotype in ('sat')
)
,do_driving_keys_exist_in_parent as (
select 
	dkppast.pipeline_name 
 	,'Table'::TEXT  object_type 
 	, dkppast.table_name   object_name 
 	,'DVPD_CHECK_SAT_SPECIFICS'::text  check_ruleset
	, case when dc.column_name is null then 'driving key "'||dkppast.driving_key ||'" does not exist in parent table':: text
	   when dc.column_class not in ('parent_key','dependent_child_key') then 'column "'||dkppast.driving_key ||'" is not a parent key or dependent child key'
			else 'ok' end message
from driving_key_per_pipeline_and_sat_table dkppast 
left join dv_pipeline_description.dvpd_pipeline_dv_column dc ON dc.pipeline_name =dkppast.pipeline_name 
															and dc.table_name = dkppast.satellite_parent_table
															and dc.column_name =dkppast.driving_key 
) 
,parameter_dependencies as (
select 
	pdt.pipeline_name 
 	,'Table'::TEXT  object_type 
 	, pdt.table_name   object_name 
 	,'DVPD_CHECK_SAT_SPECIFICS'::text  check_ruleset
	, case when pdt.uses_diff_hash 
	        and not is_effectivity_sat
	        and compare_criteria not in('key','none') 
	        and diff_hash_column_name is null 
	        		then  'diff_hash_column_name needs to be declared'
					else 'ok' end message
	from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
	where table_stereotype ='sat'
) 
select * from esat_must_have_link_parent
union
select * from do_driving_keys_exist_in_parent
union
select * from parameter_dependencies;


comment on view dv_pipeline_description.DVPD_CHECK_SAT_SPECIFICS IS
	'Test for satellite specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_SAT_SPECIFICS order by 1,2,3




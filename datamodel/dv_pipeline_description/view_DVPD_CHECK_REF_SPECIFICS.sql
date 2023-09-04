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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_REF_SPECIFICS cascade;

create or replace view dv_pipeline_description.DVPD_CHECK_REF_SPECIFICS as


with parameter_dependencies as (
select 
	pdt.pipeline_name 
 	,'Table'::TEXT  object_type 
 	, pdt.table_name   object_name 
 	,'DVPD_CHECK_REF_SPECIFICS'::text  check_ruleset
	, case when pdt.uses_diff_hash 
	        and diff_hash_column_name is null 
	        		then  'diff_hash_column_name needs to be declared'
					else 'ok' end message
	from dv_pipeline_description.dvpd_pipeline_dv_table pdt 
	where table_stereotype ='ref'
) 
select * from parameter_dependencies;


comment on view dv_pipeline_description.DVPD_CHECK_REF_SPECIFICS IS
	'Test for reference table specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_REF_SPECIFICS order by 1,2,3




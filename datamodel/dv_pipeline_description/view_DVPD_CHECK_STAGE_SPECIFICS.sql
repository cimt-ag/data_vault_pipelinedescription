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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_STAGE_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_STAGE_SPECIFICS as


with no_stage_schema_declared as (

	select 
		dpp.pipeline_name 
	 	,'storage component'::TEXT  object_type 
	 	, dpsp.storage_component  object_name 
	 	,'DVPD_CHECK_STAGE_SPECIFICS'::text  check_ruleset
		, 'no stage schema declared':: text message
	from  dv_pipeline_description.dvpd_pipeline_properties dpp   
	left join dv_pipeline_description.dvpd_pipeline_stage_properties dpsp ON dpsp.pipeline_name = dpp.pipeline_name 
	where dpsp.stage_schema is null

)
 
select * from no_stage_schema_declared;



comment on view dv_pipeline_description.DVPD_CHECK_STAGE_SPECIFICS IS
	'Test for stage property specific rules';

-- select * from dv_pipeline_description.DVPD_CHECK_STAGE_SPECIFICS order by 1,2,3




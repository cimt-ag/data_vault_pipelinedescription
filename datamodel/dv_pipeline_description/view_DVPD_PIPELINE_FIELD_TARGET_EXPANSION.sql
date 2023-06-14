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


--drop view if exists dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION as
select 
	 lower(pfter.pipeline_name) as  pipeline_name
	,upper(pfter.field_name) as field_name
	,upper(trim(field_type)) as field_type
	,lower(table_name) as table_name
	,upper(coalesce (column_name,pfter.field_name)) as column_name
	,upper(coalesce(recursion_name,'')) as recursion_name
	,coalesce(upper(field_group) ,'_A_') field_group
	,upper(coalesce (column_type,field_type)) as column_type
	,coalesce(to_number(prio_in_key_hash,'9'),0) as prio_in_key_hash
	,coalesce(exclude_from_key_hash::boolean,false) as exclude_from_key_hash
	,coalesce(to_number(prio_in_diff_hash,'9'),0) as prio_in_diff_hash
	,coalesce(exclude_from_diff_hash::boolean,false) as exclude_from_diff_hash
	,coalesce(needs_encryption::boolean,false) as needs_encryption
	,field_comment
	,coalesce (column_content_comment ,field_comment ) column_content_comment
from dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw pfter
join dv_pipeline_description.dvpd_pipeline_field_properties_raw pfpr on pfpr.pipeline = pfter.pipeline_name 
																	and pfpr.field_name = pfter.field_name 
;

comment on view dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION is
 'Fields and their mapping to tables of the pipeline. (cleased, normalized and enriched)';																

-- select * from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION order by pipeline_name ,field_name,table_name;



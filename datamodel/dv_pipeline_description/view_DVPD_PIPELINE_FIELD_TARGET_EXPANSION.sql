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

with target_usage as (
select lower(pipeline_name) pipeline_name
, lower(table_name) table_name 
, upper(coalesce (column_name,field_name)) as column_name
, count(distinct upper(field_name)) column_mapping_count
from dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw
group by 1,2,3
)
select 
	 lower(pfter.pipeline_name) as  pipeline_name
	,upper(pfter.field_name) as field_name
	,upper(trim(field_type)) as field_type
	,lower(pfter.table_name) as table_name
	,upper(coalesce (pfter.column_name,pfter.field_name)) as column_name
	,case when relation_name is not null then upper(relation_name) 
		  when column_mapping_count>1    then '/'
		  								 else '*' end as relation_name
	,upper(coalesce (column_type,field_type)) as column_type
	,coalesce(to_number(prio_in_key_hash,'9'),50000) as prio_in_key_hash
	,coalesce(exclude_from_key_hash::boolean,false) as exclude_from_key_hash
	,coalesce(to_number(prio_in_diff_hash,'9'),50000) as prio_in_diff_hash
	,coalesce(exclude_from_change_detection::boolean,false) as exclude_from_change_detection
	,coalesce(needs_encryption::boolean,false) as needs_encryption
	,field_comment
	,coalesce (column_content_comment ,field_comment ) column_content_comment
from dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw pfter
join dv_pipeline_description.dvpd_pipeline_field_properties_raw pfpr on pfpr.pipeline = pfter.pipeline_name 
																	and pfpr.field_name = pfter.field_name 
join target_usage tu on tu.pipeline_name = lower(pfter.pipeline_name)	
					and tu.table_name = lower(pfter.table_name) 
					and tu.column_name = upper(coalesce (pfter.column_name,pfter.field_name)) 
;

comment on view dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION is
 'Fields and their mapping to tables of the pipeline. (cleased, normalized and enriched)';																

-- select * from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION order by pipeline_name ,field_name,table_name;



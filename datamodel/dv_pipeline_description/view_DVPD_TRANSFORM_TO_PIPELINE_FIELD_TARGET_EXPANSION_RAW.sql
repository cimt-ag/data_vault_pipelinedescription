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


--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_TARGET_EXPANSION_RAW cascade;

create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_TARGET_EXPANSION_RAW as

with source_fields AS (
Select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
	,json_array_elements(dvpd_json->'fields')->'targets' as targets
	,json_array_elements(dvpd_json->'fields')->>'field_comment' as field_comment
from dv_pipeline_description.dvpd_dictionary dt 
)
,target_expansion AS (
select 
	 pipeline_name
	,field_name
	,field_comment
	,json_array_elements(targets)->>'table_name' as table_name
	,json_array_elements(targets)->>'column_name' as column_name
	,json_array_elements(targets)->>'column_type' as column_type
	,json_array_elements(targets)->'field_groups' as field_groups
	,json_array_elements(targets)->>'prio_in_key_hash' as prio_in_key_hash
	,json_array_elements(targets)->>'exclude_from_key_hash' as exclude_from_key_hash
	,json_array_elements(targets)->>'recursion_name' as recursion_name
	,json_array_elements(targets)->>'prio_in_diff_hash' as prio_in_diff_hash
	,json_array_elements(targets)->>'exclude_from_diff_hash' as exclude_from_diff_hash
	,json_array_elements(targets)->>'needs_encryption' as needs_encryption
	,json_array_elements(targets)->>'column_content_comment' as column_content_comment
	,json_array_elements(targets)->'hash_cleansing_rules' as hash_cleansing_rules
from source_fields
)
, field_group_expansion as (
	select 
	pipeline_name 
	,field_name 
	,table_name
	,column_name 
	,recursion_name
	,json_array_elements_text(field_groups) field_group
	from target_expansion
	)
select 
	te1.pipeline_name 
	,te1.field_name 
	,te1.table_name 
	,te1.column_name 
	,field_group
	,te1.recursion_name 
	,column_type
	,prio_in_key_hash
	,exclude_from_key_hash
	,prio_in_diff_hash
	,exclude_from_diff_hash
	,column_content_comment
from target_expansion te1
left join field_group_expansion fge on fge.pipeline_name = te1.pipeline_name 
									and fge.field_name = te1.field_name 
									and fge.table_name = te1.table_name 
									and coalesce (fge.column_name,'') = coalesce (te1.column_name,'')
									and coalesce (fge.recursion_name,'') = coalesce ( te1.recursion_name,'') ; 


comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_TARGET_EXPANSION_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';

-- select * from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION order by pipeline ,field_name,table_name;



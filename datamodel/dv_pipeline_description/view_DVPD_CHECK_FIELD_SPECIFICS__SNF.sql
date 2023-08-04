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


-- drop view if exists dv_pipeline_description.DVPD_CHECK_FIELD_SPECIFICS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_FIELD_SPECIFICS as

with target_existence as (
select
  sfm.pipeline_name
  ,'Field'::TEXT  object_type 
  ,sfm.field_name object_name
  ,'DVPD_CHECK_FIELD_SPECIFICS'::text  check_ruleset
  ,case when pdt.table_name is null then 'Unknown table_name: '|| sfm.table_name   
    else 'ok' end  message
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm
left join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = sfm.pipeline_name 
										and pdt.table_name = sfm.table_name 
)
, target_aggregation as (
select 
pipeline_name
,table_name
,column_name
,column_type
,prio_in_key_hash
,exclude_from_key_hash
,prio_in_diff_hash
,exclude_from_change_detection
,needs_encryption 
,array_to_string(array_agg( field_name),'|') field_list
--,array_to_string(array_agg(relation_name),'|') relation_list
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm
group by 1,2,3,4,5,6,7,8,9
)
, target_constellation_count as (
select 
pipeline_name , table_name ,column_name
,  array_to_string(array_agg(distinct field_list),'|')
|| '[type:'||array_to_string(array_agg (distinct  column_type),'|')||'] '
|| '[prio_in_key:'||array_to_string(array_agg (distinct cast(prio_in_key_hash as varchar)),'|')||'] '
|| '[exclude from key:'||array_to_string(array_agg (distinct cast(exclude_from_key_hash as varchar)),'|')||'] '
|| '[prio_in_diff_hash:'||array_to_string(array_agg (distinct cast(prio_in_diff_hash as varchar)),'|')||'] '
|| '[exclude_from_change_detection:'||array_to_string(array_agg (distinct cast(exclude_from_change_detection as varchar)),'|')||'] '
|| '[needs_encryption:'||array_to_string(array_agg (distinct cast(needs_encryption as varchar)),'|')||'] '
		as comparison_report
,count(1) constellation_count
from target_aggregation 
group by 1,2,3
)
, target_specification_consistency as ( 
select
  pipeline_name
  ,'column'::TEXT  object_type 
  ,table_name||'.'||column_name object_name
  ,'DVPD_CHECK_FIELD_SPECIFICS'::text  check_ruleset
  ,case when constellation_count >1  then 'Inconsistent specifiation: '|| comparison_report   
    else 'ok' end  message
from target_constellation_count
)
, field_type_declaration_test as (
select -- field type declaration
  dpfp.pipeline pipeline_name
  ,'Field'::TEXT  object_type 
  ,dpfp.field_name object_name
  ,'DVPD_CHECK_FIELD_SPECIFICS'::text  check_ruleset
  ,case when dpfp.field_type is null or length(trim(dpfp.field_type))<1 then 'field_type not declared' 
    else 'ok' end  message
from dv_pipeline_description.dvpd_pipeline_field_properties dpfp 
)
select * from target_existence
union
select * from target_specification_consistency
union
select * from field_type_declaration_test
;

comment on view dv_pipeline_description.DVPD_CHECK_FIELD_SPECIFICS IS
	'Checks for bad fields properties (missing targets, inconsistent mappings to same target column, missing properties)';

-- select * from dv_pipeline_description.DVPD_CHECK_FIELD_SPECIFICS order by 1,2,3




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


--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_RAW as 

with data_vault_schema_basics as (
	select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	, json_array_elements(dvpd_json->'data_vault_model')->>'schema_name' as schema_name
	, json_array_elements(dvpd_json->'data_vault_model')->'tables' as tables
	from dv_pipeline_description.dvpd_dictionary dt 
)
select
pipeline_name
, schema_name
, json_array_elements(tables)->>'table_name'  as table_name
, json_array_elements(tables)->>'table_stereotype' as table_stereotype
, json_array_elements(tables)->>'hub_key_column_name' as hub_key_column_name
, json_array_elements(tables)->>'link_key_column_name' as link_key_column_name
, json_array_elements(tables)->>'diff_hash_column_name' as diff_hash_column_name
, json_array_elements(tables)->>'satellite_parent_table' as satellite_parent_table
, json_array_elements(tables)->>'tracked_relation_name' as tracked_relation_name
, json_array_elements(tables)->>'is_link_without_sat' as is_link_without_sat
, json_array_elements(tables)->>'is_enddated' as is_enddated 
, json_array_elements(tables)->>'model_profile_name' as model_profile_name 
, json_array_elements(tables)->>'table_content_comment' as table_content_comment
, json_array_elements(tables)->>'has_deletion_flag' as has_deletion_flag
, json_array_elements(tables)->>'uses_diff_hash' as uses_diff_hash
, json_array_elements(tables)->>'compare_criteria' as compare_criteria
from data_vault_schema_basics;

comment on view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_DV_TABLE_RAW is
 'technical helper view. needed by the transformation of the dvpd json into the relational model. Contains postgresql specific json syntax';

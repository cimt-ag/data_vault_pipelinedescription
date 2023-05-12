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

--drop function DVPD_LOAD_PIPELINE_TO_RAW(varchar);
create or replace function dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW(
   pipeline_to_load varchar
)
returns boolean
language plpgsql    
as 
$$
declare
   update_persisted_elements varchar; 
begin	

	
/* Dont do anything when compiler is disabled */	
select property_value
INTO update_persisted_elements
FROM dv_pipeline_description.DVPD_COMPILER_SETTING
where property_name='update_persisted_elements';
	

if (not(update_persisted_elements::bool)) then
  return false;
end if;

	/* Load json scripts into relational raw model */
truncate table dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw;
INSERT
	INTO
	dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw
(pipeline_name,
	field_name,
	target_table,
	target_column_name,
	field_group,
	recursion_name,
	target_column_type,
	prio_in_key_hash,
	exclude_from_key_hash,
	prio_in_diff_hash,
	exclude_from_diff_hash,
	column_content_comment)
SELECT
	pipeline_name,
	field_name,
	target_table,
	target_column_name,
	field_group,
	recursion_name,
	target_column_type,
	prio_in_key_hash,
	exclude_from_key_hash,
	prio_in_diff_hash,
	exclude_from_diff_hash,
	column_content_comment
FROM
	dv_pipeline_description.dvpd_transform_to_pipeline_field_target_expansion_raw;

truncate
	table dv_pipeline_description.dvpd_pipeline_field_properties_raw;

insert
	into
	dv_pipeline_description.dvpd_pipeline_field_properties_raw
(pipeline,
	field_name,
	field_type,
	field_position,
	parsing_expression,
	needs_encryption,
	field_comment)
select
	pipeline,
	field_name,
	field_type,
	field_position,
	parsing_expression,
	needs_encryption,
	field_comment
from
	dv_pipeline_description.dvpd_transform_to_pipeline_field_properties_raw;

truncate table dv_pipeline_description.dvpd_pipeline_dv_table_raw;
insert
	into
	dv_pipeline_description.dvpd_pipeline_dv_table_raw
(pipeline_name,
	schema_name,
	table_name,
	stereotype,
	hub_key_column_name,
	link_key_column_name,
	diff_hash_column_name,
	satellite_parent_table,
	is_link_without_sat,
	is_enddated,
	has_deletion_flag,
	uses_diff_hash,
	model_profile_name,
	table_content_comment)
select
	pipeline_name,
	schema_name,
	table_name,
	stereotype,
	hub_key_column_name,
	link_key_column_name,
	diff_hash_column_name,
	satellite_parent_table,
	is_link_without_sat,
	is_enddated,
	has_deletion_flag,
	uses_diff_hash,
	model_profile_name,
	table_content_comment
from
	dv_pipeline_description.dvpd_transform_to_pipeline_dv_table_raw;


truncate table dv_pipeline_description.dvpd_pipeline_dv_table_field_group_raw;
insert
	into
	dv_pipeline_description.dvpd_pipeline_dv_table_field_group_raw
(pipeline_name,
	table_name,
	field_group)
select
	pipeline_name,
	table_name,
	field_group
from
	dv_pipeline_description.dvpd_transform_to_pipeline_dv_table_field_group_raw;


truncate table dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw;
insert
	into
	dv_pipeline_description.dvpd_pipeline_dv_table_link_parent_raw
(pipeline_name,
	table_name,
	parent_table_name,
	is_recursive_relation,
	recursion_name,link_parent_order,recursive_parent_order)
select
	pipeline_name,
	table_name,
	parent_table_name,
	is_recursive_relation,
	recursion_name,
	link_parent_order,
	recursive_parent_order
from
	dv_pipeline_description.dvpd_transform_to_pipeline_dv_table_link_parent_raw;

TRUNCATE TABLE  dv_pipeline_description.dvpd_pipeline_properties_raw;

insert
	into
	dv_pipeline_description.dvpd_pipeline_properties_raw
(pipeline_name,
	dvpd_version,
	pipeline_revision_tag,
	pipeline_comment,
	record_source_name_expression,
	fetch_module_name,
	model_profile_name)
select
	pipeline_name,
	dvpd_version,
	pipeline_revision_tag,
	pipeline_comment,
	record_source_name_expression,
	fetch_module_name,
	model_profile_name
from
	dv_pipeline_description.dvpd_transform_to_pipeline_properties_raw;

truncate table dv_pipeline_description.dvpd_pipeline_dv_table_driving_key_raw;
insert
	into
	dv_pipeline_description.dvpd_pipeline_dv_table_driving_key_raw
(	pipeline_name,
	table_name,
	driving_key)
select
	pipeline_name,
	table_name,
	driving_key
from
	dv_pipeline_description.dvpd_transform_to_pipeline_dv_table_driving_key_raw;


REFRESH MATERIALIZED VIEW dv_pipeline_description.DVPD_PIPELINE_DV_COLUMN;

return true;

end;
$$;

 comment on function dv_pipeline_description.DVPD_LOAD_PIPELINE_TO_RAW (profile_to_load varchar) is
 	'Helper function to convert and load the dvpd document into the relational tables';

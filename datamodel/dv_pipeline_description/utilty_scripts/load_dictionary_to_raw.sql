
truncate table dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw;
INSERT
	INTO
	dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw
(pipeline_name,
	field_name,
	target_table,
	target_column_name,
	field_group,
	recursion_suffix,
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
	recursion_suffix,
	target_column_type,
	prio_in_key_hash,
	exclude_from_key_hash,
	prio_in_diff_hash,
	exclude_from_diff_hash,
	column_content_comment
FROM
	dv_pipeline_description.dvpd_transform_to_pipeline_field_target_expansion_raw;
;


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
	is_historized)
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
	is_historized
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
	recursion_name)
select
	pipeline_name,
	table_name,
	parent_table_name,
	is_recursive_relation,
	recursion_name
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
	fetch_module_name)
select
	pipeline_name,
	dvpd_version,
	pipeline_revision_tag,
	pipeline_comment,
	record_source_name_expression,
	fetch_module_name
from
	dv_pipeline_description.dvpd_transform_to_pipeline_properties_raw;


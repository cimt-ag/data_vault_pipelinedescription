
-- DROP TABLE dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION_RAW (
	pipeline_name text NULL,
	field_name text NULL,
	target_table text NULL,
	target_column_name text NULL,
	field_group text NULL,
	recursion_suffix text NULL,
	target_column_type text NULL,
	prio_in_key_hash text NULL,
	exclude_from_key_hash text NULL,
	prio_in_diff_hash text NULL,
	exclude_from_diff_hash text NULL,
	column_content_comment text NULL
);

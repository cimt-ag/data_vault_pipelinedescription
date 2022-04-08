
-- DROP TABLE dv_pipeline_description.dvpd_pipeline_target_table_raw;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE_RAW (
	pipeline_name text NULL,
	schema_name text NULL,
	table_name text NULL,
	stereotype text NULL,
	hub_key_column_name text NULL,
	link_key_column_name text NULL,
	diff_hash_column_name text NULL,
	satellite_parent_table text NULL,
	is_link_without_sat text NULL,
	is_historized text NULL
);
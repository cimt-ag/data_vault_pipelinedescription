
-- DROP TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_RAW cascade;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_RAW (
	meta_inserted_at timestamp default now(),
	pipeline_name text NULL,
	schema_name text NULL,
	table_name text NULL,
	stereotype text NULL,
	hub_key_column_name text NULL,
	link_key_column_name text NULL,
	diff_hash_column_name text NULL,
	satellite_parent_table text NULL,
	is_link_without_sat text NULL,
	is_historized text NULL,
	model_profile_name text NULL
);
-- DROP TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_FIELD_GROUP_RAW;

CREATE TABLE dv_pipeline_description.DVPD_PIPELINE_DV_TABLE_FIELD_GROUP_RAW (
	meta_inserted_at timestamp default now(),
	pipeline_name text NULL,
	table_name text NULL,
	field_group text NULL
);
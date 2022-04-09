
-- DROP TABLE dv_pipeline_description.dvpd_pipeline_field_properties_raw;

CREATE TABLE dv_pipeline_description.dvpd_pipeline_field_properties_raw (
	meta_inserted_at timestamp default now(),
	pipeline text NULL,
	field_name text NULL,
	field_type text NULL,
	field_position int8 NULL,
	parsing_expression text NULL,
	field_comment text NULL
);
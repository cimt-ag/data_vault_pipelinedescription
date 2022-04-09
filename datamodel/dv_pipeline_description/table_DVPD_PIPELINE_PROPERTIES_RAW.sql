-- DROP TABLE dv_pipeline_description.dvpd_pipeline_properties_raw;

CREATE TABLE dv_pipeline_description.dvpd_pipeline_properties_raw (
	pipeline_name text NULL,
	dvpd_version text NULL,
	pipeline_revision_tag text NULL,
	pipeline_comment text NULL,
	record_source_name_expression text NULL,
	fetch_module_name text NULL
);
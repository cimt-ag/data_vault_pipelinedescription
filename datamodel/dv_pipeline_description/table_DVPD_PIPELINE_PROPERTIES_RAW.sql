-- DROP TABLE dv_pipeline_description.dvpd_pipeline_properties_raw cascade;

CREATE TABLE dv_pipeline_description.dvpd_pipeline_properties_raw (
	meta_inserted_at timestamp default now(),
	pipeline_name text not NULL,
	dvpd_version text NULL,
	pipeline_revision_tag text NULL,
	pipeline_comment text NULL,
	record_source_name_expression text NULL,
	fetch_module_name text NULL,
	model_profile_name text NULL,
	primary key (pipeline_name)
);
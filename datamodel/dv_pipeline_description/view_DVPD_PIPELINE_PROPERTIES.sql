--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROPERTIES cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_PROPERTIES as 

SELECT
	lower(pipeline_name) pipeline_name,
	dvpd_version,
	pipeline_revision_tag,
	pipeline_comment,
	record_source_name_expression,
	lower(fetch_module_name) fetch_module_name
FROM 
	dv_pipeline_description.dvpd_pipeline_properties_raw;



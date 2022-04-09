--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_PROPERTIES_RAW cascade;
create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_PROPERTIES_RAW as 

select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	,dvpd_json ->>'dvpd_version' as dvpd_version
	,dvpd_json ->>'pipeline_revision_tag' as pipeline_revision_tag
	,dvpd_json ->>'pipeline_comment' as pipeline_comment
	,dvpd_json ->>'record_source_name_expression' as record_source_name_expression
	,dvpd_json ->'data_extraction'->>'fetch_module_name' as fetch_module_name
from dv_pipeline_description.dvpd_dictionary dt 
;


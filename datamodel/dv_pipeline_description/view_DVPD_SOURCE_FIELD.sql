drop view if exists dv_pipeline_description.DVPD_SOURCE_FIELD cascade;
create or replace view dv_pipeline_description.DVPD_SOURCE_FIELD as

Select 
	dvpd_json ->>'pipeline_name' as pipeline
	,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
	,json_array_elements(dvpd_json->'fields')->>'technical_type' as field_type
	,json_array_elements(dvpd_json->'fields')->>'field_position' as field_position
	,json_array_elements(dvpd_json->'fields')->>'parsing_expression' as parsing_expression
	,json_array_elements(dvpd_json->'fields')->'uniqueness_groups' as uniqueness_groups
	,json_array_elements(dvpd_json->'fields')->>'field_comment' as field_comment
from dv_pipeline_description.dvpd_dictionary dt


-- select * from dv_pipeline_description.DVPD_SOURCE_FIELD order by pipeline ,field_position;
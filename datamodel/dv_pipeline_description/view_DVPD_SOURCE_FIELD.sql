--drop view if exists dv_pipeline_description.DVPD_SOURCE_FIELD cascade;
create or replace view dv_pipeline_description.DVPD_SOURCE_FIELD as

with raw_field_list as( 
Select 
	dvpd_json ->>'pipeline_name' as pipeline
	,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
	,json_array_elements(dvpd_json->'fields')->>'technical_type' as field_type
	,json_array_elements(dvpd_json->'fields')->>'field_position' as explicit_field_position
	,json_array_elements(dvpd_json->'fields')->>'parsing_expression' as parsing_expression
	,json_array_elements(dvpd_json->'fields')->'uniqueness_groups' as uniqueness_groups
	,json_array_elements(dvpd_json->'fields')->>'field_comment' as field_comment
	,row_number() over (PARTITION BY dvpd_json ->>'pipeline_name') as keep_array_order -- must onyl exist to provide originalarray order in resulset
from dv_pipeline_description.dvpd_dictionary dt
)
select
 pipeline,
 field_name,
 field_type,
 coalesce(explicit_field_position::integer,row_number() over (PARTITION BY pipeline )) field_position,
 parsing_expression,
 uniqueness_groups,
 field_comment
from raw_field_list;


-- select * from dv_pipeline_description.DVPD_SOURCE_FIELD order by pipeline ,field_position;


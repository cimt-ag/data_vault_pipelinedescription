--drop view if exists dv_pipeline_description.DVPD_PIPELINE_FIELD_PARSE_PROPERTIES cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_FIELD_PROPERTIES as


select
 pipeline
 ,upper(field_name) as field_name
 ,upper(field_type) as field_type
 ,field_position  
 ,parsing_expression
 ,coalesce (needs_encryption,false)
 ,field_comment
from dv_pipeline_description.dvpd_pipeline_field_properties_raw;


-- select * from dv_pipeline_description.DVPD_SOURCE_FIELD order by pipeline ,field_position;


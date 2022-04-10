--drop view if exists dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_TARGET_EXPANSION_RAW cascade;

create or replace view dv_pipeline_description.DVPD_TRANSFORM_TO_PIPELINE_FIELD_TARGET_EXPANSION_RAW as

with source_fields AS (
Select 
	dvpd_json ->>'pipeline_name' as pipeline_name
	,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
	,json_array_elements(dvpd_json->'fields')->'targets' as targets
	,json_array_elements(dvpd_json->'fields')->>'field_comment' as field_comment
from dv_pipeline_description.dvpd_dictionary dt 
)
,target_expansion AS (
select 
	 pipeline_name
	,field_name
	,field_comment
	,json_array_elements(targets)->>'table_name' as target_table
	,json_array_elements(targets)->>'target_column_name' as target_column_name
	,json_array_elements(targets)->>'target_column_type' as target_column_type
	,json_array_elements(targets)->'field_groups' as field_groups
	,json_array_elements(targets)->>'prio_in_key_hash' as prio_in_key_hash
	,json_array_elements(targets)->>'exclude_from_key_hash' as exclude_from_key_hash
	,json_array_elements(targets)->>'recursion_suffix' as recursion_suffix
	,json_array_elements(targets)->>'prio_in_diff_hash' as prio_in_diff_hash
	,json_array_elements(targets)->>'exclude_from_diff_hash' as exclude_from_diff_hash
	,json_array_elements(targets)->>'needs_encryption' as needs_encryption
	,json_array_elements(targets)->>'column_content_comment' as column_content_comment
	,json_array_elements(targets)->'hash_cleansing_rules' as hash_cleansing_rules
from source_fields
)
, field_group_expansion as (
	select 
	pipeline_name 
	,field_name 
	,target_table
	,target_column_name 
	,recursion_suffix
	,json_array_elements_text(field_groups) field_group
	from target_expansion
	)
select 
	te1.pipeline_name 
	,te1.field_name 
	,te1.target_table 
	,te1.target_column_name 
	,field_group
	,te1.recursion_suffix 
	,target_column_type
	,prio_in_key_hash
	,exclude_from_key_hash
	,prio_in_diff_hash
	,exclude_from_diff_hash
	,column_content_comment
from target_expansion te1
left join field_group_expansion fge on fge.pipeline_name = te1.pipeline_name 
									and fge.field_name = te1.field_name 
									and fge.target_table = te1.target_table 
									and coalesce (fge.target_column_name,'') = coalesce (te1.target_column_name,'')
									and coalesce (fge.recursion_suffix,'') = coalesce ( te1.recursion_suffix,'') ; 



-- select * from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION order by pipeline ,field_name,target_table;



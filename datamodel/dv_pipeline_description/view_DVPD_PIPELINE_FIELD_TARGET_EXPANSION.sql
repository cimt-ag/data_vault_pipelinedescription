--drop view if exists dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION as

with source_fields AS (
Select 
dvpd_json ->>'pipeline_name' as pipeline
,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
,json_array_elements(dvpd_json->'fields')->>'technical_type' as field_type
,json_array_elements(dvpd_json->'fields')->'targets' as targets
,json_array_elements(dvpd_json->'fields')->>'field_comment' as field_comment
from dv_pipeline_description.dvpd_dictionary dt 
)
,target_expansion AS (
select 
 pipeline
,field_name
,field_type
,field_comment
,json_array_elements(targets)->>'table_name' as target_table
,json_array_elements(targets)->>'target_column_name' as target_column_name
,json_array_elements(targets)->>'target_column_type' as target_column_type
,json_array_elements(targets)->'field_groups' as field_groups
,json_array_elements(targets)->>'prio_in_key_hash' as prio_in_key_hash
,json_array_elements(targets)->>'exclude_from_key_hash' as exclude_from_key_hash
,json_array_elements(targets)->>'hierarchy_key_suffix' as hierarchy_key_suffix
,json_array_elements(targets)->>'prio_in_diff_hash' as prio_in_diff_hash
,json_array_elements(targets)->>'exclude_from_diff_hash' as exclude_from_diff_hash
,json_array_elements(targets)->>'is_encrypted' as is_encrypted
,json_array_elements(targets)->>'column_content_comment' as column_content_comment
,json_array_elements(targets)->'hash_cleansing_rules' as hash_cleansing_rules
from source_fields
)
select 
 lower(pipeline) as  pipeline
,upper(field_name) as field_name
,upper(field_type) as field_type
,lower(target_table) as target_table
,upper(coalesce (target_column_name,field_name)) as target_column_name
,case when field_groups is not null then upper(json_array_elements_text(field_groups)) else '_A_' end as field_group
,upper(coalesce(hierarchy_key_suffix,'')) as hierarchy_key_suffix
,upper(coalesce (target_column_type,field_type)) as target_column_type
,coalesce(to_number(prio_in_key_hash,'9'),0) as prio_in_hashkey
,coalesce(exclude_from_key_hash::bool,false) as exclude_from_key_hash
,coalesce(to_number(prio_in_diff_hash,'9'),0) as prio_in_diff_hash
,coalesce(exclude_from_diff_hash::bool,false) as exclude_from_diff_hash
,coalesce(is_encrypted::bool,false) as is_encrypted
,hash_cleansing_rules
,field_comment
,coalesce (column_content_comment ,field_comment ) column_content_comment
from target_expansion


-- select * from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION order by pipeline ,field_name,target_table;



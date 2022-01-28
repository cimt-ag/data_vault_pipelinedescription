--drop view if exists dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING cascade;
create or replace view dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING as

with source_fields AS (
Select 
dvpd_json ->>'pipeline_name' as pipeline
,json_array_elements(dvpd_json->'fields')->>'field_name' as field_name
,json_array_elements(dvpd_json->'fields')->>'technical_type' as field_type
,json_array_elements(dvpd_json->'fields')->>'parsing_expression' as parsing_expression
,json_array_elements(dvpd_json->'fields')->'targets' as targets
,json_array_elements(dvpd_json->'fields')->'uniqeness_groups' as uniqeness_groups
,json_array_elements(dvpd_json->'fields')->'field_comment' as field_comment
from dv_pipeline_description.dvpd_dictionary dt 
)
,target_expansion AS (
select 
 pipeline
,field_name
,field_type
,parsing_expression
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
,json_array_elements(targets)->'hash_cleansing_rules' as hash_cleansing_rules
from source_fields
)
,field_group_expansion_and_normalization AS (
select 
 lower(pipeline) as  pipeline
,case when field_groups is not null then json_array_elements_text(field_groups) else '_A_' end as field_group
,upper(field_name) as field_name
,upper(field_type) as field_type
,lower(target_table) as target_table
,upper(coalesce (target_column_name,field_name)) as target_column_name
,upper(coalesce(hierarchy_key_suffix,'')) as hierarchy_key_suffix
,upper(coalesce (target_column_type,field_type)) as target_column_type
,coalesce(to_number(prio_in_key_hash,'9'),0) as prio_in_hashkey
,coalesce(exclude_from_key_hash::bool,false) as exclude_from_key_hash
,coalesce(to_number(prio_in_diff_hash,'9'),0) as prio_in_diff_hash
,coalesce(exclude_from_diff_hash::bool,false) as exclude_from_diff_hash
,coalesce(is_encrypted::bool,false) as is_encrypted
,parsing_expression
,hash_cleansing_rules
from target_expansion
)
,hierachy_partner_field as (
select 
	origin.pipeline
	,origin.field_group
	,origin.target_table
	,origin.target_column_name
	,origin.field_name origin_field_name
	,partner.field_name partner_field_name
	,partner.hierarchy_key_suffix partner_hierarchy_key_suffix
from field_group_expansion_and_normalization origin
join field_group_expansion_and_normalization partner on partner.pipeline=origin.pipeline
							and partner.field_group=origin.field_group
							and partner.target_table=origin.target_table
							and partner.target_column_name = origin.target_column_name
							and partner.field_name <>origin.field_name
where partner.hierarchy_key_suffix <>''
)
-- finale structure (adding process block information)
select 
 fgean.*
 ,case when hierarchy_key_suffix <>''  then fgean.field_group||'_0_'||hierarchy_key_suffix
 	   when partner_hierarchy_key_suffix is not null and partner_hierarchy_key_suffix <> '' 	
 	   									then fgean.field_group||'_1_'||partner_hierarchy_key_suffix
 	   else fgean.field_group end process_block
from field_group_expansion_and_normalization fgean
left join hierachy_partner_field hpf on  hpf.pipeline=fgean.pipeline
							and hpf.field_group=fgean.field_group
							and hpf.target_table=fgean.target_table
							and hpf.target_column_name = fgean.target_column_name;

-- select * from dv_pipeline_description.DVPD_SOURCE_FIELD_MAPPING order by pipeline ,field_name,target_table;



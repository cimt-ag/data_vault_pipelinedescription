--drop view if exists dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION cascade;
create or replace view dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION as
select 
	 lower(pfter.pipeline_name) as  pipeline_name
	,upper(pfter.field_name) as field_name
	,upper(trim(field_type)) as field_type
	,lower(target_table) as target_table
	,upper(coalesce (target_column_name,pfter.field_name)) as target_column_name
	,upper(coalesce(recursion_name,'')) as recursion_name
	,coalesce(upper(field_group) ,'_A_') field_group
	,upper(coalesce (target_column_type,field_type)) as target_column_type
	,coalesce(to_number(prio_in_key_hash,'9'),0) as prio_in_key_hash
	,coalesce(exclude_from_key_hash::bool,false) as exclude_from_key_hash
	,coalesce(to_number(prio_in_diff_hash,'9'),0) as prio_in_diff_hash
	,coalesce(exclude_from_diff_hash::bool,false) as exclude_from_diff_hash
	,coalesce(needs_encryption::bool,false) as needs_encryption
	,field_comment
	,coalesce (column_content_comment ,field_comment ) column_content_comment
from dv_pipeline_description.dvpd_pipeline_field_target_expansion_raw pfter
join dv_pipeline_description.dvpd_pipeline_field_properties_raw pfpr on pfpr.pipeline = pfter.pipeline_name 
																	and pfpr.field_name = pfter.field_name 
;

																

-- select * from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION order by pipeline_name ,field_name,target_table;



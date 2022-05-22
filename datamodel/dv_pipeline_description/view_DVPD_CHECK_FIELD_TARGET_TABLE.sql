-- drop view if exists dv_pipeline_description.DVPD_CHECK_FIELD_TARGET_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_FIELD_TARGET_TABLE as

with target_existence as (
select
  sfm.pipeline_name
  ,'Field'::TEXT  object_type 
  ,sfm.field_name object_name
  ,'DVPD_CHECK_FIELD_TARGET_TABLE'::text  check_ruleset
  ,case when pdt.table_name is null then 'Unknown target_table: '|| sfm.target_table   
    else 'ok' end  message
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm
left join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = sfm.pipeline_name 
										and pdt.table_name = sfm.target_table 
)
, target_aggregation as (
select 
pipeline_name
,target_table
,target_column_name
,target_column_type
,prio_in_key_hash
,exclude_from_key_hash
,prio_in_diff_hash
,exclude_from_diff_hash
,needs_encryption 
,string_agg( field_name,'|') field_list
,string_agg(recursion_name,'|') recursion_list
,string_agg(field_group,'|') field_group_list
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION sfm
group by 1,2,3,4,5,6,7,8,9
)
, target_constellation_count as (
select 
pipeline_name , target_table ,target_column_name
,  string_agg(distinct field_list,'|')
|| '[type:'||string_agg (distinct  target_column_type,'|')||'] '
|| '[prio_in_key:'||string_agg (distinct cast(prio_in_key_hash as varchar),'|')||'] '
|| '[exclude from key:'||string_agg (distinct cast(exclude_from_key_hash as varchar),'|')||'] '
|| '[prio_in_diff_hash:'||string_agg (distinct cast(prio_in_diff_hash as varchar),'|')||'] '
|| '[exclude_from_diff_hash:'||string_agg (distinct cast(exclude_from_diff_hash as varchar),'|')||'] '
|| '[needs_encryption:'||string_agg (distinct cast(needs_encryption as varchar),'|')||'] '
		as comparison_report
,count(1) constellation_count
from target_aggregation 
group by 1,2,3
)
, target_specification_consistency as ( 
select
  pipeline_name
  ,'column'::TEXT  object_type 
  ,target_table||'.'||target_column_name object_name
  ,'DVPD_CHECK_FIELD_TARGET_TABLE'::text  check_ruleset
  ,case when constellation_count >1  then 'Inconsistent specifiation: '|| comparison_report   
    else 'ok' end  message
from target_constellation_count
)
select * from target_existence
union
select * from target_specification_consistency
;

-- select * from dv_pipeline_description.DVPD_CHECK_FIELD_TARGET_TABLE order by 1,2,3




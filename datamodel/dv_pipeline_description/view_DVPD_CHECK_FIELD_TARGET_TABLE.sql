-- drop view if exists dv_pipeline_description.DVPD_CHECK_FIELD_TARGET_TABLE cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_FIELD_TARGET_TABLE as

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
;

-- select * from dv_pipeline_description.DVPD_CHECK_FIELD_TARGET_TABLE order by 1,2,3




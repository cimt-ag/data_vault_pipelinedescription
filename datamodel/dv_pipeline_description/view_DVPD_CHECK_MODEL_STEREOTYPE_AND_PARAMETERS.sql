-- drop view if exists dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS as

select
  pipeline
  ,'Table'::TEXT  object_type 
  ,table_name object_name
  ,'CHECK_MODEL_STEREOTYPE_AND_PARAMETERS'::text  check_ruleset
  ,case when scm.stereotype is null then 'Unknown stereotype:'||dmtpp.stereotype 
  		when scm.needs_hub_key_column_name = 1 and dmtpp.hub_key_column_name is null 
  			 then 'hub_key_column_name is not declared'
  		when scm.needs_link_key_column_name = 1 and dmtpp.link_key_column_name is null 
  			 then 'link_key_column_name is not declared'
  		when scm.needs_sattelite_parent_table = 1 and dmtpp.satellite_parent_table  is null 
  			 then 'satellite_parent_table is not declared'
  		when scm.needs_link_parent_tables  = 1 and dmtpp.link_parent_tables  is null 
  			 then 'link_parent_tables are not declared'
    else 'ok' end  message
from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE dmtpp
left join dv_pipeline_description.dvpd_stereotype_check_matrix scm on scm.stereotype = dmtpp.stereotype 
;

-- select * from dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS order by 1,2,3




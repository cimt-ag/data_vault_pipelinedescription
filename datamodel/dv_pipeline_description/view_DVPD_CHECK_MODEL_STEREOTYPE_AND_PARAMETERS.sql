-- drop view if exists dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS as

with link_parent_table_count as (
select pipeline_name ,table_name ,count(link_parent_table)
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
where not is_recursive_relation 
group by 1,2
)
select
  pdt.pipeline_name
  ,'Table'::TEXT  object_type 
  ,pdt.table_name object_name
  ,'CHECK_MODEL_STEREOTYPE_AND_PARAMETERS'::text  check_ruleset
  ,case when scm.stereotype is null then 'Unknown stereotype:'||pdt.stereotype 
  		when scm.needs_hub_key_column_name = 1 and pdt.hub_key_column_name is null 
  			 then 'hub_key_column_name is not declared'
  		when scm.needs_link_key_column_name = 1 and pdt.link_key_column_name is null 
  			 then 'link_key_column_name is not declared'
  		when scm.needs_sattelite_parent_table = 1 and pdt.satellite_parent_table  is null 
  			 then 'satellite_parent_table is not declared'
  		when scm.needs_link_parent_tables  = 1 and lptc.table_name  is null 
  			 then 'link_parent_tables are not declared'
    else 'ok' end  message
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join dv_pipeline_description.dvpd_stereotype_check_matrix scm on scm.stereotype = pdt.stereotype 
left join link_parent_table_count lptc  on lptc.pipeline_name = pdt.pipeline_name 
										and lptc.table_name = pdt.table_name 

;

-- select * from dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS order by 1,2,3




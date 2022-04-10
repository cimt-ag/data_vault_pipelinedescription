-- drop view if exists dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS as

with all_parent_relations as (
select 
	pipeline_name
	,lower(table_name)  table_name
	,lower(parent_table) parent_table
from (
select 
		pipeline_name 
		,ptt.table_name
		,dmlp.parent_table_name parent_table
	from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE ptt
	join dv_pipeline_description.dvpd_dv_model_link_parent dmlp on dmlp.table_name = ptt.table_name  
	union
	select 
		pipeline_name 
		,table_name
		,satellite_parent_table  parent_table
	from dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE
	where satellite_parent_table is not null
	) raw_union
)
select
  apr.pipeline_name
  ,'Table'::TEXT  object_type 
  ,apr.table_name object_name
  ,'DVPD_CHECK_MODEL_RELATIONS'::text  check_ruleset
  ,case when dmtpp.table_name is null then 'Unknown parent_table: '|| apr.parent_table  
    else 'ok' end  message
from all_parent_relations apr
left join dv_pipeline_description.DVPD_PIPELINE_TARGET_TABLE dmtpp on dmtpp.pipeline_name = apr.pipeline_name 
										and dmtpp.table_name = apr.parent_table 
;

-- select * from dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS order by 1,2,3




-- drop view if exists dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS as

with all_parent_relations as (
select 
	pipeline
	,lower(table_name)  table_name
	,lower(parent_table) parent_table
from (
select 
		pipeline 
		,table_name
		,json_array_elements_text(link_parent_tables) parent_table
	from dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE
	where link_parent_tables is not null
	union
	select 
		pipeline 
		,table_name
		,satellite_parent_table  parent_table
	from dv_pipeline_description.DVPD_DV_MODEL_TABLE_PER_PIPELINE
	where satellite_parent_table is not null
	) raw_union
)
select
  apr.pipeline
  ,'Table'::TEXT  object_type 
  ,apr.table_name object_name
  ,'DVPD_CHECK_MODEL_RELATIONS'::text  check_ruleset
  ,case when dmtpp.table_name is null then 'Unknown parent_table: '|| apr.parent_table  
    else 'ok' end  message
from all_parent_relations apr
left join dv_pipeline_description.dvpd_dv_model_table_per_pipeline dmtpp on dmtpp.pipeline = apr.pipeline 
										and dmtpp.table_name = apr.parent_table 
;

-- select * from dv_pipeline_description.DVPD_CHECK_MODEL_STEREOTYPE_AND_PARAMETERS order by 1,2,3




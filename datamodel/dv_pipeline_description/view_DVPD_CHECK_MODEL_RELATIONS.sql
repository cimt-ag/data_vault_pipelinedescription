-- drop view if exists dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS cascade;
create or replace view dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS as

with all_parent_relations as (
select 
	pipeline_name
	,lower(table_name)  table_name
	,lower(parent_table) parent_table
from (
select 
		pdt.pipeline_name 
		,pdt.table_name
		,pdtlp.link_parent_table parent_table
	from  dv_pipeline_description.dvpd_pipeline_dv_table pdt
	join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp on  pdtlp.pipeline_name =pdt.pipeline_name 
																		and pdtlp.table_name = pdt.table_name  
	union
	select 
		pipeline_name 
		,table_name
		,satellite_parent_table  parent_table
	from dv_pipeline_description.dvpd_pipeline_dv_table pdt
	where satellite_parent_table is not null
	) raw_union
)
, parent_relation_diagnostics as (
select
  apr.pipeline_name
  ,'Table'::TEXT  object_type 
  ,apr.table_name object_name
  ,'DVPD_CHECK_MODEL_RELATIONS'::text  check_ruleset
  ,case when pdt.table_name is null then 'Unknown parent_table: '|| apr.parent_table  
  		 when pdt.stereotype not in ('hub','lnk') then 'Parent table :'|| apr.parent_table || ' is not a hub or link'
    	else 'ok' 
    end  message
from all_parent_relations apr
left join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = apr.pipeline_name 
										and pdt.table_name = apr.parent_table 
)
,valid_model_profiles as ( 
select distinct model_profile_name 
from dv_pipeline_description.dvpd_model_profile
)
, model_profile_diagnostics as (
select
  pdt.pipeline_name
  ,'Table'::TEXT  object_type 
  ,pdt.table_name object_name
  ,'DVPD_CHECK_MODEL_RELATIONS'::text  check_ruleset
  ,case when vmp.model_profile_name is null then 'Unkown model profile : '|| pdt.model_profile_name  
    	else 'ok' 
    end  message
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join valid_model_profiles vmp on vmp.model_profile_name = pdt.model_profile_name 

)
select * from parent_relation_diagnostics
union 
select * from model_profile_diagnostics
;

-- select * from dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS order by 1,2,3




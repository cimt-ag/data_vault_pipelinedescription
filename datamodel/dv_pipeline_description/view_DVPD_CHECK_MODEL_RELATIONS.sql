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
;

-- select * from dv_pipeline_description.DVPD_CHECK_MODEL_RELATIONS order by 1,2,3




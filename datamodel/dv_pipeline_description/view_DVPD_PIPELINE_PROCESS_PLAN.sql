drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN as 

with tables_with_explicit_field_group as (
select distinct 
	pipeline
	,target_table  table_name
	,dmt.stereotype 
	,field_group
from dv_pipeline_description.dvpd_source_field_mapping sfm
join dv_pipeline_description.dvpd_dv_model_table dmt on dmt.table_name =sfm.target_table 
where field_group <> '_A_'
union
select distinct
	pipeline 
	,table_name 
	,stereotype 
	,json_array_elements_text(tracked_field_groups) field_group
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline
where tracked_field_groups is not null
)
,tables_without_explicit_field_group as(
select distinct 
	dmtpp.pipeline 
	,dmtpp.table_name
	,dmtpp.stereotype 
from dv_pipeline_description.dvpd_dv_model_table_per_pipeline dmtpp
left join tables_with_explicit_field_group twepb on twepb.pipeline =dmtpp.pipeline 
												   and twepb.table_name = dmtpp.table_name 
where twepb.table_name is null												   
)
,links_restricted_by_satellite as (
select 
	twogb.pipeline 
	,twogb.table_name
	,twogb.stereotype 
	,twepb.field_group 
from tables_without_explicit_field_group  twogb
join dv_pipeline_description.dvpd_dv_model_table_per_pipeline dmtpp on dmtpp.pipeline = twogb.pipeline 
																and dmtpp.satellite_parent_table = twogb.table_name 
join tables_with_explicit_field_group twepb on twepb.pipeline = twogb.pipeline 
											 and twepb.table_name = dmtpp.table_name 
											 and twepb.stereotype in ('msat','esat','sat')
where twogb.stereotype = 'lnk'  
)
,links_not_restricted_by_satellite as (
select 	pipeline 
	,table_name
	,stereotype  
from tables_without_explicit_field_group
where stereotype = 'lnk'
except 
select pipeline 
	,table_name
	,stereotype
from links_restricted_by_satellite 
)
--,links_relevant_to_determine_hub_field_groups (
select 	lnrbs.pipeline 
	,lnrbs.table_name
	,lnrbs.stereotype
	,twepb.table_name  hub_table_name
	,twepb.field_group 
from links_not_restricted_by_satellite lnrbs
join dv_pipeline_description.dvpd_dv_model_link_parent dmlp on dmlp.table_name = lnrbs.table_name 
join tables_with_explicit_field_group twepb on twepb.pipeline =lnrbs.pipeline 
										     and twepb.table_name  = dmlp.parent_table_name 
										     


### hier gehts weiter

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN_BASIC order by pipeline,field_group,table_name;										

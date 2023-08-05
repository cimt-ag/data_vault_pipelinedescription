with hubs_with_explicit_relation_names as (
select distinct 
	pdt.pipeline_name
	,pdt.table_name
	,relation_name as relation_to_process
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte
join dv_pipeline_description.dvpd_pipeline_dv_table pdt  on pdt.table_name =pfte.table_name 
														and pdt.pipeline_name = pfte.pipeline_name 
														and pdt.table_stereotype ='hub'
where relation_name is not null and relation_name not in ('*')  
)
,link_explicit_parent_count as (
select 	pdtlp.pipeline_name
	,pdtlp.table_name
	,count(distinct link_parent_table) parent_count
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
where (pdtlp.pipeline_name,pdtlp.link_parent_table ) in (Select pipeline_name,table_name from hubs_with_explicit_relation_names)
---and pdtlp.pipeline_name in ('test63_fg_drive_scenario_3','test64_fg_drive_scenario_4','test69_fg_drive_scenario_9_simple_hierarchy') --											 <<<<<<<<<<<<<<<<<<<<<DEBUG										     
group by 1,2
)
,link_explicit_parent_count_per_parent_process as (
select 	pdtlp.pipeline_name
	,pdtlp.table_name
	,hwern.relation_to_process
	,count(distinct hwern.table_name) parent_count_per_process
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp 
join hubs_with_explicit_relation_names hwern on hwern.pipeline_name =pdtlp.pipeline_name 
										     and hwern.table_name  = pdtlp.link_parent_table
---where pdtlp.pipeline_name in ('test63_fg_drive_scenario_3','test64_fg_drive_scenario_4','test69_fg_drive_scenario_9_simple_hierarchy') --														 <<<<<<<<<<<<<<<<<<<<<DEBUG										     
group by 1,2,3
)
Select 
    dppp.pipeline_name
	,dppp.table_name
	,dppp.relation_to_process
	,lepcppp.relation_to_process as involved_parent_relation_name
	,dppp.has_explicit_relation_names
from dv_pipeline_description.dvpd_pipeline_process_plan dppp
join dv_pipeline_description.dvpd_pipeline_dv_table dpdt on dpdt.pipeline_name= dppp.pipeline_name 
													 and dpdt.table_name = dppp.table_name
													 and dpdt.table_stereotype = 'lnk'
left join link_explicit_parent_count lepc on lepc.pipeline_name = dppp.pipeline_name
									and lepc.table_name=dppp.table_name
left join link_explicit_parent_count_per_parent_process	lepcppp on lepcppp.pipeline_name = lepc.pipeline_name								
															   and lepcppp.table_name = lepc.table_name
															   and lepcppp.parent_count_per_process = lepc.parent_count
---where dppp.pipeline_name in ('test63_fg_drive_scenario_3','test64_fg_drive_scenario_4','test69_fg_drive_scenario_9_simple_hierarchy') --														 <<<<<<<<<<<<<<<<<<<<<DEBUG										     
order by 1,2,3,4															   
															   
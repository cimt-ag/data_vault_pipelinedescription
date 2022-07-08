-- drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN as 

with tables_with_explicit_field_group as (
-- field groups declared on field mappings
select distinct 
	pdt.pipeline_name
	,pdt.table_name
	,pdt.stereotype 
	,field_group
	,'explicit' fg_rule
from dv_pipeline_description.DVPD_PIPELINE_FIELD_TARGET_EXPANSION pfte
join dv_pipeline_description.dvpd_pipeline_dv_table pdt  on pdt.table_name =pfte.target_table 
														and pdt.pipeline_name = pfte.pipeline_name 
where field_group <> '_A_'  
and recursion_name is null --MWG 22020708
union
-- field groups declared in model
select distinct
	pdt.pipeline_name 
	,pdt.table_name 
	,pdt.stereotype 
	,upper(field_group) field_group
	,'explicit' fg_rule
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
join dv_pipeline_description.dvpd_pipeline_dv_table_field_group_raw tfgr on tfgr.pipeline_name = pdt.pipeline_name 
																		and tfgr.table_name = pdt.table_name 
)
,tables_without_explicit_field_group as(
select distinct 
	pdt.pipeline_name 
	,pdt.table_name
	,pdt.stereotype 
from dv_pipeline_description.dvpd_pipeline_dv_table pdt
left join tables_with_explicit_field_group twepb on twepb.pipeline_name  =pdt.pipeline_name 
												   and twepb.table_name = pdt.table_name 
where twepb.table_name is null												   
)
,links_restricted_by_satellite as (
select 
	twogb.pipeline_name 
	,twogb.table_name
	,twogb.stereotype 
	,twepb.field_group 
	,'restrict by sat'::text fg_rule
from tables_without_explicit_field_group  twogb
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = twogb.pipeline_name 
																and pdt.satellite_parent_table = twogb.table_name 
join tables_with_explicit_field_group twepb on twepb.pipeline_name = twogb.pipeline_name 
											 and twepb.table_name = pdt.table_name 
											 and twepb.stereotype in ('msat','esat','sat')
where twogb.stereotype = 'lnk'
)
,links_not_restricted_by_satellite as (
select 	pipeline_name
	,table_name
	,stereotype  
from tables_without_explicit_field_group
where stereotype = 'lnk'
except 
select pipeline_name 
	,table_name
	,stereotype
from links_restricted_by_satellite 
)
,links_relevant_to_determine_hub_field_groups as (
select 	lnrbs.pipeline_name
	,lnrbs.table_name
	,lnrbs.stereotype
	,pdtlp.link_parent_table 
	,twepb.field_group 
from links_not_restricted_by_satellite lnrbs
join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp on pdtlp.table_name = lnrbs.table_name 
													and pdtlp.pipeline_name = lnrbs .pipeline_name 
join tables_with_explicit_field_group twepb on twepb.pipeline_name =lnrbs.pipeline_name 
										     and twepb.table_name  = pdtlp.link_parent_table  
)										     
,link_parent_count_per_hub_fg as (
select pipeline_name
	,table_name 
	,field_group
	,count(distinct link_parent_table) fg_driven_hub_count
from links_relevant_to_determine_hub_field_groups
group by pipeline_name ,table_name,field_group
)
,link_parent_count_for_fg_free_hubs as (
select pdtlp.pipeline_name 
	,pdtlp.table_name 
	,count(distinct link_parent_table) free_hub_count
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
join tables_without_explicit_field_group twoefg on twoefg.table_name = pdtlp.link_parent_table 
									and twoefg.pipeline_name =pdtlp.pipeline_name  
group by pdtlp.pipeline_name,pdtlp.table_name
)
,link_parent_count_in_model as (
select table_name ,count(distinct link_parent_table) parent_count
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
group by table_name
)
,links_restricted_by_hub_field_groups as (
select 
  lpcphf.pipeline_name 
  ,lpcphf.table_name 
  ,'lnk'::text stereotype
  ,lpcphf.field_group 
  ,'restricted by hub'::text fg_rule
from link_parent_count_per_hub_fg lpcphf
join link_parent_count_in_model lpcim on lpcim.table_name = lpcphf.table_name 
left join link_parent_count_for_fg_free_hubs lpcfffh on lpcfffh.pipeline_name = lpcphf.pipeline_name 
													and lpcfffh.table_name = lpcphf.table_name 
where fg_driven_hub_count+coalesce (free_hub_count,0) = parent_count
)
,hub_links_probably_driving_fg_of_satellite as (
select 
  pipeline_name
  ,table_name 
  ,stereotype
  ,field_group
from  tables_with_explicit_field_group
where stereotype ='hub'
union 
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,field_group
from  links_restricted_by_hub_field_groups
)
, sats_driven_by_fg_of_parent as (
select 
	twoefg.pipeline_name 
	,twoefg.table_name 
	,twoefg.stereotype 
	,hlpsfos.field_group 
    ,'restricted by parent'::text fg_rule
from hub_links_probably_driving_fg_of_satellite  hlpsfos 
join dv_pipeline_description.dvpd_pipeline_dv_table pdt  on pdt.pipeline_name = hlpsfos.pipeline_name 
																and pdt.satellite_parent_table  = hlpsfos.table_name 
join tables_without_explicit_field_group twoefg on twoefg.pipeline_name = hlpsfos.pipeline_name 
												and twoefg.table_name =pdt.table_name 
)
, tables_restricted_to_field_group as (
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,field_group
  ,fg_rule 
from tables_with_explicit_field_group
union 
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,field_group
  ,fg_rule 
from links_restricted_by_satellite
union
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,field_group
  ,fg_rule 
from links_restricted_by_hub_field_groups
union
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,field_group
  ,fg_rule 
from sats_driven_by_fg_of_parent
)
, tables_without_field_group as (
Select 
  pipeline_name 
  ,table_name 
  ,stereotype
from tables_without_explicit_field_group
except 
Select distinct
  pipeline_name 
  ,table_name 
  ,stereotype
from tables_restricted_to_field_group
)
, final_table_field_group_relation as (
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,'_A_' field_group
  ,'no field group' fg_rule 
from tables_without_field_group
union
select 
  pipeline_name 
  ,table_name 
  ,stereotype
  ,field_group
  ,fg_rule 
from tables_restricted_to_field_group
)
, additional_recursive_hub_processes as (
Select 
  ftfgr_hub.pipeline_name 
  ,ftfgr_hub.table_name 
  ,ftfgr_hub.stereotype
  ,ftfgr_link.field_group
  ,ftfgr_hub.fg_rule 
  ,pdtlp.recursion_name 
from final_table_field_group_relation ftfgr_hub 
join dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp on pdtlp.pipeline_name =ftfgr_hub .pipeline_name 
															and pdtlp.link_parent_table = ftfgr_hub.table_name 
															and pdtlp.is_recursive_relation
join final_table_field_group_relation ftfgr_link on ftfgr_link.pipeline_name = ftfgr_hub.pipeline_name 
												and ftfgr_link.table_name = pdtlp.table_name 
)
-- >>>>> Final view <<<<
select 
  pipeline_name  
  ,table_name 
  ,stereotype
  ,case when field_group <> '_A_' then '_'||field_group
  		else field_group 
	end as process_block 
  ,field_group
  ,'' recursion_name
  ,fg_rule 
from final_table_field_group_relation
union
select
  pipeline_name 
  ,table_name 
  ,stereotype
  ,case when field_group='_A_' then '_'||recursion_name 
  	  else  '_'||recursion_name||'_'||field_group end     as process_block
  ,field_group
  ,recursion_name
  ,fg_rule 
from additional_recursive_hub_processes
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_PLAN order by pipeline,table_name,process_block;										

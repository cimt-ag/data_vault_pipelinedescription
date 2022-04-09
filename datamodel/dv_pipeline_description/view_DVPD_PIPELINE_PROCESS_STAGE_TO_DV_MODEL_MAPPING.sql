--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING as 

with parent_table_keys_and_process_block_check as (
select 
	parent_plan.pipeline 
	,mlp.table_name 
	,mlp.parent_table_name 
	,coalesce (dptt.hub_key_column_name ,dptt.link_key_column_name ) parent_key_column_name
	,sum( case when parent_plan.process_block <>'_A_' then 1 else 0 end) non_general_process_count
from dv_pipeline_description.dvpd_dv_model_link_parent mlp
join dv_pipeline_description.dvpd_pipeline_process_plan parent_plan on parent_plan.table_name =mlp.parent_table_name 
join dv_pipeline_description.dvpd_pipeline_target_table dptt on dptt.pipeline = parent_plan.pipeline 
															 and dptt.table_name = mlp.parent_table_name 		
group by 1,2,3,4
union 
select 
	parent_plan.pipeline 
	,dptt.table_name 
	,dptt.satellite_parent_table parent_table_name 
	,coalesce (parent.hub_key_column_name ,parent.link_key_column_name ) parent_key_column_name
	,sum( case when parent_plan.process_block <>'_A_' then 1 else 0 end) non_general_process_count
from dv_pipeline_description.dvpd_pipeline_target_table dptt  
join dv_pipeline_description.dvpd_pipeline_process_plan parent_plan on parent_plan.pipeline = dptt.pipeline 
															and parent_plan.table_name =dptt.satellite_parent_table  
join dv_pipeline_description.dvpd_pipeline_target_table parent on parent.pipeline = parent_plan.pipeline 
														 and parent.table_name = dptt.satellite_parent_table 															
group by 1,2,3,4
)
,hub_with_recursion_link as (
select distinct
	parent_table_name  table_name
	,recursion_suffix 
from dv_pipeline_description.dvpd_dv_model_link_parent
where recursion_suffix <> ''
)
, implicit_recursion_businesskey as (
select 
pipeline 
 ,target_table 
 ,target_column_name 
 ,count(1)
from dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte
join hub_with_recursion_link hwrl on hwrl.table_name=pfte.target_table 
group by 1,2,3
having count(1) = 1
)
,implicit_recursion_businesskey_suffix_addon as (
	select 
	 pipeline
	 ,target_table 
	 ,target_column_name 
	 ,recursion_suffix 
	from implicit_recursion_businesskey irb
	join (
		select table_name,recursion_suffix  from hub_with_recursion_link
		union 
		select table_name,'' recursion_suffix from  hub_with_recursion_link
	) suffix_row  on suffix_row.table_name = irb.target_table  
)
,dvpd_pipeline_field_target_expansion_with_implicit_recursion as (
select 
	pfte.pipeline 
	,pfte.target_table 
	,pfte.target_column_name 
	,field_group 
	,coalesce (irbsa.recursion_suffix,pfte.recursion_suffix  ) recursion_suffix
	,(irbsa.recursion_suffix is not null) is_implicit_suffix
	,field_name 
	,field_type 
	,needs_encryption 
	,prio_in_key_hash 
	,prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte
left join implicit_recursion_businesskey_suffix_addon irbsa on irbsa.pipeline = pfte.pipeline 
									   and irbsa.target_table = pfte.target_table 
									   and irbsa.target_column_name = pfte.target_column_name 
)
select distinct 
	ppp.pipeline
	,ppp.process_block 
	,ppp.table_name
	,ppp.stereotype 
	,dmc.column_name 
	,dmc.dv_column_class  
	,case when pfte.field_name is not null then pfte.field_name 
		  when process_block ='_A_' or is_implicit_suffix or ptapbc.non_general_process_count =0 then dmc.column_name 
	  		 else dmc.column_name||process_block  
	 end stage_column_name
	,dmc.column_type 
	,dmc.column_block 
	,ppp.field_group
	,ppp.recursion_suffix 
	,pfte.field_name 
	,pfte.field_type 
	,pfte.needs_encryption
	,pfte.prio_in_key_hash 
	,pfte.prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_dv_model_column dmc on dmc.table_name=ppp.table_name 
												and dmc.dv_column_class not in ('meta')
left join parent_table_keys_and_process_block_check ptapbc	 on ptapbc.pipeline = ppp.pipeline 
														and ptapbc.table_name = ppp.table_name 
														and ptapbc.parent_key_column_name = dmc.column_name 
left join dvpd_pipeline_field_target_expansion_with_implicit_recursion pfte on pfte.pipeline =ppp.pipeline 
																		and pfte.target_table =dmc.table_name 
																		and pfte.target_column_name =dmc.column_name
																		and (pfte.field_group = ppp.field_group or pfte.field_group ='_A_')
																		and pfte.recursion_suffix = ppp.recursion_suffix 
where (dv_column_class in ('meta','key','parent_key','diff_hash') or pfte.field_name is not null	)	
--restrict for debug:
--and ppp.pipeline like 'test50%'
--order by table_name,process_block ,column_name 
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING order by pipeline,table_name,process_block;										

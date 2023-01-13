--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE as 

with parent_table_keys_and_process_block_check as (
select 
	parent_plan.pipeline_name 
	,pdtlp.table_name 
	,pdtlp.link_parent_table as parent_table_name 
	,coalesce (pdt.hub_key_column_name ,pdt.link_key_column_name ) parent_key_column_name
	,sum( case when parent_plan.process_block <>'_A_' then 1 else 0 end) non_general_process_count
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent pdtlp
join dv_pipeline_description.dvpd_pipeline_process_plan parent_plan on parent_plan.table_name =pdtlp.link_parent_table 
																	and parent_plan.pipeline_name = pdtlp.pipeline_name 
join dv_pipeline_description.dvpd_pipeline_dv_table pdt on pdt.pipeline_name = parent_plan.pipeline_name 
															 and pdt.table_name = pdtlp.link_parent_table 		
group by 1,2,3,4
union 
select 
	parent_plan.pipeline_name 
	,pdt.table_name 
	,pdt.satellite_parent_table parent_table_name 
	,coalesce (parent.hub_key_column_name ,parent.link_key_column_name ) parent_key_column_name
	,sum( case when parent_plan.process_block <>'_A_' then 1 else 0 end) non_general_process_count
from dv_pipeline_description.dvpd_pipeline_dv_table pdt  
join dv_pipeline_description.dvpd_pipeline_process_plan parent_plan on parent_plan.pipeline_name = pdt.pipeline_name 
															and parent_plan.table_name =pdt.satellite_parent_table  
join dv_pipeline_description.dvpd_pipeline_dv_table parent on parent.pipeline_name = parent_plan.pipeline_name 
														 and parent.table_name = pdt.satellite_parent_table 															
group by 1,2,3,4
)
,hub_with_recursion_link as (
select distinct
	pipeline_name 
	,link_parent_table  table_name
	,recursion_name 
from dv_pipeline_description.dvpd_pipeline_dv_table_link_parent
where is_recursive_relation 
)
, implicit_recursion_businesskey as (
select 
pfte.pipeline_name 
 ,target_table 
 ,target_column_name 
 ,count(1)
from dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte
join hub_with_recursion_link hwrl on hwrl.table_name=pfte.target_table 
								 and hwrl.pipeline_name = pfte.pipeline_name 
group by 1,2,3
having count(1) = 1
)
,implicit_recursion_businesskey_suffix_addon as (
	select 
	 irb.pipeline_name
	 ,target_table 
	 ,target_column_name 
	 ,recursion_name 
	from implicit_recursion_businesskey irb
	join (
		select pipeline_name,table_name,recursion_name  from hub_with_recursion_link
		union 
		select pipeline_name,table_name,'' recursion_name from  hub_with_recursion_link
	) suffix_row  on suffix_row.table_name = irb.target_table  
				  and suffix_row .pipeline_name = irb.pipeline_name 
)
,dvpd_pipeline_field_target_expansion_with_implicit_recursion as (
select 
	pfte.pipeline_name 
	,pfte.target_table 
	,pfte.target_column_name 
	,field_group 
	,coalesce (irbsa.recursion_name,pfte.recursion_name  ) recursion_name
	,(irbsa.recursion_name is not null) is_implicit_suffix
	,field_name 
	,field_type 
	,needs_encryption 
	,prio_in_key_hash 
	,prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte
left join implicit_recursion_businesskey_suffix_addon irbsa on irbsa.pipeline_name = pfte.pipeline_name 
									   and irbsa.target_table = pfte.target_table 
									   and irbsa.target_column_name = pfte.target_column_name 
)
select distinct 
	ppp.pipeline_name
	,ppp.process_block 
	,ppp.table_name
	,ppp.stereotype 
	,pdc.column_name 
	,pdc.dv_column_class  
    -- ,case when pfte.field_name is not null then pdc.column_name  -- legacy generator compatible  (Stage = Target, will fail on multiple mappings to same target)
	,case when pfte.field_name is not null then pfte.field_name   
		  when process_block ='_A_' or is_implicit_suffix or ptapbc.non_general_process_count =0 then pdc.column_name 
	  		 else pdc.column_name||process_block  
	 end stage_column_name
	,pdc.column_type 
	,pdc.column_block 
	,ppp.field_group
	,ppp.recursion_name 
	,pfte.field_name 
	,pfte.field_type 
	,pfte.needs_encryption
	,pfte.prio_in_key_hash 
	,pfte.prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_pipeline_dv_column pdc on pdc.pipeline_name =ppp.pipeline_name 
												and pdc.table_name=ppp.table_name 
												and pdc.dv_column_class not in ('meta')
left join parent_table_keys_and_process_block_check ptapbc	 on ptapbc.pipeline_name = ppp.pipeline_name 
														and ptapbc.table_name = ppp.table_name 
														and ptapbc.parent_key_column_name = pdc.column_name 
left join dvpd_pipeline_field_target_expansion_with_implicit_recursion pfte on pfte.pipeline_name =ppp.pipeline_name 
																		and pfte.target_table =pdc.table_name 
																		and pfte.target_column_name =pdc.column_name
																		and (pfte.field_group = ppp.field_group or pfte.field_group ='_A_')
																		and pfte.recursion_name = ppp.recursion_name 
	
--restrict for debug:
--and ppp.pipeline like 'test50%'
--order by table_name,process_block ,column_name 
;

-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING_BASE order by pipeline,table_name,process_block;										

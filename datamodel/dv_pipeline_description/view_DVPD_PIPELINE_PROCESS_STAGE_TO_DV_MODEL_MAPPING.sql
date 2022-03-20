--drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING as 

select distinct 
	ppp.pipeline
	,ppp.process_block 
	,ppp.table_name
	,dmc.column_name 
	,dmc.dv_column_class  
	,case when (pfte.field_group ='_A_' and pfte.hierarchy_key_suffix='') or process_block ='_A_' then dmc.column_name 
	 else dmc.column_name||'_'||process_block end stage_column_name
	,dmc.column_type 
	,dmc.column_block 
	,ppp.field_group
	,ppp.hierarchy_key_suffix 
	,pfte.field_name 
	,pfte.field_type 
	,pfte.is_encrypted
	,pfte.prio_in_hashkey 
	,pfte.prio_in_diff_hash 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_dv_model_column dmc on dmc.table_name=ppp.table_name 
												and dmc.dv_column_class not in ('meta')
left join dv_pipeline_description.dvpd_pipeline_field_target_expansion pfte on pfte.pipeline =ppp.pipeline 
																		and pfte.target_table =dmc.table_name 
																		and pfte.target_column_name =dmc.column_name
																		and (pfte.field_group = ppp.field_group or pfte.field_group ='_A_')
																		and pfte.hierarchy_key_suffix = ppp.hierarchy_key_suffix 
where dv_column_class in ('meta','key','parent_key','diff_hash') or pfte.field_name is not null																		


-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING order by pipeline,table_name,process_block;										

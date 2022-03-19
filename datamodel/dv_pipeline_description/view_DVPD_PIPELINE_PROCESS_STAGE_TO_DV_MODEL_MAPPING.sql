drop view if exists dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING cascade;

create or replace view dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING as 

select distinct 
	ppp.pipeline
	,ppp.table_name
	,dmc.column_name 
	,dmc.dv_column_class  
	,case when process_block ='_A_' then dmc.column_name 
	 else dmc.column_name||'_'||process_block end stage_column_name
	,dmc.column_type 
	,ppp.process_block 
	,ppp.field_group
	,ppp.hierarchy_key_suffix 
from dv_pipeline_description.dvpd_pipeline_process_plan ppp
join dv_pipeline_description.dvpd_dv_model_column dmc on dmc.table_name=ppp.table_name 
												and dmc.dv_column_class not in ('meta');


-- select * from dv_pipeline_description.DVPD_PIPELINE_PROCESS_STAGE_TO_DV_MODEL_MAPPING order by pipeline,table_name,process_block;										
